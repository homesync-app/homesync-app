import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// De dónde vino la instalación, según los `utm_*` del referrer de Play.
///
/// Es la pieza que une una campaña (Instagram, Meta Ads, invitación por
/// WhatsApp) con lo que esa persona hace después dentro de la app.
@immutable
class InstallAttribution {
  const InstallAttribution({
    required this.rawReferrer,
    this.source,
    this.medium,
    this.campaign,
    this.content,
    this.term,
  });

  /// Tope del referrer crudo. Los anuncios de instalación de Meta mandan en
  /// `utm_content` un JSON cifrado de unos cientos de caracteres: se guarda
  /// entero para poder descifrarlo después en el servidor.
  static const maxRawLength = 4096;

  final String rawReferrer;
  final String? source;
  final String? medium;
  final String? campaign;
  final String? content;
  final String? term;

  /// Parsea el referrer. Devuelve null si Play no mandó nada (sideload,
  /// instalación sin Play Services).
  static InstallAttribution? parse(String? referrer) {
    final raw = referrer?.trim();
    if (raw == null || raw.isEmpty) return null;

    final params = InstallReferrerService._splitReferrer(raw) ?? const {};
    String? param(String key) {
      final value = params[key]?.trim();
      return value == null || value.isEmpty ? null : value;
    }

    return InstallAttribution(
      rawReferrer:
          raw.length <= maxRawLength ? raw : raw.substring(0, maxRawLength),
      source: param('utm_source'),
      medium: param('utm_medium'),
      campaign: param('utm_campaign'),
      content: param('utm_content'),
      term: param('utm_term'),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is InstallAttribution &&
      other.rawReferrer == rawReferrer &&
      other.source == source &&
      other.medium == medium &&
      other.campaign == campaign &&
      other.content == content &&
      other.term == term;

  @override
  int get hashCode =>
      Object.hash(rawReferrer, source, medium, campaign, content, term);
}

/// Lee el `referrer` que Play Store guardó al instalar la app.
///
/// Sirve para dos cosas:
/// - El link que se comparte por WhatsApp (`AppStoreLinks.playStore`) lleva
///   `utm_content=<código>`, así quien llega invitado encuentra el panel
///   "Tengo un código" ya completo en vez de volver al chat a copiarlo.
/// - La atribución de la instalación ([pendingAttribution]): qué campaña o
///   canal trajo a esta persona, para medir el embudo por campaña.
///
/// Play se consulta una vez y el resultado queda cacheado. Si Play falla se
/// reintenta en el próximo arranque: el referrer sigue disponible 90 días.
class InstallReferrerService {
  InstallReferrerService(
    this._prefs, {
    Future<String?> Function()? readReferrer,
    bool? isAndroid,
  })  : _readReferrer = readReferrer ?? _readFromPlay,
        // Platform (no defaultTargetPlatform): en los tests de widgets
        // defaultTargetPlatform vale android y dispararía el canal nativo.
        _isAndroid = isAndroid ?? (!kIsWeb && Platform.isAndroid);

  static const checkedPrefsKey = 'install_referrer_checked_v1';
  static const referrerCacheKey = 'install_referrer_raw_v1';
  static const attributionReportedKey = 'install_attribution_reported_v1';

  static const _timeout = Duration(seconds: 4);
  static final _inviteCodePattern = RegExp(r'^[A-Z0-9]{6}$');

  final SharedPreferences _prefs;
  final Future<String?> Function() _readReferrer;
  final bool _isAndroid;

  /// El código y la atribución pueden pedir el referrer a la vez al arrancar:
  /// comparten la misma consulta a Play.
  Future<String?>? _inFlight;

  /// Devuelve el código de invitación de la instalación, o null si no hay,
  /// si ya se consultó antes o si Play no responde.
  ///
  /// Se ofrece una sola vez por instalación: si la persona elige crear su
  /// propio hogar, no se lo volvemos a sugerir.
  Future<String?> takeInviteCode() async {
    if (!_isAndroid) return null;
    if (_prefs.getBool(checkedPrefsKey) ?? false) return null;
    await _prefs.setBool(checkedPrefsKey, true);

    return parseInviteCode(await _loadReferrer());
  }

  /// La atribución que todavía no se subió al backend, o null si ya se subió,
  /// si no es Android o si Play no la tiene.
  Future<InstallAttribution?> pendingAttribution() async {
    if (!_isAndroid) return null;
    if (_prefs.getBool(attributionReportedKey) ?? false) return null;
    return InstallAttribution.parse(await _loadReferrer());
  }

  /// La atribución quedó guardada en el backend: no se vuelve a mandar.
  Future<void> markAttributionReported() async {
    await _prefs.setBool(attributionReportedKey, true);
  }

  Future<String?> _loadReferrer() {
    final cached = _prefs.getString(referrerCacheKey);
    if (cached != null) return Future.value(cached);
    return _inFlight ??= _queryPlay().whenComplete(() => _inFlight = null);
  }

  Future<String?> _queryPlay() async {
    try {
      final referrer = await _readReferrer().timeout(_timeout);
      // Play respondió: se cachea aunque venga vacío, no hay nada más que
      // esperar de esta instalación.
      await _prefs.setString(referrerCacheKey, referrer?.trim() ?? '');
      return referrer;
    } catch (error) {
      // Sin Play Services, instalación por sideload o timeout: no es un error
      // para la persona, simplemente escribe el código a mano.
      log.w('Install referrer unavailable: $error');
      return null;
    }
  }

  /// Extrae el código de `utm_source=invite&...&utm_content=ABC123`.
  ///
  /// Solo acepta referrers de invitación con un código de 6 caracteres; el
  /// tráfico orgánico (`utm_source=google-play&utm_medium=organic`) da null.
  static String? parseInviteCode(String? referrer) {
    final raw = referrer?.trim();
    if (raw == null || raw.isEmpty) return null;

    final params = _splitReferrer(raw);
    if (params == null) return null;

    if (params['utm_source'] != 'invite') return null;
    final code = params['utm_content']?.trim().toUpperCase();
    if (code == null || !_inviteCodePattern.hasMatch(code)) return null;
    return code;
  }

  static Map<String, String>? _splitReferrer(String raw) {
    try {
      // Play suele entregarlo ya decodificado, pero hay tiendas y versiones
      // que lo mandan con escape: decodificar una vez más no rompe el caso
      // normal porque los códigos son alfanuméricos.
      final decoded = raw.contains('%') ? Uri.decodeComponent(raw) : raw;
      return Uri.splitQueryString(decoded);
    } on ArgumentError {
      return null;
    } on FormatException {
      return null;
    }
  }

  static Future<String?> _readFromPlay() async {
    final details = await PlayInstallReferrer.installReferrer;
    return details.installReferrer;
  }
}
