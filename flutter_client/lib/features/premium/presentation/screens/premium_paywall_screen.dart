import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/mascot_motion_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

const String _kMascotDir = 'assets/images/premium_3d_avatars';
const Map<AvatarMotion, String> _kMascotMotions = {
  AvatarMotion.idle: '$_kMascotDir/animated/premium_orange_cat.webp',
  AvatarMotion.tada: '$_kMascotDir/animated/premium_orange_cat_tada.webp',
};
const String _kMascotFallback = '$_kMascotDir/premium_orange_cat.webp';

class PremiumPaywallScreen extends ConsumerStatefulWidget {
  const PremiumPaywallScreen({super.key});

  @override
  ConsumerState<PremiumPaywallScreen> createState() =>
      _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends ConsumerState<PremiumPaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(analyticsServiceProvider).trackPaywallOpened(
            source: 'premium_screen',
            variant: 'full_screen',
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final productsAsync = ref.watch(premiumProductsProvider);
    final isPremium = ref.watch(premiumProvider).value ?? false;

    return Scaffold(
      backgroundColor: theme.background,
      // El contenido arranca detras del AppBar (solo tiene la X): sin esto el
      // hero queda ~56dp mas abajo y toda la pantalla se siente "hundida".
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: t.premiumPaywallCloseTooltip,
          icon: Icon(Icons.close, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: theme.isDarkMode
                      ? [
                          theme.background,
                          AppColors.primary.withValues(alpha: 0.12),
                          theme.surface,
                        ]
                      : const [
                          AppColors.background,
                          AppColors.primaryLight,
                          AppColors.surface,
                        ],
                ),
              ),
            ),
          ),
          // Sin halo detras del hero: cualquier radial dorado sutil genera
          // banding en pantallas reales y se lee como un "recuadro" que no
          // se integra con el fondo (feedback del owner, 2026-07-06).
          // El contenido scrollea a pantalla completa y se desliza POR DEBAJO
          // del panel de compra flotante: sin costura dura entre ambos.
          SafeArea(
            top: false,
            bottom: isPremium,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                // Debajo de la barra de estado, solapado con la fila de la X
                // para que el hero arranque bien arriba.
                MediaQuery.paddingOf(context).top + 8,
                20,
                isPremium ? 24 : 320,
              ),
              child: Column(
                children: [
                  if (isPremium)
                    const _PremiumActiveContent()
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.04)
                  else ...[
                    const _HeroHeader()
                        .animate()
                        .fadeIn(duration: 350.ms)
                        .slideY(begin: 0.06),
                    const SizedBox(height: 22),
                    const _BenefitsCard()
                        .animate()
                        .fadeIn(delay: 140.ms, duration: 350.ms)
                        .slideY(begin: 0.06),
                  ],
                ],
              ),
            ),
          ),
          if (!isPremium)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: productsAsync.when(
                data: (products) => _PurchasePanel(products: products),
                loading: () => const _PanelShell(
                  child: SizedBox(
                    height: 160,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                error: (err, _) => _PanelShell(
                  child: _StoreError(error: err.toString()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Mascota del paywall: entra con el ta-da, "respira" en reposo y repite el
/// gesto al tocarla.
class _HeroMascot extends StatefulWidget {
  const _HeroMascot();

  @override
  State<_HeroMascot> createState() => _HeroMascotState();
}

class _HeroMascotState extends State<_HeroMascot> {
  final PremiumAvatarMotionController _motion = PremiumAvatarMotionController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        AppHaptics.tap();
        _motion.play(AvatarMotion.tada);
      },
      child: SizedBox(
        width: 148,
        height: 148,
        child: PremiumAnimatedAvatar(
          motionAssets: _kMascotMotions,
          fallbackAsset: _kMascotFallback,
          ambientMotion: AvatarMotion.tada,
          // Deja terminar la transicion de ruta + fade del hero antes del
          // ta-da, para que el gesto se vea completo y no "cortado".
          arrivalDelay: const Duration(milliseconds: 550),
          breathing: true,
          controller: _motion,
          size: 148,
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        // Brand mascot instead of a generic medallion: the hero moment.
        const _HeroMascot()
            .animate()
            .scale(
              begin: const Offset(0.86, 0.86),
              end: const Offset(1, 1),
              duration: 500.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 250.ms),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.32),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.accentGold,
                size: 14,
              ),
              const SizedBox(width: 5),
              Text(
                t.premiumPaywallEyebrow,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.premiumPaywallTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
            letterSpacing: -0.7,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            t.premiumPaywallSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.32,
            ),
          ),
        ),
      ],
    );
  }
}

/// All the benefits grouped in a single soft card, like modern paywalls do,
/// instead of a stack of setting-like rows.
class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final benefits = [
      (
        Icons.event_repeat_rounded,
        AppColors.primary,
        t.premiumBenefitRecurringPayments,
        t.premiumBenefitRecurringPaymentsDesc,
      ),
      (
        Icons.shopping_cart_checkout_rounded,
        AppColors.sage,
        t.premiumBenefitShoppingFinanceSync,
        t.premiumBenefitShoppingFinanceSyncDesc,
      ),
      (
        Icons.insights_rounded,
        AppColors.accentBlue,
        t.premiumBenefitAdvancedStats,
        t.premiumBenefitAdvancedStatsDesc,
      ),
      (
        Icons.palette_rounded,
        AppColors.accentPurple,
        t.premiumBenefitFullCustomization,
        t.premiumBenefitFullCustomizationDesc,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.isDarkMode
            ? theme.surface.withValues(alpha: 0.74)
            : Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(color: theme.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < benefits.length; i++) ...[
            _BenefitRow(
              icon: benefits[i].$1,
              color: benefits[i].$2,
              title: benefits[i].$3,
              desc: benefits[i].$4,
            ),
            if (i < benefits.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                indent: 62,
                color: theme.border.withValues(alpha: 0.3),
              ),
          ],
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _BenefitRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Surface pinned to the bottom that holds the whole purchase flow so the
/// plans and the CTA never scroll away.
class _PanelShell extends StatelessWidget {
  final Widget child;

  const _PanelShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    const radius = BorderRadius.vertical(top: Radius.circular(AppRadii.xxl));
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.isDarkMode ? 0.5 : 0.16,
            ),
            blurRadius: 36,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      // Frosted glass: se ve el contenido difuminado pasar por debajo, como
      // en los sheets de iOS — separa el panel del fondo sin costura dura.
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            color: theme.isDarkMode
                ? theme.surface.withValues(alpha: 0.88)
                : Colors.white.withValues(alpha: 0.86),
            // El panel flota fuera del SafeArea: absorbe el inset inferior
            // para que su fondo llegue hasta el borde de la pantalla.
            child: SafeArea(top: false, child: child),
          ),
        ),
      ),
    );
  }
}

class _PurchasePanel extends ConsumerStatefulWidget {
  final List<rc.Package> products;

  const _PurchasePanel({required this.products});

  @override
  ConsumerState<_PurchasePanel> createState() => _PurchasePanelState();
}

class _PurchasePanelState extends ConsumerState<_PurchasePanel> {
  rc.Package? _selectedPackage;

  bool _isAnnual(rc.Package package) {
    return package.packageType == rc.PackageType.annual ||
        package.storeProduct.identifier.contains(':annual');
  }

  rc.Package _defaultPackage() {
    return widget.products.firstWhere(
      _isAnnual,
      orElse: () => widget.products.first,
    );
  }

  @override
  void didUpdateWidget(covariant _PurchasePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.isEmpty) return;
    final selectedId = _selectedPackage?.identifier;
    final stillExists = widget.products.any(
      (package) => package.identifier == selectedId,
    );
    if (!stillExists) _selectedPackage = _defaultPackage();
  }

  Future<void> _buy(rc.Package package) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final isPremium =
          await ref.read(premiumProvider.notifier).buyProduct(package);
      if (isPremium && mounted) {
        AppHaptics.celebrate();
        // La mascota del home festeja la compra al volver (no-op si el
        // header no esta montado; mismo patron que saldar deuda).
        ref.read(homeMascotMotionProvider).play(AvatarMotion.celebrate);
        Navigator.pop(context);
      }
    } catch (_) {
      // Purchase errors (billing unavailable, DEVELOPER_ERROR on
      // non-Play builds, region issues, etc.) must never crash the
      // app — buyProduct already logs them. Show a friendly notice.
      messenger.showSnackBar(SnackBar(content: Text(t.commonError)));
    }
  }

  Future<void> _restore() async {
    final isPremium =
        await ref.read(premiumProvider.notifier).restorePurchases();
    if (isPremium && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    if (widget.products.isEmpty) {
      return _PanelShell(
        child: Column(
          children: [
            Text(
              t.premiumFreeTrialAvailable,
              style: TextStyle(
                color: theme.textPrimary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              onPressed: AppEnvironment.isProduction
                  ? null
                  : () async {
                      await ref
                          .read(premiumProvider.notifier)
                          .togglePremiumMock();
                      if (context.mounted) Navigator.pop(context);
                    },
              child: Text(t.premiumActivateButton),
            ),
            if (!AppEnvironment.isProduction) ...[
              const SizedBox(height: 8),
              Text(
                t.premiumTestingModeLabel,
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    final selectedPackage = _selectedPackage ?? _defaultPackage();
    final sortedProducts = [...widget.products]..sort((a, b) {
        final aAnnual = _isAnnual(a);
        final bAnnual = _isAnnual(b);
        if (aAnnual == bAnnual) return 0;
        return aAnnual ? -1 : 1;
      });

    return _PanelShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Extra headroom so the floating badge of the annual card breathes.
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < sortedProducts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: _PlanCard(
                      package: sortedProducts[i],
                      isAnnual: _isAnnual(sortedProducts[i]),
                      isSelected: sortedProducts[i].identifier ==
                          selectedPackage.identifier,
                      onTap: () {
                        AppHaptics.selection();
                        setState(
                          () => _selectedPackage = sortedProducts[i],
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AnimatedPress(
            scale: 0.98,
            haptic: AppPressHaptic.light,
            onTap: () => _buy(selectedPackage),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(AppRadii.pill),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.34),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Text(
                t.premiumContinueWithPlan,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t.premiumCancelAnytime,
                style: TextStyle(
                  color: theme.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '  ·  ',
                style: TextStyle(color: theme.textMuted, fontSize: 11.5),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: _restore,
                child: Text(
                  t.premiumRestorePurchases,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final rc.Package package;
  final bool isSelected;
  final bool isAnnual;
  final VoidCallback onTap;

  const _PlanCard({
    required this.package,
    required this.isSelected,
    required this.isAnnual,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final product = package.storeProduct;
    final monthlyEquivalent = isAnnual
        ? product.pricePerMonthString ?? _formattedMonthlyEquivalent(product)
        : null;
    final subtitle = monthlyEquivalent != null
        ? t.premiumMonthlyEquivalent(monthlyEquivalent)
        : (isAnnual ? t.premiumBilledAnnually : t.premiumBilledMonthly);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(
                      alpha: theme.isDarkMode ? 0.16 : 0.07,
                    )
                  : (theme.isDarkMode
                      ? theme.background.withValues(alpha: 0.5)
                      : theme.background),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: isSelected ? AppColors.primary : theme.border,
                width: isSelected ? 2 : 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isAnnual ? t.premiumAnnualPlan : t.premiumMonthlyPlan,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutBack,
                      scale: isSelected ? 1 : 0,
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  product.priceString,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    fontFeatures: kTabularFigures,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (isAnnual)
            Positioned(
              top: -9,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Text(
                  t.premiumSavePercent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _formattedMonthlyEquivalent(rc.StoreProduct product) {
    if (!isAnnual || product.price <= 0) return null;
    final monthlyPrice = product.price / 12;
    return '${product.currencyCode} ${monthlyPrice.toStringAsFixed(2)}';
  }
}

class _PremiumActiveContent extends StatelessWidget {
  const _PremiumActiveContent();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PremiumActiveHero(),
        const SizedBox(height: 18),
        Text(
          t.premiumActiveBenefitsTitle,
          style: TextStyle(
            color: context.theme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        const _BenefitsCard().animate().fadeIn(delay: 90.ms).slideY(
              begin: 0.06,
            ),
        const SizedBox(height: 14),
        AnimatedPress(
          scale: 0.98,
          haptic: AppPressHaptic.light,
          onTap: () => Navigator.pop(context),
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(AppRadii.pill),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.16),
              ),
            ),
            child: Text(
              t.premiumContinueButton,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PremiumActiveHero extends StatelessWidget {
  const _PremiumActiveHero();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.isDarkMode
              ? [
                  theme.surface,
                  AppColors.accentGold.withValues(alpha: 0.10),
                ]
              : const [
                  Color(0xFFFFFBF4),
                  Color(0xFFFFF4DD),
                  Color(0xFFFFFCF9),
                ],
        ),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.36),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentGold.withValues(alpha: 0.13),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(
                    color: AppColors.accentGold.withValues(alpha: 0.24),
                  ),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppColors.accentGold,
                  size: 28,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.sage,
                      size: 17,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.premiumActiveStatusPill,
                      style: const TextStyle(
                        color: AppColors.sage,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            t.premiumAlreadyActiveTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.05,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            t.premiumAlreadyActiveBody,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              height: 1.32,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreError extends ConsumerWidget {
  final String error;
  const _StoreError({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        Icon(
          Icons.cloud_off_rounded,
          color: theme.textSecondary,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          t.premiumStoreErrorTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          error,
          style: TextStyle(color: theme.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 24),
        if (!AppEnvironment.isProduction)
          ElevatedButton(
            onPressed: () =>
                ref.read(premiumProvider.notifier).togglePremiumMock(),
            child: Text(t.premiumDeveloperModeButton),
          ),
      ],
    );
  }
}
