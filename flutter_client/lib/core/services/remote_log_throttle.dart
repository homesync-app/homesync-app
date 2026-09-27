import 'dart:collection';

/// Decides whether an error is sent to `application_logs`.
///
/// Without a limit, an error that repeats every frame (a debug semantics
/// assertion, for example) sent tens of thousands of rows: in March 2026 one
/// test account produced 74,292 in a month. The server also caps inserts per
/// user (trigger on application_logs), but stopping here avoids the network
/// traffic and the cost of each request.
///
/// Rules, in order:
/// - at most [maxPerSession] sends per app run;
/// - the same error (same [signatureOf]) is not repeated within
///   [dedupeWindow];
/// - at most [maxPerMinute] sends in any one-minute window.
class RemoteLogThrottle {
  RemoteLogThrottle({
    DateTime Function()? clock,
    this.maxPerSession = 100,
    this.maxPerMinute = 10,
    this.dedupeWindow = const Duration(minutes: 5),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final int maxPerSession;
  final int maxPerMinute;
  final Duration dedupeWindow;

  static const _minute = Duration(minutes: 1);
  static const _maxTrackedSignatures = 256;

  final Queue<DateTime> _sentLastMinute = Queue<DateTime>();
  final Map<String, DateTime> _lastSentBySignature = <String, DateTime>{};
  int _sentThisSession = 0;

  /// Returns true and records the send when [message] may go out.
  bool tryAcquire({required String level, required String message}) {
    if (_sentThisSession >= maxPerSession) return false;

    final now = _clock();
    final signature = signatureOf(level, message);
    final lastSent = _lastSentBySignature[signature];
    if (lastSent != null && now.difference(lastSent) < dedupeWindow) {
      return false;
    }

    while (_sentLastMinute.isNotEmpty &&
        now.difference(_sentLastMinute.first) >= _minute) {
      _sentLastMinute.removeFirst();
    }
    if (_sentLastMinute.length >= maxPerMinute) return false;

    _sentLastMinute.addLast(now);
    _sentThisSession++;
    _lastSentBySignature[signature] = now;
    if (_lastSentBySignature.length > _maxTrackedSignatures) {
      _lastSentBySignature.removeWhere(
        (_, sentAt) => now.difference(sentAt) >= dedupeWindow,
      );
    }
    return true;
  }

  static final _uuid = RegExp(
    r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
  );
  static final _shortHash = RegExp(r'#[0-9a-f]{5}\b');
  static final _digits = RegExp(r'\d+');
  static final _spaces = RegExp(r'\s+');
  static const _maxSignatureLength = 200;

  /// Identity of an error: level plus the first line of the message, without
  /// ids or numbers, so "overflowed by 18 pixels" and "by 23 pixels" count as
  /// the same error.
  static String signatureOf(String level, String message) {
    var normalized = message
        .split('\n')
        .first
        .replaceAll(_uuid, '<uuid>')
        .replaceAll(_shortHash, '#<id>')
        .replaceAll(_digits, '<n>')
        .replaceAll(_spaces, ' ')
        .trim();
    if (normalized.length > _maxSignatureLength) {
      normalized = normalized.substring(0, _maxSignatureLength);
    }
    return '$level|$normalized';
  }
}
