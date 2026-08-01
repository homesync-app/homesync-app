import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_fund.dart';

Map<String, dynamic> _fund({
  int balance = 0,
  int members = 2,
  Map<String, dynamic>? goal,
}) {
  return {
    'household_id': 'household',
    'balance': balance,
    'week_earned': 40,
    'members': members,
    'rhythm_weeks': 3,
    'rhythm_window': 4,
    'goal': goal,
  };
}

Map<String, dynamic> _goal({
  int cost = 200,
  String status = 'active',
  List<Map<String, dynamic>> confirmations = const [],
}) {
  return {
    'id': 'goal-1',
    'catalog_key': 'movie_night',
    'title': 'Noche de cine',
    'icon': '🎬',
    'cost': cost,
    'status': status,
    'created_at': '2026-08-01T00:00:00Z',
    'confirmations': confirmations,
  };
}

void main() {
  group('HouseholdFund', () {
    test('without a goal there is no progress and nothing is missing', () {
      final fund = HouseholdFund.fromMap(_fund(balance: 120));

      expect(fund.hasGoal, isFalse);
      expect(fund.progress, 0);
      expect(fund.remaining, 0);
      expect(fund.pendingConfirmations, 0);
    });

    test('progress and remaining track the active goal', () {
      final fund = HouseholdFund.fromMap(
        _fund(balance: 150, goal: _goal(cost: 200)),
      );

      expect(fund.progress, closeTo(0.75, 0.001));
      expect(fund.remaining, 50);
      expect(fund.rhythmWeeks, 3);
      expect(fund.rhythmWindow, 4);
    });

    test('overshooting the goal clamps progress and never goes negative', () {
      final fund = HouseholdFund.fromMap(
        _fund(balance: 500, goal: _goal(cost: 200)),
      );

      expect(fund.progress, 1.0);
      expect(fund.remaining, 0);
    });

    test('a goal that is not ready has no keys pending', () {
      final fund = HouseholdFund.fromMap(
        _fund(balance: 10, goal: _goal(cost: 200)),
      );

      expect(fund.goal!.isReady, isFalse);
      expect(fund.pendingConfirmations, 0);
    });

    test('the unlock needs every member, not a hardcoded two', () {
      final fund = HouseholdFund.fromMap(
        _fund(
          balance: 200,
          members: 3,
          goal: _goal(
            cost: 200,
            status: 'ready',
            confirmations: [
              {'user_id': 'a', 'name': 'Alex', 'confirmed_at': null},
            ],
          ),
        ),
      );

      expect(fund.goal!.isReady, isTrue);
      expect(fund.pendingConfirmations, 2);
      expect(fund.goal!.confirmedBy('a'), isTrue);
      expect(fund.goal!.confirmedBy('b'), isFalse);
      expect(fund.goal!.confirmedBy(null), isFalse);
    });

    test('once everyone confirmed nothing is pending', () {
      final fund = HouseholdFund.fromMap(
        _fund(
          balance: 200,
          goal: _goal(
            cost: 200,
            status: 'ready',
            confirmations: [
              {'user_id': 'a', 'name': 'Alex', 'confirmed_at': null},
              {'user_id': 'b', 'name': 'Sam', 'confirmed_at': null},
            ],
          ),
        ),
      );

      expect(fund.pendingConfirmations, 0);
    });

    test('a malformed payload degrades to an empty fund', () {
      final fund = HouseholdFund.fromMap({'goal': 'not a map'});

      expect(fund.balance, 0);
      expect(fund.hasGoal, isFalse);
      expect(fund.rhythmWindow, 4);
    });
  });

  group('FundConfirmationOutcome', () {
    test('reads the unlock result and the proposal it opened', () {
      final outcome = FundConfirmationOutcome.fromMap({
        'goal_id': 'goal-1',
        'status': 'unlocked',
        'confirmations': 2,
        'members': 2,
        'unlocked': true,
        'proposal_id': 'proposal-9',
      });

      expect(outcome.unlocked, isTrue);
      expect(outcome.status, FundGoalStatus.unlocked);
      expect(outcome.proposalId, 'proposal-9');
    });

    test('a single key does not unlock', () {
      final outcome = FundConfirmationOutcome.fromMap({
        'goal_id': 'goal-1',
        'status': 'ready',
        'confirmations': 1,
        'members': 2,
        'unlocked': false,
        'proposal_id': null,
      });

      expect(outcome.unlocked, isFalse);
      expect(outcome.status, FundGoalStatus.ready);
      expect(outcome.proposalId, isNull);
    });
  });

  group('FundGoalCatalogItem', () {
    test('every catalog cost fits the range the server accepts', () {
      for (final item in FundGoalCatalogItem.all) {
        expect(item.cost, inInclusiveRange(50, 2000), reason: item.key);
        expect(item.icon, isNotEmpty);
      }
    });

    test('catalog keys are unique', () {
      final keys = FundGoalCatalogItem.all.map((item) => item.key).toSet();

      expect(keys.length, FundGoalCatalogItem.all.length);
    });
  });

  group('CoupleProposal origin', () {
    test('a proposal opened by a fund unlock is flagged as such', () {
      final proposal = CoupleProposal.fromMap({
        'id': 'p1',
        'household_id': 'h',
        'created_by': 'a',
        'title': 'Cena afuera',
        'category': 'plan',
        'status': 'pending',
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
        'origin': 'fund_goal',
      });

      expect(proposal.isFromFund, isTrue);
    });

    test('a proposal someone wrote defaults to member origin', () {
      final proposal = CoupleProposal.fromMap({
        'id': 'p2',
        'household_id': 'h',
        'created_by': 'a',
        'title': 'Charlar del finde',
        'category': 'talk',
        'status': 'pending',
        'created_at': '2026-08-01T00:00:00Z',
        'updated_at': '2026-08-01T00:00:00Z',
      });

      expect(proposal.isFromFund, isFalse);
      expect(proposal.origin, 'member');
    });
  });
}
