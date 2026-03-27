import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';

import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_categories.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final bool defaultOnlyMe;

  const ExpenseFormSheet({
    super.key,
    this.expense,
    this.defaultOnlyMe = false,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();

  static Future<void> show(BuildContext context,
      {ExpenseModel? expense, bool defaultOnlyMe = false}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: ExpenseFormSheet(
            expense: expense,
            defaultOnlyMe: defaultOnlyMe,
          ),
        ),
      ),
    );
  }
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isIncome = false;
  Map<String, dynamic>? _selectedCategory;

  // Form fields
  DateTime _selectedDate = DateTime.now();
  String _paidByUserId = '';
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  // Shopping items integration
  final Set<ShoppingItemModel> _selectedShoppingItems = {};

  // Split logic
  SplitType _splitMode = SplitType.equal;
  Set<String> _selectedMembersForSplit = {}; // For 'equal'
  final Map<String, double> _fixedSplitAmounts = {}; // For 'fixed'
  final Map<String, TextEditingController> _fixedSplitControllers = {};
  final Map<String, FocusNode> _fixedSplitFocusNodes = {};
  bool _isProgrammaticFixedSplitUpdate = false;

  final List<Map<String, dynamic>> _expenseCategories = [
    {
      'id': 'supermarket',
      'name': 'Supermercado',
      'icon': '🛒',
      'color': AppColors.getCategoryColor('supermarket')
    },
    {
      'id': 'utilities',
      'name': 'Servicios',
      'icon': '💡',
      'color': AppColors.getCategoryColor('utilities')
    },
    {
      'id': 'rent',
      'name': 'Alquiler',
      'icon': '🏠',
      'color': AppColors.getCategoryColor('rent')
    },
    {
      'id': 'restaurants',
      'name': 'Restaurantes',
      'icon': '🍽️',
      'color': AppColors.getCategoryColor('restaurants')
    },
    {
      'id': 'transport',
      'name': 'Transporte',
      'icon': '🚙',
      'color': AppColors.getCategoryColor('transport')
    },
    {
      'id': 'entertainment',
      'name': 'Entretenimiento',
      'icon': '🎬',
      'color': AppColors.getCategoryColor('entertainment')
    },
    {
      'id': 'health',
      'name': 'Salud',
      'icon': '💊',
      'color': AppColors.getCategoryColor('health')
    },
    {
      'id': 'finanzas',
      'name': 'Ahorro / Inversión',
      'icon': '🏦',
      'color': AppColors.getCategoryColor('finanzas')
    },
    {
      'id': 'settlement',
      'name': 'Liquidación',
      'icon': '🤝',
      'color': AppColors.getCategoryColor('settlement')
    },
    {
      'id': 'mercadolibre',
      'name': 'Compras online',
      'icon': '🛍️',
      'color': AppColors.getCategoryColor('mercadolibre')
    },
    {
      'id': 'other',
      'name': 'Otros Gastos',
      'icon': '📦',
      'color': AppColors.getCategoryColor('other')
    },
  ];

  final List<Map<String, dynamic>> _incomeCategories = [
    {
      'id': 'salary',
      'name': 'Sueldo',
      'icon': '💰',
      'color': AppColors.success
    },
    {
      'id': 'freelance',
      'name': 'Freelance',
      'icon': '💻',
      'color': AppColors.accentBlue
    },
    {
      'id': 'ventas',
      'name': 'Ventas',
      'icon': '📊',
      'color': AppColors.accentTeal
    },
    {
      'id': 'bonus',
      'name': 'Bono / Premio',
      'icon': '🎊',
      'color': AppColors.accentPurple
    },
    {
      'id': 'reembolso',
      'name': 'Reembolso',
      'icon': '🔙',
      'color': AppColors.sage
    },
    {
      'id': 'gift',
      'name': 'Regalo',
      'icon': '🎁',
      'color': const Color(0xFFFF8A65)
    },
    {
      'id': 'investment',
      'name': 'Rendimiento',
      'icon': '📈',
      'color': const Color(0xFF4CAF50)
    },
    {
      'id': 'other',
      'name': 'Otros Ingresos',
      'icon': '💵',
      'color': AppColors.success
    },
  ];

  List<Map<String, dynamic>> get _currentCategories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
    _titleController.addListener(_onTitleChanged);

    if (widget.expense != null) {
      _isIncome = widget.expense!.type == 'income';
      _loadExpenseData(widget.expense!);
    } else if (widget.defaultOnlyMe) {
      _splitMode = SplitType.personal;
    }

    if (widget.expense == null) {
      _initializeDefaultSelections();
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _amountController.dispose();
    _titleController.dispose();
    for (final controller in _fixedSplitControllers.values) {
      controller.dispose();
    }
    for (final focusNode in _fixedSplitFocusNodes.values) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTitleChanged() {
    if (widget.expense != null) return; // Don't auto-suggest if editing
    _matchAndSetCategory(_titleController.text);
  }

  void _matchAndSetCategory(String t) {
    setState(() => _internalMatchCategory(t));
  }

  void _internalMatchCategory(String t) {
    t = t.toLowerCase();
    String? matchedId;
    if (t.contains('supermercado') ||
        t.contains('coto') ||
        t.contains('carrefour') ||
        t.contains('despensa') ||
        t.contains('comida') ||
        t.contains('alimento')) {
      matchedId = 'supermarket';
    } else if (t.contains('mercadolibre') || t.contains('mercado libre')) {
      matchedId = 'mercadolibre';
    } else if (t.contains('luz') ||
        t.contains('agua') ||
        t.contains('gas') ||
        t.contains('internet') ||
        t.contains('wifi') ||
        t.contains('servicio')) {
      matchedId = 'utilities';
    } else if (t.contains('alquiler') ||
        t.contains('expensas') ||
        t.contains('renta')) {
      matchedId = 'rent';
    } else if (t.contains('restaurante') ||
        t.contains('cena') ||
        t.contains('pedidosya') ||
        t.contains('delivery') ||
        t.contains('mc') ||
        t.contains('pizza')) {
      matchedId = 'restaurants';
    } else if (t.contains('liquidación') ||
        t.contains('liquidacion') ||
        t.contains('saldar') ||
        t.contains('deuda') ||
        t.contains('hogar')) {
      matchedId = 'settlement';
    } else if (t.contains('ahorro') ||
        t.contains('banco') ||
        t.contains('finanzas')) {
      matchedId = 'finanzas';
    } else if (t.contains('sueldo') ||
        t.contains('nomina') ||
        t.contains('salario') ||
        t.contains('cobro')) {
      matchedId = 'salary';
    } else if (t.contains('freelance') ||
        t.contains('venta') ||
        t.contains('mercadopago') ||
        t.contains('transferencia')) {
      matchedId = 'freelance';
    } else if (t.contains('regalo') ||
        t.contains('premio') ||
        t.contains('sorpresa')) {
      matchedId = 'gift';
    } else if (t.contains('inversion') ||
        t.contains('plazo fijo') ||
        t.contains('bono') ||
        t.contains('bit') ||
        t.contains('crypto')) {
      matchedId = 'investment';
    } else if (t.contains('transporte') ||
        t.contains('uber') ||
        t.contains('cabify') ||
        t.contains('nafta') ||
        t.contains('gasolina') ||
        t.contains('sube') ||
        t.contains('taxi') ||
        t.contains('cole')) {
      matchedId = 'transport';
    } else if (t.contains('cine') ||
        t.contains('teatro') ||
        t.contains('juego') ||
        t.contains('fiesta') ||
        t.contains('salida')) {
      matchedId = 'entertainment';
    } else if (t.contains('farmacia') ||
        t.contains('medico') ||
        t.contains('salud') ||
        t.contains('pastillas') ||
        t.contains('remedio')) {
      matchedId = 'health';
    }

    if (matchedId != null) {
      final isIncomeMatch = _incomeCategories.any((c) => c['id'] == matchedId);
      final isExpenseMatch =
          _expenseCategories.any((c) => c['id'] == matchedId);

      if (isIncomeMatch && !_isIncome) {
        _isIncome = true;
        _selectedCategory =
            _incomeCategories.firstWhere((c) => c['id'] == matchedId);
      } else if (isExpenseMatch && _isIncome) {
        _isIncome = false;
        _selectedCategory =
            _expenseCategories.firstWhere((c) => c['id'] == matchedId);
      } else if (_selectedCategory?['id'] != matchedId) {
        _selectedCategory = _currentCategories.firstWhere(
            (c) => c['id'] == matchedId,
            orElse: () => _currentCategories.first);
      }
    }
  }

  void _loadExpenseData(ExpenseModel exp) {
    _titleController.text = exp.title;
    _amountController.text = exp.amount.toString();
    if (exp.category != null) {
      _selectedCategory = _currentCategories.firstWhere(
        (c) => c['id'] == exp.category,
        orElse: () => _currentCategories.last,
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

    if (exp.splits != null) {
      final splits = exp.splits!;
      if (_splitMode == SplitType.equal) {
        _selectedMembersForSplit = splits.map((s) => s.userId).toSet();
      } else if (_splitMode == SplitType.fixed) {
        for (final s in splits) {
          _fixedSplitAmounts[s.userId] = s.amount;
        }
      }
    }
  }

  Future<void> _initializeDefaultSelections() async {
    try {
      final members = await ref.read(householdMembersProvider.future);
      if (!mounted || members.isEmpty || _paidByUserId.isNotEmpty) return;

      final currentUserId = ref.read(currentUserIdProvider);
      final matchingMember = members.any((m) => m.userId == currentUserId)
          ? members.firstWhere((m) => m.userId == currentUserId)
          : members.first;

      setState(() {
        _paidByUserId = matchingMember.userId;
        if (_selectedMembersForSplit.isEmpty) {
          _selectedMembersForSplit = members.map((m) => m.userId).toSet();
        }
      });
    } catch (_) {
      // Members provider will surface its own loading/error state in build.
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
    if (!_formKey.currentState!.validate()) return;

    final cleanAmtStr =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amountParsed = double.tryParse(cleanAmtStr);
    if (amountParsed == null || amountParsed <= 0) {
      // This case should ideally be caught by the validator, but as a fallback
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa un monto válido.')));
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception("No pertenecés a un hogar");

    final members = await ref.read(householdMembersProvider.future);

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);

      String computedTitle = _titleController.text.trim();
      if (computedTitle.isEmpty) {
        if (_selectedShoppingItems.isNotEmpty) {
          computedTitle = 'Compras del Supermercado';
        } else {
          computedTitle = _selectedCategory!['name'];
        }
      }

      final caps = ref.read(householdCapabilitiesProvider);
      final showSplit = caps.showExpensesSplit;

      List<Map<String, dynamic>> splits = [];

      if (!showSplit) {
        splits = [
          {'user_id': _paidByUserId, 'amount': amountParsed}
        ];
      } else if (_splitMode == SplitType.equal) {
        final household = ref.read(currentHouseholdProvider).valueOrNull;
        final defaultRatio = household?.defaultSplitRatio ?? 0.5;

        if (members.length == 2 && defaultRatio != 0.5) {
          final currentUserId = ref.read(currentUserIdProvider);
          for (final mem in members) {
            final isMe = mem.userId == currentUserId;
            final memRatio = isMe ? defaultRatio : (1.0 - defaultRatio);
            splits.add(
                {'user_id': mem.userId, 'amount': amountParsed * memRatio});
          }
        } else {
          if (_selectedMembersForSplit.isEmpty) {
            throw Exception(
                "Debes seleccionar al menos un miembro para dividir.");
          }
          final splitAmount = amountParsed / _selectedMembersForSplit.length;
          for (final memId in _selectedMembersForSplit) {
            splits.add({'user_id': memId, 'amount': splitAmount});
          }
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
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'El reparto debe sumar el total (\$${amountParsed.toStringAsFixed(2)})'),
              backgroundColor: AppColors.error,
            ),
          );
          setState(() => _isLoading = false);
          return;
        }
      } else if (_splitMode == SplitType.gift) {
        splits = [];
      } else if (_splitMode == SplitType.personal) {
        splits = [
          {'user_id': _paidByUserId, 'amount': amountParsed}
        ];
      }

      String description = '';
      if (_selectedShoppingItems.isNotEmpty) {
        final itemsStr = _selectedShoppingItems
            .map((e) => "- ${e.emoji} ${e.name}")
            .join("\n");
        description = "Lista de compras:\n$itemsStr";
      }

      final saveResult = await repo.saveExpense(
        id: widget.expense?.id,
        householdId: householdId,
        title: computedTitle,
        amount: amountParsed,
        category: _selectedCategory!['id'],
        paidBy: _paidByUserId,
        paidAt: _selectedDate,
        description: description.isEmpty ? null : description,
        splitType: !caps.showExpensesSplit ? SplitType.personal : _splitMode,
        type: _isIncome ? 'income' : 'expense',
        splits: splits,
      );
      saveResult.fold(
        (failure) => throw Exception(failure.message),
        (_) {},
      );

      if (_selectedShoppingItems.isNotEmpty) {
        final shoppingRepo = ref.read(shoppingRepositoryProvider);
        final userId = ref.read(currentUserIdProvider);
        for (final item in _selectedShoppingItems) {
          if (item.id.startsWith('temp_')) {
            final result = await shoppingRepo.addItem(
              name: item.name,
              category: (item.category != 'general')
                  ? item.category
                  : (_selectedCategory?['id'] ?? 'general'),
              emoji: item.emoji,
              userId: userId ?? '',
              householdId: householdId,
            );

            await result.fold(
              (l) async => null,
              (newItem) async => await shoppingRepo.toggleItem(
                itemId: newItem.id,
                completed: true,
                userId: userId,
              ),
            );
          } else {
            await shoppingRepo.toggleItem(
              itemId: item.id,
              completed: true,
              userId: userId,
            );
          }
        }
        ref.invalidate(shoppingItemsProvider);
      }

      ref.invalidate(expenseControllerProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(userBalanceProvider);

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.expense != null
                ? 'Gasto actualizado'
                : 'Gasto guardado'),
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
        if (members.isEmpty) {
          return const Center(
            child: Text('No hay miembros disponibles para registrar gastos.'),
          );
        }

        final caps = ref.watch(householdCapabilitiesProvider);
        final showSplit = caps.showExpensesSplit;

        final payer = members.firstWhere((m) => m.userId == _paidByUserId,
            orElse: () => members.first);

        return Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: context.theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 28,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2))),
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildTypeToggle(),
                          const SizedBox(height: 28),
                          _buildAmountField(),
                          const SizedBox(height: 32),
                          _buildSectionIntro(
                            eyebrow: 'Detalle',
                            title: _isIncome
                                ? '¿De dónde viene?'
                                : '¿Qué estás registrando?',
                            subtitle: _isIncome
                                ? 'Podés dejar un nombre claro para reconocer este ingreso más rápido.'
                                : 'Dale un nombre simple para ubicar este gasto de un vistazo.',
                          ),
                          const SizedBox(height: 14),
                          _buildTitleField(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'Contexto',
                            title: _isIncome
                                ? 'Cuándo y quién lo recibió'
                                : 'Cuándo y quién pagó',
                            subtitle:
                                'Estos datos ordenan el movimiento dentro del hogar.',
                          ),
                          const SizedBox(height: 14),
                          _buildDateAndPayerRow(context, payer, members),
                          const SizedBox(height: 28),
                          _buildShoppingIntegration(
                              context, shoppingItemsAsync),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'Categoría',
                            title: _isIncome
                                ? 'Cómo querés clasificarlo'
                                : 'Dónde entra este gasto',
                            subtitle:
                                'Elegí la categoría para mantener Finanzas más ordenado.',
                          ),
                          const SizedBox(height: 14),
                          _buildCategorySelector(context),
                          const SizedBox(height: 28),
                          if (showSplit) ...[
                            _buildSectionIntro(
                              eyebrow: 'Reparto',
                              title: _isIncome
                                  ? 'Cómo se reparte este ingreso'
                                  : 'Cómo se divide este gasto',
                              subtitle:
                                  'Definí si es compartido, fijo, regalo o personal.',
                            ),
                            const SizedBox(height: 14),
                            _buildSplitConfiguration(context, members),
                          ],
                          const SizedBox(height: 32),
                          const SizedBox(height: 48),
                          _buildSaveButton(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isEditing = widget.expense != null;
    final theme = context.theme;
    final title = isEditing
        ? (_isIncome ? 'Modificar Ingreso' : 'Modificar Gasto')
        : (_isIncome ? 'Nuevo Ingreso' : 'Nuevo Gasto');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              if (isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.accentRed),
                  onPressed: () => _confirmDelete(),
                )
              else
                const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionIntro({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Eliminar gasto?',
            style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(expenseControllerProvider.notifier)
            .deleteExpense(widget.expense!.id);
        ref.invalidate(personalFinanceSummaryProvider);
        ref.invalidate(recentActivityProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(userBalanceProvider);
        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Error: $e')));
        }
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

  double _parseFormattedAmount(String value) {
    final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return 0.0;
    return double.tryParse(normalized) ?? 0.0;
  }

  String _formatInputAmount(double value) {
    if (value <= 0) return '';
    return NumberFormat.decimalPattern('es_ES').format(value.round());
  }

  TextEditingController _controllerForFixedMember(String userId) {
    return _fixedSplitControllers.putIfAbsent(userId, () {
      final initial = _formatInputAmount(_fixedSplitAmounts[userId] ?? 0.0);
      return TextEditingController(text: initial);
    });
  }

  FocusNode _focusNodeForFixedMember(String userId, List<MemberModel> members) {
    return _fixedSplitFocusNodes.putIfAbsent(userId, () {
      final node = FocusNode();
      node.addListener(() {
        if (!mounted) return;
        setState(() {});
        if (node.hasFocus) {
          _applyFixedSplitIntelligentRemainder(userId, members);
        }
      });
      return node;
    });
  }

  void _setFixedControllerText(String userId, double amount) {
    final controller = _controllerForFixedMember(userId);
    final formatted = _formatInputAmount(amount);
    if (controller.text == formatted) return;
    _isProgrammaticFixedSplitUpdate = true;
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isProgrammaticFixedSplitUpdate = false;
  }

  void _applyFixedSplitIntelligentRemainder(
      String userId, List<MemberModel> members) {
    if (members.length != 2) return;
    final total = _parseFormattedAmount(_amountController.text);
    final entered = (_fixedSplitAmounts[userId] ?? 0.0).clamp(0.0, total);
    final otherId = members.firstWhere((m) => m.userId != userId).userId;
    final remaining = (total - entered).clamp(0.0, total);

    _fixedSplitAmounts[userId] = entered;
    _fixedSplitAmounts[otherId] = remaining;
    _setFixedControllerText(otherId, remaining);
  }

  void _onFixedSplitChanged(
      String userId, String value, List<MemberModel> members) {
    if (_isProgrammaticFixedSplitUpdate) return;

    final clean = value.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
      setState(() {
        _fixedSplitAmounts[userId] = 0.0;
        _setFixedControllerText(userId, 0.0);
        _applyFixedSplitIntelligentRemainder(userId, members);
      });
      return;
    }

    final parsed = int.tryParse(clean);
    if (parsed == null) return;

    setState(() {
      final total = _parseFormattedAmount(_amountController.text);
      final entered =
          parsed.toDouble().clamp(0.0, total > 0 ? total : parsed.toDouble());
      _fixedSplitAmounts[userId] = entered;
      _setFixedControllerText(userId, entered);
      _applyFixedSplitIntelligentRemainder(userId, members);
    });
  }

  void _dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final node in _fixedSplitFocusNodes.values) {
      node.unfocus();
    }
  }

  Widget _buildTypeToggle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            alignment: _isIncome ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: _isIncome ? AppColors.success : AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (_isIncome ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: _buildTypeOption(
                  label: 'Gasto',
                  isSelected: !_isIncome,
                  onTap: () {
                    if (_isIncome) {
                      setState(() {
                        _isIncome = false;
                        _selectedCategory = _expenseCategories.first;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: _buildTypeOption(
                  label: 'Ingreso',
                  isSelected: _isIncome,
                  onTap: () {
                    if (!_isIncome) {
                      setState(() {
                        _isIncome = true;
                        _selectedCategory = _incomeCategories.first;
                        _splitMode = SplitType.personal;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 52,
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
              fontSize: 16,
              letterSpacing: isSelected ? -0.2 : 0,
            ),
            child: Text(label),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountField() {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.82),
          width: 1,
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'Monto total',
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 2),
                child: Text(
                  '\$',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(
                width: 150,
                child: TextFormField(
                  autofocus: true,
                  controller: _amountController,
                  onChanged: _onAmountChanged,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                  textAlign: TextAlign.start,
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(
                      color: theme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                    filled: false,
                    fillColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            width: 72,
            height: 1,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            _isIncome
                ? Icons.account_balance_wallet_outlined
                : Icons.shopping_bag_outlined,
            color: theme.textSecondary,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextField(
              controller: _titleController,
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: _isIncome
                    ? '¿De qué es el ingreso? (Opcional)'
                    : '¿Qué compraste? (Opcional)',
                hintStyle: TextStyle(
                  color: theme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                filled: false,
                fillColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateAndPayerRow(
      BuildContext context, MemberModel payer, List<MemberModel> members) {
    final caps = ref.watch(householdCapabilitiesProvider);
    final showSplit = caps.showExpensesSplit;

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
        if (showSplit) ...[
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
      ],
    );
  }

  void _showMemberSelector(BuildContext context, List<MemberModel> members) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pagado por',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 16),
                ...members.map((member) => ListTile(
                      leading: CustomUserAvatar(
                          avatarUrl: member.avatarUrl,
                          name: member.displayName,
                          radius: 20),
                      title: Text(member.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary)),
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

  Widget _buildActionTile(
      {required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(value,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis)),
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
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_selectedCategory!['color'] as Color)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                AppColors.getCategoryMaterialIcon(_selectedCategory!['id']),
                size: 24,
                color: _selectedCategory!['color'] as Color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Categoría',
                      style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500)),
                  Text(_selectedCategory!['name'],
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showCategorySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      builder: (context) {
        return SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Seleccionar Categoría',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary)),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _currentCategories.length,
                  itemBuilder: (context, index) {
                    final cat = _currentCategories[index];
                    final isSelected = _selectedCategory!['id'] == cat['id'];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color:
                                (cat['color'] as Color).withValues(alpha: 0.1),
                            shape: BoxShape.circle),
                        child: Icon(
                          AppColors.getCategoryMaterialIcon(cat['id']),
                          size: 20,
                          color: cat['color'] as Color,
                        ),
                      ),
                      title: Text(cat['name'],
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500)),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary)
                          : null,
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

  Widget _buildShoppingIntegration(BuildContext context,
      AsyncValue<List<ShoppingItemModel>> shoppingItemsAsync) {
    if (_isIncome) return const SizedBox.shrink();

    return shoppingItemsAsync.when(
      data: (allItems) {
        // Eliminamos el early return para que siempre sea visible
        final isPremium = ref.watch(premiumProvider);

        return Opacity(
          opacity: isPremium ? 1.0 : 0.6,
          child: InkWell(
            onTap: isPremium
                ? () => _showShoppingItemsSelector(context)
                : () => PremiumPaywall.show(context),
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPremium
                    ? AppColors.primary.withValues(alpha: 0.05)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isPremium
                      ? AppColors.primary.withValues(alpha: 0.2)
                      : AppColors.divider,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPremium
                          ? Icons.shopping_cart_outlined
                          : Icons.lock_rounded,
                      color:
                          isPremium ? AppColors.primary : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedShoppingItems.isEmpty
                              ? 'Vincular con la lista'
                              : '${_selectedShoppingItems.length} artículos vinculados',
                          style: TextStyle(
                              color: isPremium
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15),
                        ),
                        Text(
                            isPremium
                                ? 'Marca artículos como comprados'
                                : 'Función Premium de HomeSync',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Icon(
                    isPremium
                        ? Icons.add_circle_outline_rounded
                        : Icons.chevron_right_rounded,
                    color: isPremium ? AppColors.primary : AppColors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  void _showShoppingItemsSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ShoppingItemsSelector(
        initialSelected: _selectedShoppingItems,
        onItemsSelected: (selected) {
          setState(() {
            _selectedShoppingItems.clear();
            _selectedShoppingItems.addAll(selected);
            if (selected.isNotEmpty) {
              _internalMatchCategory(selected.last.name);
            }
          });
        },
      ),
    );
  }

  Widget _buildSplitConfiguration(
      BuildContext context, List<MemberModel> members) {
    final theme = context.theme;
    final splitModes = _isIncome
        ? const [SplitType.equal, SplitType.personal]
        : SplitType.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: splitModes.map((mode) {
            final isSelected = _splitMode == mode;
            String label = '';
            IconData icon = Icons.help_outline;

            final householdAsync = ref.watch(currentHouseholdProvider);
            final household = householdAsync.value;

            switch (mode) {
              case SplitType.equal:
                if (_isIncome) {
                  label = 'Compartido';
                  icon = Icons.groups_rounded;
                } else {
                  final ratio = household?.defaultSplitRatio ?? 0.5;
                  if (members.length == 2 && ratio != 0.5) {
                    label =
                        '${(ratio * 100).toInt()}/${(100 - (ratio * 100)).toInt()}';
                    icon = Icons.pie_chart_rounded;
                  } else {
                    label = '50/50';
                    icon = Icons.balance_rounded;
                  }
                }
                break;
              case SplitType.fixed:
                label = 'Fijo';
                icon = Icons.calculate_rounded;
                break;
              case SplitType.gift:
                label = 'Regalo';
                icon = Icons.redeem_rounded;
                break;
              case SplitType.personal:
                label = 'Solo yo';
                icon = Icons.person_rounded;
                break;
            }
            if (label.isEmpty) return const SizedBox.shrink();

            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (val) {
                if (val) {
                  _dismissKeyboard();
                  setState(() => _splitMode = mode);
                }
              },
              side: BorderSide(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : theme.border.withValues(alpha: 0.78),
                width: 1.15,
              ),
              showCheckmark: false,
              avatar: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : theme.elevatedSurface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: isSelected ? AppColors.primary : theme.textSecondary,
                ),
              ),
              backgroundColor: theme.surface,
              selectedColor: theme.primary.withValues(alpha: 0.08),
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : theme.textPrimary,
                fontWeight: FontWeight.w800,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    if (_splitMode == SplitType.equal) {
      final household = ref.watch(currentHouseholdProvider).valueOrNull;
      final defaultRatio = household?.defaultSplitRatio ?? 0.5;

      if (members.length == 2 && defaultRatio != 0.5) {
        final currentUserId = ref.read(currentUserIdProvider);
        return Column(
          children: members.map((m) {
            final isMe = m.userId == currentUserId;
            final memRatio = isMe ? defaultRatio : (1.0 - defaultRatio);
            return ListTile(
              dense: true,
              leading: CustomUserAvatar(
                  avatarUrl: m.avatarUrl, name: m.displayName, radius: 14),
              title: Text(m.displayName, style: const TextStyle(fontSize: 13)),
              trailing: Text('${(memRatio * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: theme.primary)),
            );
          }).toList(),
        );
      }
      return _buildEqualSelection(members);
    } else if (_splitMode == SplitType.fixed) {
      return Column(
        children: members.map((m) {
          final focusNode = _focusNodeForFixedMember(m.userId, members);
          final controller = _controllerForFixedMember(m.userId);
          final currentAmount = _fixedSplitAmounts[m.userId] ?? 0.0;
          if (!focusNode.hasFocus) {
            final formattedAmount = _formatInputAmount(currentAmount);
            if (controller.text != formattedAmount) {
              controller.text = formattedAmount;
            }
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: theme.border.withValues(alpha: 0.82)),
              boxShadow: theme.cardShadow,
            ),
            child: Row(
              children: [
                CustomUserAvatar(
                    avatarUrl: m.avatarUrl, name: m.displayName, radius: 16),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(m.displayName,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.textPrimary))),
                Text('\$',
                    style: TextStyle(
                        color: theme.textMuted,
                        fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  width: 132,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.elevatedSurface,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: theme.border.withValues(alpha: 0.7)),
                  ),
                  child: TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: theme.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      hintText: '0',
                      hintStyle: TextStyle(color: theme.textMuted),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) =>
                        _onFixedSplitChanged(m.userId, val, members),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    } else if (_splitMode == SplitType.gift) {
      return _buildInfoBox(
          'Este gasto no afectará el balance ${caps.actionMemberLabel}.',
          AppColors.primary);
    } else if (_splitMode == SplitType.personal) {
      return _buildInfoBox(
          'Registrado como gasto personal.', theme.textSecondary);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoBox(String text, Color color) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.045),
          border: Border.all(color: color.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.circular(18)),
      child: Text(text,
          style: TextStyle(
              color: color == theme.textSecondary
                  ? theme.textSecondary
                  : color.withValues(alpha: 0.82),
              fontSize: 13,
              fontWeight: FontWeight.w500)),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
          shadowColor: AppColors.primary.withValues(alpha: 0.22),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _isIncome ? 'Guardar Ingreso' : 'Guardar Gasto',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEqualSelection(List<MemberModel> members) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: members.map((m) {
        final isSelected = _selectedMembersForSplit.contains(m.userId);
        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            setState(() {
              if (isSelected) {
                if (_selectedMembersForSplit.length > 1) {
                  _selectedMembersForSplit.remove(m.userId);
                }
              } else {
                _selectedMembersForSplit.add(m.userId);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.24)
                    : AppColors.divider.withValues(alpha: 0.9),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomUserAvatar(
                  avatarUrl: m.avatarUrl,
                  name: m.displayName,
                  radius: 14,
                ),
                const SizedBox(width: 10),
                Text(
                  m.displayName,
                  style: TextStyle(
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ShoppingItemsSelector extends ConsumerStatefulWidget {
  final Set<ShoppingItemModel> initialSelected;
  final Function(Set<ShoppingItemModel>) onItemsSelected;

  const _ShoppingItemsSelector({
    required this.initialSelected,
    required this.onItemsSelected,
  });

  @override
  ConsumerState<_ShoppingItemsSelector> createState() =>
      _ShoppingItemsSelectorState();
}

class _ShoppingItemsSelectorState
    extends ConsumerState<_ShoppingItemsSelector> {
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
                !predefinedMatches.any((pm) =>
                    pm['name']!.toLowerCase() == itemName.toLowerCase())) {
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
                  child: Text('Artículos de la Lista',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary)),
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
                        icon: Icon(Icons.search,
                            size: 20, color: AppColors.textSecondary),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                      onSubmitted: (val) async {
                        if (val.trim().isEmpty) return;
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _searchFocus.requestFocus();

                        await ref
                            .read(shoppingItemsProvider.notifier)
                            .addItem(
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
                          title: Text('Agregar "$_searchQuery"',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary)),
                          subtitle: const Text('Producto personalizado',
                              style: TextStyle(fontSize: 12)),
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
                          leading: Text(item.emoji,
                              style: const TextStyle(fontSize: 24)),
                          title: Text(item.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary)),
                          trailing: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider),
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
                          child: Text('Sugerencias globales',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textMuted,
                                  letterSpacing: 1)),
                        ),
                        ...predefinedMatches.take(25).map((item) {
                          return ListTile(
                            leading: Text(item['emoji']!,
                                style: const TextStyle(fontSize: 22)),
                            title: Text(item['name']!,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary)),
                            trailing: const Icon(
                                Icons.add_circle_outline_rounded,
                                color: AppColors.primary,
                                size: 24),
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
                          elevation: 0),
                      child: const Text('Listo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
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
