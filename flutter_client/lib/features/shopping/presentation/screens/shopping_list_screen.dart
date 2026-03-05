import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/shopping_predefined.dart';
import '../../domain/models/shopping_model.dart';
import '../../domain/models/shopping_categories.dart';
import '../providers/shopping_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShoppingListScreen — Lista de compras interactiva (Estilo Bring!)
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  final Set<String> _expandedSections = {};
  final ValueNotifier<List<Map<String, String>>> _suggestionsVal =
      ValueNotifier([]);
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _suggestionsVal.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _inputController.text.toLowerCase().trim();
    if (query == _lastQuery) return;
    _lastQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _performSearch();
    });
  }

  void _performSearch() {
    final query = _lastQuery;
    if (query.isEmpty) {
      if (_suggestionsVal.value.isNotEmpty) _suggestionsVal.value = [];
      return;
    }

    final List<Map<String, String>> matches = [];
    for (final catList in ShoppingPredefined.itemsPerCategory.values) {
      for (final item in catList) {
        if (item['name']!.toLowerCase().contains(query)) {
          if (!matches.any((m) => m['name'] == item['name'])) {
            matches.add(item);
          }
        }
      }
    }
    _suggestionsVal.value = matches.take(5).toList();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _toggleItem(ShoppingItemModel item) async {
    HapticFeedback.lightImpact();
    ref
        .read(shoppingItemsProvider.notifier)
        .toggleItem(item.id, !item.completed);
  }

  Future<void> _deleteItem(ShoppingItemModel item) async {
    HapticFeedback.mediumImpact();
    ref.read(shoppingItemsProvider.notifier).deleteItem(item.id);
  }

  void _toggleSection(String id) {
    setState(() {
      if (_expandedSections.contains(id)) {
        _expandedSections.remove(id);
      } else {
        _expandedSections.add(id);
      }
    });
  }

  Future<void> _handleSelection(
    String name,
    List<ShoppingItemModel> pending,
    List<ShoppingItemModel> done, {
    String? emoji,
    String? category,
  }) async {
    final val = name.trim();
    if (val.isEmpty) return;

    _inputController.clear();
    _lastQuery = '';
    _suggestionsVal.value = [];
    _inputFocus.unfocus();

    // Find if already exists in pending
    final existing = pending
        .where((i) => i.name.toLowerCase() == val.toLowerCase())
        .firstOrNull;
    if (existing != null) return; // Already there

    // Find if already exists in done (bring it back)
    final doneMatch = done
        .where((i) => i.name.toLowerCase() == val.toLowerCase())
        .firstOrNull;
    if (doneMatch != null) {
      await _toggleItem(doneMatch);
      return;
    }

    String categoryId = category ?? 'general';
    String finalEmoji = emoji ?? '🛒';

    if (category == null) {
      for (final catKey in ShoppingPredefined.itemsPerCategory.keys) {
        final list = ShoppingPredefined.itemsPerCategory[catKey]!;
        for (final p in list) {
          if (p['name']!.toLowerCase() == val.toLowerCase()) {
            categoryId = catKey;
            finalEmoji = p['emoji']!;
            break;
          }
        }
      }
    }

    try {
      await ref.read(shoppingItemsProvider.notifier).addItem(
            name: val,
            quantity: '',
            unit: '',
            category: categoryId,
            emoji: finalEmoji,
            note: '',
          );
    } catch (e) {
      if (mounted) _showSnack('Error: $e', AppColors.error);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, String sectionId,
      {bool isAccent = false, String? emoji}) {
    final isExpanded = _expandedSections.contains(sectionId);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: () => _toggleSection(sectionId),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isExpanded
                  ? AppColors.surfaceVariant.withValues(alpha: 0.3)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? AppColors.accentGreen.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (emoji != null) ...[
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 12),
                    ],
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isAccent
                            ? AppColors.accentGreen
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_right,
                  color: isAccent
                      ? AppColors.accentGreen
                      : AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPredefinedGrid(Map<String, dynamic> cat,
      List<ShoppingItemModel> pending, List<ShoppingItemModel> done) {
    final predefined = ShoppingPredefined.itemsPerCategory[cat['id']] ?? [];
    if (predefined.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox());
    }

    final catColor = Color(cat['color'] as int);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        delegate: SliverChildBuilderDelegate(
          (ctx, i) {
            final prefItem = predefined[i];
            final name = prefItem['name']!;
            final isPending = pending
                .any((item) => item.name.toLowerCase() == name.toLowerCase());

            return _PredefinedItemTile(
              item: prefItem,
              catColor: catColor,
              isPending: isPending,
              onTap: () => _handleSelection(
                name,
                pending,
                done,
                emoji: prefItem['emoji'],
                category: cat['id'],
              ),
            );
          },
          childCount: predefined.length,
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(
      List<ShoppingItemModel> pending, List<ShoppingItemModel> done) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ValueListenableBuilder<List<Map<String, String>>>(
          valueListenable: _suggestionsVal,
          builder: (context, suggestions, child) {
            if (suggestions.isEmpty) return const SizedBox();
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10)
                ],
              ),
              child: Column(
                children: suggestions
                    .map((s) => ListTile(
                          leading: Text(s['emoji']!,
                              style: const TextStyle(fontSize: 20)),
                          title: Text(s['name']!,
                              style: const TextStyle(
                                  color: AppColors.textPrimary)),
                          trailing: const Icon(Icons.add_circle_outline,
                              color: AppColors.accentGreen),
                          onTap: () =>
                              _handleSelection(s['name']!, pending, done),
                        ))
                    .toList(),
              ),
            );
          },
        ),
        Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -4),
              )
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocus,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Necesito...',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.background,
                      prefixIcon:
                          const Icon(Icons.search, color: AppColors.textMuted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (val) => _handleSelection(val, pending, done),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () =>
                      _handleSelection(_inputController.text, pending, done),
                  borderRadius: BorderRadius.circular(25),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shoppingState = ref.watch(shoppingItemsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lista de Compras',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined,
                color: AppColors.textSecondary),
            onPressed: () {
              // Limpiar completados logic
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('¿Limpiar completados?',
                      style: TextStyle(color: AppColors.textPrimary)),
                  content: const Text(
                      'Se eliminarán todos los ítems que ya fueron comprados.',
                      style: TextStyle(color: AppColors.textSecondary)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ref
                            .read(shoppingItemsProvider.notifier)
                            .clearCompleted();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error),
                      child: const Text('Limpiar',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: shoppingState.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
            child: Text('Error: $err',
                style: const TextStyle(color: AppColors.error))),
        data: (items) {
          final pending = items.where((i) => !i.completed).toList();
          final done = items.where((i) => i.completed).toList();

          return Column(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(shoppingItemsProvider);
                    },
                    color: AppColors.primary,
                    child: CustomScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                      slivers: [
                        // ── PENDING ITEMS ──────────────────────────────────
                        if (pending.isNotEmpty) ...[
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) => _ShoppingItemTile(
                                  item: pending[i],
                                  onToggle: () => _toggleItem(pending[i]),
                                  onDelete: () => _deleteItem(pending[i]),
                                ),
                                childCount: pending.length,
                              ),
                            ),
                          ),
                        ],

                        if (pending.isEmpty && done.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('🍏', style: TextStyle(fontSize: 64)),
                                  SizedBox(height: 16),
                                  Text(
                                    'La heladera está llena.\n¿Necesitás algo?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        if (done.isNotEmpty) ...[
                          _buildSectionHeader(
                              'Utilizados recientemente', 'recent',
                              emoji: '🕒'),
                          if (_expandedSections.contains('recent'))
                            SliverPadding(
                              padding:
                                  const EdgeInsets.fromLTRB(16, 12, 16, 16),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (ctx, i) => _ShoppingItemTile(
                                    item: done[i],
                                    onToggle: () => _toggleItem(done[i]),
                                    onDelete: () => _deleteItem(done[i]),
                                    isCompleted: true,
                                  ),
                                  childCount: done.length,
                                ),
                              ),
                            ),
                        ],

                        // ── CATEGORIES SECTIONS ─────────────────────────────────
                        for (var cat in ShoppingCategories.all) ...[
                          _buildSectionHeader(cat['name'], cat['id'],
                              emoji: cat['emoji']),
                          if (_expandedSections.contains(cat['id']))
                            _buildPredefinedGrid(cat, pending, done),
                        ],

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),
                  ),
                ),
              ),
              _buildBottomOverlay(pending, done)
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Components
// ─────────────────────────────────────────────────────────────────────────────

class _PredefinedItemTile extends StatelessWidget {
  final Map<String, String> item;
  final Color catColor;
  final bool isPending;
  final VoidCallback onTap;

  const _PredefinedItemTile({
    required this.item,
    required this.catColor,
    required this.isPending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPending
              ? AppColors.surfaceVariant.withValues(alpha: 0.3)
              : catColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending
                ? Colors.transparent
                : catColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              item['emoji']!,
              style: TextStyle(
                fontSize: 28,
                color: isPending
                    ? AppColors.textMuted.withValues(alpha: 0.5)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                item['name']!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  height: 1.1,
                  color:
                      isPending ? AppColors.textMuted : AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingItemModel item;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final bool isCompleted;

  const _ShoppingItemTile({
    required this.item,
    required this.onToggle,
    required this.onDelete,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final catInfo = ShoppingCategories.all.firstWhere(
      (c) => c['id'] == item.category,
      orElse: () => ShoppingCategories.all.first,
    );
    final catColor = Color(catInfo['color'] as int);

    return AnimatedPress(
      onTap: () {
        onToggle();
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text('¿Eliminar ${item.name}?',
                style: const TextStyle(color: AppColors.textPrimary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onDelete();
                },
                style:
                    ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                child: const Text('Eliminar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surfaceVariant.withValues(alpha: 0.5)
              : catColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: isCompleted
              ? null
              : Border.all(color: catColor.withValues(alpha: 0.5), width: 2.0),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.emoji.isNotEmpty
                        ? item.emoji
                        : catInfo['emoji'] as String,
                    style: TextStyle(
                      fontSize: isCompleted ? 20 : 32,
                      color: isCompleted ? AppColors.textMuted : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      item.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: isCompleted ? 11 : 13,
                        height: 1.1,
                        color: isCompleted
                            ? AppColors.textMuted
                            : AppColors.textPrimary,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isCompleted)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
