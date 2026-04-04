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
