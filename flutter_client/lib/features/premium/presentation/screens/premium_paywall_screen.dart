import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/widgets/homesync_logo.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

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
    final t = AppLocalizations.of(context);
    final productsAsync = ref.watch(premiumProductsProvider);
    final isPremium = ref.watch(premiumProvider).value ?? false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: t.premiumPaywallCloseTooltip,
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.background,
                  AppColors.primaryLight,
                  AppColors.surface,
                ],
              ),
            ),
          ),
          Positioned(
            top: 36,
            right: 20,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.accentGold.withValues(alpha: 0.16),
              size: 108,
            ),
          ),
          Positioned(
            top: 128,
            left: -48,
            child: Container(
              width: 148,
              height: 148,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sage.withValues(alpha: 0.13),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  _HeroHeader(isDarkMode: isDarkMode)
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06),
                  const SizedBox(height: 24),
                  _BenefitCard(
                    icon: Icons.event_repeat_rounded,
                    color: AppColors.primary,
                    title: t.premiumBenefitRecurringPayments,
                    desc: t.premiumBenefitRecurringPaymentsDesc,
                  ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.08),
                  _BenefitCard(
                    icon: Icons.shopping_cart_checkout_rounded,
                    color: AppColors.sage,
                    title: t.premiumBenefitShoppingFinanceSync,
                    desc: t.premiumBenefitShoppingFinanceSyncDesc,
                  ).animate().fadeIn(delay: 180.ms).slideY(begin: 0.08),
                  _BenefitCard(
                    icon: Icons.insights_rounded,
                    color: AppColors.accentBlue,
                    title: t.premiumBenefitAdvancedStats,
                    desc: t.premiumBenefitAdvancedStatsDesc,
                  ).animate().fadeIn(delay: 240.ms).slideY(begin: 0.08),
                  _BenefitCard(
                    icon: Icons.palette_rounded,
                    color: AppColors.accentPurple,
                    title: t.premiumBenefitFullCustomization,
                    desc: t.premiumBenefitFullCustomizationDesc,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.08),
                  const SizedBox(height: 16),
                  if (isPremium)
                    _AlreadyPremiumCard()
                  else
                    productsAsync.when(
                      data: (products) => _ProductList(products: products),
                      loading: () => const CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                      error: (err, _) => _StoreError(error: err.toString()),
                    ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () =>
                        ref.read(restorePremiumPurchasesUseCaseProvider).call(),
                    child: Text(
                      t.premiumRestorePurchases,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final bool isDarkMode;

  const _HeroHeader({required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(AppRadii.modal),
            border: Border.all(color: Colors.white),
            boxShadow: AppElevation.floating(
              color: AppColors.shadowBase,
              isDarkMode: isDarkMode,
            ),
          ),
          child: const HomeSyncLogo(size: 82, showShadow: false),
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.32),
            ),
          ),
          child: Text(
            t.premiumPaywallEyebrow,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t.premiumPaywallTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 31,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            height: 1.08,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.premiumPaywallSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _BenefitCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.32,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  final List<ProductDetails> products;

  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.86),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              t.premiumFreeTrialAvailable,
              style: const TextStyle(
                color: AppColors.textPrimary,
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
              onPressed: () async {
                await ref.read(premiumProvider.notifier).togglePremiumMock();
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(t.premiumActivateButton),
            ),
            if (!AppEnvironment.isProduction) ...[
              const SizedBox(height: 8),
              Text(
                t.premiumTestingModeLabel,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      children:
          products.map((product) => _ProductCard(product: product)).toList(),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductDetails product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final isYearly = product.id.contains('yearly');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isYearly
            ? AppColors.primaryLight
            : Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: isYearly ? AppColors.primary : AppColors.border,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        title: Text(
          product.title.split('(').first.trim(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          product.description,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.price,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            if (isYearly)
              Text(
                t.premiumSavePercent,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        onTap: () => ref.read(buyPremiumProductUseCaseProvider).call(product),
      ),
    );
  }
}

class _AlreadyPremiumCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.stars_rounded,
            color: AppColors.accentGold,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            t.premiumAlreadyActiveTitle,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.premiumAlreadyActiveBody,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(color: AppColors.border),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            child: Text(t.premiumContinueButton),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () async {
              await ref.read(premiumProvider.notifier).togglePremiumMock();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(
              t.premiumDeactivateTesting,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
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
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        const Icon(
          Icons.cloud_off_rounded,
          color: AppColors.textSecondary,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          t.premiumStoreErrorTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          error,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () =>
              ref.read(premiumProvider.notifier).togglePremiumMock(),
          child: Text(t.premiumDeveloperModeButton),
        ),
      ],
    );
  }
}
