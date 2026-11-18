import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/models/task_completion_result.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_actions_sheet.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/domain/models/category_model.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/couple_task_tile.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/custom_bottom_nav.dart';

final _members = [
  for (final entry in [
    ('me', 'Sofi', 'orange_cat'),
    ('partner', 'Mati', 'market_dog'),
  ])
    MemberModel(
      id: entry.$1,
      userId: entry.$1,
      fullName: entry.$2,
      avatarUrl: 'premium://premium_${entry.$3}',
      householdId: 'home',
      role: 'member',
      joinedAt: DateTime(2026),
      type: MemberType.parent,
    ),
];

class _Members extends HouseholdMembersNotifier {
  final bool waiting;
  _Members(this.waiting);
  @override
  Future<List<MemberModel>> build() async =>
      waiting ? [_members.first] : _members;
}

final _tasks = [
  for (final entry in [
    ('plant', 'Regar las plantas', 'jardin', 'me', 0),
    ('cook', 'Preparar la cena', 'cocina', 'partner', 0),
    ('clean', 'Limpiar el baño', 'limpieza', 'me', 1),
  ])
    TaskModel(
      id: entry.$1,
      title: entry.$2,
      category: entry.$3,
      assignedTo: entry.$4,
      dueAt: DateTime.now().add(Duration(days: entry.$5)),
      householdId: 'home',
      createdAt: DateTime(2026),
      status: TaskStatus.active,
      xpReward: 0,
      coinReward: 0,
    ),
];

class _Tasks extends Tasks {
  final bool _empty;
  final Completer<TaskCompletionResult?> _completion = Completer();
  int _calls = 0;
  _Tasks(this._empty);
  @override
  bool get hasMore => false;
  @override
  Future<List<TaskModel>> build() async => _empty ? [] : _tasks;
  @override
  Future<TaskCompletionResult?> completeTask(
    TaskModel task, {
    List<String>? userIds,
    DateTime? completedAt,
  }) async {
    _calls++;
    return _completion.future;
  }
}

const _categories = <String, String>{
  'jardin': 'Jardín',
  'cocina': 'Cocina',
  'limpieza': 'Limpieza',
};

void main() {
  setUpAll(() async {
    final font = FontLoader('Outfit');
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
      'Black',
    ]) {
      font.addFont(
        Future.value(
          ByteData.sublistView(
            File('assets/fonts/outfit/Outfit-$weight.ttf').readAsBytesSync(),
          ),
        ),
      );
    }
    await font.load();
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter';
    final materialFontFile = File(
      '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (materialFontFile.existsSync()) {
      final material = FontLoader('MaterialIcons')
        ..addFont(
          Future.value(
            ByteData.sublistView(materialFontFile.readAsBytesSync()),
          ),
        );
      await material.load();
    }
  });

  Future<void> capture(WidgetTester tester, GlobalKey key, String name) async {
    for (var pass = 0; pass < 2; pass++) {
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
    if (const bool.fromEnvironment('CAPTURE_HOME')) {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        File('build/couple_home/$name.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(bytes!.buffer.asUint8List());
      });
    }
  }

  for (final scenario in ['light', 'dark', 'narrow', 'waiting', 'empty']) {
    testWidgets('tasks $scenario: real list, filters, calendar and completion',
        (tester) async {
      final narrow = scenario == 'narrow';
      final waiting = scenario == 'waiting';
      final empty = scenario == 'empty';
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(narrow ? 320 : 412, narrow ? 1300 : 1000);
      addTearDown(tester.view.reset);
      final shot = GlobalKey();
      final tasks = _Tasks(empty);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserIdProvider.overrideWithValue('me'),
            householdIdProvider.overrideWith((ref) async => 'home'),
            householdMembersProvider.overrideWith(() => _Members(waiting)),
            householdCapabilitiesProvider.overrideWith(
              (ref) => const HouseholdCapabilities(type: HouseholdType.couple),
            ),
            currentHouseholdProvider.overrideWith(
              (ref) async => const HouseholdModel(
                id: 'home',
                name: 'Home',
                householdType: 'couple',
              ),
            ),
            tasksProvider.overrideWith(() => tasks),
            categoriesProvider.overrideWith(
              (ref) async => [
                for (final entry in _categories.entries)
                  CategoryModel(
                    id: entry.key,
                    name: entry.value,
                    color: '#84A59D',
                    icon: '',
                  ),
              ],
            ),
            householdContributionProvider('home').overrideWith(
              (ref) async => HouseholdContribution(
                householdId: 'home',
                weekStart: DateTime(2026, 9, 28),
                weekEnd: DateTime(2026, 10, 5),
                totalTasks: 10,
                rhythmWeeks: 3,
                rhythmWindow: 4,
                members: [
                  for (final entry in [
                    ('me', 'Sofi', 3),
                    ('partner', 'Mati', 7),
                  ])
                    ContributionMember(
                      userId: entry.$1,
                      name: entry.$2,
                      avatarUrl: null,
                      tasksDone: entry.$3,
                      demandingDone: 0,
                    ),
                ],
                categories: [],
              ),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: scenario == 'dark'
                ? AppTheme.darkTheme()
                : AppTheme.lightTheme(),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(narrow ? 1.3 : 1)),
              child: child!,
            ),
            home: RepaintBoundary(key: shot, child: const TasksScreen()),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await capture(tester, shot, 'tasks_$scenario');
      expect(tester.takeException(), isNull);
      final context = tester.element(find.byType(TasksScreen));
      final t = AppLocalizations.of(context);
      expect(
        find.text(t.coupleWeekDuoTitle),
        waiting ? findsNothing : findsOneWidget,
      );
      expect(
        find.text(t.coupleTasksCompletedCount(3)),
        waiting ? findsNothing : findsOneWidget,
      );
      expect(find.byIcon(Icons.add_rounded), findsNothing);
      if (!empty) {
        await tester.tap(find.text('Regar las plantas'));
        await tester.pump(const Duration(milliseconds: 500));
        expect(
          tester
              .widgetList<CoupleTaskTile>(find.byType(CoupleTaskTile))
              .where((tile) => tile.expanded),
          hasLength(1),
        );
        await capture(tester, shot, 'tasks_${scenario}_expanded');
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Regar las plantas'));
        await tester.pump(const Duration(milliseconds: 500));
        final categoryList = find.byWidgetPredicate(
          (widget) =>
              widget is ListView && widget.scrollDirection == Axis.horizontal,
        );
        await tester.drag(categoryList, const Offset(-450, 0));
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.text('Limpieza').first);
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Regar las plantas'), findsNothing);
        expect(find.text('Limpiar el baño'), findsOneWidget);
        final container = ProviderScope.containerOf(context);
        container.read(taskCategoryFilterProvider.notifier).clear();
        await tester.pump(const Duration(seconds: 1));
      }
      final container = ProviderScope.containerOf(context);
      container.read(taskViewModeProvider.notifier).setCalendar();
      await tester.pump(const Duration(seconds: 1));
      for (var frame = 0; frame < 10; frame++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await capture(tester, shot, 'calendar_$scenario');
      expect(find.text(t.calendarNoTasksScheduled), findsWidgets);
      expect(tester.takeException(), isNull);
      container.read(taskViewModeProvider.notifier).setList();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      if (!empty) {
        final complete = find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedPress &&
              widget.semanticLabel ==
                  t.coupleHomeCompleteTask('Regar las plantas'),
        );
        await tester.ensureVisible(complete);
        await tester.tap(complete);
        await tester.pump();
        await tester.tap(complete);
        expect(tasks._calls, 1);
        tasks._completion.complete(
          const TaskCompletionResult(
            success: true,
            message: '',
            queued: false,
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
      'central action keeps destination and offers only expense and task creation',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    addTearDown(tester.view.reset);
    var destination = 1;
    late BuildContext host;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserIdProvider.overrideWithValue('me'),
          householdIdProvider.overrideWith((ref) async => 'home'),
          householdMembersProvider.overrideWith(() => _Members(false)),
          currentHouseholdProvider.overrideWith(
            (ref) async => const HouseholdModel(
              id: 'home',
              name: 'Home',
              householdType: 'couple',
            ),
          ),
          categoriesProvider.overrideWith((ref) async => []),
        ],
        child: MaterialApp(
          locale: const Locale('es'),
          theme: AppTheme.lightTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.3)),
            child: child!,
          ),
          home: Builder(
            builder: (context) {
              host = context;
              return Scaffold(
                bottomNavigationBar: CustomBottomNav(
                  currentIndex: destination,
                  onTap: (value) => destination = value,
                  actionLabel: 'Acciones',
                  onAction: () => showCoupleActionsSheet(context),
                  items: [
                    for (final entry in [
                      (0, 'Inicio'),
                      (1, 'Tareas'),
                      (2, 'Finanzas'),
                      (3, 'Compras'),
                    ])
                      CustomBottomNavItem(
                        index: entry.$1,
                        label: entry.$2,
                        icon: Icons.home_outlined,
                        selectedIcon: Icons.home_rounded,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.getSize(find.byType(CustomBottomNav)).height, lessThan(100));
    expect(
      tester.getCenter(find.byIcon(Icons.add_rounded)).dy,
      greaterThan(900),
    );
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final t = AppLocalizations.of(host);
    expect(destination, 1);
    expect(find.text(t.coupleHomeAddExpense), findsOneWidget);
    expect(find.text(t.tasksFabNew), findsOneWidget);
    expect(find.text(t.coupleHomeLeaveNote), findsOneWidget);
    expect(find.text(t.couplePlansTitle), findsOneWidget);
    expect(find.text(t.coupleHomeAddShopping), findsNothing);
    Navigator.of(host).pop();
    await tester.pump(const Duration(seconds: 1));
    expect(destination, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
