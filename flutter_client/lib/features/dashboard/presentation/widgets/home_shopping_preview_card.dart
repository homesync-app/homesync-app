import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

class HomeShoppingPreviewCard extends ConsumerWidget {
  final String title;
  final String ctaLabel;
  final String emptyMessage;
  final int maxItems;

  const HomeShoppingPreviewCard({
    super.key,
    this.title = 'Lista actual',
    this.ctaLabel = 'Abrir compras',
    this.emptyMessage = 'No hay productos pendientes.',
    this.maxItems = 4,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final shoppingAsync = ref.watch(shoppingItemsProvider);

    void openShopping() {
      final index = indexForMainTab(caps, MainTab.shopping);
      if (index >= 0) {
        ref.read(bottomNavIndexProvider.notifier).setIndex(index);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.7,
              ),
            ),
            TextButton(
              onPressed: openShopping,
              child: Text(
                ctaLabel,
                style: TextStyle(
                  color: theme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        shoppingAsync.when(
          loading: () => _ShoppingPreviewLoading(theme: theme),
          error: (error, _) => _ShoppingPreviewError(
            onTap: openShopping,
            message: 'No pudimos cargar la lista.',
          ),
          data: (items) {
            final pending = items.where((item) => !item.completed).toList();
            if (pending.isEmpty) {
              return _ShoppingPreviewEmpty(
                message: emptyMessage,
                onTap: openShopping,
              );
            }

            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.border.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadow.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.shopping_cart_rounded,
                            color: AppColors.accentGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${pending.length} pendiente${pending.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: theme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...pending.take(maxItems).map(
                        (item) => ListTile(
                          onTap: openShopping,
                          leading: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 21),
                          ),
                          title: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: item.quantity != null
                              ? Text(
                                  '${item.quantity} ${item.unit ?? ''}'.trim(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: theme.textMuted,
                          ),
                        ),
                      ),
                  if (pending.length > maxItems)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${pending.length - maxItems} más en la lista',
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ShoppingPreviewLoading extends StatelessWidget {
  final AppThemeColors theme;

  const _ShoppingPreviewLoading({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          _ShoppingPreviewLoadingRow(),
          _ShoppingPreviewLoadingRow(),
          _ShoppingPreviewLoadingRow(),
        ],
      ),
    );
  }
}

class _ShoppingPreviewLoadingRow extends StatelessWidget {
  const _ShoppingPreviewLoadingRow();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: theme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: theme.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShoppingPreviewEmpty extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _ShoppingPreviewEmpty({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 34,
              color: AppColors.accentGold,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingPreviewError extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _ShoppingPreviewError({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: theme.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
