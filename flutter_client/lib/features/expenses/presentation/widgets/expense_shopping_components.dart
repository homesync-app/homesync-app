import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/shopping/presentation/widgets/shopping_icon.dart';
import 'package:homesync_client/features/shopping/utils/shopping_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class ExpenseShoppingIntegrationCard extends StatefulWidget {
  final int animationTrigger;
  final bool isPreparing;
  final bool isPremium;
  final List<ShoppingItemModel> linkedItems;
  final Set<ShoppingItemModel> autoAddedItems;
  final List<String> detectedItemNames;
  final VoidCallback onTap;
  final VoidCallback? onClearAll;
  final void Function(ShoppingItemModel item)? onRemoveItem;

  const ExpenseShoppingIntegrationCard({
    super.key,
    this.animationTrigger = 0,
    this.isPreparing = false,
    required this.isPremium,
    required this.linkedItems,
    this.autoAddedItems = const {},
    this.detectedItemNames = const [],
    required this.onTap,
    this.onClearAll,
    this.onRemoveItem,
  });

  @override
  State<ExpenseShoppingIntegrationCard> createState() =>
      _ExpenseShoppingIntegrationCardState();
}

class _ExpenseShoppingIntegrationCardState
    extends State<ExpenseShoppingIntegrationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
      value: widget.animationTrigger > 0 ? 0 : 1,
    );
    if (widget.animationTrigger > 0) {
      _revealController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ExpenseShoppingIntegrationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animationTrigger != oldWidget.animationTrigger &&
        widget.animationTrigger > 0) {
      _revealController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final hasItems =
        widget.linkedItems.isNotEmpty || widget.detectedItemNames.isNotEmpty;
    final newCount = widget.autoAddedItems.length;

    if (widget.isPreparing) return _buildPreparingCard(context);

    if (!widget.isPremium) return _buildLockedCard(context, hasItems);

    return _ShoppingCardReveal(
      controller: _revealController,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadii.control,
        child: Container(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              AppColors.primary.withValues(alpha: 0.02),
              theme.surface,
            ),
            borderRadius: AppRadii.card,
            border: Border.all(
              color: theme.border.withValues(alpha: 0.78),
              width: 1,
            ),
            boxShadow: AppElevation.card(
              color: theme.shadowBase,
              isDarkMode: theme.isDarkMode,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppRadii.md),
                      ),
                      child: const Center(
                        child: ShoppingIcon(
                          categoryId: 'general',
                          fallbackEmoji: '\u{1F6D2}',
                          allowCategoryFallback: true,
                          size: 25,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasItems
                                ? t.expensesFormShoppingDetectedTitle
                                : t.expensesFormShoppingLinkTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: theme.textPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          if (hasItems && newCount > 0)
                            Text(
                              t.expensesFormShoppingDetectedSummary(
                                widget.linkedItems.length,
                                newCount,
                              ),
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                                height: 1.4,
                              ),
                            )
                          else if (hasItems)
                            Text(
                              t.expensesFormShoppingWillMarkBought,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                                height: 1.4,
                              ),
                            )
                          else
                            Text(
                              t.expensesFormShoppingTapToLink,
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (hasItems && widget.onClearAll != null)
                      InkWell(
                        onTap: widget.onClearAll,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                theme.surfaceContainer.withValues(alpha: 0.72),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.border.withValues(alpha: 0.72),
                            ),
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.textSecondary,
                            size: 18,
                            semanticLabel:
                                t.expensesFormShoppingClearAllSemantic,
                          ),
                        ),
                      )
                    else
                      Icon(
                        hasItems
                            ? Icons.edit_outlined
                            : Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                  ],
                ),
              ),
              if (hasItems) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: widget.linkedItems.indexed.map((entry) {
                      final index = entry.$1;
                      final item = entry.$2;
                      final isNew = widget.autoAddedItems.contains(item);
                      return _StaggeredReveal(
                        controller: _revealController,
                        index: index,
                        child: _ItemChip(
                          item: item,
                          isNew: isNew,
                          onRemove: widget.onRemoveItem != null
                              ? () => widget.onRemoveItem!(item)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreparingCard(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return Container(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          AppColors.primary.withValues(alpha: 0.016),
          theme.surface,
        ),
        borderRadius: AppRadii.card,
        border: Border.all(
          color: theme.border.withValues(alpha: 0.72),
          width: 1,
        ),
        boxShadow: AppElevation.card(
          color: theme.shadowBase,
          isDarkMode: theme.isDarkMode,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.86),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Center(
                    child: ShoppingIcon(
                      categoryId: 'general',
                      fallbackEmoji: '\u{1F6D2}',
                      allowCategoryFallback: true,
                      size: 25,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.expensesFormShoppingDetectedTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.expensesFormShoppingPreparingProducts,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(7, (index) {
                final width =
                    <double>[112, 132, 104, 124, 96, 142, 116][index % 7];
                return _PreparingProductPill(width: width);
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedCard(BuildContext context, bool hasItems) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final displayNames = hasItems
        ? widget.linkedItems.map((i) => i.name).toList()
        : widget.detectedItemNames;

    return _ShoppingCardReveal(
      controller: _revealController,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              AppColors.sage.withValues(alpha: 0.018),
              theme.surface,
            ),
            borderRadius: AppRadii.card,
            border: Border.all(
              color: AppColors.sage.withValues(alpha: 0.16),
              width: 1,
            ),
            boxShadow: AppElevation.card(
              color: theme.shadowBase,
              isDarkMode: theme.isDarkMode,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.09),
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
                              Flexible(
                                child: Text(
                                  hasItems
                                      ? t.expensesFormShoppingDetectedTitle
                                      : t.expensesFormShoppingLinkTitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.5,
                                    color: theme.textPrimary.withValues(
                                      alpha: 0.78,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  displayNames.isNotEmpty
                                      ? t.expensesFormShoppingDetectedCount(
                                          displayNames.length,
                                        )
                                      : t.expensesFormShoppingTapToLink,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: theme.textSecondary,
                                    height: 1.25,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withValues(
                                    alpha: 0.86,
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.pill),
                                ),
                                child: const Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: theme.surfaceContainer.withValues(alpha: 0.78),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.border.withValues(alpha: 0.76),
                        ),
                      ),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: theme.textSecondary,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              if (displayNames.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: displayNames.take(8).indexed.map((entry) {
                      final index = entry.$1;
                      final raw = entry.$2;
                      // Resuelve emoji y nombre limpio desde el catálogo.
                      // raw puede ser nombre canónico ("Antitranspirante") o
                      // string crudo del OCR ("ANTITRANS DOVE M POMEL").
                      final catalogEntry = ReceiptMatcher.findPredefined(raw);
                      final cleanRaw = ReceiptMatcher.cleanName(raw);
                      final displayName = catalogEntry != null
                          ? localizedShoppingCatalogName(
                              context,
                              name: catalogEntry.name,
                              nameKey: catalogEntry.nameKey,
                            )
                          : (cleanRaw.isNotEmpty ? cleanRaw : raw);
                      return _StaggeredReveal(
                        controller: _revealController,
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: theme.surfaceContainer.withValues(
                              alpha: 0.58,
                            ),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                            border: Border.all(
                              color: theme.border.withValues(alpha: 0.7),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ShoppingIcon(
                                productKey: catalogEntry?.nameKey ??
                                    shoppingCatalogKeyForName(displayName),
                                categoryId: catalogEntry?.category ?? 'general',
                                fallbackEmoji:
                                    catalogEntry?.emoji ?? '\u{1F6D2}',
                                allowProductAsset: true,
                                allowCategoryFallback: true,
                                size: 18,
                                opacity: 0.58,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.textSecondary
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShoppingCardReveal extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const _ShoppingCardReveal({
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

class _StaggeredReveal extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final Widget child;

  const _StaggeredReveal({
    required this.controller,
    required this.index,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (0.18 + index * 0.045).clamp(0.0, 0.82);
    final end = (start + 0.22).clamp(0.0, 1.0);
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

class _PreparingProductPill extends StatelessWidget {
  final double width;

  const _PreparingProductPill({required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      width: width,
      height: 38,
      decoration: BoxDecoration(
        color: theme.surfaceContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.66),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.82),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                color: theme.border.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(AppRadii.pill),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _ItemChip extends StatelessWidget {
  final ShoppingItemModel item;
  final bool isNew;
  final VoidCallback? onRemove;

  const _ItemChip({
    required this.item,
    required this.isNew,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final chipBorderColor = isNew
        ? theme.border.withValues(alpha: 0.78)
        : AppColors.sage.withValues(alpha: 0.34);
    final chipBackgroundColor = isNew
        ? theme.surface.withValues(alpha: 0.86)
        : AppColors.sage.withValues(alpha: 0.065);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: chipBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShoppingIcon(
            productKey: item.nameKey ?? shoppingCatalogKeyForName(item.name),
            categoryId: item.category,
            fallbackEmoji: item.emoji.isNotEmpty ? item.emoji : '\u{1F6D2}',
            allowProductAsset: true,
            allowCategoryFallback: true,
            size: 19,
          ),
          const SizedBox(width: 6),
          Text(
            localizedShoppingItemName(context, item),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.05,
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(AppRadii.xs),
              ),
              child: Text(
                AppLocalizations.of(context).expensesFormShoppingBadgeNew,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 6),
            const Icon(
              Icons.check_circle_rounded,
              size: 14,
              color: AppColors.accentGreen,
            ),
          ],
        ],
      ),
    );

    if (onRemove == null) return chip;
    return InkWell(
      onTap: onRemove,
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: chip,
    );
  }
}

class ShoppingItemsSelectorSheet extends ConsumerStatefulWidget {
  final Set<ShoppingItemModel> initialSelected;
  final ValueChanged<Set<ShoppingItemModel>> onItemsSelected;

  const ShoppingItemsSelectorSheet({
    super.key,
    required this.initialSelected,
    required this.onItemsSelected,
  });

  @override
  ConsumerState<ShoppingItemsSelectorSheet> createState() =>
      _ShoppingItemsSelectorSheetState();
}

class _ShoppingItemsSelectorSheetState
    extends ConsumerState<ShoppingItemsSelectorSheet> {
  String _searchQuery = '';
  final Set<ShoppingItemModel> _currentSelection = {};
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentSelection.addAll(widget.initialSelected);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final query = _searchQuery.toLowerCase().trim();
    final householdItems = ref.watch(shoppingItemsProvider).value ?? [];
    final pendingHouseholdItems =
        householdItems.where((item) => !item.completed).toList();

    final filteredPendingHouseholdItems = pendingHouseholdItems
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();

    final List<Map<String, String>> predefinedMatches = [];
    if (query.isNotEmpty) {
      ShoppingPredefined.itemsPerCategory.forEach((catId, catList) {
        final catName = ShoppingCategories.nameFor(catId).toLowerCase();
        final catMatchesQuery = catName.contains(query);

        for (final item in catList) {
          final itemName = item['name']!;
          if (itemName.toLowerCase().contains(query) || catMatchesQuery) {
            final existsInHousehold = pendingHouseholdItems
                .any((ai) => ai.name.toLowerCase() == itemName.toLowerCase());
            final existsInSelection = _currentSelection
                .any((cs) => cs.name.toLowerCase() == itemName.toLowerCase());

            if (!existsInHousehold &&
                !existsInSelection &&
                !predefinedMatches.any(
                  (pm) => pm['name']!.toLowerCase() == itemName.toLowerCase(),
                )) {
              predefinedMatches.add({...item, 'categoryId': catId});
            }
          }
        }
      });
    }

    final showAddOption = query.isNotEmpty &&
        !filteredPendingHouseholdItems
            .any((item) => item.name.toLowerCase() == query) &&
        !predefinedMatches
            .any((item) => item['name']!.toLowerCase() == query) &&
        !_currentSelection.any((item) => item.name.toLowerCase() == query);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  child: Text(
                    t.expensesFormShoppingItemsSheetTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.xs,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      decoration: InputDecoration(
                        hintText: t.expensesFormShoppingSearchHint,
                        hintStyle: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 14,
                        ),
                        icon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onSubmitted: (val) async {
                        if (val.trim().isEmpty) return;
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _searchFocus.requestFocus();

                        await ref.read(shoppingItemsProvider.notifier).addItem(
                              name: val.trim(),
                              category: 'general',
                              emoji: '🏷️',
                            );

                        final temp = ShoppingItemModel(
                          id: 'selection_sync_${val.trim()}',
                          name: val.trim(),
                          householdId: '',
                          createdAt: DateTime.now(),
                          emoji: '🏷️',
                          category: 'general',
                        );
                        setState(() => _currentSelection.add(temp));
                        widget.onItemsSelected(_currentSelection);
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    children: [
                      if (showAddOption)
                        ListTile(
                          leading:
                              const Text('âž•', style: TextStyle(fontSize: 24)),
                          title: Text(
                            t.expensesFormShoppingAddQuery(_searchQuery),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: Text(
                            t.expensesFormShoppingCustomProduct,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () async {
                            final queryToSave = _searchQuery.trim();
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _searchFocus.requestFocus();

                            await ref
                                .read(shoppingItemsProvider.notifier)
                                .addItem(
                                  name: queryToSave,
                                  category: 'general',
                                  emoji: '🏷️',
                                );

                            final temp = ShoppingItemModel(
                              id: 'selection_sync_$queryToSave',
                              name: queryToSave,
                              householdId: '',
                              createdAt: DateTime.now(),
                              emoji: '🏷️',
                              category: 'general',
                            );
                            setState(() => _currentSelection.add(temp));
                            widget.onItemsSelected(_currentSelection);
                          },
                        ),
                      ...filteredPendingHouseholdItems.map((item) {
                        final isSelected = _currentSelection.contains(item);
                        return ListTile(
                          leading: ShoppingIcon(
                            productKey: item.nameKey ??
                                shoppingCatalogKeyForName(item.name),
                            categoryId: item.category,
                            fallbackEmoji: item.emoji,
                            allowProductAsset: true,
                            size: 30,
                          ),
                          title: Text(
                            localizedShoppingItemName(context, item),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                          onTap: () {
                            if (_searchQuery.isNotEmpty) {
                              _searchController.clear();
                              _searchFocus.requestFocus();
                            }
                            setState(() {
                              if (isSelected) {
                                _currentSelection.remove(item);
                              } else {
                                _currentSelection.add(item);
                              }
                              if (_searchQuery.isNotEmpty) {
                                _searchQuery = '';
                              }
                            });
                            widget.onItemsSelected(_currentSelection);
                          },
                        );
                      }),
                      if (predefinedMatches.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            AppSpacing.lg,
                            AppSpacing.md,
                            AppSpacing.xs,
                          ),
                          child: Text(
                            t.expensesFormShoppingGlobalSuggestions,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMuted,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        ...predefinedMatches.take(25).map((item) {
                          return ListTile(
                            leading: Text(
                              item['emoji']!,
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              localizedShoppingCatalogName(
                                context,
                                name: item['name']!,
                              ),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            onTap: () async {
                              final name = item['name']!;
                              final cat = item['categoryId']!;
                              final emoji = item['emoji']!;

                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _searchFocus.requestFocus();

                              await ref
                                  .read(shoppingItemsProvider.notifier)
                                  .addItem(
                                    name: name,
                                    category: cat,
                                    emoji: emoji,
                                  );

                              final temp = ShoppingItemModel(
                                id: 'selection_sync_$name',
                                name: name,
                                householdId: '',
                                createdAt: DateTime.now(),
                                emoji: emoji,
                                category: cat,
                              );
                              setState(() => _currentSelection.add(temp));
                              widget.onItemsSelected(_currentSelection);
                            },
                          );
                        }),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        t.commonAccept,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
