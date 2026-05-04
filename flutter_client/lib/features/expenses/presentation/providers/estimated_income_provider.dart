import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'estimated_income_provider.g.dart';

const _kAmount = 'estimated_income_amount';
const _kDay = 'estimated_income_day';

class EstimatedIncome {
  final double amount;
  final int dayOfMonth;

  const EstimatedIncome({required this.amount, required this.dayOfMonth});

  bool get isSet => amount > 0;
}

@riverpod
class EstimatedIncomeNotifier extends _$EstimatedIncomeNotifier {
  @override
  Future<EstimatedIncome> build() async {
    final prefs = await SharedPreferences.getInstance();
    final amount = prefs.getDouble(_kAmount) ?? 0.0;
    final day = prefs.getInt(_kDay) ?? 1;
    return EstimatedIncome(amount: amount, dayOfMonth: day);
  }

  Future<void> save({required double amount, required int dayOfMonth}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kAmount, amount);
    await prefs.setInt(_kDay, dayOfMonth);
    state = AsyncData(EstimatedIncome(amount: amount, dayOfMonth: dayOfMonth));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAmount);
    await prefs.remove(_kDay);
    state = const AsyncData(EstimatedIncome(amount: 0, dayOfMonth: 1));
  }
}
