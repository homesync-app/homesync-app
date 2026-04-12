import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import '../models/expense_model.dart';
import '../models/feed_item_model.dart';
import '../models/expense_template_model.dart';

enum SplitType { equal, fixed, gift, personal }

abstract class ExpenseRepository {
  Future<Either<Failure, String>> getHouseholdId(String userId);

  Future<Either<Failure, List<ExpenseModel>>> getRecentExpenses(
      String householdId);

  Future<Either<Failure, List<FeedItemModel>>> getCombinedFeed(
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
    String? receiptPath, // path en Storage, solo si el usuario confirmó con ticket
  });

  Future<Either<Failure, void>> deleteExpense(String id);

  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
  });

  Future<Map<String, dynamic>> getPersonalFinanceSummary(String userId, String householdId);

  // Template Management
  Future<Either<Failure, List<ExpenseTemplateModel>>> getTemplates(String householdId);
  Future<Either<Failure, Unit>> saveTemplate(ExpenseTemplateModel template);
  Future<Either<Failure, Unit>> toggleTemplateActivity(String id, bool active);

  Future<Either<Failure, Map<String, dynamic>>> payPlannedExpense({
    required String plannedId,
    required double amount,
    required DateTime paidAt,
    required String paidBy,
  });

  Future<Either<Failure, Unit>> processRecurringExpenses(String householdId);
  Future<Either<Failure, Unit>> deletePlannedExpense(String id);
}
