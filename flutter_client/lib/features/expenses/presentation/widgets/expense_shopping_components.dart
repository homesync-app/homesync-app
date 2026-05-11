import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class ExpenseShoppingIntegrationCard extends StatelessWidget {
  final bool isPremium;
  final List<ShoppingItemModel> linkedItems;
  final Set<ShoppingItemModel> autoAddedItems;
  final List<String> detectedItemNames;
  final VoidCallback onTap;
  final VoidCallback? onClearAll;
  final void Function(ShoppingItemModel item)? onRemoveItem;

  const ExpenseShoppingIntegrationCard({
    super.key,
    required this.isPremium,
    required this.linkedItems,
    this.autoAddedItems = const {},
    this.detectedItemNames = const [],
    required this.onTap,
    this.onClearAll,
    this.onRemoveItem,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasItems = linkedItems.isNotEmpty || detectedItemNames.isNotEmpty;
    final newCount = autoAddedItems.length;

    if (!isPremium) return _buildLockedCard(context, hasItems);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            AppColors.primary.withValues(alpha: 0.018),
            AppColors.surface,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.78),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowBase.withValues(alpha: 0.035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.105),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      size: 18,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.1,
                          ),
                        ),
                        if (hasItems && newCount > 0)
                          Text(
                            t.expensesFormShoppingDetectedSummary(
                              linkedItems.length,
                              newCount,
                            ),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          )
                        else if (hasItems)
                          Text(
                            t.expensesFormShoppingWillMarkBought,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          )
                        else
                          Text(
                            t.expensesFormShoppingTapToLink,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (hasItems && onClearAll != null)
                    InkWell(
                      onTap: onClearAll,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.background.withValues(alpha: 0.72),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.divider.withValues(alpha: 0.72),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 18,
                          semanticLabel: t.expensesFormShoppingClearAllSemantic,
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    color: AppColors.divider.withValues(alpha: 0.52),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: linkedItems.map((item) {
                    final isNew = autoAddedItems.contains(item);
                    return _ItemChip(
                      item: item,
                      isNew: isNew,
                      onRemove: onRemoveItem != null
                          ? () => onRemoveItem!(item)
                          : null,
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
    );
  }

  Widget _buildLockedCard(BuildContext context, bool hasItems) {
    final t = AppLocalizations.of(context);
    final displayNames =
        hasItems ? linkedItems.map((i) => i.name).toList() : detectedItemNames;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.divider.withValues(alpha: 0.6),
            width: 1,
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
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.grey,
                      size: 18,
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
                                t.expensesFormShoppingLinkTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PREMIUM',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          displayNames.isNotEmpty
                              ? t.expensesFormShoppingDetectedCount(
                                  displayNames.length,
                                )
                              : t.expensesFormShoppingTapToLink,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                    size: 18,
                  ),
                ],
              ),
            ),
            if (displayNames.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: displayNames.take(8).map((raw) {
                    // Resuelve emoji y nombre limpio desde el catÃ¡logo.
                    // raw puede ser nombre canÃ³nico ("Antitranspirante") o
                    // string crudo del OCR ("ANTITRANS DOVE M POMEL").
                    final catalogEntry = ReceiptMatcher.findPredefined(raw);
                    final emoji = catalogEntry?.emoji ?? 'ðŸ›’';
                    final cleanRaw = ReceiptMatcher.cleanName(raw);
                    final displayName = catalogEntry?.name ??
                        (cleanRaw.isNotEmpty ? cleanRaw : raw);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
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
    final chipBorderColor = isNew
        ? AppColors.divider.withValues(alpha: 0.95)
        : AppColors.sage.withValues(alpha: 0.34);
    final chipBackgroundColor = isNew
        ? AppColors.background.withValues(alpha: 0.84)
        : AppColors.sage.withValues(alpha: 0.065);

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6.5),
      decoration: BoxDecoration(
        color: chipBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: chipBorderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.emoji.isNotEmpty ? item.emoji : 'ðŸ›’',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 6),
          Text(
            item.name,
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
                borderRadius: BorderRadius.circular(8),
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
      borderRadius: BorderRadius.circular(20),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
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
                              emoji: 'ðŸ·ï¸',
                            );

                        final temp = ShoppingItemModel(
                          id: 'selection_sync_${val.trim()}',
                          name: val.trim(),
                          householdId: '',
                          createdAt: DateTime.now(),
                          emoji: 'ðŸ·ï¸',
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                  emoji: 'ðŸ·ï¸',
                                );

                            final temp = ShoppingItemModel(
                              id: 'selection_sync_$queryToSave',
                              name: queryToSave,
                              householdId: '',
                              createdAt: DateTime.now(),
                              emoji: 'ðŸ·ï¸',
                              category: 'general',
                            );
                            setState(() => _currentSelection.add(temp));
                            widget.onItemsSelected(_currentSelection);
                          },
                        ),
                      ...filteredPendingHouseholdItems.map((item) {
                        final isSelected = _currentSelection.contains(item);
                        return ListTile(
                          leading: Text(
                            item.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            item.name,
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
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
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
                              item['name']!,
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
                  padding: const EdgeInsets.all(24),
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


