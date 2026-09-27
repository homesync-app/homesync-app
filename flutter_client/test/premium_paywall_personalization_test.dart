import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

class _FakePremiumNotifier extends PremiumNotifier {
  @override
  Future<bool> build() async => false;
}

class _FakeMembers extends HouseholdMembersNotifier {
  _FakeMembers(this.members);

  final List<MemberModel> members;

  @override
  Future<List<MemberModel>> build() async => members;
}

MemberModel _member(String userId, String fullName) => MemberModel(
      id: 'm-$userId',
      userId: userId,
      householdId: 'h1',
      role: 'member',
      joinedAt: DateTime(2026),
      fullName: fullName,
      type: MemberType.parent,
    );

rc.Package _package(String id, rc.PackageType type, String price) {
  const context = rc.PresentedOfferingContext('household', null, null);
  return rc.Package(
    id,
    type,
    rc.StoreProduct('premium_household:$id', '', '', 0, price, 'USD'),
    context,
  );
}

Future<AppLocalizations> _pumpPaywall(
  WidgetTester tester, {
  required HouseholdModel household,
  required List<MemberModel> members,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 860));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        premiumProvider.overrideWith(_FakePremiumNotifier.new),
        premiumProductsProvider.overrideWith(
          (ref) async => [
            _package('annual', rc.PackageType.annual, r'US$ 29.99'),
            _package('monthly', rc.PackageType.monthly, r'US$ 3.99'),
          ],
        ),
        currentHouseholdProvider.overrideWith((ref) async => household),
        householdMembersProvider.overrideWith(() => _FakeMembers(members)),
        currentUserIdProvider.overrideWithValue('me'),
      ],
      child: const MaterialApp(
        locale: Locale('es'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PremiumPaywallScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pump(const Duration(seconds: 2));
  return AppLocalizations.of(tester.element(find.byType(Scaffold).first));
}

void main() {
  testWidgets('pareja sin nombre propio: badge con los dos nombres',
      (tester) async {
    final t = await _pumpPaywall(
      tester,
      household: const HouseholdModel(
        id: 'h1',
        name: 'Mi Hogar',
        householdType: 'couple',
      ),
      members: [_member('partner', 'Sofía Gómez'), _member('me', 'Matías')],
    );

    // Primero el usuario actual, aunque venga segundo en la lista.
    expect(
      find.text(t.premiumPaywallEyebrowFor('Matías y Sofía')),
      findsOneWidget,
    );
    expect(find.text(t.premiumPaywallTitle('couple')), findsOneWidget);
    expect(find.text(t.premiumPaywallSubtitle('couple')), findsOneWidget);

    // El anual viene elegido y el botón dice cuánto se paga.
    expect(
      find.text(t.premiumActivateAnnualCta(r'US$ 29.99')),
      findsOneWidget,
    );
    await tester.tap(find.text(t.premiumMonthlyPlan));
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text(t.premiumActivateMonthlyCta(r'US$ 3.99')),
      findsOneWidget,
    );

    expect(find.text(t.premiumLegalTerms), findsOneWidget);
    expect(find.text(t.premiumLegalPrivacy), findsOneWidget);
  });

  testWidgets('hogar con nombre propio: el badge usa ese nombre',
      (tester) async {
    final t = await _pumpPaywall(
      tester,
      household: const HouseholdModel(
        id: 'h1',
        name: 'Casa Pérez',
        householdType: 'family',
      ),
      members: [_member('me', 'Blas'), _member('kid', 'Tomi')],
    );

    expect(
      find.text(t.premiumPaywallEyebrowFor('Casa Pérez')),
      findsOneWidget,
    );
    expect(find.text(t.premiumPaywallTitle('family')), findsOneWidget);
  });

  testWidgets('solo con nombre por defecto: badge genérico', (tester) async {
    final t = await _pumpPaywall(
      tester,
      household: const HouseholdModel(
        id: 'h1',
        name: 'Mi Hogar',
        householdType: 'solo',
      ),
      members: [_member('me', 'Blas')],
    );

    expect(find.text(t.premiumPaywallEyebrow), findsOneWidget);
    expect(find.text(t.premiumPaywallTitle('solo')), findsOneWidget);
  });
}
