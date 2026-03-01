import '../models/expense_model.dart';

enum SplitType { equal, fixed, gift, personal }

abstract class ExpenseRepository {
  Future<String> getHouseholdId(String userId);
  
  Future<List<ExpenseModel>> getRecentExpenses(String householdId);
  
  Future<Map<String, dynamic>> getExpenseWithSplits(String expenseId);
  
  Future<List<HouseholdBalanceModel>> getHouseholdBalances(String householdId);
  
  Future<void> saveExpense({
    String? id,
    required String householdId,
    required String title,
    required double amount,
    required String category,
    required String paidBy,
    required DateTime paidAt,
    String? description,
    required SplitType splitType,
    List<Map<String, dynamic>>? splits,
  });
  
  Future<void> deleteExpense(String id);
  
  Future<void> settleDebt({
    required String householdId,
    required String toUserId,
    required double amount,
  });
}
