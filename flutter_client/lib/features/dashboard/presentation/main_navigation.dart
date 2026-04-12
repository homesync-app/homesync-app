import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

enum MainTab {
  home,
  tasks,
  expenses,
  social,
  stats,
  shopping,
}

bool isMainTabVisible(HouseholdCapabilities caps, MainTab tab) {
  return switch (tab) {
    MainTab.home => true,
    MainTab.tasks => caps.showTasks,
    MainTab.expenses => true,
    MainTab.social => caps.showPartnerTab,
    MainTab.stats => caps.showStats,
    MainTab.shopping => true,
  };
}

List<MainTab> visibleMainTabs(HouseholdCapabilities caps) {
  return MainTab.values
      .where((tab) => isMainTabVisible(caps, tab))
      .toList(growable: false);
}

int indexForMainTab(HouseholdCapabilities caps, MainTab tab) {
  final tabs = visibleMainTabs(caps);
  return tabs.indexOf(tab);
}
