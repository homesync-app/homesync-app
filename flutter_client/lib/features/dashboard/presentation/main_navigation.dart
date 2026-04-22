import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

enum MainTab {
  home,
  tasks,
  expenses,
  social,
  stats,
  shopping,
}

bool isMainTabVisible(
  HouseholdCapabilities caps,
  MainTab tab, {
  MemberModel? currentMember,
}) {
  return switch (tab) {
    MainTab.home => true,
    MainTab.tasks => caps.showTasks,
    MainTab.expenses => currentMember?.canSeeFinanceTab ?? true,
    MainTab.social => caps.showPartnerTab,
    MainTab.stats => caps.showStats,
    MainTab.shopping => true,
  };
}

List<MainTab> visibleMainTabs(
  HouseholdCapabilities caps, {
  MemberModel? currentMember,
}) {
  return MainTab.values
      .where((tab) => isMainTabVisible(caps, tab, currentMember: currentMember))
      .toList(growable: false);
}

int indexForMainTab(
  HouseholdCapabilities caps,
  MainTab tab, {
  MemberModel? currentMember,
}) {
  final tabs = visibleMainTabs(caps, currentMember: currentMember);
  return tabs.indexOf(tab);
}
