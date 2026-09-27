import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_components.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_segmented_tabs.dart';
import 'package:homesync_client/shared/widgets/custom_bottom_nav.dart';
import 'package:homesync_client/shared/widgets/semantic_tap.dart';

Widget _app(Widget child, {double textScale = 1.0}) {
  return MaterialApp(
    theme: AppTheme.lightTheme(),
    locale: const Locale('es'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, app) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
      ),
      child: app!,
    ),
    home: Scaffold(body: child),
  );
}

/// The test engine draws every glyph 1 em wide, about twice as wide as
/// Outfit. Layout checks load the real font so they measure what users see.
Future<void> _loadAppFont() async {
  final loader = FontLoader('Outfit');
  for (final weight in [
    'Regular',
    'Medium',
    'SemiBold',
    'Bold',
    'ExtraBold',
    'Black',
  ]) {
    final bytes =
        File('assets/fonts/outfit/Outfit-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

SemanticsNode _node(SemanticsFinder finder) => finder.evaluate().single;

void main() {
  group('AnimatedPress', () {
    testWidgets('is an enabled button that reads its text and taps',
        (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Center(
            child: AnimatedPress(
              onTap: () => taps++,
              child: const Text('Guardar'),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Guardar')),
        isSemantics(
          label: 'Guardar',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      tester.semantics.tap(find.semantics.byLabel('Guardar'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('without a callback it reads as a disabled button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(const Center(child: AnimatedPress(child: Text('Guardar')))),
      );

      expect(
        tester.getSemantics(find.text('Guardar')),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );
      handle.dispose();
    });

    testWidgets('an icon-only press reads its label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Center(
            child: AnimatedPress(
              semanticLabel: 'Configuración',
              onTap: () {},
              child: const Icon(Icons.settings_outlined),
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('Configuración'), findsOne);
      expect(
        tester.getSemantics(find.byIcon(Icons.settings_outlined)),
        isSemantics(isButton: true, label: 'Configuración'),
      );
      handle.dispose();
    });

    testWidgets('a decorative Material button inside reads as one button',
        (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Center(
            child: AnimatedPress(
              semanticLabel: 'Crear tarea',
              excludeChildSemantics: true,
              onTap: () => taps++,
              child: const ElevatedButton(
                onPressed: null,
                child: Text('Crear tarea'),
              ),
            ),
          ),
        ),
      );

      final press = find.semantics.byLabel('Crear tarea');
      expect(press, findsOne);
      expect(
        _node(press),
        isSemantics(isButton: true, isEnabled: true, hasTapAction: true),
      );
      tester.semantics.tap(press);
      await tester.pumpAndSettle();
      expect(taps, 1);
      handle.dispose();
    });

    testWidgets('segmented tabs expose which tab is active', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          DefaultTabController(
            length: 2,
            child: Builder(
              builder: (context) => AppSegmentedTabs(
                controller: DefaultTabController.of(context),
                labels: const ['Movimientos', 'Ahorro'],
              ),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Movimientos')),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        tester.getSemantics(find.text('Ahorro')),
        isSemantics(isButton: true, isSelected: false),
      );
      handle.dispose();
    });
  });

  group('SemanticTap', () {
    testWidgets('a checked item reads as a checkbox, not a button',
        (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          Center(
            child: SemanticTap(
              checked: true,
              onTap: () {},
              child: const Text('Lavar los platos'),
            ),
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Lavar los platos')),
        isSemantics(
          hasCheckedState: true,
          isChecked: true,
          isButton: false,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    testWidgets('a label with excluded children still taps', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        _app(
          Center(
            child: SemanticTap(
              label: 'Avatar',
              excludeChildSemantics: true,
              onTap: () => taps++,
              child: const Text('AB'),
            ),
          ),
        ),
      );

      expect(find.semantics.byLabel('AB'), findsNothing);
      tester.semantics.tap(find.semantics.byLabel('Avatar'));
      await tester.pumpAndSettle();
      expect(taps, 1);
      handle.dispose();
    });
  });

  group('Settings selectors', () {
    testWidgets('theme mode options expose the active one', (tester) async {
      final handle = tester.ensureSemantics();
      ThemeMode? picked;
      await tester.pumpWidget(
        _app(
          SettingsThemeModeSelector(
            currentMode: ThemeMode.dark,
            onModeChanged: (mode) => picked = mode,
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Oscuro')),
        isSemantics(
          isButton: true,
          isSelected: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      expect(
        tester.getSemantics(find.text('Claro')),
        isSemantics(isSelected: false),
      );
      tester.semantics.tap(find.semantics.byLabel('Claro'));
      await tester.pumpAndSettle();
      expect(picked, ThemeMode.light);
      handle.dispose();
    });

    testWidgets('currency chips read the code and name once', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SettingsCurrencyCard(
            currentCurrency: currencyByCode('ARS'),
            onCurrencyChanged: (_) {},
          ),
        ),
      );

      final ars = find.semantics.byLabel('ARS · Peso argentino');
      expect(ars, findsOne);
      expect(
        _node(ars),
        isSemantics(isButton: true, isSelected: true),
      );
      expect(
        _node(find.semantics.byLabel('USD · Dólar estadounidense')),
        isSemantics(isSelected: false),
      );
      handle.dispose();
    });

    testWidgets('language options expose the active one', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        _app(
          SettingsLanguageCard(
            currentLocale: const Locale('en'),
            onLocaleChanged: (_) {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.text('Inglés')),
        isSemantics(isSelected: true, isInMutuallyExclusiveGroup: true),
      );
      expect(
        tester.getSemantics(find.text('Español')),
        isSemantics(isSelected: false),
      );
      handle.dispose();
    });
  });

  group('Text at 1.3x, the most the app allows', () {
    setUpAll(_loadAppFont);

    testWidgets('settings selectors fit a 320 dp wide screen', (tester) async {
      tester.view.physicalSize = const Size(320, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SettingsThemeModeSelector(
                  currentMode: ThemeMode.system,
                  onModeChanged: (_) {},
                ),
                const SizedBox(height: 16),
                SettingsCurrencyCard(
                  currentCurrency: currencyByCode('USD'),
                  onCurrencyChanged: (_) {},
                ),
                const SizedBox(height: 16),
                SettingsLanguageCard(
                  currentLocale: null,
                  onLocaleChanged: (_) {},
                ),
              ],
            ),
          ),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('the bottom nav fits five tabs on 320 dp', (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const labels = ['Inicio', 'Tareas', 'Finanzas', 'Compras', 'Pareja'];
      await tester.pumpWidget(
        _app(
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNav(
              currentIndex: 0,
              onTap: (_) {},
              items: [
                for (var i = 0; i < labels.length; i++)
                  CustomBottomNavItem(
                    index: i,
                    icon: Icons.circle_outlined,
                    selectedIcon: Icons.circle,
                    label: labels[i],
                  ),
              ],
            ),
          ),
          textScale: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
