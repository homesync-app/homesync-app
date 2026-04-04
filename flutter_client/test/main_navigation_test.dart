import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

void main() {
  group('main navigation', () {
    test('keeps current ordering when tasks are enabled', () {
      const caps = HouseholdCapabilities(
        type: HouseholdType.family,
        tasksEnabled: true,
      );

      expect(
        visibleMainTabs(caps),
        [
          MainTab.home,
          MainTab.tasks,
          MainTab.expenses,
          MainTab.social,
          MainTab.stats,
          MainTab.shopping,
        ],
      );
      expect(indexForMainTab(caps, MainTab.tasks), 1);
      expect(indexForMainTab(caps, MainTab.expenses), 2);
      expect(indexForMainTab(caps, MainTab.shopping), 5);
    });

    test('reindexes tabs when tasks are disabled', () {
      const caps = HouseholdCapabilities(
        type: HouseholdType.family,
        tasksEnabled: false,
      );

      expect(
        visibleMainTabs(caps),
        [
          MainTab.home,
          MainTab.expenses,
          MainTab.social,
          MainTab.shopping,
        ],
      );
      expect(indexForMainTab(caps, MainTab.tasks), -1);
      expect(indexForMainTab(caps, MainTab.expenses), 1);
      expect(indexForMainTab(caps, MainTab.shopping), 3);
      expect(indexForMainTab(caps, MainTab.stats), -1);
    });

    test('reindexes tabs without social hub', () {
      const caps = HouseholdCapabilities(
        type: HouseholdType.solo,
        tasksEnabled: false,
      );

      expect(
        visibleMainTabs(caps),
        [
          MainTab.home,
          MainTab.expenses,
          MainTab.shopping,
        ],
      );
      expect(indexForMainTab(caps, MainTab.social), -1);
      expect(indexForMainTab(caps, MainTab.shopping), 2);
    });
  });
}
