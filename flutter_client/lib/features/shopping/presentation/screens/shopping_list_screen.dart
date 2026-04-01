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
import '../widgets/shopping_item_sheet.dart';

// -----------------------------------------------------------------------------
// ShoppingListScreen - Lista de compras interactiva (Estilo Bring!)
// -----------------------------------------------------------------------------

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

// Buscar por nombre de item y por nombre de categoria
    ShoppingPredefined.itemsPerCategory.forEach((catId, catList) {
      final catName = ShoppingCategories.nameFor(catId).toLowerCase();
      final catMatchesQuery = catName.contains(query);

      for (final item in catList) {
        if (item['name']!.toLowerCase().contains(query) || catMatchesQuery) {
          if (!matches.any((m) => m['name'] == item['name'])) {
            matches.add(item);
          }
        }
      }
    });

    _suggestionsVal.value = matches.take(query.length < 2 ? 5 : 10).toList();
  }

  // -- Actions --------------------------------------------------------------

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

    // Si estaba buscando algo, limpiamos al navegar por secciones
    if (_inputController.text.isNotEmpty) {
      _inputController.clear();
      _lastQuery = '';
      _suggestionsVal.value = [];
    }
  }

  Future<void> _handleSelection(
    String name,
    List<ShoppingItemModel> pending,
    List<ShoppingItemModel> done, {
    String? emoji,
    String? category,
  }) async {
    HapticFeedback.lightImpact();
    final val = name.trim();
    if (val.isEmpty) return;

    // Borramos el buscador y mantenemos el foco para permitir agregar múltiples productos seguidos fácilmente
    _inputController.clear();
    _lastQuery = '';
    _suggestionsVal.value = [];
    _inputFocus.requestFocus();

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
    String finalEmoji = emoji ?? '';

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

    ref.read(shoppingItemsProvider.notifier).addItem(
          name: val,
          category: categoryId,
          emoji: finalEmoji,
        );
  }

  // -- Build -----------------------------------------------------------------

  Widget _buildSectionHeader(String title, String sectionId,
      {bool isAccent = false, String? emoji, int? count, Color? accentColor}) {
    final isExpanded = _expandedSections.contains(sectionId);
    final highlightColor = accentColor ??
        (isAccent ? AppColors.accentGreen : AppColors.textPrimary);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
        child: InkWell(
          onTap: () => _toggleSection(sectionId),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    if (emoji != null) ...[
                      Text(
                        emoji,
                        style: TextStyle(
                          fontSize: isExpanded ? 18 : 17,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.25,
                                color: isExpanded
                                    ? highlightColor
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (count != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isExpanded
                                    ? highlightColor.withValues(alpha: 0.72)
                                    : AppColors.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isExpanded
                            ? highlightColor
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 1,
                  margin: EdgeInsets.only(right: isExpanded ? 0 : 18),
                  color: (isExpanded ? highlightColor : AppColors.divider)
                      .withValues(alpha: isExpanded ? 0.22 : 0.18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStaticSectionTitle(
    String title, {
    String? emoji,
    int? count,
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.textPrimary;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
        child: Row(
          children: [
            if (emoji != null) ...[
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  color: color,
                ),
              ),
            ),
            if (count != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
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
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentGreen.withValues(alpha: 0.24),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add_rounded,
                        color: Colors.white, size: 28),
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
      body: shoppingState.when(
        loading: () => _buildShimmerGrid(),
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
                        _buildStaticSectionTitle(
                          'Lista actual',
                          count: pending.length,
                          accentColor: AppColors.primary,
                        ),
                        // -- EMPTY STATE / PENDING LIST HEADER ------------------------
                        if (pending.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 10, 24, 28),
                              child: TweenAnimationBuilder<double>(
                                duration: const Duration(seconds: 1),
                                tween: Tween(begin: 0.0, end: 1.0),
                                builder: (context, value, child) => Opacity(
                                  opacity: value,
                                  child: Transform.scale(
                                    scale: 0.94 + (0.06 * value),
                                    child: child,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(28),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppColors.primary
                                                .withValues(alpha: 0.14),
                                            AppColors.accentGreen
                                                .withValues(alpha: 0.10),
                                          ],
                                        ),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.10),
                                            blurRadius: 24,
                                            offset: const Offset(0, 10),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shopping_basket_rounded,
                                        size: 56,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.10),
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        done.isEmpty
                                            ? 'Todo en orden'
                                            : 'Lista resuelta',
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      done.isEmpty
                                          ? 'Heladera lista.\nNecesitan algo hoy?'
                                          : 'Todo comprado.\nQueres anotar algo mas?',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 22,
                                        height: 1.3,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Agrega productos usando las categorias\no el buscador de abajo.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else ...[
                          // Mostramos la grilla de pendientes si no esta vacio.
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
                                (ctx, i) {
                                  final item = pending[i];
                                  return TweenAnimationBuilder<double>(
                                    key: ValueKey(item.id),
                                    duration: const Duration(milliseconds: 300),
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) => Opacity(
                                      opacity: value,
                                      child: Transform.translate(
                                        offset: Offset(0, 15 * (1 - value)),
                                        child: child,
                                      ),
                                    ),
                                    child: _ShoppingItemTile(
                                      item: item,
                                      onToggle: () => _toggleItem(item),
                                      onDelete: () => _deleteItem(item),
                                    ),
                                  );
                                },
                                childCount: pending.length,
                              ),
                            ),
                          ),
                        ],

                        if (done.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Volver a comprar',
                            'recent',
                            accentColor: AppColors.accentGreen,
                          ),
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
                                  (ctx, i) {
                                    final item = done[i];
                                    return TweenAnimationBuilder<double>(
                                      key: ValueKey(item.id),
                                      duration:
                                          const Duration(milliseconds: 300),
                                      tween: Tween(begin: 0.0, end: 1.0),
                                      curve: Curves.easeOutCubic,
                                      builder: (context, value, child) =>
                                          Opacity(
                                        opacity: value,
                                        child: child,
                                      ),
                                      child: _ShoppingItemTile(
                                        item: item,
                                        onToggle: () => _toggleItem(item),
                                        onDelete: () => _deleteItem(item),
                                        isCompleted: true,
                                      ),
                                    );
                                  },
                                  childCount: done.length,
                                ),
                              ),
                            ),
                        ],

                        _buildStaticSectionTitle(
                          'Categorias',
                        ),
                        // -- CATEGORIES SECTIONS ---------------------------------
                        for (final cat in ShoppingCategories.all
                            .where((cat) => cat['id'] != 'general')) ...[
                          _buildSectionHeader(cat['name'], cat['id'],
                              emoji: cat['emoji'],
                              accentColor: Color(cat['color'] as int),
                              count: (ShoppingPredefined
                                          .itemsPerCategory[cat['id']] ??
                                      [])
                                  .length),
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

  Widget _buildShimmerGrid() {
    return ShimmerLoading(
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.85,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Components
// -----------------------------------------------------------------------------

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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPending
              ? AppColors.surfaceVariant.withValues(alpha: 0.22)
              : catColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isPending
                ? AppColors.divider.withValues(alpha: 0.40)
                : catColor.withValues(alpha: 0.28),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
        HapticFeedback.lightImpact();
        onToggle();
      },
      onLongPress: () {
        ShoppingItemSheet.show(context, item: item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.surfaceVariant.withValues(alpha: 0.28)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isCompleted
                ? AppColors.divider.withValues(alpha: 0.52)
                : catColor.withValues(alpha: 0.32),
            width: isCompleted ? 1.0 : 1.4,
          ),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: catColor.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
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
