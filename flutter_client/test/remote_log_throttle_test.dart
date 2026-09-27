import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/services/remote_log_throttle.dart';

void main() {
  late DateTime now;
  RemoteLogThrottle build({
    int maxPerSession = 100,
    int maxPerMinute = 10,
    Duration dedupeWindow = const Duration(minutes: 5),
  }) {
    return RemoteLogThrottle(
      clock: () => now,
      maxPerSession: maxPerSession,
      maxPerMinute: maxPerMinute,
      dedupeWindow: dedupeWindow,
    );
  }

  setUp(() => now = DateTime(2026, 10, 1, 12));

  test('the same error is sent once per dedupe window', () {
    final throttle = build();

    expect(throttle.tryAcquire(level: 'error', message: 'Boom'), isTrue);
    now = now.add(const Duration(minutes: 4));
    expect(throttle.tryAcquire(level: 'error', message: 'Boom'), isFalse);
    now = now.add(const Duration(minutes: 1));
    expect(throttle.tryAcquire(level: 'error', message: 'Boom'), isTrue);
  });

  test('a per-frame flood of one error sends a single row', () {
    final throttle = build();
    var sent = 0;
    for (var frame = 0; frame < 1000; frame++) {
      now = now.add(const Duration(milliseconds: 16));
      if (throttle.tryAcquire(
        level: 'error',
        message: "Failed assertion: line 5$frame pos 12: '!semantics'",
      )) {
        sent++;
      }
    }
    expect(sent, 1);
  });

  test('different errors share a per-minute budget', () {
    final throttle = build(maxPerMinute: 3);

    for (var i = 0; i < 3; i++) {
      expect(
        throttle.tryAcquire(level: 'error', message: 'Error ${'x' * i}'),
        isTrue,
      );
    }
    expect(throttle.tryAcquire(level: 'error', message: 'Another'), isFalse);

    now = now.add(const Duration(minutes: 1));
    expect(throttle.tryAcquire(level: 'error', message: 'Another'), isTrue);
  });

  test('a dropped error does not use the per-minute budget', () {
    final throttle = build(maxPerMinute: 2);

    expect(throttle.tryAcquire(level: 'error', message: 'A'), isTrue);
    expect(throttle.tryAcquire(level: 'error', message: 'A'), isFalse);
    expect(throttle.tryAcquire(level: 'error', message: 'B'), isTrue);
  });

  test('a session never sends more than maxPerSession rows', () {
    final throttle = build(maxPerSession: 5, maxPerMinute: 100);
    var sent = 0;
    for (var i = 0; i < 50; i++) {
      now = now.add(const Duration(minutes: 1));
      if (throttle.tryAcquire(level: 'error', message: 'Error ${'x' * i}')) {
        sent++;
      }
    }
    expect(sent, 5);
  });

  group('signatureOf', () {
    test('ignores numbers, ids and everything after the first line', () {
      expect(
        RemoteLogThrottle.signatureOf(
          'error',
          'A RenderFlex overflowed by 18 pixels on the bottom.\n#0 main',
        ),
        RemoteLogThrottle.signatureOf(
          'error',
          'A RenderFlex overflowed by 23 pixels on the bottom.\n#4 other',
        ),
      );
      expect(
        RemoteLogThrottle.signatureOf(
          'error',
          'Task 2f1c3a4b-1111-4a2b-9c3d-0123456789ab not found',
        ),
        'error|Task <uuid> not found',
      );
      expect(
        RemoteLogThrottle.signatureOf(
          'error',
          'Form-[LabeledGlobalKey<FormState>#95b58] marked dirty',
        ),
        'error|Form-[LabeledGlobalKey<FormState>#<id>] marked dirty',
      );
    });

    test('keeps levels apart', () {
      expect(
        RemoteLogThrottle.signatureOf('error', 'Boom'),
        isNot(RemoteLogThrottle.signatureOf('fatal', 'Boom')),
      );
    });
  });
}
