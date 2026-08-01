import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';

Map<String, dynamic> _payload({
  int total = 0,
  List<Map<String, dynamic>> members = const [],
  List<Map<String, dynamic>> categories = const [],
  int rhythmWeeks = 0,
}) {
  return {
    'household_id': 'household',
    'week_start': '2026-07-27T00:00:00Z',
    'week_end': '2026-08-03T00:00:00Z',
    'total_tasks': total,
    'rhythm_weeks': rhythmWeeks,
    'rhythm_window': 4,
    'members': members,
    'categories': categories,
  };
}

Map<String, dynamic> _member(String id, String name, int done, int demanding) {
  return {
    'user_id': id,
    'name': name,
    'avatar_url': null,
    'tasks_done': done,
    'demanding_done': demanding,
  };
}

Map<String, dynamic> _category(
  String name,
  int total,
  int dominantCount,
  bool skewed,
) {
  return {
    'category': name,
    'total': total,
    'dominant_user_id': 'a',
    'dominant_name': 'Alex',
    'dominant_count': dominantCount,
    'skewed': skewed,
  };
}

void main() {
  group('HouseholdContribution', () {
    test('an empty week is empty and not "balanced"', () {
      final contribution = HouseholdContribution.fromMap(_payload());

      expect(contribution.isEmpty, isTrue);
      // Nothing happened, so calling it evenly split would be a lie.
      expect(contribution.isBalanced, isFalse);
      expect(contribution.skewedCategories, isEmpty);
    });

    test('shares are computed over the household total', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(
          total: 10,
          members: [_member('a', 'Alex', 6, 2), _member('b', 'Sam', 4, 1)],
        ),
      );

      expect(contribution.shareOf(contribution.members[0]), closeTo(0.6, 0.001));
      expect(contribution.shareOf(contribution.members[1]), closeTo(0.4, 0.001));
    });

    test('shares stay bounded if a member outpaces the total', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(total: 2, members: [_member('a', 'Alex', 5, 0)]),
      );

      expect(contribution.shareOf(contribution.members[0]), 1.0);
    });

    test('members keep join order and are never ranked by output', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(
          total: 10,
          members: [_member('a', 'Alex', 1, 0), _member('b', 'Sam', 9, 0)],
        ),
      );

      // The one who did less still comes first: this view has no podium.
      expect(
        contribution.members.map((member) => member.name),
        ['Alex', 'Sam'],
      );
    });

    test('only skewed categories surface as a reading', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(
          total: 10,
          members: [_member('a', 'Alex', 6, 0), _member('b', 'Sam', 4, 0)],
          categories: [
            _category('cocina', 4, 4, true),
            _category('limpieza', 4, 2, false),
            _category('ropa', 2, 2, false),
          ],
        ),
      );

      expect(contribution.isBalanced, isFalse);
      expect(
        contribution.skewedCategories.map((category) => category.category),
        ['cocina'],
      );
    });

    test('work with no skew reads as evenly split', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(
          total: 6,
          members: [_member('a', 'Alex', 3, 0), _member('b', 'Sam', 3, 0)],
          categories: [_category('limpieza', 6, 3, false)],
        ),
      );

      expect(contribution.isBalanced, isTrue);
      expect(contribution.skewedCategories, isEmpty);
    });

    test('rhythm is reported as a window, never as a streak', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(total: 1, rhythmWeeks: 3),
      );

      expect(contribution.rhythmWeeks, 3);
      expect(contribution.rhythmWindow, 4);
      expect(contribution.rhythmWeeks, lessThanOrEqualTo(4));
    });

    test('a malformed payload degrades instead of throwing', () {
      final contribution = HouseholdContribution.fromMap({
        'members': 'nope',
        'categories': 42,
      });

      expect(contribution.members, isEmpty);
      expect(contribution.categories, isEmpty);
      expect(contribution.totalTasks, 0);
      expect(contribution.rhythmWindow, 4);
    });

    test('demanding counts survive the round trip', () {
      final contribution = HouseholdContribution.fromMap(
        _payload(total: 3, members: [_member('a', 'Alex', 3, 2)]),
      );

      expect(contribution.members.single.demandingDone, 2);
    });
  });
}
