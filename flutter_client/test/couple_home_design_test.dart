import 'dart:io';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file/file.dart' as fixture_file;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/core/utils/premium_avatar_assets.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/screens/modes/home_couple_view.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_activity_tile.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_home_widgets.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/love_note_envelope.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/domain/usecases/generate_invitation_code_usecase.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/partner_invite_card.dart';
import 'package:homesync_client/features/onboarding/presentation/providers/couple_home_tour_controller.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _members = [
  for (final pair in [
    ('me', 'Sofi', 'premium_orange_cat'),
    ('partner', 'Mati', 'premium_market_dog'),
  ])
    MemberModel(
      id: pair.$1,
      userId: pair.$1,
      householdId: 'home',
      role: 'member',
      joinedAt: DateTime(2026),
      type: MemberType.parent,
      fullName: pair.$2,
      avatarUrl: 'premium://${pair.$3}',
    ),
];

class _InviteCode extends Fake implements GenerateInvitationCodeUseCase {
  @override
  Future<Either<Failure, String>> call() async => const Right('TEST42');
}

class _Members extends HouseholdMembersNotifier {
  final bool paired;
  final String scenario;
  _Members([this.paired = true, this.scenario = 'light']);
  @override
  Future<List<MemberModel>> build() async =>
      (paired ? _members : [_members.first]).map((member) {
        final map = member.toMap();
        final user = map['users'] as Map<String, dynamic>;
        if (scenario == 'emoji') {
          user['avatar_url'] = member.userId == 'me' ? '🌻' : '🐢';
        }
        if (scenario == 'initials') user['avatar_url'] = null;
        if (scenario == 'photo' || scenario == 'photo_error') {
          user['avatar_url'] = member.userId == 'me'
              ? 'https://home-test.invalid/$scenario.png'
              : '🌻';
        }
        return MemberModel.fromMap(map);
      }).toList();
}

class _PhotoFile extends Fake implements fixture_file.File {
  @override
  Future<Uint8List> readAsBytes() => SynchronousFuture(
        File('test/fixtures/home_avatar_photo.png').readAsBytesSync(),
      );
}

class _PhotoCache extends Fake implements BaseCacheManager {
  @override
  Stream<FileResponse> getFileStream(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
  }) {
    if (url.contains('photo_error')) return Stream.error(StateError('offline'));
    return Stream.value(
      FileInfo(
        _PhotoFile(),
        FileSource.Cache,
        DateTime(2099),
        url,
      ),
    );
  }
}

class _Balances extends ExpenseBalances {
  final double amount;
  _Balances([this.amount = -48500]);
  @override
  Future<List<HouseholdBalanceModel>> build() async =>
      [HouseholdBalanceModel(userId: 'me', balance: amount)];
}

class _Feed extends CombinedFeedController {
  @override
  Future<List<FeedItemModel>> build() async => [];
}

final _tasks = [
  TaskModel(
    id: 'a',
    title: 'Regar las plantas',
    category: 'jardineria',
    assignedTo: 'me',
    status: TaskStatus.active,
    xpReward: 0,
    coinReward: 0,
    householdId: 'home',
    createdAt: DateTime(2026),
  ),
  TaskModel(
    id: 'b',
    title: 'Preparar la cena',
    category: 'cocina',
    assignedTo: 'partner',
    status: TaskStatus.active,
    xpReward: 0,
    coinReward: 0,
    householdId: 'home',
    createdAt: DateTime(2026),
  ),
];
void main() {
  test('every premium pair has one order-independent illustration', () {
    final scenes = <String>{};
    for (final a in PremiumAvatarArt.ids) {
      final first = 'premium://premium_$a';
      expect(File(PremiumAvatarArt.portraitFor(first)!).existsSync(), isTrue);
      for (final b in PremiumAvatarArt.ids) {
        final second = 'premium://premium_$b';
        final path = PremiumAvatarArt.duoFor(first, second)!;
        expect(path, PremiumAvatarArt.duoFor(second, first));
        expect(File(path).existsSync(), isTrue, reason: path);
        scenes.add(path);
      }
    }
    expect(scenes, hasLength(36));
    expect(PremiumAvatarArt.duoFor(null, '🌻'), isNull);
    expect(
      PremiumAvatarArt.portraitFor('https://example.com/photo.png'),
      isNull,
    );
    expect(PremiumAvatarArt.portraitFor('premium://unknown'), isNull);
  });
  setUpAll(() async {
    final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter';
    for (final entry in {
      'Outfit': [
        for (final w in [
          'Regular',
          'Medium',
          'SemiBold',
          'Bold',
          'ExtraBold',
          'Black',
        ])
          'assets/fonts/outfit/Outfit-$w.ttf',
      ],
      'MaterialIcons': [
        '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ],
      'sans-serif': [r'C:\Windows\Fonts\seguiemj.ttf'],
    }.entries) {
      final loader = FontLoader(entry.key);
      for (final path in entry.value) {
        if (File(path).existsSync()) {
          loader.addFont(
            Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
          );
        }
      }
      await loader.load();
    }
  });
  testWidgets('task action completes once and disables while busy',
      (tester) async {
    var calls = 0;
    Widget app(bool busy) => MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: CoupleHomeTaskRow(
              task: _tasks.first,
              assigned: null,
              currentUserId: 'me',
              busy: busy,
              onTap: () => calls++,
            ),
          ),
        );
    await tester.pumpWidget(app(false));
    await tester.tap(find.text('Regar las plantas'));
    expect(calls, 1);
    await tester.pumpWidget(app(true));
    await tester.tap(find.text('Regar las plantas'));
    expect(calls, 1);
    expect(tester.takeException(), isNull);
  });
  for (final scenario in [
    'light',
    'dark',
    'narrow',
    'english',
    'empty',
    'creditor',
    'shared',
    'waiting',
    'note',
    'emoji',
    'initials',
    'photo',
    'photo_error',
    'activity',
    'activity_dark',
    'activity_narrow',
  ]) {
    final dark = scenario == 'dark' || scenario == 'activity_dark';
    final waiting = scenario == 'waiting';
    final hasNote = scenario == 'note';
    final narrow = scenario == 'narrow' ||
        scenario == 'english' ||
        scenario == 'activity_narrow';
    final empty = scenario == 'empty';
    final creditor = scenario == 'creditor';
    final shared = scenario == 'shared';
    testWidgets('couple home $scenario', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(narrow ? 320 : 412, narrow ? 1800 : 1200);
      addTearDown(tester.view.reset);
      CachedNetworkImageProvider.defaultCacheManager = _PhotoCache();
      addTearDown(() {
        PaintingBinding.instance.imageCache.clear();
      });
      SharedPreferences.setMockInitialValues({tourFlagKey: true});
      final prefs = await SharedPreferences.getInstance();
      final shot = GlobalKey();
      var settingsOpened = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            generateInvitationCodeUseCaseProvider
                .overrideWithValue(_InviteCode()),
            currentUserIdProvider.overrideWithValue('me'),
            householdMembersProvider
                .overrideWith(() => _Members(!waiting, scenario)),
            householdCapabilitiesProvider.overrideWith(
              (ref) => const HouseholdCapabilities(type: HouseholdType.couple),
            ),
            currentHouseholdProvider.overrideWith(
              (ref) async => HouseholdModel(
                id: 'home',
                name: 'Home',
                householdType: 'couple',
                financeMode: shared ? 'shared' : 'divided',
              ),
            ),
            expenseBalancesProvider.overrideWith(
              () => _Balances(
                empty
                    ? 0
                    : creditor
                        ? 48500
                        : -48500,
              ),
            ),
            combinedFeedControllerProvider.overrideWith(_Feed.new),
            monthlyProjectionProvider.overrideWith(
              (ref) async =>
                  const MonthlyProjectionData(spent: 580500, pending: 0),
            ),
            todayTasksProvider.overrideWith(
              (ref) => AsyncData(empty ? <TaskModel>[] : _tasks),
            ),
            recentActivityProvider.overrideWith(
              (ref) => AsyncData(
                scenario.startsWith('activity')
                    ? [
                        {
                          'id': 'plant-activity',
                          'type': 'task',
                          'creator_id': 'me',
                          'created_at': DateTime.now()
                              .subtract(const Duration(minutes: 15))
                              .toIso8601String(),
                          'data': {
                            'task_title': 'Regar las plantas',
                            'category': 'jardineria',
                            'task_id': 'a',
                          },
                        },
                        {
                          'id': 'expense-activity',
                          'type': 'expense',
                          'creator_id': 'partner',
                          'created_at': DateTime.now()
                              .subtract(const Duration(hours: 1))
                              .toIso8601String(),
                          'data': {
                            'title': 'Supermercado',
                            'category': 'supermarket',
                            'amount': 12500,
                          },
                        },
                      ]
                    : [],
              ),
            ),
            pendingLoveNoteProvider.overrideWithValue(
              hasNote
                  ? LoveNoteModel(
                      id: 'note',
                      fromUserId: 'partner',
                      toUserId: 'me',
                      content: 'Que tengas un lindo día',
                      createdAt: DateTime(2026, 10, 4),
                    )
                  : null,
            ),
            categoriesProvider.overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            locale: Locale(scenario == 'english' ? 'en' : 'es'),
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(narrow ? 1.3 : 1)),
              child: child!,
            ),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
            home: RepaintBoundary(
              key: shot,
              child: Scaffold(
                body: HomeCoupleView(
                  householdId: 'home',
                  onRefresh: () async {},
                  onAvatarTap: () => settingsOpened++,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.runAsync(() async {
        for (final element in find.byType(CachedNetworkImage).evaluate()) {
          final image = element.widget as CachedNetworkImage;
          await precacheImage(
            ResizeImage.resizeIfNeeded(
              image.memCacheWidth,
              image.memCacheHeight,
              CachedNetworkImageProvider(image.imageUrl),
            ),
            element,
            onError: scenario == 'photo_error'
                ? (error, stack) => expect(error, isA<StateError>())
                : null,
          );
        }
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage(
            (element.widget as Image).image,
            element,
            onError: scenario == 'photo_error'
                ? (error, stack) => expect(error, isA<StateError>())
                : null,
          );
        }
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(tester.takeException(), isNull);
      if (scenario == 'photo') {
        expect(
          find.descendant(
            of: find.byType(CachedNetworkImage),
            matching: find.byWidgetPredicate(
              (widget) => widget is RawImage && widget.image != null,
            ),
          ),
          findsOneWidget,
        );
      }
      if (scenario == 'photo_error') expect(find.text('S'), findsOneWidget);
      if (const bool.fromEnvironment('CAPTURE_HOME')) {
        await tester.runAsync(() async {
          final boundary =
              shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage(pixelRatio: 2);
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File('build/couple_home/$scenario.png')
            ..createSync(recursive: true)
            ..writeAsBytesSync(data!.buffer.asUint8List());
        });
      }
      final homeContext = tester.element(find.byType(HomeCoupleView));
      final t = AppLocalizations.of(homeContext);
      final container = ProviderScope.containerOf(homeContext);
      expect(find.byType(CoupleHomeWelcome), findsOneWidget);
      expect(find.text(t.coupleHomeWelcomeTitle), findsOneWidget);
      expect(
        find.text(t.coupleWeekMoneySettle),
        empty || creditor || shared || waiting ? findsNothing : findsOneWidget,
      );
      if (waiting) expect(find.byType(PartnerInviteCard), findsOneWidget);
      if (hasNote) expect(find.byType(LoveNoteEnvelope), findsOneWidget);
      if (empty) expect(find.text(t.homeAllDoneToday), findsOneWidget);
      if (creditor) {
        expect(find.text(t.coupleSettleCreditorHint('Mati')), findsOneWidget);
      }
      await tester.tap(find.byTooltip(t.settingsAppBarTitle));
      expect(settingsOpened, 1);
      expect(
        find.text(t.homeCoupleActivityTitle),
        scenario.startsWith('activity') ? findsOneWidget : findsNothing,
      );
      expect(
        find.byType(CoupleActivityTile),
        scenario.startsWith('activity') ? findsNWidgets(2) : findsNothing,
      );
      expect(find.byIcon(Icons.check_rounded), findsNothing);
      expect(find.text(t.coupleHomeAddShopping), findsNothing);
      expect(find.text(t.coupleHomeAddExpense), findsNothing);
      expect(find.text(t.coupleHomeLeaveNote), findsNothing);
      if (!waiting) {
        expect(
          tester.getTopLeft(find.byType(CoupleHomeBalance)).dy,
          lessThan(tester.getTopLeft(find.text(t.homeCoupleTasksTitle)).dy),
        );
      }
      await tester.ensureVisible(find.text(t.homeViewWeekButton));
      await tester.tap(find.text(t.homeViewWeekButton));
      expect(
        container.read(bottomNavIndexProvider),
        indexForMainTab(
          const HouseholdCapabilities(type: HouseholdType.couple),
          MainTab.tasks,
        ),
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    });
  }
}
