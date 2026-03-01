/// App-wide constants. Never scatter magic strings in the UI.
class AppConstants {
  AppConstants._();

  // Supabase table names
  static const String tableUsers = 'users';
  static const String tableHouseholds = 'households';
  static const String tableHouseholdMembers = 'household_members';
  static const String tableTasks = 'tasks';
  static const String tableExpenses = 'expenses';
  static const String tableRewards = 'rewards';
  static const String tableRewardRedemptions = 'reward_redemptions';
  static const String tableLedgerEntries = 'ledger_entries';
  static const String tableShoppingItems = 'shopping_items';
  static const String tableSavingsGoals = 'savings_goals';

  // Ledger currency
  static const String currencyCoin = 'COIN';
  static const String currencyXP = 'XP';

  // Household roles
  static const String roleOwner = 'owner';
  static const String roleMember = 'member';

  // Default values
  static const String defaultAvatar = '🧑';
  static const String defaultRewardIcon = '🎁';
}
