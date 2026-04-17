import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/receipt_scan_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/domain/models/receipt_scan_result.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/new_items_suggestion_banner.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/receipt_preview_widget.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'expense_category_matcher.dart';
import 'expense_form_components.dart';
import 'expense_form_data.dart';
import 'expense_form_selectors.dart';
import 'expense_shopping_components.dart';
import 'expense_split_builder.dart';
import 'expense_split_components.dart';
import 'expense_split_state.dart';

class ExpenseFormSheet extends ConsumerStatefulWidget {
  final ExpenseModel? expense;
  final bool defaultOnlyMe;
  final bool triggerScanOnOpen;

  const ExpenseFormSheet({
    super.key,
    this.expense,
    this.defaultOnlyMe = false,
    this.triggerScanOnOpen = false,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();

  static Future<void> show(BuildContext context,
      {ExpenseModel? expense,
      bool defaultOnlyMe = false,
      bool triggerScanOnOpen = false,}) {
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
            triggerScanOnOpen: triggerScanOnOpen,
          ),
        ),
      ),
    );
  }
}

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _showSuccessState = false;
  bool _isIncome = false;
  Map<String, dynamic>? _selectedCategory;

  // Form fields
  DateTime _selectedDate = DateTime.now();
  String _paidByUserId = '';
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();

  // Shopping items integration
  final Set<ShoppingItemModel> _selectedShoppingItems = {};
  bool _isScanningReceipt = false;
  ReceiptScanResult? _scanResult;
  List<String> _unmatchedOcrItems = [];
  final Set<ShoppingItemModel> _ocrMatchedShoppingItems = {};

  // Split logic
  SplitType _splitMode = SplitType.equal;
  Set<String> _selectedMembersForSplit = {}; // For 'equal'
  late final ExpenseFixedSplitManager _fixedSplitManager;
  final List<Map<String, dynamic>> _expenseCategories =
      buildExpenseCategories();
  final List<Map<String, dynamic>> _incomeCategories = buildIncomeCategories();

  List<Map<String, dynamic>> get _currentCategories =>
      _isIncome ? _incomeCategories : _expenseCategories;

  List<MemberModel> _financeMembers(List<MemberModel> members) {
    final caps = ref.read(householdCapabilitiesProvider);
    if (caps.type != HouseholdType.family) return members;

    final adults = members.where((member) => member.isAdult).toList();
    return adults.isNotEmpty ? adults : members;
  }

  @override
  void initState() {
    super.initState();
    _selectedCategory = _expenseCategories.first;
    _titleController.addListener(_onTitleChanged);
    _fixedSplitManager = ExpenseFixedSplitManager(
      formatAmount: _formatInputAmount,
      parseAmount: _parseFormattedAmount,
      readTotalInput: () => _amountController.text,
      onStateChanged: () => setState(() {}),
      isMounted: () => mounted,
    );

    if (widget.expense != null) {
      _isIncome = widget.expense!.type == 'income';
      _loadExpenseData(widget.expense!);
    } else if (widget.defaultOnlyMe) {
      _splitMode = SplitType.personal;
    }

    if (widget.expense == null) {
      _initializeDefaultSelections();
    }

    if (widget.triggerScanOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scanReceipt(ImageSource.camera);
      });
    }
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    _amountController.dispose();
    _titleController.dispose();
    _fixedSplitManager.dispose();
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
    final match = resolveExpenseCategoryMatch(
      title: t,
      isIncome: _isIncome,
      expenseCategories: _expenseCategories,
      incomeCategories: _incomeCategories,
      selectedCategory: _selectedCategory,
    );

    _isIncome = match.isIncome;
    _selectedCategory = match.selectedCategory;
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
        final initialFixedAmounts = <String, double>{};
        for (final s in splits) {
          initialFixedAmounts[s.userId] = s.amount;
        }
        _fixedSplitManager.seedAmounts(initialFixedAmounts);
      }
    }
  }

  Future<void> _initializeDefaultSelections() async {
    try {
      final members = await ref.read(householdMembersProvider.future);
      if (!mounted || members.isEmpty || _paidByUserId.isNotEmpty) return;
      final financeMembers = _financeMembers(members);

      final currentUserId = ref.read(currentUserIdProvider);
      final matchingMember =
          financeMembers.any((m) => m.userId == currentUserId)
              ? financeMembers.firstWhere((m) => m.userId == currentUserId)
              : financeMembers.first;

      setState(() {
        _paidByUserId = matchingMember.userId;
        if (_selectedMembersForSplit.isEmpty) {
          _selectedMembersForSplit =
              financeMembers.map((m) => m.userId).toSet();
        }
      });
    } catch (error, stackTrace) {
      log.w(
        'ExpenseFormSheet could not initialize default selections',
        error: error,
        stackTrace: stackTrace,
      );
      // Members provider will surface its own loading/error state in build.
    }
  }

  Future<void> _scanReceipt(ImageSource source) async {
    if (_isScanningReceipt) return;
    setState(() => _isScanningReceipt = true);
    try {
      final service = ReceiptScanService(Supabase.instance.client);
      final result = await service.scan(source: source);
      if (result == null || !mounted) return;
      _prefillFromScan(result);

      final canLink = ref.read(canUseReceiptShoppingLinkProvider);
      if (canLink) {
        _matchOcrItemsToShoppingList(result.detectedItems);
      }
    } on ScanLimitException catch (e) {
      debugPrint('[ReceiptScan] Límite alcanzado: $e');
      if (!mounted) return;
      if (e.isPremium) {
        // Usuario premium que agotó sus 50 scans: solo informar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.warning,
            duration: const Duration(seconds: 8),
          ),
        );
      } else {
        // Usuario free que agotó sus 10 scans: mostrar paywall
        PremiumPaywall.show(context);
      }
    } catch (e, st) {
      debugPrint('[ReceiptScan] ERROR: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo leer el ticket: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
    } finally {
      if (mounted) setState(() => _isScanningReceipt = false);
    }
  }

  void _prefillFromScan(ReceiptScanResult result) {
    setState(() {
      _scanResult = result;

      if ((result.merchant ?? '').isNotEmpty) {
        _titleController.text = result.merchant!;
      }
      if (result.amount != null) {
        _amountController.text = _formatAmountFromOcr(result.amount!);
      }
      if (result.date != null) {
        _selectedDate = result.date!;
      }
      if (result.category != null) {
        final matched = _expenseCategories
            .where((c) => c['id'] == result.category)
            .toList();
        if (matched.isNotEmpty) {
          _selectedCategory = matched.first;
        }
      }
    });

    if (result.hasLowConfidence && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket difícil de leer; revisá los datos antes de guardar'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _matchOcrItemsToShoppingList(List<String> ocrItems) {
    final pending = ref
            .read(shoppingItemsProvider)
            .valueOrNull
            ?.where((item) => !item.completed)
            .toList() ??
        const <ShoppingItemModel>[];

    final householdId =
        ref.read(currentHouseholdProvider).valueOrNull?.id ?? '';

    final result = resolveScanItems(
      ocrItems: ocrItems,
      pendingShoppingItems: pending,
      householdId: householdId,
    );

    setState(() {
      _ocrMatchedShoppingItems
        ..clear()
        ..addAll(result.allLinked);
      _selectedShoppingItems
        ..removeAll(_ocrMatchedShoppingItems)
        ..addAll(result.allLinked);
      _unmatchedOcrItems = result.unrecognized;
    });
  }

  void _clearScan() {
    setState(() {
      _scanResult = null;
      _unmatchedOcrItems = [];
      _selectedShoppingItems.removeAll(_ocrMatchedShoppingItems);
      _ocrMatchedShoppingItems.clear();
    });
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
          const SnackBar(content: Text('Ingresa un monto válido.')),);
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) throw Exception('No pertenecés a un hogar');

    final members = await ref.read(householdMembersProvider.future);
    final financeMembers = _financeMembers(members);

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

      final household = ref.read(currentHouseholdProvider).valueOrNull;
      final splitResult = ExpenseSplitBuilder.build(
        showSplit: showSplit,
        splitMode: _splitMode,
        amount: amountParsed,
        paidByUserId: _paidByUserId,
        financeMembers: financeMembers,
        selectedMembers: _selectedMembersForSplit,
        fixedAmounts: _fixedSplitManager.amounts,
        defaultRatio: household?.defaultSplitRatio ?? 0.5,
        currentUserId: ref.read(currentUserIdProvider),
      );

      if (splitResult.hasValidationError) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(splitResult.validationMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final splits = splitResult.splits;

      final descriptionParts = <String>[];
      if (_selectedShoppingItems.isNotEmpty) {
        final itemsStr = _selectedShoppingItems
            .map((e) => '- ${e.emoji} ${e.name}')
            .join('\n');
        descriptionParts.add('Lista de compras:\n$itemsStr');
      }
      final description = descriptionParts.join('\n\n');

      String? receiptPath = widget.expense?.receiptPath;
      if (_scanResult != null) {
        try {
          final receiptService = ReceiptScanService(Supabase.instance.client);
          receiptPath = await receiptService.uploadReceipt(
            localImagePath: _scanResult!.localImagePath,
            householdId: householdId,
          );
        } catch (e) {
          debugPrint('[ExpenseForm] Upload de ticket falló: $e');
        }
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
        receiptPath: receiptPath,
      );
      saveResult.fold(
        (failure) => throw failure,
        (_) {},
      );

      int shoppingItemsSynced = 0;
      if (_selectedShoppingItems.isNotEmpty) {
        final shoppingRepo = ref.read(shoppingRepositoryProvider);
        final userId = ref.read(currentUserIdProvider);
        for (final item in _selectedShoppingItems) {
          if (item.id.startsWith('temp_')) {
            // Nuevo item (detectado por OCR, no estaba en la lista):
            // primero lo agrega, luego lo marca como comprado.
            final addResult = await shoppingRepo.addItem(
              name: item.name,
              category: (item.category != 'general')
                  ? item.category
                  : (_selectedCategory?['id'] ?? 'general'),
              emoji: item.emoji,
              userId: userId ?? '',
              householdId: householdId,
            );

            // Usar match explícito para garantizar que el await del toggleItem
            // se resuelve correctamente (fold con lambdas async no siempre await bien).
            if (addResult.isRight()) {
              final newItem = addResult.getRight().toNullable()!;
              await shoppingRepo.toggleItem(
                itemId: newItem.id,
                completed: true,
                userId: userId,
              );
              shoppingItemsSynced++;
            }
          } else {
            final toggleResult = await shoppingRepo.toggleItem(
              itemId: item.id,
              completed: true,
              userId: userId,
            );
            if (toggleResult.isRight()) shoppingItemsSynced++;
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
        setState(() => _showSuccessState = true);
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        Navigator.pop(context);
        final baseMsg = widget.expense != null ? 'Gasto actualizado' : 'Gasto guardado';
        final shoppingMsg = shoppingItemsSynced > 0
            ? ' · $shoppingItemsSynced ${shoppingItemsSynced == 1 ? 'artículo' : 'artículos'} comprados ✅'
            : '';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$baseMsg$shoppingMsg'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showSuccessState = false;
        });
      }
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
        final financeMembers = _financeMembers(members);

        final caps = ref.watch(householdCapabilitiesProvider);
        final showSplit = caps.showExpensesSplit;

        final payer = financeMembers.firstWhere(
          (m) => m.userId == _paidByUserId,
          orElse: () => financeMembers.first,
        );

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
                        borderRadius: BorderRadius.circular(2),),),
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
                          if (!_isIncome && _scanResult != null) ...[
                            const SizedBox(height: 10),
                            _buildReceiptPreviewInline(),
                          ],
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
                          _buildDateAndPayerRow(
                            context,
                            payer,
                            financeMembers,
                          ),
                          const SizedBox(height: 28),
                          _buildShoppingIntegration(
                              context, shoppingItemsAsync,),
                          if (_unmatchedOcrItems.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            NewItemsSuggestionBanner(
                              items: _unmatchedOcrItems,
                              householdId: ref
                                      .read(currentHouseholdProvider)
                                      .valueOrNull
                                      ?.id ??
                                  '',
                              onDismiss: () =>
                                  setState(() => _unmatchedOcrItems = []),
                              onItemsAdded: (addedItems) {
                                setState(() {
                                  _selectedShoppingItems.addAll(addedItems);
                                  _ocrMatchedShoppingItems.addAll(addedItems);
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: 'Categoría',
                            title: _isIncome
                                ? 'Cómo querés clasificarlo'
                                : 'Dónde entra este gasto',
                            subtitle:
                                'Podés elegirla, pero también la sugerimos automáticamente según cómo lo describas.',
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
                            _buildSplitConfiguration(context, financeMembers),
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
    return ExpenseFormHeader(
      isEditing: widget.expense != null,
      isIncome: _isIncome,
      onClose: () => Navigator.pop(context),
      onDelete: widget.expense != null ? _confirmDelete : null,
    );
  }

  Widget _buildSectionIntro({
    required String eyebrow,
    required String title,
    required String subtitle,
  }) {
    return ExpenseSectionIntro(
      eyebrow: eyebrow,
      title: title,
    );
  }

  Future<void> _confirmDelete() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Eliminar gasto?',
            style: TextStyle(fontWeight: FontWeight.w900),),
        content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
            child: const Text('Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),),
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

  /// Formatea el monto detectado por OCR al estilo argentino: punto para miles,
  /// coma para decimal. Ej: 10666.5 → "10.666,50"
  String _formatAmountFromOcr(double amount) {
    if (amount <= 0) return '';
    final intPart = amount.truncate();
    final decPart = ((amount - intPart) * 100).round().abs();
    final intFormatted = NumberFormat('#,##0', 'es_ES').format(intPart);
    return '$intFormatted,${decPart.toString().padLeft(2, '0')}';
  }

  void _dismissKeyboard() {
    _fixedSplitManager.dismissKeyboard();
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
    return ExpenseTypeOption(
      label: label,
      isSelected: isSelected,
      onTap: onTap,
    );
  }

  Widget _buildAmountField() {
    return ExpenseAmountField(
      controller: _amountController,
      onChanged: _onAmountChanged,
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
          if (!_isIncome)
            GestureDetector(
              onTap: _isScanningReceipt
                  ? null
                  : () => _scanReceipt(ImageSource.camera),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _scanResult != null
                      ? AppColors.accentGreen.withValues(alpha: 0.12)
                      : AppColors.accentBlue.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _isScanningReceipt
                    ? const Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentBlue,
                        ),
                      )
                    : Icon(
                        _scanResult != null
                            ? Icons.receipt_long_rounded
                            : Icons.document_scanner_outlined,
                        color: _scanResult != null
                            ? AppColors.accentGreen
                            : AppColors.accentBlue,
                        size: 20,
                      ),
              ),
            )
          else
            Icon(
              Icons.account_balance_wallet_outlined,
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
      BuildContext context, MemberModel payer, List<MemberModel> members,) {
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
              onTap: () => showExpenseMemberSelectorSheet(
                context: context,
                members: members,
                onSelected: (member) {
                  setState(() => _paidByUserId = member.userId);
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionTile(
      {required IconData icon,
      required String label,
      required String value,
      required VoidCallback onTap,}) {
    return ExpenseActionTile(
      icon: icon,
      label: label,
      value: value,
      onTap: onTap,
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    return GestureDetector(
      onTap: () => showExpenseCategorySelectorSheet(
        context: context,
        categories: _currentCategories,
        selectedCategory: _selectedCategory!,
        onSelected: (category) {
          setState(() => _selectedCategory = category);
        },
      ),
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
                CategoryMapping.getCategoryMaterialIcon(
                    _selectedCategory!['id'],),
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
                          fontWeight: FontWeight.w500,),),
                  Text(_selectedCategory!['name'],
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,),),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary,),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingIntegration(BuildContext context,
      AsyncValue<List<ShoppingItemModel>> shoppingItemsAsync,) {
    if (_isIncome) return const SizedBox.shrink();

    // Para usuarios no-premium, no mostrar la sección de vinculación.
    // El scan solo pre-rellena monto y categoría.
    final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
    if (!isPremium) return const SizedBox.shrink();

    return shoppingItemsAsync.when(
      data: (allItems) {
        // Items auto-agregados por OCR (temp_) vs los que ya estaban en lista
        final ocrAutoAdded = _ocrMatchedShoppingItems
            .where((i) => i.id.startsWith('temp_'))
            .toSet();

        return ExpenseShoppingIntegrationCard(
          isPremium: true,
          linkedItems: _selectedShoppingItems.toList(),
          autoAddedItems: ocrAutoAdded,
          onTap: () => _showShoppingItemsSelector(context),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildReceiptPreviewInline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ReceiptPreviewWidget(
              localPath: _scanResult!.localImagePath,
              onRemove: _clearScan,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScanButton(
                  icon: Icons.camera_alt_outlined,
                  label: 'Re-escanear',
                  isLoading: _isScanningReceipt,
                  onTap: _isScanningReceipt
                      ? null
                      : () => _scanReceipt(ImageSource.camera),
                ),
                const SizedBox(height: 6),
                _ScanButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Galería',
                  isLoading: false,
                  onTap: _isScanningReceipt
                      ? null
                      : () => _scanReceipt(ImageSource.gallery),
                ),
              ],
            ),
          ],
        ),
        if (_scanResult!.hasLowConfidence) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Confianza baja: revisá los datos antes de guardar.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  void _showShoppingItemsSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ShoppingItemsSelectorSheet(
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
      BuildContext context, List<MemberModel> members,) {
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

            return ExpenseSplitModeChip(
              label: label,
              icon: icon,
              isSelected: isSelected,
              onTap: () {
                _dismissKeyboard();
                setState(() => _splitMode = mode);
              },
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
                  avatarUrl: m.avatarUrl, name: m.displayName, radius: 14,),
              title: Text(m.displayName, style: const TextStyle(fontSize: 13)),
              trailing: Text('${(memRatio * 100).toInt()}%',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: theme.primary,),),
            );
          }).toList(),
        );
      }
      return _buildEqualSelection(members);
    } else if (_splitMode == SplitType.fixed) {
      return Column(
        children: members.map((m) {
          final focusNode =
              _fixedSplitManager.focusNodeForMember(m.userId, members);
          final controller = _fixedSplitManager.controllerForMember(m.userId);
          final currentAmount = _fixedSplitManager.amountFor(m.userId);
          if (!focusNode.hasFocus) {
            _fixedSplitManager.syncControllerTextIfNeeded(
              m.userId,
              currentAmount,
            );
          }

          return ExpenseFixedSplitRow(
            member: m,
            controller: controller,
            focusNode: focusNode,
            onChanged: (val) =>
                _fixedSplitManager.onChanged(m.userId, val, members),
          );
        }).toList(),
      );
    } else if (_splitMode == SplitType.gift) {
      return _buildInfoBox(
          'Este gasto no afectará el balance ${caps.actionMemberLabel}.',
          AppColors.primary,);
    } else if (_splitMode == SplitType.personal) {
      return _buildInfoBox(
          'Registrado como gasto personal.', theme.textSecondary,);
    }
    return const SizedBox.shrink();
  }

  Widget _buildInfoBox(String text, Color color) {
    return ExpenseInfoBox(
      text: text,
      color: color,
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: AnimatedPress(
        scale: _isLoading ? 1 : 0.97,
        onTap: _isLoading ? null : _saveExpense,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.primary,
            disabledForegroundColor: Colors.white,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.22),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              );
            },
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : _showSuccessState
                    ? Row(
                        key: const ValueKey('success'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.expense != null
                                ? 'Actualizado'
                                : (_isIncome
                                    ? 'Ingreso guardado'
                                    : 'Gasto guardado'),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('idle'),
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
        ),
      ),
    );
  }

  Widget _buildEqualSelection(List<MemberModel> members) {
    return ExpenseEqualSplitSelection(
      members: members,
      selectedMembers: _selectedMembersForSplit,
      onToggle: (userId) {
        setState(() {
          final isSelected = _selectedMembersForSplit.contains(userId);
          if (isSelected) {
            if (_selectedMembersForSplit.length > 1) {
              _selectedMembersForSplit.remove(userId);
            }
          } else {
            _selectedMembersForSplit.add(userId);
          }
        });
      },
    );
  }
}

class _ScanButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ScanButton({
    required this.icon,
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.accentBlue.withValues(alpha: 0.07),
          border: Border.all(
            color: AppColors.accentBlue.withValues(alpha: 0.25),
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 18, color: AppColors.accentBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accentBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
