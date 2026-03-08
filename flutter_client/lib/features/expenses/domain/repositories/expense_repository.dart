import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../models/expense_model.dart';

enum SplitType { equal, fixed, gift, personal }

abstract class ExpenseRepository {
  Future<Either<Failure, String>> getHouseholdId(String userId);

  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
      String householdId);

  Future<Either<Failure, Map<String, dynamic>>> getExpenseWithSplits(
      String expenseId);

  Future<Either<Failure, List<HouseholdBalanceModel>>> getHouseholdBalances(
      String householdId);

  Future<Either<Failure, void>> saveExpense({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    String type = 'expense',
    List<Map<String, dynamic>>? splits,
  });

  Future<Either<Failure, void>> deleteExpense(String id);

  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  });

  Future<Map<String, dynamic>> getPersonalFinanceSummary(String userId, String householdId);
}
