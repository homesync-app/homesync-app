import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

class _FakePremiumNotifier extends PremiumNotifier {
  @override
  Future<bool> build() async => false;
}

void main() {
  testWidgets('paywall: hero arriba y panel de compra pegado abajo',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          premiumProvider.overrideWith(_FakePremiumNotifier.new),
          premiumProductsProvider.overrideWith(
            (ref) async => <rc.Package>[],
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PremiumPaywallScreen(),
        ),
      ),
    );
    // Resolver providers async + animaciones de entrada.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 2));

    final heroFinder = find.byType(PremiumAnimatedAvatar);
    expect(heroFinder, findsOneWidget);
    final heroRect = tester.getRect(heroFinder);
    // ignore: avoid_print
    print('hero rect: $heroRect');

    // Sin productos el panel explica qué pasó y deja salida: reintentar o
    // restaurar (antes era un "Prueba gratis" sin acción en producción).
    final t = AppLocalizations.of(tester.element(heroFinder));
    final marker = find.text(t.premiumProductsUnavailableTitle);
    expect(marker, findsOneWidget);
    expect(find.text(t.commonRetry), findsOneWidget);
    expect(find.text(t.premiumRestorePurchases), findsOneWidget);
    final panelRect = tester.getRect(marker);
    // ignore: avoid_print
    print('panel marker rect: $panelRect');

    // El hero debe estar en el tercio superior y el panel en el inferior.
    expect(heroRect.top, lessThan(300));
    expect(panelRect.top, greaterThan(400));
  });
}
