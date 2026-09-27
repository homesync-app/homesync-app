import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';

/// La sugerencia de ahorro proponia aportar TODO el sobrante del mes aunque a
/// la meta le faltara poco: con $3.430.000 de sobrante y una meta de
/// $2.000.000 al 90%, mostraba "Adelantarias un 171.5% tu meta".
void main() {
  SavingsGoalModel goal({double target = 2000000, double current = 0}) =>
      SavingsGoalModel(
        id: 'g1',
        householdId: 'h1',
        title: 'Viaje a Bariloche',
        targetAmount: target,
        currentAmount: current,
        createdAt: DateTime(2026, 3, 20),
      );

  group('SavingsSuggestion.forGoal', () {
    test('nunca propone mas de lo que le falta a la meta', () {
      final s = SavingsSuggestion.forGoal(goal(current: 1800000), 3430000)!;
      expect(s.amount, 200000);
      expect(s.completesGoal, isTrue);
      expect(s.percentageBoost, 10);
    });

    test('el avance nunca pasa de 100', () {
      final s = SavingsSuggestion.forGoal(goal(), 9000000)!;
      expect(s.amount, 2000000);
      expect(s.percentageBoost, 100);
      expect(s.completesGoal, isTrue);
    });

    test('con sobrante menor a lo que falta propone todo el sobrante', () {
      final s = SavingsSuggestion.forGoal(goal(current: 500000), 300000)!;
      expect(s.amount, 300000);
      expect(s.completesGoal, isFalse);
      expect(s.percentageBoost, 15);
    });

    test('el avance es un entero (sin "171.5" con punto en espanol)', () {
      final s = SavingsSuggestion.forGoal(goal(target: 3000000), 1000000)!;
      expect(s.percentageBoost, 33);
      expect('${s.percentageBoost}', isNot(contains('.')));
    });

    test('un avance chiquito se muestra como 1%, no 0%', () {
      final s = SavingsSuggestion.forGoal(goal(target: 10000000), 20000)!;
      expect(s.percentageBoost, 1);
    });

    test('sin nada util que proponer devuelve null', () {
      expect(SavingsSuggestion.forGoal(goal(current: 2000000), 500000), isNull);
      expect(SavingsSuggestion.forGoal(goal(target: 0), 500000), isNull);
      expect(SavingsSuggestion.forGoal(goal(), 0), isNull);
    });
  });
}
