import 'package:homesync_client/core/services/logger_service.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Decide cuándo pedir la reseña de Play con el diálogo nativo.
///
/// Se pide en un momento de alivio, nunca en medio de una tarea:
/// - justo después de dejar el balance de la pareja en cero, o
/// - al completar la décima tarea desde que se instaló la app.
///
/// Y solo si pasó al menos una semana desde el primer uso y no se pidió en los
/// últimos 120 días. Play aplica además su propia cuota, así que el diálogo
/// puede no aparecer aunque se pida: está bien, no hay que insistir.
class ReviewPromptService {
  ReviewPromptService(
    this._prefs, {
    Future<bool> Function()? isAvailable,
    Future<void> Function()? requestReview,
    DateTime Function()? clock,
    this.presentDelay = const Duration(milliseconds: 1200),
  })  : _isAvailable = isAvailable ?? InAppReview.instance.isAvailable,
        _requestReview = requestReview ?? InAppReview.instance.requestReview,
        _clock = clock ?? DateTime.now;

  static const firstSeenPrefsKey = 'review_prompt_first_seen_at';
  static const lastAskedPrefsKey = 'review_prompt_last_asked_at';
  static const taskCountPrefsKey = 'review_prompt_task_completions';

  static const minDaysSinceFirstSeen = 7;
  static const cooldownDays = 120;
  static const taskMilestone = 10;

  final SharedPreferences _prefs;
  final Future<bool> Function() _isAvailable;
  final Future<void> Function() _requestReview;
  final DateTime Function() _clock;

  /// Pausa antes de mostrar el diálogo, para que no tape el snackbar de éxito
  /// ni la animación de cierre del diálogo anterior.
  final Duration presentDelay;

  bool _inFlight = false;

  /// Registra el primer uso. Idempotente: se llama en cada arranque.
  Future<void> markFirstSeen() async {
    if (_prefs.getString(firstSeenPrefsKey) != null) return;
    await _prefs.setString(firstSeenPrefsKey, _clock().toIso8601String());
  }

  /// El balance de la pareja quedó en cero.
  Future<bool> onSettleUp() => _maybeAsk(trigger: 'settle_up');

  /// Se completó una tarea desde la home.
  Future<bool> onTaskCompleted() async {
    final count = (_prefs.getInt(taskCountPrefsKey) ?? 0) + 1;
    await _prefs.setInt(taskCountPrefsKey, count);
    if (count < taskMilestone) return false;
    return _maybeAsk(trigger: 'tasks_milestone');
  }

  Future<bool> _maybeAsk({required String trigger}) async {
    if (_inFlight) return false;
    _inFlight = true;
    try {
      final now = _clock();
      final firstSeen = _readDate(firstSeenPrefsKey);
      if (firstSeen == null) {
        await markFirstSeen();
        return false;
      }
      if (now.difference(firstSeen).inDays < minDaysSinceFirstSeen) {
        return false;
      }
      final lastAsked = _readDate(lastAskedPrefsKey);
      if (lastAsked != null &&
          now.difference(lastAsked).inDays < cooldownDays) {
        return false;
      }
      if (!await _isAvailable()) return false;

      // Se guarda antes de pedir: si el diálogo falla, igual respetamos la
      // pausa en vez de reintentar en la próxima tarea.
      await _prefs.setString(lastAskedPrefsKey, now.toIso8601String());
      if (presentDelay > Duration.zero) {
        await Future<void>.delayed(presentDelay);
      }
      await _requestReview();
      log.i('Review prompt requested (trigger=$trigger)');
      return true;
    } catch (error) {
      log.w('Review prompt failed (trigger=$trigger): $error');
      return false;
    } finally {
      _inFlight = false;
    }
  }

  DateTime? _readDate(String key) {
    final raw = _prefs.getString(key);
    return raw == null ? null : DateTime.tryParse(raw);
  }
}
