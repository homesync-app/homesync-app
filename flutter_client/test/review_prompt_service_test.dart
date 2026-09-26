import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/services/review_prompt_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late DateTime now;
  late int requests;

  ReviewPromptService build({bool available = true}) {
    return ReviewPromptService(
      prefs,
      isAvailable: () async => available,
      requestReview: () async {
        requests++;
      },
      clock: () => now,
      presentDelay: Duration.zero,
    );
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 10, 1, 12);
    requests = 0;
  });

  test('nunca pide durante la primera semana', () async {
    final service = build();
    await service.markFirstSeen();
    now = now.add(const Duration(days: 6));

    expect(await service.onSettleUp(), isFalse);
    expect(requests, 0);
  });

  test('pide después de un equilibrio pasada la primera semana', () async {
    final service = build();
    await service.markFirstSeen();
    now = now.add(const Duration(days: 8));

    expect(await service.onSettleUp(), isTrue);
    expect(requests, 1);
  });

  test('respeta la pausa de 120 días', () async {
    final service = build();
    await service.markFirstSeen();
    now = now.add(const Duration(days: 8));
    await service.onSettleUp();

    now = now.add(const Duration(days: 119));
    expect(await service.onSettleUp(), isFalse);

    now = now.add(const Duration(days: 2));
    expect(await service.onSettleUp(), isTrue);
    expect(requests, 2);
  });

  test('las tareas piden recién a partir de la décima', () async {
    final service = build();
    await service.markFirstSeen();
    now = now.add(const Duration(days: 8));

    for (var i = 0; i < ReviewPromptService.taskMilestone - 1; i++) {
      expect(await service.onTaskCompleted(), isFalse);
    }
    expect(requests, 0);
    expect(await service.onTaskCompleted(), isTrue);
    expect(requests, 1);
  });

  test('sin diálogo de la tienda no pide ni consume la pausa', () async {
    final service = build(available: false);
    await service.markFirstSeen();
    now = now.add(const Duration(days: 8));

    expect(await service.onSettleUp(), isFalse);
    expect(prefs.getString(ReviewPromptService.lastAskedPrefsKey), isNull);
  });

  test('markFirstSeen conserva la fecha original', () async {
    final service = build();
    await service.markFirstSeen();
    final first = prefs.getString(ReviewPromptService.firstSeenPrefsKey);

    now = now.add(const Duration(days: 30));
    await service.markFirstSeen();

    expect(prefs.getString(ReviewPromptService.firstSeenPrefsKey), first);
  });
}
