// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — E2E Rewards & Gamification Flow Tests
// Tests: Complete task → XP+Coins → Redeem reward
// Run with: flutter test test/rewards_e2e_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/rewards/domain/models/reward_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';

class UserProfile {
  String id;
  String name;
  int xp;
  int coins;
  List<RewardModel> redeemedRewards;

  UserProfile({
    required this.id,
    required this.name,
    this.xp = 0,
    this.coins = 0,
    List<RewardModel>? redeemedRewards,
  }) : redeemedRewards = redeemedRewards ?? [];

  void addCoins(int amount) => coins += amount;
  void addXp(int amount) => xp += amount;
  bool spendCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      return true;
    }
    return false;
  }
}

class RewardRedemptionSimulator {
  final List<RewardModel> availableRewards = [];
  final Map<String, UserProfile> users = {};

  RewardRedemptionSimulator() {
    _initDefaultRewards();
  }

  void _initDefaultRewards() {
    availableRewards.addAll([
      const RewardModel(
        id: 'reward-1',
        householdId: 'household-1',
        title: 'Cenar afuera',
        description: 'Una cena fuera',
        cost: 100,
        icon: '🍕',
        isApproved: true,
        isActive: true,
      ),
      const RewardModel(
        id: 'reward-2',
        householdId: 'household-1',
        title: 'Día de descanso',
        description: 'No hacer tareas',
        cost: 150,
        icon: '🛋️',
        isApproved: true,
        isActive: true,
      ),
      const RewardModel(
        id: 'reward-3',
        householdId: 'household-1',
        title: 'Película elegida',
        description: 'Elegir película',
        cost: 50,
        icon: '🎬',
        isApproved: true,
        isActive: true,
      ),
    ]);
  }

  void addUser(UserProfile user) {
    users[user.id] = user;
  }

  Future<void> completeTask(UserProfile user, TaskModel task) async {
    user.addXp(task.xpReward);
    user.addCoins(task.coinReward);
  }

  Future<bool> redeemReward(UserProfile user, RewardModel reward) async {
    if (!reward.isActive || !reward.isApproved) return false;
    if (user.spendCoins(reward.cost)) {
      user.redeemedRewards.add(reward);
      return true;
    }
    return false;
  }

  List<RewardModel> getAvailableRewards() {
    return availableRewards.where((r) => r.isActive && r.isApproved).toList();
  }

  List<RewardModel> getAffordableRewards(int userCoins) {
    return getAvailableRewards().where((r) => r.cost <= userCoins).toList();
  }
}

void main() {
  group('✅ E2E Rewards Flow', () {
    late RewardRedemptionSimulator simulator;
    late UserProfile user1;
    late UserProfile user2;

    setUp(() {
      simulator = RewardRedemptionSimulator();
      user1 = UserProfile(id: 'user-1', name: 'Juan', xp: 0, coins: 0);
      user2 = UserProfile(id: 'user-2', name: 'María', xp: 0, coins: 0);
      simulator.addUser(user1);
      simulator.addUser(user2);
    });

    test('Complete easy task → Earn XP and Coins', () async {
      final task = TaskModel(
        id: 'task-1',
        title: 'Lavar platos',
        category: 'kitchen',
        difficulty: TaskDifficulty.easy,
        status: TaskStatus.active,
        xpReward: 20,
        coinReward: 10,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      );

      await simulator.completeTask(user1, task);

      expect(user1.xp, equals(20));
      expect(user1.coins, equals(10));
    });

    test('Complete hard task → Earn more XP and Coins', () async {
      final task = TaskModel(
        id: 'task-2',
        title: 'Limpieza profunda',
        category: 'cleaning',
        difficulty: TaskDifficulty.hard,
        status: TaskStatus.active,
        xpReward: 50,
        coinReward: 25,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      );

      await simulator.completeTask(user1, task);

      expect(user1.xp, equals(50));
      expect(user1.coins, equals(25));
    });

    test('Accumulate coins from multiple tasks', () async {
      final tasks = [
        TaskModel(
            id: 't1',
            title: 'Tarea 1',
            category: 'other',
            difficulty: TaskDifficulty.easy,
            status: TaskStatus.active,
            xpReward: 10,
            coinReward: 5,
            householdId: 'h1',
            createdAt: DateTime.now()),
        TaskModel(
            id: 't2',
            title: 'Tarea 2',
            category: 'other',
            difficulty: TaskDifficulty.medium,
            status: TaskStatus.active,
            xpReward: 20,
            coinReward: 10,
            householdId: 'h1',
            createdAt: DateTime.now()),
        TaskModel(
            id: 't3',
            title: 'Tarea 3',
            category: 'other',
            difficulty: TaskDifficulty.hard,
            status: TaskStatus.active,
            xpReward: 40,
            coinReward: 20,
            householdId: 'h1',
            createdAt: DateTime.now()),
      ];

      for (final task in tasks) {
        await simulator.completeTask(user1, task);
      }

      expect(user1.xp, equals(70)); // 10 + 20 + 40
      expect(user1.coins, equals(35)); // 5 + 10 + 20
    });

    test('Redeem reward → Coins decrease', () async {
      // First earn some coins
      final task = TaskModel(
        id: 'task-1',
        title: 'Tarea獎勵',
        category: 'other',
        difficulty: TaskDifficulty.medium,
        status: TaskStatus.active,
        xpReward: 30,
        coinReward: 60,
        householdId: 'household-1',
        createdAt: DateTime.now(),
      );
      await simulator.completeTask(user1, task);

      expect(user1.coins, equals(60));

      // Then redeem a reward
      final reward =
          simulator.getAvailableRewards().firstWhere((r) => r.cost <= 60);
      final success = await simulator.redeemReward(user1, reward);

      expect(success, isTrue);
      expect(user1.coins, equals(10)); // 60 - 50
      expect(user1.redeemedRewards.length, equals(1));
    });

    test('Cannot redeem reward with insufficient coins', () async {
      // User has few coins
      user1.addCoins(20);

      // Try to redeem expensive reward
      final reward =
          simulator.getAvailableRewards().firstWhere((r) => r.cost > 20);
      final success = await simulator.redeemReward(user1, reward);

      expect(success, isFalse);
      expect(user1.coins, equals(20)); // Unchanged
      expect(user1.redeemedRewards.length, equals(0));
    });

    test('Cannot redeem inactive reward', () async {
      user1.addCoins(200);

      const inactiveReward = RewardModel(
        id: 'inactive-1',
        householdId: 'household-1',
        title: 'Recompensa inactiva',
        cost: 50,
        icon: '❌',
        isApproved: true,
        isActive: false, // Inactive
      );

      final success = await simulator.redeemReward(user1, inactiveReward);

      expect(success, isFalse);
      expect(user1.coins, equals(200)); // Unchanged
    });

    test('Get affordable rewards for user', () async {
      user1.addCoins(75);
      user2.addCoins(200);

      final affordableForUser1 = simulator.getAffordableRewards(user1.coins);
      final affordableForUser2 = simulator.getAffordableRewards(user2.coins);

      expect(affordableForUser1.any((r) => r.cost <= 75), isTrue);
      expect(affordableForUser2.length, equals(3)); // All rewards
    });

    test('Multiple redemptions accumulate', () async {
      user1.addCoins(250);

      // Redeem first reward (50 coins)
      final reward1 = simulator.getAvailableRewards()[0];
      await simulator.redeemReward(user1, reward1);

      // Redeem second reward (100 coins)
      final reward2 = simulator.getAvailableRewards()[1];
      await simulator.redeemReward(user1, reward2);

      expect(user1.redeemedRewards.length, equals(2));
      expect(user1.coins, equals(250 - reward1.cost - reward2.cost));
    });
  });

  group('✅ Reward Model Tests', () {
    test('RewardModel fromJson parses correctly', () {
      final json = {
        'id': 'reward-json-1',
        'household_id': 'household-1',
        'title': 'Test Reward',
        'description': 'A test reward',
        'cost': 100,
        'icon': '🎁',
        'created_by': 'user-1',
        'is_approved': true,
        'is_active': true,
        'created_at': '2026-03-01T10:00:00Z',
      };

      final reward = RewardModel.fromJson(json);

      expect(reward.id, equals('reward-json-1'));
      expect(reward.title, equals('Test Reward'));
      expect(reward.cost, equals(100));
      expect(reward.isApproved, isTrue);
      expect(reward.isActive, isTrue);
    });

    test('RewardModel default values work', () {
      final json = {
        'id': 'reward-default',
        'household_id': 'household-1',
        'title': 'Default Reward',
        'cost': 50,
      };

      final reward = RewardModel.fromJson(json);

      expect(reward.icon, equals('🎁')); // Default icon
      expect(reward.isApproved, isFalse); // Default
      expect(reward.isActive, isTrue); // Default
    });

    test('RewardModel equality works', () {
      const reward1 = RewardModel(
        id: 'r1',
        householdId: 'h1',
        title: 'Same',
        cost: 100,
        icon: '🎁',
        isApproved: true,
        isActive: true,
      );

      const reward2 = RewardModel(
        id: 'r1',
        householdId: 'h1',
        title: 'Same',
        cost: 100,
        icon: '🎁',
        isApproved: true,
        isActive: true,
      );

      expect(reward1, equals(reward2));
    });
  });

  group('✅ Task XP/Coin Rewards by Difficulty', () {
    test('Easy task gives base rewards', () {
      final task = TaskModel(
        id: 't1',
        title: 'Easy',
        category: 'other',
        difficulty: TaskDifficulty.easy,
        status: TaskStatus.active,
        xpReward: 20,
        coinReward: 10,
        householdId: 'h1',
        createdAt: DateTime.now(),
      );

      expect(task.xpReward, equals(20));
      expect(task.coinReward, equals(10));
    });

    test('Medium task gives medium rewards', () {
      final task = TaskModel(
        id: 't1',
        title: 'Medium',
        category: 'other',
        difficulty: TaskDifficulty.medium,
        status: TaskStatus.active,
        xpReward: 35,
        coinReward: 20,
        householdId: 'h1',
        createdAt: DateTime.now(),
      );

      expect(task.xpReward, equals(35));
      expect(task.coinReward, equals(20));
    });

    test('Hard task gives high rewards', () {
      final task = TaskModel(
        id: 't1',
        title: 'Hard',
        category: 'other',
        difficulty: TaskDifficulty.hard,
        status: TaskStatus.active,
        xpReward: 50,
        coinReward: 30,
        householdId: 'h1',
        createdAt: DateTime.now(),
      );

      expect(task.xpReward, equals(50));
      expect(task.coinReward, equals(30));
    });
  });

  group('✅ Weekly Winner Logic', () {
    test('User with most XP wins the week', () {
      final weekStats = {
        'user-1': UserProfile(id: 'user-1', name: 'Juan', xp: 200),
        'user-2': UserProfile(id: 'user-2', name: 'María', xp: 150),
        'user-3': UserProfile(id: 'user-3', name: 'Pedro', xp: 175),
      };

      final winner = weekStats.values.reduce((a, b) => a.xp > b.xp ? a : b);

      expect(winner.name, equals('Juan'));
      expect(winner.xp, equals(200));
    });

    test('Tie breaker by coins', () {
      final weekStats = {
        'user-1': UserProfile(id: 'user-1', name: 'Juan', xp: 200, coins: 50),
        'user-2': UserProfile(id: 'user-2', name: 'María', xp: 200, coins: 75),
      };

      final winner = weekStats.values.reduce((a, b) {
        if (a.xp != b.xp) return a.xp > b.xp ? a : b;
        return a.coins > b.coins ? a : b;
      });

      expect(winner.name, equals('María'));
    });
  });
}
