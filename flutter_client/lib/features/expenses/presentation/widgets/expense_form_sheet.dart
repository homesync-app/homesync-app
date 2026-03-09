import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';

import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseModel? expense;

  const ExpenseFormSheet({
    super.key,
    this.expense,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();

  static Future<void> show(BuildContext context, {ExpenseModel? expense}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExpenseFormSheet(expense: expense),
    );
  }
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  bool _isLoading = false;
  bool _isIncome = false;
  Map<String, dynamic>? _selectedCategory;

  // Form fields
  DateTime _selectedDate = DateTime.now();
  String _paidByUserId = '';
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  // Shopping items integration
  final Set<ShoppingItemModel> _selectedShoppingItems = {};

  // Split logic
  SplitType _splitMode = SplitType.equal;
  Set<String> _selectedMembersForSplit = {}; // For 'equal'
  final Map<String, double> _fixedSplitAmounts = {}; // For 'fixed'

  final List<Map<String, dynamic>> _categories = [
    {'id': 'supermarket', 'name': 'Supermercado', 'icon': '🛒', 'color': AppColors.accentGold},
    {'id': 'utilities', 'name': 'Servicios', 'icon': '💡', 'color': AppColors.accentTeal},
    {'id': 'rent', 'name': 'Alquiler', 'icon': '🏠', 'color': AppColors.primary},
    {'id': 'restaurants', 'name': 'Restaurantes', 'icon': '🍽️', 'color': const Color(0xFFF06292)},
    {'id': 'transport', 'name': 'Transporte', 'icon': '🚗', 'color': const Color(0xFF4DB6AC)},
    {'id': 'entertainment', 'name': 'Entretenimiento', 'icon': '🎬', 'color': const Color(0xFF9575CD)},
    {'id': 'health', 'name': 'Salud', 'icon': '💊', 'color': AppColors.accentRed},
    {'id': 'other', 'name': 'Otros', 'icon': '📦', 'color': AppColors.textSecondary},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.first;
    _titleController.addListener(_onTitleChanged);
    
    if (widget.expense != null) {
      _loadExpenseData(widget.expense!);
      _isIncome = widget.expense!.type == 'income';
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    super.dispose();
  }

  void _onTitleChanged() {
    if (widget.expense != null) return; // Don't auto-suggest if editing
    _matchAndSetCategory(_titleController.text);
  }

  void _matchAndSetCategory(String t) {
    t = t.toLowerCase();
    String? matchedId;
    if (t.contains('supermercado') || t.contains('coto') || t.contains('carrefour') || t.contains('despensa') || t.contains('comida') || t.contains('alimento')) {
      matchedId = 'supermarket';
    } else if (t.contains('luz') || t.contains('agua') || t.contains('gas') || t.contains('internet') || t.contains('wifi') || t.contains('servicio')) matchedId = 'utilities';
    else if (t.contains('alquiler') || t.contains('expensas') || t.contains('renta')) matchedId = 'rent';
    else if (t.contains('restaurante') || t.contains('cena') || t.contains('pedidosya') || t.contains('delivery') || t.contains('mc') || t.contains('pizza')) matchedId = 'restaurants';
    else if (t.contains('transporte') || t.contains('uber') || t.contains('cabify') || t.contains('nafta') || t.contains('gasolina') || t.contains('sube') || t.contains('taxi') || t.contains('cole')) matchedId = 'transport';
    else if (t.contains('cine') || t.contains('teatro') || t.contains('juego') || t.contains('fiesta') || t.contains('salida')) matchedId = 'entertainment';
    else if (t.contains('farmacia') || t.contains('medico') || t.contains('salud') || t.contains('pastillas') || t.contains('remedio')) matchedId = 'health';
    
    if (matchedId != null && _selectedCategory?['id'] != matchedId) {
      setState(() {
        _selectedCategory = _categories.firstWhere((c) => c['id'] == matchedId, orElse: () => _categories.first);
      });
    }
  }

  void _loadExpenseData(ExpenseModel exp) {
    _titleController.text = exp.title;
    _amountController.text = exp.amount.toString();
    _notesController.text = exp.description ?? '';
    if (exp.category != null) {
      _selectedCategory = _categories.firstWhere(
        (c) => c['id'] == exp.category,
        orElse: () => _categories.last,
      );
    }
    _selectedDate = exp.paidAt;
    _paidByUserId = exp.paidBy;

    if (exp.splitType != null) {
      _splitMode = SplitType.values.firstWhere(
        (e) => e.name == exp.splitType,
        orElse: () => SplitType.equal,
      );
    }
    
    if (exp.expenseSplits != null) {
      final splits = exp.expenseSplits!;
      if (_splitMode == SplitType.equal) {
        _selectedMembersForSplit = splits.map((s) => s['user_id'] as String).toSet();
      } else if (_splitMode == SplitType.fixed) {
        for (final s in splits) {
          _fixedSplitAmounts[s['user_id']] = (s['amount'] as num).toDouble();
        }
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveExpense() async {
    final cleanAmtStr = _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amountParsed = double.tryParse(cleanAmtStr);
    if (amountParsed == null || amountParsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido.')));
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception("No pertenecés a un hogar");

    final membersAsync = ref.read(householdMembersProvider);
    
    if (membersAsync.value == null) return;
    final members = membersAsync.value!;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);
      
      String computedTitle = _titleController.text.trim();
      if (computedTitle.isEmpty) {
        if (_selectedShoppingItems.isNotEmpty) {
          final itemNames = _selectedShoppingItems.map((e) => e.name).take(3).join(', ');
          computedTitle = _selectedShoppingItems.length > 3 ? 'Compras: $itemNames...' : 'Compras: $itemNames';
        } else {
          computedTitle = _selectedCategory!['name'];
        }
      }

      List<Map<String, dynamic>> splits = [];

      if (_splitMode == SplitType.equal) {
        if (_selectedMembersForSplit.isEmpty) {
          throw Exception("Debes seleccionar al menos un miembro para dividir.");
        }
        final splitAmount = amountParsed / _selectedMembersForSplit.length;
        for (final memId in _selectedMembersForSplit) {
          splits.add({'user_id': memId, 'amount': splitAmount});
        }
      } else if (_splitMode == SplitType.fixed) {
        double totalFixed = 0;
        for (final mem in members) {
          final amt = _fixedSplitAmounts[mem.userId] ?? 0.0;
          if (amt > 0) {
            totalFixed += amt;
            splits.add({'user_id': mem.userId, 'amount': amt});
          }
        }
        if ((totalFixed - amountParsed).abs() > 0.01) {
          throw Exception("Los montos fijos deben sumar el total del gasto.");
        }
      } else if (_splitMode == SplitType.gift) {
        splits = []; 
      } else if (_splitMode == SplitType.personal) {
        splits = [{'user_id': _paidByUserId, 'amount': amountParsed}];
      }

      await repo.saveExpense(
        id: widget.expense?.id,
        householdId: householdId,
        title: computedTitle,
        amount: amountParsed,
        category: _selectedCategory!['id'],
        paidBy: _paidByUserId,
        paidAt: _selectedDate,
        description: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        splitType: _splitMode,
        type: _isIncome ? 'income' : 'expense',
        splits: splits,
      );

      if (_selectedShoppingItems.isNotEmpty) {
        final shoppingRepo = ref.read(shoppingRepositoryProvider);
        for (final item in _selectedShoppingItems) {
            await shoppingRepo.toggleItem(
              itemId: item.id,
              completed: true,
              userId: null,
            );
        }
        ref.invalidate(shoppingItemsProvider);
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense != null ? 'Gasto actualizado' : 'Gasto guardado'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);
    
    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Center(child: Text('Error: $e')),
      data: (members) {
        if (_paidByUserId.isEmpty) {
          final currentUserId = ref.read(currentUserIdProvider);
          final matchingMember = members.any((m) => m.userId == currentUserId) 
            ? members.firstWhere((m) => m.userId == currentUserId)
            : members.first;
          _paidByUserId = matchingMember.userId;
          
          if (_selectedMembersForSplit.isEmpty && widget.expense == null) {
             _selectedMembersForSplit = members.map((m) => m.userId).toSet();
          }
        }

        final payer = members.firstWhere((m) => m.userId == _paidByUserId, orElse: () => members.first);

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildTypeToggle(),
                      const SizedBox(height: 24),
                      _buildAmountField(),
                      const SizedBox(height: 32),
                      _buildTitleField(),
                      const SizedBox(height: 24),
                      _buildDateAndPayerRow(context, payer, members),
                      const SizedBox(height: 24),
                      _buildShoppingIntegration(context, shoppingItemsAsync),
                      const SizedBox(height: 32),
                      _buildCategorySelector(context),
                      const SizedBox(height: 32),
                      _buildSplitConfiguration(context, members),
                      const SizedBox(height: 40),
                      _buildSaveButton(),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isEditing = widget.expense != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            isEditing ? 'Modificar Gasto' : 'Nuevo Gasto',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accentRed),
              onPressed: () => _confirmDelete(),
            )
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Eliminar gasto?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref.read(expenseRepositoryProvider).deleteExpense(widget.expense!.id);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  void _onAmountChanged(String val) {
    String clean = val.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
       _amountController.text = '';
       return;
    }
    int? parsed = int.tryParse(clean);
    if (parsed != null) {
      String formatted = NumberFormat.decimalPattern('es_ES').format(parsed);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeOption(
              label: 'Gasto',
              isSelected: !_isIncome,
              onTap: () => setState(() => _isIncome = false),
            ),
          ),
          Expanded(
            child: _buildTypeOption(
              label: 'Ingreso',
              isSelected: _isIncome,
              onTap: () => setState(() => _isIncome = true),
              activeColor: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color activeColor = AppColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    return Center(
      child: Column(
        children: [
          const Text('Monto total', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            onChanged: _onAmountChanged,
            textAlign: TextAlign.center,
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 56, fontWeight: FontWeight.w900, letterSpacing: -2.0),
            decoration: const InputDecoration(
              prefixText: '\$',
              prefixStyle: TextStyle(color: AppColors.textMuted, fontSize: 32, fontWeight: FontWeight.w700),
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _titleController,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
        decoration: const InputDecoration(
          hintText: '¿Qué compraste? (Opcional)',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 16),
          border: InputBorder.none,
          icon: Icon(Icons.shopping_bag_outlined, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildDateAndPayerRow(BuildContext context, MemberModel payer, List<MemberModel> members) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.calendar_today_rounded,
            label: 'Fecha',
            value: DateFormat('d MMM', 'es').format(_selectedDate),
            onTap: _selectDate,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionTile(
            icon: Icons.person_outline_rounded,
            label: 'Pagó',
            value: payer.displayName,
            onTap: () => _showMemberSelector(context, members),
          ),
        ),
      ],
    );
  }

  void _showMemberSelector(BuildContext context, List<MemberModel> members) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pagado por', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                ...members.map((member) => ListTile(
                  leading: CustomUserAvatar(avatarUrl: member.avatarUrl, name: member.displayName, radius: 20),
                  title: Text(member.displayName, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  onTap: () {
                    setState(() => _paidByUserId = member.userId);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, required String value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCategorySelector(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_selectedCategory!['color'] as Color).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Text(_selectedCategory!['icon'], style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categoría', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  Text(_selectedCategory!['name'], style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Seleccionar Categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory!['id'] == cat['id'];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: (cat['color'] as Color).withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Text(cat['icon'], style: const TextStyle(fontSize: 20)),
                      ),
                      title: Text(cat['name'], style: TextStyle(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShoppingIntegration(BuildContext context, AsyncValue<List<ShoppingItemModel>> shoppingItemsAsync) {
    return shoppingItemsAsync.when(
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => _showShoppingItemsSelector(context, items),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.shopping_cart_outlined, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedShoppingItems.isEmpty ? 'Vincular con la lista' : '${_selectedShoppingItems.length} artículos vinculados',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      const Text('Marca artículos como comprados', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showShoppingItemsSelector(BuildContext context, List<ShoppingItemModel> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Artículos de la Lista', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isSelected = _selectedShoppingItems.contains(item);
                        return ListTile(
                          leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          trailing: Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? AppColors.primary : AppColors.divider),
                          onTap: () {
                            setModalState(() {
                              if (isSelected) {
                                _selectedShoppingItems.remove(item);
                              } else {
                                _selectedShoppingItems.add(item);
                                _matchAndSetCategory(item.name);
                              }
                            });
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: const StadiumBorder(), elevation: 0),
                        child: const Text('Listo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  Widget _buildSplitConfiguration(BuildContext context, List<MemberModel> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('División del gasto', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: SplitType.values.map((mode) {
            final isSelected = _splitMode == mode;
            String label = '';
            IconData icon = Icons.help_outline;
            switch (mode) {
              case SplitType.equal: label = '50/50'; icon = Icons.balance_rounded; break;
              case SplitType.fixed: label = 'Fijo'; icon = Icons.calculate_rounded; break;
              case SplitType.gift: label = 'Regalo'; icon = Icons.redeem_rounded; break;
              case SplitType.personal: label = 'Solo yo'; icon = Icons.person_rounded; break;
            }
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => _splitMode = mode);
              },
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider, width: 1.5),
              showCheckmark: false,
              avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondary),
              backgroundColor: AppColors.surface,
              selectedColor: AppColors.primary,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: const StadiumBorder(),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _buildSplitDetails(members),
        ),
      ],
    );
  }

  Widget _buildSplitDetails(List<MemberModel> members) {
    if (_splitMode == SplitType.equal) {
      return Wrap(
        spacing: 8,
        children: members.map((m) {
          final isSelected = _selectedMembersForSplit.contains(m.userId);
          return FilterChip(
            label: Text(m.displayName),
            selected: isSelected,
            onSelected: (val) {
              setState(() {
                if (val) {
                  _selectedMembersForSplit.add(m.userId);
                } else if (_selectedMembersForSplit.length > 1) {
                  _selectedMembersForSplit.remove(m.userId);
                }
              });
            },
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            shape: const StadiumBorder(),
            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
            labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500),
          );
        }).toList(),
      );
    } else if (_splitMode == SplitType.fixed) {
      return Column(
        children: members.map((m) {
          final controller = TextEditingController(text: _fixedSplitAmounts[m.userId]?.toStringAsFixed(2) ?? '');
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
            child: Row(
              children: [
                CustomUserAvatar(avatarUrl: m.avatarUrl, name: m.displayName, radius: 16),
                const SizedBox(width: 12),
                Expanded(child: Text(m.displayName, style: const TextStyle(fontWeight: FontWeight.w600))),
                const Text('\$', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
                    decoration: const InputDecoration(border: InputBorder.none, hintText: '0.00'),
                    onChanged: (val) => _fixedSplitAmounts[m.userId] = double.tryParse(val) ?? 0.0,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_splitMode == SplitType.gift) {
      return _buildInfoBox('🎁 Este gasto no afectará el balance de tu pareja.', AppColors.primary);
    } else if (_splitMode == SplitType.personal) {
      return _buildInfoBox('👤 Registrado como gasto personal.', AppColors.textSecondary);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoBox(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), border: Border.all(color: color.withValues(alpha: 0.1)), borderRadius: BorderRadius.circular(16)),
      child: Text(text, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) 
          : Text(_isIncome ? 'Guardar Ingreso' : 'Guardar Gasto', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      ),
    );
  }
}
