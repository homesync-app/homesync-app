import 'package:flutter_riverpod/flutter_riverpod.dart';

class BottomNavNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final bottomNavIndexProvider = NotifierProvider<BottomNavNotifier, int>(() {
  return BottomNavNotifier();
});

class SocialHubTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index.clamp(0, 1);
  }
}

final socialHubTabIndexProvider =
    NotifierProvider<SocialHubTabNotifier, int>(() {
  return SocialHubTabNotifier();
});

// Backwards-compatible alias while older rewards screens still reference the
// previous provider name.
final parejaTabIndexProvider = socialHubTabIndexProvider;

/// True while the onboarding wizard (SetupScreen) is mid-flight creating a
/// household but hasn't finished collecting profile/finance/task steps yet.
///
/// The wizard creates the household partway through (when the user taps
/// "Create"), which makes `householdIdProvider` resolve to a non-null value.
/// Without this guard, the root router (MainScreen) would immediately swap the
/// wizard out for Home/MemberOnboarding, skipping the remaining steps and
/// losing the chosen name/avatar (they're persisted only on the final step).
/// SetupScreen sets this to `true` right before creating the household and back
/// to `false` once setup completes; MainScreen keeps showing SetupScreen while
/// it's `true`.
class SetupInProgressNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void begin() => state = true;
  void finish() => state = false;
}

final setupInProgressProvider =
    NotifierProvider<SetupInProgressNotifier, bool>(() {
  return SetupInProgressNotifier();
});
