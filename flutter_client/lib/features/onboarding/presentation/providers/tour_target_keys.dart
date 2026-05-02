import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';

/// Registry of GlobalKeys for the elements the tour needs to spotlight.
///
/// Widgets register/unregister their key when they mount/unmount; the tour
/// controller reads them by [TourTarget] without knowing where they live.
class TourTargetKeysNotifier extends Notifier<Map<TourTarget, GlobalKey>> {
  @override
  Map<TourTarget, GlobalKey> build() => <TourTarget, GlobalKey>{};

  void register(TourTarget target, GlobalKey key) {
    if (state[target] == key) return;
    state = {...state, target: key};
  }

  void unregister(TourTarget target, GlobalKey key) {
    if (state[target] != key) return;
    final next = {...state}..remove(target);
    state = next;
  }

  GlobalKey? keyFor(TourTarget target) => state[target];
}

final tourTargetKeysProvider =
    NotifierProvider<TourTargetKeysNotifier, Map<TourTarget, GlobalKey>>(
  TourTargetKeysNotifier.new,
);
