import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

class ExpenseShoppingIntegrationCard extends StatelessWidget {
  final bool isPremium;
  final List<ShoppingItemModel> linkedItems;
  final Set<ShoppingItemModel> autoAddedItems;
  final List<String> detectedItemNames;
  final VoidCallback onTap;

  const ExpenseShoppingIntegrationCard({
    super.key,
    required this.isPremium,
    required this.linkedItems,
    this.autoAddedItems = const {},
    this.detectedItemNames = const [],
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasItems = linkedItems.isNotEmpty || detectedItemNames.isNotEmpty;
    final newCount = autoAddedItems.length;

    if (!isPremium) return _buildLockedCard(context, hasItems);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                      color: AppColors.primary.withValues(alpha: 0.10),
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
                              ? '${linkedItems.length} ${linkedItems.length == 1 ? 'artículo' : 'artículos'} del ticket'
                              : 'Vincular con lista de compras',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (hasItems && newCount > 0)
                          Text(
                            '$newCount nuevo${newCount == 1 ? '' : 's'} · se agregan a tu lista',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          )
                        else if (hasItems)
                          const Text(
                            'Se marcarán como comprados al guardar',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          )
                        else
                          const Text(
                            'Toca para vincular artículos',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 12),
              const Divider(height: 1, indent: 16, endIndent: 16),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: linkedItems.map((item) {
                    final isNew = autoAddedItems.contains(item);
                    return _ItemChip(item: item, isNew: isNew);
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
                            const Text(
                              'Vincular con lista de compras',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: Colors.grey,
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
                              ? '${displayNames.length} ${displayNames.length == 1 ? 'producto detectado' : 'productos detectados'}'
                              : 'Toca para vincular artículos',
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
                  children: displayNames.take(8).map((name) {
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
                          const Text(
                            '🛒',
                            style: TextStyle(fontSize: 13),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            name,
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

  const _ItemChip({required this.item, required this.isNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isNew
              ? AppColors.primary.withValues(alpha: 0.30)
              : AppColors.divider,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.emoji.isNotEmpty ? item.emoji : '🛒',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(width: 5),
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          if (isNew) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'nuevo',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(width: 5),
            const Icon(Icons.check_circle, size: 13, color: Color(0xFF22C55E)),
          ],
        ],
      ),
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
                const Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Text(
                    'Artículos de la Lista',
                    style: TextStyle(
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
                      decoration: const InputDecoration(
                        hintText: 'Buscar o agregar producto...',
                        hintStyle:
                            TextStyle(color: AppColors.textMuted, fontSize: 14),
                        icon: Icon(
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
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      if (showAddOption)
                        ListTile(
                          leading:
                              const Text('➕', style: TextStyle(fontSize: 24)),
                          title: Text(
                            'Agregar "$_searchQuery"',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          subtitle: const Text(
                            'Producto personalizado',
                            style: TextStyle(fontSize: 12),
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
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                          child: Text(
                            'Sugerencias globales',
                            style: TextStyle(
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
                      child: const Text(
                        'Listo',
                        style: TextStyle(
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
