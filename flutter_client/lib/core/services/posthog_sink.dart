import 'package:homesync_client/config/app_environment.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'logger_service.dart';

/// Segundo destino de analytics, detrás de [AnalyticsService].
///
/// Ninguna feature debe importar `posthog_flutter` directamente: todo pasa por
/// `AnalyticsService`, que hace fan-out a Firebase y a este sink. Así queda un
/// solo lugar donde agregar/quitar un destino.
///
/// Todo método es a prueba de fallos: si `setup()` nunca corrió (tests, web,
/// build con `POSTHOG_API_KEY=""`) las llamadas son no-ops silenciosos. Un
/// error de analytics nunca puede tumbar un flujo de producto.
class PostHogSink {
  PostHogSink._();

  static final PostHogSink instance = PostHogSink._();

  bool _ready = false;

  /// True solo cuando `setup()` terminó bien. Los tests lo dejan en false.
  bool get isReady => _ready;

  /// Inicializa el SDK. Idempotente y no bloqueante del arranque: si falla,
  /// la app sigue andando sin analytics de producto.
  Future<void> setup() async {
    if (_ready) return;
    if (!AppEnvironment.postHogEnabled) {
      log.i('PostHog disabled: no API key for this build');
      return;
    }

    try {
      final config = PostHogConfig(AppEnvironment.postHogApiKey)
        ..host = AppEnvironment.postHogHost
        ..debug = !AppEnvironment.isProduction
        // Lifecycle da Application opened/backgrounded/installed/updated, que
        // es lo que alimenta los reportes de retención D1/D7/D30.
        ..captureApplicationLifecycleEvents = true
        // Screens los emite PosthogObserver desde navigatorObservers.
        ..sessionReplay = false
        // Sin identify no creamos perfil: evita inflar personas con
        // instalaciones que nunca se registran.
        ..personProfiles = PostHogPersonProfiles.identifiedOnly;

      await Posthog().setup(config);
      _ready = true;
      log.i('PostHog configured (${AppEnvironment.current.name})');
    } catch (error, stackTrace) {
      log.w('PostHog setup failed', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> capture(
    String eventName,
    Map<String, Object> properties,
  ) async {
    await _guard(
      'capture:$eventName',
      () => Posthog().capture(
        eventName: eventName,
        properties: properties.isEmpty ? null : properties,
      ),
    );
  }

  Future<void> screen(String screenName, {String? screenClass}) async {
    await _guard(
      'screen:$screenName',
      () => Posthog().screen(
        screenName: screenName,
        properties: screenClass == null ? null : {'screen_class': screenClass},
      ),
    );
  }

  Future<void> identify(String userId) async {
    await _guard('identify', () => Posthog().identify(userId: userId));
  }

  /// Corta la sesión y el vínculo con la persona. Obligatorio al cerrar sesión:
  /// sin esto, el próximo usuario del dispositivo hereda el distinct id.
  Future<void> reset() async {
    await _guard('reset', () => Posthog().reset());
  }

  Future<void> setPersonProperty(String name, Object value) async {
    await _guard(
      'setPersonProperty:$name',
      () => Posthog().setPersonProperties(userPropertiesToSet: {name: value}),
    );
  }

  /// Super property: viaja en todos los eventos siguientes. Se usa para las
  /// dimensiones con las que se segmenta todo (modo de hogar, premium, etc.).
  Future<void> register(String key, Object value) async {
    await _guard('register:$key', () => Posthog().register(key, value));
  }

  Future<void> _guard(String context, Future<void> Function() action) async {
    if (!_ready) return;
    try {
      await action();
    } catch (error, stackTrace) {
      log.w('PostHog skipped in $context', error: error, stackTrace: stackTrace);
    }
  }
}
