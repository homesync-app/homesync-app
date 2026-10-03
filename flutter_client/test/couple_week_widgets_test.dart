import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/services/premium_avatar_motion_cache.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_plan.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_money_card.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_plans_section.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_week_widgets.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

// Corre los bloques de la pestaña Pareja con datos fijos: que no desborden a
// 320 dp con texto 1.3x y que cada estado muestre lo que tiene que mostrar.
//
// Con --dart-define=CAPTURE_COUPLE=true además guarda capturas en
// build/couple_preview/ (Outfit, íconos y emoji reales) para revisar el
// diseño sin iniciar sesión:
//   flutter test test/couple_week_widgets_test.dart --dart-define=CAPTURE_COUPLE=true

const _capture = bool.fromEnvironment('CAPTURE_COUPLE');
const _me = 'user-me';
const _partner = 'user-partner';
final _currency = supportedCurrencies.first;

const _mePerson = CouplePerson(
  userId: _me,
  label: 'Vos',
  avatarName: 'Sofi',
  avatarUrl: 'premium://premium_orange_cat',
);
const _partnerPerson = CouplePerson(
  userId: _partner,
  label: 'Mati',
  avatarName: 'Mati',
  avatarUrl: 'premium://premium_market_dog',
);

HouseholdContribution _contribution({
  required int mine,
  required int theirs,
  List<Map<String, dynamic>> categories = const [],
}) {
  return HouseholdContribution.fromMap({
    'household_id': 'h1',
    'week_start': '2026-09-28T00:00:00Z',
    'week_end': '2026-10-05T00:00:00Z',
    'total_tasks': mine + theirs,
    'rhythm_weeks': 3,
    'rhythm_window': 4,
    'members': [
      {
        'user_id': _me,
        'name': 'Sofi',
        'tasks_done': mine,
        'demanding_done': mine > 0 ? 1 : 0,
      },
      {
        'user_id': _partner,
        'name': 'Mati',
        'tasks_done': theirs,
        'demanding_done': theirs > 1 ? 2 : 0,
      },
    ],
    'categories': categories,
  });
}

/// La pestaña armada con los mismos bloques y espacios que
/// `CoupleWeekScreen`, sin providers de red.
class _CoupleWeekPreview extends StatelessWidget {
  final HouseholdContribution contribution;
  final bool sharedEconomy;
  final double myBalance;
  final CoupleMonthMoney month;
  final bool completed;

  const _CoupleWeekPreview({
    required this.contribution,
    required this.sharedEconomy,
    required this.myBalance,
    required this.month,
    this.completed = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final reading = CoupleWeekReading.from(contribution, currentUserId: _me);
    final mine = contribution.members.firstWhere((m) => m.userId == _me);
    final theirs = contribution.members.firstWhere((m) => m.userId == _partner);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.md,
        AppInsets.screenHorizontal,
        AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.householdSocialTabLabel('couple'),
            style: AppTypography.screenTitle.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CouplePlansView(
            selected: CouplePlan.movies,
            progress: completed
                ? [
                    CouplePlanProgress(
                      planId: 'movies',
                      saved: true,
                      completedAt: DateTime(2026, 10, 3),
                    ),
                  ]
                : const [],
            note:
                CoupleNoteRow(partnerLabel: _partnerPerson.label, onTap: () {}),
            busy: false,
            onAction: (_) {},
            onNext: () {},
            onSelect: (_) {},
            onSaved: () {},
          ),
          const SizedBox(height: AppSpacing.lg),
          CoupleSplitCard(
            contribution: contribution,
            me: CoupleSplitPerson(
              userId: _me,
              label: _mePerson.label,
              avatarName: _mePerson.avatarName,
              avatarUrl: _mePerson.avatarUrl,
              tasksDone: mine.tasksDone,
              demandingDone: mine.demandingDone,
            ),
            partner: CoupleSplitPerson(
              userId: _partner,
              label: _partnerPerson.label,
              avatarName: _partnerPerson.avatarName,
              avatarUrl: _partnerPerson.avatarUrl,
              tasksDone: theirs.tasksDone,
              demandingDone: theirs.demandingDone,
            ),
            reading: reading,
            weekLabel: t.coupleWeekOf('28 de septiembre'),
            categoryLabel: reading.category == null ? null : 'Cocina',
            tasksRemaining: 3,
            overdue: 0,
            onSeeTasks: () {},
          ),
          const SizedBox(height: AppSpacing.xl),
          CoupleMoneySectionHeader(
            onAction: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          CoupleMoneyCard(
            sharedEconomy: sharedEconomy,
            balance: CoupleBalanceView.fromMyBalance(myBalance),
            month: month,
            me: _mePerson,
            partner: _partnerPerson,
            formatAmount: _currency.format,
            onSettle: () {},
          ),
        ],
      ),
    );
  }
}

final _shotKey = GlobalKey();

Widget _app(
  Widget child, {
  bool dark = false,
  double textScale = 1.0,
  Locale locale = const Locale('es'),
}) {
  return ProviderScope(
    overrides: [
      premiumAvatarMotionPathsProvider.overrideWith((ref, id) async => null),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: dark ? AppTheme.darkTheme() : AppTheme.lightTheme(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, app) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(textScale),
        ),
        child: app!,
      ),
      home: Builder(
        builder: (context) => ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: RepaintBoundary(
              key: _shotKey,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _loadFont(String family, List<String> paths) async {
  final files = paths.map(File.new).where((file) => file.existsSync());
  if (files.isEmpty) return;
  final loader = FontLoader(family);
  for (final file in files) {
    loader.addFont(Future.value(ByteData.sublistView(file.readAsBytesSync())));
  }
  await loader.load();
}

/// El motor de test dibuja cada glifo de 1 em de ancho: para medir lo que ve
/// la gente hace falta Outfit. Íconos y emoji solo hacen falta para capturas.
Future<void> _loadFonts() async {
  await _loadFont('Outfit', [
    for (final weight in [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
      'Black',
    ])
      'assets/fonts/outfit/Outfit-$weight.ttf',
  ]);
  if (!_capture) return;
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? r'C:\flutter';
  await _loadFont('MaterialIcons', [
    '$flutterRoot/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
  ]);
  // El tema cae en 'sans-serif' para lo que Outfit no tiene: ahí van los emoji.
  await _loadFont('sans-serif', [r'C:\Windows\Fonts\seguiemj.ttf']);
}

Future<void> _settleImages(WidgetTester tester) async {
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      final image = element.widget as Image;
      await precacheImage(image.image, element);
    }
  });
  await tester.pumpAndSettle();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  if (!_capture) return;
  await _settleImages(tester);
  await tester.runAsync(() async {
    final boundary =
        _shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.5);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final out = File('build/couple_preview/$name.png')
      ..createSync(recursive: true);
    out.writeAsBytesSync(bytes!.buffer.asUint8List());
  });
}

void _setViewport(WidgetTester tester, double width) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 2600);
  addTearDown(tester.view.reset);
}

final _skewedWeek = _contribution(
  mine: 3,
  theirs: 7,
  categories: [
    {
      'category': 'cocina',
      'total': 5,
      'dominant_user_id': _partner,
      'dominant_name': 'Mati',
      'dominant_count': 5,
      'skewed': true,
    },
  ],
);

void main() {
  setUpAll(_loadFonts);

  testWidgets('planes primero, reparto sin barra ni aprobaciones',
      (tester) async {
    _setViewport(tester, 412);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _skewedWeek,
          sharedEconomy: false,
          myBalance: -48500,
          month: const CoupleMonthMoney(mePaid: 1118000, partnerPaid: 952000),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('En casa, en equipo'), findsOneWidget);
    expect(
      find.text('Cocina: esta semana lo hizo casi todo Mati.'),
      findsOneWidget,
    );
    expect(find.text('Lo hicimos'), findsOneWidget);
    expect(find.text('Ofrecer una mano'), findsNothing);
    expect(find.text('Le debés a Mati'), findsOneWidget);
    expect(find.text(_currency.format(48500)), findsOneWidget);
    expect(find.text('Ya pagué'), findsOneWidget);
    expect(find.text('Te toca responder'), findsNothing);
    expect(find.text('Cine en casa'), findsOneWidget);
    await _shoot(tester, '01_semana_despareja');
  });

  testWidgets('semana vacía: ideas para arrancar y economía integrada',
      (tester) async {
    _setViewport(tester, 412);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _contribution(mine: 0, theirs: 0),
          sharedEconomy: true,
          myBalance: 0,
          month: const CoupleMonthMoney(mePaid: 312000, partnerPaid: 268500),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gastaron entre los dos este mes'), findsOneWidget);
    expect(find.text('Lo que pagó cada uno este mes'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
    expect(find.text('Noche de pelis'), findsOneWidget);
    await _shoot(tester, '02_semana_vacia');
  });

  testWidgets('modo oscuro', (tester) async {
    _setViewport(tester, 412);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _contribution(mine: 5, theirs: 4),
          sharedEconomy: false,
          myBalance: 23000,
          month: const CoupleMonthMoney(mePaid: 640000, partnerPaid: 585000),
        ),
        dark: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mati te debe'), findsOneWidget);
    expect(find.text('Ya pagué'), findsNothing);
    await _shoot(tester, '03_modo_oscuro');
  });

  testWidgets('no desborda a 320 dp con texto 1.3x', (tester) async {
    _setViewport(tester, 320);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _skewedWeek,
          sharedEconomy: false,
          myBalance: -1250000,
          month: const CoupleMonthMoney(mePaid: 11180000, partnerPaid: 9520000),
        ),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    await _shoot(tester, '04_angosta_texto_grande');
  });

  testWidgets('album earned state in English at 320 dp and 1.3x',
      (tester) async {
    _setViewport(tester, 320);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _contribution(mine: 5, theirs: 4),
          sharedEconomy: false,
          myBalance: 0,
          month: const CoupleMonthMoney(mePaid: 0, partnerPaid: 0),
          completed: true,
        ),
        locale: const Locale('en'),
        textScale: 1.3,
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('One more memory!'), findsOneWidget);
    expect(find.text('1 of 5'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await _shoot(tester, '05_album_english');
  });

  testWidgets('earned stamp, all artwork and actions at normal size',
      (tester) async {
    _setViewport(tester, 412);
    await tester.pumpWidget(
      _app(
        _CoupleWeekPreview(
          contribution: _contribution(mine: 5, theirs: 4),
          sharedEconomy: false,
          myBalance: 0,
          month: const CoupleMonthMoney(mePaid: 80000, partnerPaid: 80000),
          completed: true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 de 5'), findsOneWidget);
    await _shoot(tester, '06_album_logro');
  });
}
