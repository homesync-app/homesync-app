import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lee el código de invitación que viajó en el `referrer` de Play Store.
///
/// El link que se comparte por WhatsApp (`AppStoreLinks.playStore`) lleva
/// `utm_content=<código>`. Play lo guarda al instalar, así que quien llega
/// invitado puede encontrar el panel "Tengo un código" ya completo en vez de
/// volver al chat a copiarlo.
///
/// Se consulta una sola vez por instalación: si la persona elige crear su
/// propio hogar, no se lo volvemos a sugerir.
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

  static const _timeout = Duration(seconds: 4);
  static final _inviteCodePattern = RegExp(r'^[A-Z0-9]{6}$');

  final SharedPreferences _prefs;
  final Future<String?> Function() _readReferrer;
  final bool _isAndroid;

  /// Devuelve el código de invitación de la instalación, o null si no hay,
  /// si ya se consultó antes o si Play no responde.
  Future<String?> takeInviteCode() async {
    if (!_isAndroid) return null;
    if (_prefs.getBool(checkedPrefsKey) ?? false) return null;
    await _prefs.setBool(checkedPrefsKey, true);

    try {
      final referrer = await _readReferrer().timeout(_timeout);
      return parseInviteCode(referrer);
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

    Map<String, String> params;
    try {
      // Play suele entregarlo ya decodificado, pero hay tiendas y versiones
      // que lo mandan con escape: decodificar una vez más no rompe el caso
      // normal porque los códigos son alfanuméricos.
      final decoded = raw.contains('%') ? Uri.decodeComponent(raw) : raw;
      params = Uri.splitQueryString(decoded);
    } on ArgumentError {
      return null;
    } on FormatException {
      return null;
    }

    if (params['utm_source'] != 'invite') return null;
    final code = params['utm_content']?.trim().toUpperCase();
    if (code == null || !_inviteCodePattern.hasMatch(code)) return null;
    return code;
  }

  static Future<String?> _readFromPlay() async {
    final details = await PlayInstallReferrer.installReferrer;
    return details.installReferrer;
  }
}
