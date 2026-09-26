import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/install_referrer_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';

/// Guarda la atribución de la instalación en el backend (tabla
/// `install_attributions`) y la manda a analytics.
///
/// Se llama cuando hay usuario logueado. Una vez guardada no se vuelve a
/// mandar; si falla, se reintenta en el próximo arranque.
class InstallAttributionReporter {
  InstallAttributionReporter({
    required InstallReferrerService referrer,
    required AnalyticsService analytics,
    required Future<void> Function(Map<String, dynamic> params) saveAttribution,
    this.appVersion,
    this.platform = 'android',
  })  : _referrer = referrer,
        _analytics = analytics,
        _saveAttribution = saveAttribution;

  static const rpcName = 'record_install_attribution_v1';

  final InstallReferrerService _referrer;
  final AnalyticsService _analytics;
  final Future<void> Function(Map<String, dynamic> params) _saveAttribution;
  final String? appVersion;
  final String platform;

  bool _running = false;

  Future<void> reportIfNeeded() async {
    // Login y refresh de identidad pueden disparar dos veces seguidas.
    if (_running) return;
    _running = true;
    try {
      final attribution = await _referrer.pendingAttribution();
      if (attribution == null) return;

      await _saveAttribution(rpcParams(attribution));
      await _referrer.markAttributionReported();
      await _analytics.trackInstallAttributed(
        source: attribution.source,
        medium: attribution.medium,
        campaign: attribution.campaign,
      );
    } catch (error, stackTrace) {
      log.w(
        'Install attribution not saved, retrying next launch',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _running = false;
    }
  }

  Map<String, dynamic> rpcParams(InstallAttribution attribution) => {
        'p_source': attribution.source,
        'p_medium': attribution.medium,
        'p_campaign': attribution.campaign,
        'p_content': attribution.content,
        'p_term': attribution.term,
        'p_raw_referrer': attribution.rawReferrer,
        'p_platform': platform,
        'p_app_version': appVersion,
      };
}
