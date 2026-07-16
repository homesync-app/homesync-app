import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/shopping/presentation/widgets/shopping_icon.dart';
import 'package:homesync_client/features/shopping/utils/shopping_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class NewItemsSuggestionBanner extends ConsumerStatefulWidget {
  final int animationTrigger;
  final List<String> items;
  final String householdId;
  final VoidCallback onDismiss;
  final void Function(List<ShoppingItemModel> added)? onItemsAdded;

  const NewItemsSuggestionBanner({
    super.key,
    this.animationTrigger = 0,
    required this.items,
    required this.householdId,
    required this.onDismiss,
    this.onItemsAdded,
  });

  @override
  ConsumerState<NewItemsSuggestionBanner> createState() =>
      _NewItemsSuggestionBannerState();
}

class _NewItemsSuggestionBannerState
    extends ConsumerState<NewItemsSuggestionBanner>
    with SingleTickerProviderStateMixin {
  late final Set<String> _selected;
  late final AnimationController _revealController;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.items);
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
      value: widget.animationTrigger > 0 ? 0 : 1,
    );
    if (widget.animationTrigger > 0) {
      Future<void>.delayed(const Duration(milliseconds: 160), () {
        if (mounted) _revealController.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant NewItemsSuggestionBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationTrigger != oldWidget.animationTrigger &&
        widget.animationTrigger > 0) {
      Future<void>.delayed(const Duration(milliseconds: 160), () {
        if (mounted) _revealController.forward(from: 0);
      });
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _addSelected() async {
    if (_selected.isEmpty || _isAdding) return;
    setState(() => _isAdding = true);

    try {
      final notifier = ref.read(shoppingItemsProvider.notifier);
      final addedItems = <ShoppingItemModel>[];

      for (final rawName in _selected) {
        final predefined = ReceiptMatcher.findPredefined(rawName);
        final displayName =
            predefined?.name ?? ReceiptMatcher.cleanName(rawName);
        if (displayName.isEmpty) continue;

        await notifier.addItem(
          name: displayName,
          emoji: predefined?.emoji ?? '\u{1F6D2}',
          category: predefined?.category ?? 'general',
        );

        addedItems.add(
          ShoppingItemModel(
            id: 'temp_${displayName.toLowerCase().replaceAll(' ', '_')}',
            name: displayName,
            emoji: predefined?.emoji ?? '\u{1F6D2}',
            category: predefined?.category ?? 'general',
            householdId: widget.householdId,
            createdAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        final t = AppLocalizations.of(context);
        widget.onItemsAdded?.call(addedItems);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.expensesNewItemsAddedCount(_selected.length)),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onDismiss();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).commonErrorWithDetails('$e'),
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return _BannerReveal(
      controller: _revealController,
      child: Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            AppColors.sage.withValues(alpha: 0.036),
            theme.surface,
          ),
          border: Border.all(
            color: AppColors.sage.withValues(alpha: 0.22),
          ),
          borderRadius: AppRadii.card,
          boxShadow: AppElevation.card(
            color: theme.shadowBase,
            isDarkMode: theme.isDarkMode,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.sage.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Center(
                    child: ShoppingIcon(
                      categoryId: 'general',
                      fallbackEmoji: '\u{1F6D2}',
                      allowCategoryFallback: true,
                      size: 25,
                      color: AppColors.sage,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              t.expensesNewItemsDetectedTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.cardTitle.copyWith(
                                fontSize: 15,
                                height: 1.18,
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(
                                alpha: 0.78,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppRadii.pill),
                            ),
                            child: Text(
                              '${_selected.length}/${widget.items.length}',
                              style: AppTypography.caption.copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.expensesNewItemsDetectedSubtitle,
                        style: AppTypography.caption.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _isAdding ? null : widget.onDismiss,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: theme.surfaceContainer.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.border.withValues(alpha: 0.68),
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.items.indexed.map((entry) {
                final index = entry.$1;
                final item = entry.$2;
                final isSelected = _selected.contains(item);
                final predefined = ReceiptMatcher.findPredefined(item);
                final cleanName = ReceiptMatcher.cleanName(item);
                final label = predefined != null
                    ? localizedShoppingCatalogName(
                        context,
                        name: predefined.name,
                        nameKey: predefined.nameKey,
                      )
                    : (cleanName.isNotEmpty ? cleanName : item);

                return _BannerChipReveal(
                  controller: _revealController,
                  index: index,
                  child: _SuggestionChip(
                    label: label,
                    productKey:
                        predefined?.nameKey ?? shoppingCatalogKeyForName(label),
                    categoryId: predefined?.category ?? 'general',
                    fallbackEmoji: predefined?.emoji ?? '\u{1F6D2}',
                    selected: isSelected,
                    enabled: !_isAdding,
                    onTap: () {
                      if (_isAdding) return;
                      setState(() {
                        if (isSelected) {
                          _selected.remove(item);
                        } else {
                          _selected.add(item);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isAdding ? null : widget.onDismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: AppTypography.bodyStrong.copyWith(
                        fontSize: 13.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                    child: Text(t.expensesNewItemsIgnore),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: _SoftAddButton(
                    enabled: _selected.isNotEmpty && !_isAdding,
                    loading: _isAdding,
                    label: t.expensesNewItemsAddToList(_selected.length),
                    onTap: _addSelected,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerReveal extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _BannerReveal({
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: const Interval(0, 0.36, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 10),
            child: child,
          ),
        );
      },
    );
  }
}

class _BannerChipReveal extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _BannerChipReveal({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (0.18 + index * 0.06).clamp(0.0, 0.82);
    final end = (start + 0.24).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final value = animation.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 7),
            child: Transform.scale(
              scale: 0.96 + value * 0.04,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class _SoftAddButton extends StatelessWidget {
  final bool enabled;
  final bool loading;
  final String label;
  final VoidCallback onTap;

  const _SoftAddButton({
    required this.enabled,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground =
        enabled ? AppColors.primary : AppColors.primary.withValues(alpha: 0.42);
    final background = enabled
        ? AppColors.primaryLight.withValues(alpha: 0.96)
        : AppColors.primaryLight.withValues(alpha: 0.58);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: enabled ? 0.18 : 0.1),
            ),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primary,
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        height: 1,
                        color: foreground,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final String? productKey;
  final String categoryId;
  final String fallbackEmoji;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.productKey,
    required this.categoryId,
    required this.fallbackEmoji,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final borderColor = selected
        ? AppColors.sage.withValues(alpha: 0.44)
        : theme.border.withValues(alpha: 0.74);
    final background = selected
        ? AppColors.sage.withValues(alpha: 0.105)
        : theme.surface.withValues(alpha: 0.92);

    return Opacity(
      opacity: enabled ? 1 : 0.62,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          constraints: const BoxConstraints(minHeight: 42, maxWidth: 210),
          padding: const EdgeInsets.fromLTRB(9, 7, 10, 7),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.54)
                      : theme.surfaceContainer.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Center(
                      child: ShoppingIcon(
                        productKey: productKey,
                        categoryId: categoryId,
                        fallbackEmoji: fallbackEmoji,
                        allowProductAsset: true,
                        allowCategoryFallback: true,
                        size: 21,
                      ),
                    ),
                    if (selected)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 15,
                          height: 15,
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.surface,
                              width: 1.8,
                            ),
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? theme.textPrimary : theme.textSecondary,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 12.5,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
