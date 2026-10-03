import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/couple_space/data/repositories/couple_plans_repository.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_plan.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_plans_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_plans_section.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _Client extends Fake implements SupabaseClient {}

class _PlansRepository extends CouplePlansRepository {
  final changes = StreamController<List<CouplePlanProgress>>.broadcast();
  final calls = <CouplePlanAction>[];
  List<CouplePlanProgress> rows = [];
  Completer<void>? gate;
  bool fail = false;

  _PlansRepository() : super(_Client());

  @override
  Stream<List<CouplePlanProgress>> watchProgress(String householdId) async* {
    yield rows;
    yield* changes.stream;
  }

  @override
  Future<CouplePlanProgress> act(
    String householdId,
    CouplePlan plan,
    CouplePlanAction action,
  ) async {
    calls.add(action);
    if (gate != null) await gate!.future;
    if (fail) throw const SocketException('offline');
    final old = rows.where((r) => r.planId == plan.name).firstOrNull;
    final result = CouplePlanProgress(
      planId: plan.name,
      saved: switch (action) {
        CouplePlanAction.save => true,
        CouplePlanAction.unsave => false,
        _ => old?.saved ?? false,
      },
      completedAt: switch (action) {
        CouplePlanAction.complete => old?.completedAt ?? DateTime(2026, 10, 3),
        CouplePlanAction.undo => null,
        _ => old?.completedAt,
      },
    );
    rows = [...rows.where((r) => r.planId != plan.name), result];
    changes.add(rows);
    return result;
  }
}

Future<void> _mount(WidgetTester tester, _PlansRepository repo) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(412, 2200);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [couplePlansRepositoryProvider.overrideWith((ref) => repo)],
      child: MaterialApp(
        theme: AppTheme.lightTheme(),
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CouplePlansSection(
                householdId: 'household',
                note: SizedBox.shrink(),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() async {
    final loader = FontLoader('Outfit');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
      'Black',
    ]) {
      loader.addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/outfit/Outfit-$weight.ttf').readAsBytesSync(),
          ),
        ),
      );
    }
    await loader.load();
  });

  testWidgets('save, shared completion and undo keep independent state',
      (tester) async {
    final repo = _PlansRepository();
    addTearDown(repo.changes.close);
    await _mount(tester, repo);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('Guardado'), findsOneWidget);
    repo.gate = Completer<void>();
    await tester.tap(find.text('Lo hicimos'));
    await tester.pump();
    await tester.tap(find.text('Lo hicimos'));
    expect(
      repo.calls.where((a) => a == CouplePlanAction.complete),
      hasLength(1),
    );
    repo.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('1 de 5'), findsOneWidget);
    expect(find.text('¡Un recuerdo más!'), findsOneWidget);
    expect(find.text('Guardado'), findsOneWidget);
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();
    expect(find.text('0 de 5'), findsOneWidget);
    expect(find.text('Guardado'), findsOneWidget);
    // Partner's change arrives on the same subscription without a refresh.
    repo.rows = [
      ...repo.rows,
      CouplePlanProgress(planId: 'walk', completedAt: DateTime(2026, 10, 3)),
    ];
    repo.changes.add(repo.rows);
    await tester.pumpAndSettle();
    expect(find.text('1 de 5'), findsOneWidget);
  });

  testWidgets('a failed mutation does not invent a stamp and can be retried',
      (tester) async {
    final repo = _PlansRepository()..fail = true;
    addTearDown(repo.changes.close);
    await _mount(tester, repo);
    await tester.tap(find.text('Lo hicimos'));
    await tester.pumpAndSettle();
    expect(find.text('0 de 5'), findsOneWidget);
    expect(find.text('¡Un recuerdo más!'), findsNothing);
    repo.fail = false;
    await tester.tap(find.text('Lo hicimos'));
    await tester.pumpAndSettle();
    expect(find.text('1 de 5'), findsOneWidget);
  });

  testWidgets('saved plans open their detail without an approval step',
      (tester) async {
    final repo = _PlansRepository()
      ..rows = [const CouplePlanProgress(planId: 'cooking', saved: true)];
    addTearDown(repo.changes.close);
    await _mount(tester, repo);
    await tester.tap(find.text('Planes guardados'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cocineros por un rato'));
    await tester.pumpAndSettle();
    expect(find.text('Cocineros por un rato'), findsOneWidget);
    expect(find.text('Guardado'), findsOneWidget);
    expect(find.text('Lo hicimos'), findsOneWidget);
    expect(find.text('Te toca responder'), findsNothing);
    expect(repo.calls, isEmpty);
  });
}
