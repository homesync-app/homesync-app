import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/shopping_predefined.dart';
import '../services/shopping_service.dart';
import '../services/supabase_auth_service.dart';
import '../theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShoppingListScreen — Lista de compras interactiva (Estilo Bring!)
// ─────────────────────────────────────────────────────────────────────────────

class ShoppingListScreen extends StatefulWidget {
  final SupabaseAuthService auth;
  const ShoppingListScreen({super.key, required this.auth});

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  final _service = ShoppingService();
  final _scrollController = ScrollController();
  final _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  List<ShoppingItem> _items = [];
  bool _isLoading = true;
  String? _householdId;

  final Set<String> _expandedSections = {};
  List<Map<String, String>> _suggestions = [];
  late final StreamSubscription _localSub;

  @override
  void initState() {
    super.initState();
    _init();
    _inputController.addListener(_onSearchChanged);
    _localSub = ShoppingService.localChanges.listen((_) {
      if (mounted) _loadItems();
    });
  }

  @override
  void dispose() {
    _localSub.cancel();
    _service.dispose();
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _inputController.text.toLowerCase().trim();
    if (query.isEmpty) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = []);
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
    setState(() => _suggestions = matches.take(5).toList());
  }

  Future<void> _init() async {
    final user = widget.auth.currentUser;
    if (user == null) return;

    final hm = await Supabase.instance.client
        .from('household_members')
        .select('household_id')
        .eq('user_id', user.id)
        .maybeSingle();

    _householdId = hm?['household_id'] as String?;

    if (_householdId != null) {
      await _service.subscribeToChanges(
        householdId: _householdId!,
        onChanged: _loadItems,
      );
    }
    await _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await _service.fetchItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<ShoppingItem> get _pending => _items.where((i) => !i.completed).toList();
  List<ShoppingItem> get _done => _items.where((i) => i.completed).toList();

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> _toggleItem(ShoppingItem item) async {
    HapticFeedback.lightImpact();
    setState(() {
      final idx = _items.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _items[idx] = item.copyWith(
          completed: !item.completed,
          completedAt: !item.completed ? DateTime.now() : null,
        );
      }
    });
    await _service.toggleItem(item.id, !item.completed);
  }

  Future<void> _deleteItem(ShoppingItem item) async {
    HapticFeedback.mediumImpact();
    setState(() => _items.removeWhere((e) => e.id == item.id));
    await _service.deleteItem(item.id);
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

  Future<void> _handleSelection(String name,
      {String? emoji, String? category}) async {
    final val = name.trim();
    if (val.isEmpty) return;

    _inputController.clear();
    _suggestions = [];
    _inputFocus.unfocus();

    // Find if already exists in pending
    final existing = _pending
        .where((i) => i.name.toLowerCase() == val.toLowerCase())
        .firstOrNull;
    if (existing != null) return; // Already there

    // Find if already exists in done (bring it back)
    final doneMatch = _done
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
      final newItem = await _service.addItem(
        name: val,
        quantity: '',
        unit: '',
        category: categoryId,
        emoji: finalEmoji,
        note: '',
      );
      if (mounted) {
        setState(() => _items.insert(0, newItem));
      }
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
                  ? AppColors.surfaceVariant.withOpacity(0.3)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isExpanded
                    ? AppColors.accentGreen.withOpacity(0.3)
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

  Widget _buildPredefinedGrid(Map<String, dynamic> cat) {
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
            final isPending = _pending
                .any((item) => item.name.toLowerCase() == name.toLowerCase());

            return _PredefinedItemTile(
              item: prefItem,
              catColor: catColor,
              isPending: isPending,
              onTap: () => _handleSelection(name,
                  emoji: prefItem['emoji'], category: cat['id']),
            );
          },
          childCount: predefined.length,
        ),
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)
              ],
            ),
            child: Column(
              children: _suggestions
                  .map((s) => ListTile(
                        leading: Text(s['emoji']!,
                            style: const TextStyle(fontSize: 20)),
                        title: Text(s['name']!,
                            style:
                                const TextStyle(color: AppColors.textPrimary)),
                        trailing: const Icon(Icons.add_circle_outline,
                            color: AppColors.accentGreen),
                        onTap: () => _handleSelection(s['name']!),
                      ))
                  .toList(),
            ),
          ),
        Container(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
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
                    onSubmitted: (val) => _handleSelection(val),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: () => _handleSelection(_inputController.text),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomOverlay(),
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
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: RefreshIndicator(
                onRefresh: _loadItems,
                color: AppColors.primary,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // ── PENDING ITEMS ──────────────────────────────────
                    if (_pending.isNotEmpty) ...[
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
                              item: _pending[i],
                              onToggle: () => _toggleItem(_pending[i]),
                              onDelete: () => _deleteItem(_pending[i]),
                            ),
                            childCount: _pending.length,
                          ),
                        ),
                      ),
                    ],

                    if (_pending.isEmpty && _done.isEmpty)
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
                                    height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (_done.isNotEmpty) ...[
                      _buildSectionHeader('Utilizados recientemente', 'recent',
                          emoji: '🕒'),
                      if (_expandedSections.contains('recent'))
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
                                item: _done[i],
                                onToggle: () => _toggleItem(_done[i]),
                                onDelete: () => _deleteItem(_done[i]),
                                isCompleted: true,
                              ),
                              childCount: _done.length,
                            ),
                          ),
                        ),
                    ],

                    // ── CATEGORIES SECTIONS ─────────────────────────────────
                    for (var cat in ShoppingCategories.all) ...[
                      _buildSectionHeader(cat['name'], cat['id'],
                          emoji: cat['emoji']),
                      if (_expandedSections.contains(cat['id']))
                        _buildPredefinedGrid(cat),
                    ],

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              ),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isPending
              ? AppColors.surfaceVariant.withOpacity(0.3)
              : catColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPending ? Colors.transparent : catColor.withOpacity(0.2),
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
                color: isPending ? AppColors.textMuted.withOpacity(0.5) : null,
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
  final ShoppingItem item;
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onToggle();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
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
              ? AppColors.surfaceVariant.withOpacity(0.5)
              : catColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: isCompleted
              ? null
              : Border.all(color: catColor.withOpacity(0.5), width: 2.0),
          boxShadow: isCompleted
              ? []
              : [
                  BoxShadow(
                    color: catColor.withOpacity(0.1),
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
