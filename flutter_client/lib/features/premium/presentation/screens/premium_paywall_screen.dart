import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

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
          Container(
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
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                children: [
                  const _HeroHeader()
                      .animate()
                      .fadeIn(duration: 350.ms)
                      .slideY(begin: 0.06),
                  const SizedBox(height: 18),
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
                  if (!isPremium) ...[
                    const SizedBox(height: 2),
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () async {
                        final isPremium = await ref
                            .read(premiumProvider.notifier)
                            .restorePurchases();
                        if (isPremium && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        t.premiumRestorePurchases,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
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
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.accentGold.withValues(alpha: 0.32),
            ),
          ),
          child: Text(
            t.premiumPaywallEyebrow,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          t.premiumPaywallTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23.5,
            fontWeight: FontWeight.w900,
            color: theme.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.premiumPaywallSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: theme.textSecondary,
            height: 1.32,
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
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: theme.isDarkMode
              ? theme.surface.withValues(alpha: 0.74)
              : Colors.white.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: theme.border.withValues(alpha: 0.28)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                      height: 1.18,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.textSecondary,
                      height: 1.28,
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

class _ProductList extends ConsumerStatefulWidget {
  final List<rc.Package> products;

  const _ProductList({required this.products});

  @override
  ConsumerState<_ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<_ProductList> {
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
  void didUpdateWidget(covariant _ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.products.isEmpty) return;
    final selectedId = _selectedPackage?.identifier;
    final stillExists = widget.products.any(
      (package) => package.identifier == selectedId,
    );
    if (!stillExists) _selectedPackage = _defaultPackage();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    if (widget.products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface.withValues(alpha: theme.isDarkMode ? 1 : 0.86),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.border),
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          t.premiumChoosePlanTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: theme.isDarkMode ? 1 : 0.9),
            borderRadius: BorderRadius.circular(AppRadii.xl),
            border: Border.all(color: theme.border, width: 1.2),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < sortedProducts.length; index++) ...[
                _ProductOptionRow(
                  package: sortedProducts[index],
                  isSelected: sortedProducts[index].identifier ==
                      selectedPackage.identifier,
                  isAnnual: _isAnnual(sortedProducts[index]),
                  onTap: () =>
                      setState(() => _selectedPackage = sortedProducts[index]),
                ),
                if (index < sortedProducts.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: theme.border,
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
          onPressed: () async {
            final messenger = ScaffoldMessenger.of(context);
            try {
              final isPremium = await ref
                  .read(premiumProvider.notifier)
                  .buyProduct(selectedPackage);
              if (isPremium && context.mounted) Navigator.pop(context);
            } catch (_) {
              // Purchase errors (billing unavailable, DEVELOPER_ERROR on
              // non-Play builds, region issues, etc.) must never crash the
              // app — buyProduct already logs them. Show a friendly notice.
              messenger.showSnackBar(
                SnackBar(content: Text(t.commonError)),
              );
            }
          },
          child: Text(
            t.premiumContinueWithPlan,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}

class _ProductOptionRow extends StatelessWidget {
  final rc.Package package;
  final bool isSelected;
  final bool isAnnual;
  final VoidCallback onTap;

  const _ProductOptionRow({
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
    final periodLabel = isAnnual ? t.premiumAnnualPlan : t.premiumMonthlyPlan;
    final supportingLabel =
        isAnnual ? t.premiumBilledAnnually : t.premiumBilledMonthly;
    final monthlyEquivalent = isAnnual
        ? product.pricePerMonthString ?? _formattedMonthlyEquivalent(product)
        : null;

    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: theme.isDarkMode ? 0.16 : 0.10)
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
          child: Row(
            children: [
              _PlanRadio(isSelected: isSelected),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            periodLabel,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        if (isAnnual) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            child: Text(
                              t.premiumBestValueBadge,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      monthlyEquivalent != null
                          ? t.premiumMonthlyEquivalent(monthlyEquivalent)
                          : supportingLabel,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (monthlyEquivalent != null)
                      Text(
                        supportingLabel,
                        style: TextStyle(
                          color: theme.textMuted,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    product.priceString,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  if (isAnnual)
                    Text(
                      t.premiumSavePercent,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _formattedMonthlyEquivalent(rc.StoreProduct product) {
    if (!isAnnual || product.price <= 0) return null;
    final monthlyPrice = product.price / 12;
    return '${product.currencyCode} ${monthlyPrice.toStringAsFixed(2)}';
  }
}

class _PlanRadio extends StatelessWidget {
  final bool isSelected;

  const _PlanRadio({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : theme.border,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(
              Icons.check_rounded,
              size: 15,
              color: Colors.white,
            )
          : null,
    );
  }
}

class _AlreadyPremiumCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: theme.isDarkMode ? 1 : 0.86),
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
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.premiumAlreadyActiveBody,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.textPrimary,
              side: BorderSide(color: theme.border),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.lg),
              ),
            ),
            child: Text(t.premiumContinueButton),
          ),
          const SizedBox(height: 12),
          if (!AppEnvironment.isProduction)
            TextButton(
              onPressed: () async {
                await ref.read(premiumProvider.notifier).togglePremiumMock();
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(
                t.premiumDeactivateTesting,
                style: TextStyle(color: theme.textMuted, fontSize: 12),
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
