import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// En pareja solo quien debe registra el pago (se salda al instante, el otro
/// no confirma nada). Antes quien tenía plata a favor también veía
/// "Registrar pago", y el botón tapaba el final de un monto largo.
Future<AppLocalizations> _pump(
  WidgetTester tester, {
  required double balance,
  required VoidCallback onSettle,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  await tester.binding.setSurfaceSize(const Size(320, 640));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: MaterialApp(
        locale: const Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: BalanceCard(
              coins: 0,
              xp: 0,
              showGamification: false,
              userBalance: balance,
              partnerName: 'Rocio',
              onSettle: onSettle,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump(const Duration(seconds: 1));
  return AppLocalizations.of(tester.element(find.byType(BalanceCard)));
}

void main() {
  testWidgets('quien debe ve "Ya pagué" y al tocarlo salda', (tester) async {
    var settled = 0;
    final t = await _pump(
      tester,
      balance: -130607,
      onSettle: () => settled++,
    );

    expect(find.text(t.balanceCardSettleButton), findsOneWidget);
    expect(find.text(t.coupleSettleCreditorHint('Rocio')), findsNothing);

    await tester.tap(find.text(t.balanceCardSettleButton));
    expect(settled, 1);
    // El monto largo se achica: sin overflow al lado del botón en 320 dp.
    expect(tester.takeException(), isNull);
  });

  testWidgets('quien tiene plata a favor no tiene botón, solo la aclaración',
      (tester) async {
    final t = await _pump(tester, balance: 130607, onSettle: () {});

    expect(find.text(t.balanceCardSettleButton), findsNothing);
    expect(find.text(t.coupleSettleCreditorHint('Rocio')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
