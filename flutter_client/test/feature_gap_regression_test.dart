import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/repositories/household_repository.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/domain/repositories/savings_repository.dart';
import 'package:homesync_client/features/savings/domain/usecases/add_contribution_usecase.dart';
import 'package:homesync_client/features/savings/domain/usecases/create_savings_goal_usecase.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/features/settings/domain/repositories/settings_repository.dart';
import 'package:homesync_client/features/settings/domain/usecases/update_avatar_usecase.dart';
import 'package:homesync_client/features/settings/presentation/providers/settings_provider.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:homesync_client/features/shopping/domain/usecases/add_shopping_item_usecase.dart';
import 'package:homesync_client/features/shopping/domain/usecases/get_shopping_items_usecase.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
  String? lastAvatarUrl;

  @override
  Future<Map<String, dynamic>> resetUserAccount() async => {'success': true};

  @override
  Future<void> updateAvatar(String avatarUrl) async {
    lastAvatarUrl = avatarUrl;
  }

  @override
  Future<void> updateFullName(String name) async {}

  @override
  Future<void> updateNotificationSettings(bool enabled) async {}
}

class FakeShoppingRepository implements ShoppingRepository {
  @override
  Future<Either<Failure, ShoppingItemModel>> addItem({
    required String householdId,
    required String name,
    required String userId,
    String? clientId,
    String? nameKey,
    String? quantity,
    String? unit,
    String category = 'general',
    String emoji = 'cart',
    String? note,
    bool shouldSync = true,
  }) async {
    return Right(
      ShoppingItemModel(
        id: clientId ?? 'item-1',
        householdId: householdId,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        emoji: emoji,
        note: note,
        addedBy: userId,
        createdAt: DateTime.now(),
        shouldSync: shouldSync,
      ),
    );
  }

  @override
  Future<Either<Failure, void>> clearCompleted(String householdId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteItem(String itemId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<ShoppingItemModel>>> fetchItems(
    String householdId,
  ) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> toggleItem({
    required String itemId,
    required bool completed,
    required String? userId,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateItem({
    required String itemId,
    required String name,
    String? nameKey,
    required String category,
    required String emoji,
    String? note,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> uncompleteAll(String householdId) async =>
      const Right(null);
}

class FakeSavingsRepository implements SavingsRepository {
  @override
  Future<Either<Failure, void>> addContribution({
    required String goalId,
    required String userId,
    required double amount,
    String? note,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> createGoal({
    required String householdId,
    required String title,
    required double targetAmount,
    required String color,
    required String icon,
  }) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteGoal({required String goalId}) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<SavingsContributionModel>>> getGoalContributions({
    required String goalId,
  }) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<SavingsGoalModel>>> getGoals({
    required String householdId,
    int? limit,
    int? offset,
  }) async =>
      const Right([]);
}

class FakeHouseholdRepository implements HouseholdRepository {
  @override
  Future<Either<Failure, String>> generateInvitationCode() async =>
      const Right('CODE123');

  @override
  Future<Either<Failure, HouseholdModel?>> getHousehold(
    String householdId,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, String?>> getHouseholdId(String userId) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>>
      getHouseholdMembersRaw() async => const Right([]);

  @override
  Future<Either<Failure, List<String>>> getMemberIds(
          String householdId,) async =>
      const Right([]);

  @override
  Future<Either<Failure, Map<String, dynamic>>> joinHousehold(
          String code,) async =>
      const Right({});

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaAddDummyMember({
    required String householdId,
    required String fullName,
    String? displayRole,
    String? avatarUrl,
    String role = 'member',
  }) async =>
      const Right({});

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaDeleteDummyMember({
    required String householdId,
    required String userId,
  }) async =>
      const Right({});

  @override
  Future<Either<Failure, Map<String, dynamic>>> qaResetScenario(
    String householdId,
  ) async =>
      const Right({});

  @override
  Future<Either<Failure, void>> removeMember(String userId) async =>
      const Right(null);

  @override
  Future<Either<Failure, Map<String, dynamic>>>
      resetAndClearHousehold() async => const Right({});

  @override
  Future<Either<Failure, Map<String, dynamic>>> resetUserAccount() async =>
      const Right({});

  @override
  Future<Either<Failure, void>> updateDefaultSplitRatio(
    String householdId,
    double ratio,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateHouseholdType(
    String householdId,
    String type,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateTasksEnabled(
    String householdId,
    bool enabled,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateMemberDisplayRole(
    String userId,
    String? displayRole,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateMemberType(
    String userId,
    String type,
  ) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateFinanceSettings(
    String householdId, {
    required String financeMode,
    required double defaultSplitRatio,
  }) async =>
      const Right(null);
}

void main() {
  group('Settings', () {
    test('notificationEnabledProvider toggles state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(notificationEnabledProvider), isTrue);

      container.read(notificationEnabledProvider.notifier).toggle(false);
      expect(container.read(notificationEnabledProvider), isFalse);
    });

    test('UpdateAvatarUseCase validates empty avatar and delegates valid one',
        () async {
      final repository = FakeSettingsRepository();
      final useCase = UpdateAvatarUseCase(repository);

      expect(() => useCase.execute(''), throwsException);

      await useCase.execute('avatar://premium');
      expect(repository.lastAvatarUrl, equals('avatar://premium'));
    });
  });

  group('Household', () {
    test('householdCapabilitiesProvider respects forced admin type', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final admin = container.read(adminProvider.notifier);
      admin.adminLogin();
      admin.forceType(HouseholdType.family);

      final capabilities = container.read(householdCapabilitiesProvider);
      expect(capabilities.type, equals(HouseholdType.family));
    });

    test(
        'householdMembersProvider returns empty list when household is unresolved',
        () async {
      final container = ProviderContainer(
        overrides: [
          householdIdProvider.overrideWith((ref) async => null),
          currentUserIdProvider.overrideWith((ref) => null),
          householdRepositoryProvider
              .overrideWithValue(FakeHouseholdRepository()),
        ],
      );
      addTearDown(container.dispose);

      final members = await container.read(householdMembersProvider.future);
      expect(members, isEmpty);
    });
  });

  group('Shopping', () {
    test('GetShoppingItemsUseCase rejects empty householdId', () async {
      final useCase = GetShoppingItemsUseCase(FakeShoppingRepository());

      final result = await useCase.execute('');
      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse((_) => const ValidationFailure('fallback')),
        isA<ValidationFailure>(),
      );
    });

    test('AddShoppingItemUseCase rejects blank item name', () async {
      final useCase = AddShoppingItemUseCase(FakeShoppingRepository());

      final result = await useCase.execute(
        householdId: 'household-1',
        name: '   ',
        userId: 'user-1',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse((_) => const ValidationFailure('fallback')),
        isA<ValidationFailure>(),
      );
    });

    test(
        'shoppingItemsProvider returns empty list when household is unresolved',
        () async {
      final container = ProviderContainer(
        overrides: [
          householdIdProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      final items = await container.read(shoppingItemsProvider.future);
      expect(items, isEmpty);
    });
  });

  group('Savings', () {
    test('CreateSavingsGoalUseCase rejects non-positive target amount',
        () async {
      final useCase = CreateSavingsGoalUseCase(FakeSavingsRepository());

      final result = await useCase.execute(
        householdId: 'household-1',
        title: 'Vacaciones',
        targetAmount: 0,
        color: '#FF7E67',
        icon: 'money',
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse((_) => const ValidationFailure('fallback')),
        isA<ValidationFailure>(),
      );
    });

    test('AddContributionUseCase rejects empty goalId', () async {
      final useCase = AddContributionUseCase(FakeSavingsRepository());

      final result = await useCase.execute(
        goalId: '',
        userId: 'user-1',
        amount: 1000,
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.swap().getOrElse((_) => const ValidationFailure('fallback')),
        isA<ValidationFailure>(),
      );
    });

    test('savingsGoalsProvider returns empty list when household is unresolved',
        () async {
      final container = ProviderContainer(
        overrides: [
          householdIdProvider.overrideWith((ref) async => null),
        ],
      );
      addTearDown(container.dispose);

      final goals = await container.read(savingsGoalsProvider.future);
      expect(goals, isEmpty);
    });
  });
}
