import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/stats/domain/utils/weekly_duel_period.dart';

void main() {
  group('weeklyDuelTargetWeekStart', () {
    test('uses the current week on Sunday evening', () {
      final weekStart = weeklyDuelTargetWeekStart(DateTime(2026, 5, 24, 20));

      expect(weekStart, DateTime(2026, 5, 18));
    });

    test('still uses the closed previous week on Monday morning', () {
      final weekStart = weeklyDuelTargetWeekStart(DateTime(2026, 5, 25, 9));

      expect(weekStart, DateTime(2026, 5, 18));
    });

    test('uses the new week after Monday morning', () {
      final weekStart = weeklyDuelTargetWeekStart(DateTime(2026, 5, 25, 12));

      expect(weekStart, DateTime(2026, 5, 25));
    });
  });
}
