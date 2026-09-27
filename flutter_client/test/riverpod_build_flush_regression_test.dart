import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the "setState() or markNeedsBuild() called during
/// build" errors that 1.2.3 logged from MainScreen and HomeCoupleView.
///
/// Both stacks show the same chain: a widget's `ref.watch` in build flushes a
/// stale provider graph, a dependent invalidates itself, and the scheduler
/// calls setState on the ProviderScope in the middle of the build. Riverpod
/// 3.3.2 did that; 3.4.0 and 3.4.2 fixed it (riverpod issue #4812), which is
/// why pubspec.yaml requires flutter_riverpod ^3.4.2. This test mirrors the
/// upstream one, with the same shape as householdIdProvider ->
/// currentUserIdProvider -> identity.
void main() {
  testWidgets(
      're-watching a stale provider graph during build neither throws '
      'nor freezes the scheduler', (tester) async {
    var identity = 0;
    final identityProvider = NotifierProvider<_ValueNotifier, int>(
      () => _ValueNotifier(() => identity),
    );
    final userIdProvider = Provider<int>((ref) => ref.watch(identityProvider));
    final householdProvider =
        Provider<int>((ref) => ref.watch(userIdProvider) * 10);
    final profileProvider =
        Provider<int>((ref) => ref.watch(userIdProvider) + 1);

    final container = ProviderContainer();
    addTearDown(container.dispose);

    Widget home() {
      return UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final household = ref.watch(householdProvider);
            final profile = ref.watch(profileProvider);
            return Text(
              'household=$household profile=$profile',
              textDirection: TextDirection.ltr,
            );
          },
        ),
      );
    }

    // 1. The home watches the graph.
    await tester.pumpWidget(home());
    expect(find.text('household=0 profile=1'), findsOneWidget);

    // 2. Another screen: nobody listens to the keepAlive graph anymore.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const SizedBox(),
      ),
    );

    // 3. The identity changes while the graph is unlistened, so it stays
    //    stale.
    identity++;
    container.invalidate(identityProvider);
    await tester.pump();

    // 4. Back home: the build re-watches the stale graph.
    await tester.pumpWidget(home());
    expect(tester.takeException(), isNull);
    expect(find.text('household=10 profile=2'), findsOneWidget);

    // 5. The scheduler still refreshes afterwards.
    identity++;
    container.invalidate(identityProvider);
    await tester.pump();
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('household=20 profile=3'), findsOneWidget);
  });
}

class _ValueNotifier extends Notifier<int> {
  _ValueNotifier(this._read);

  final int Function() _read;

  @override
  int build() => _read();
}
