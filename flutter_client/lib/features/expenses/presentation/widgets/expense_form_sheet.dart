import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/ocr_log_service.dart';
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
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';
import 'package:homesync_client/features/shopping/presentation/providers/shopping_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
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

  static Future<void> show(
    BuildContext context, {
    ExpenseModel? expense,
    bool defaultOnlyMe = false,
    bool triggerScanOnOpen = false,
  }) {
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

  // TelemetrÃ­a OCR: id de la fila de log para asociar matcher_result + user_action.
  String? _ocrLogId;
  bool _ocrConfirmed = false;

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
    // Si hubo scan y el usuario cerrÃ³ sin confirmar, lo marcamos como cancelled.
    if (_ocrLogId != null && !_ocrConfirmed) {
      OcrLogService(Supabase.instance.client).updateUserAction(
        logId: _ocrLogId!,
        action: 'cancelled',
      );
    }
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
    final t = AppLocalizations.of(context);
    if (_isScanningReceipt) return;
    setState(() => _isScanningReceipt = true);
    try {
      final service = ReceiptScanService(Supabase.instance.client);
      final result = await service.scan(source: source);
      if (result == null || !mounted) return;
      _prefillFromScan(result);

      // Logging asÃ­ncrono â€” no bloquea la UI ni rompe si falla.
      final isPremium = ref.read(premiumProvider).value ?? false;
      final householdId = ref.read(currentHouseholdProvider).value?.id;
      OcrLogService(Supabase.instance.client)
          .logScan(
        merchant: result.merchant,
        confidence: result.confidence,
        rawItems: result.rawItems,
        householdId: householdId,
        tier: isPremium ? 'premium' : 'free',
      )
          .then((logId) {
        if (logId != null && mounted) {
          setState(() => _ocrLogId = logId);
        }
      });

      // Solo corremos el matcher para categorÃ­as donde tiene sentido vincular
      // con la lista de compras. Para cafeterÃ­as, transporte, servicios, etc.
      // el usuario no espera ver productos detectados.
      const shoppingRelevantCategories = {'supermarket', 'health'};
      if (shoppingRelevantCategories.contains(result.category)) {
        _matchOcrItemsToShoppingList(result.rawItems);
      }
    } catch (e, st) {
      debugPrint('[ReceiptScan] ERROR: $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.expensesFormOcrError(e.toString())),
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

      final merchant = result.merchant;
      if ((merchant ?? '').isNotEmpty) {
        _titleController.text = merchant!;
      }
      final amount = result.amount;
      if (amount != null) {
        _amountController.text = _formatAmountFromOcr(amount);
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
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.expensesFormOcrLowConfidence),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _matchOcrItemsToShoppingList(List<String> ocrItems) {
    final pending = ref
            .read(shoppingItemsProvider)
            .value
            ?.where((item) => !item.completed)
            .toList() ??
        const <ShoppingItemModel>[];

    final householdId =
        ref.read(currentHouseholdProvider).value?.id ?? '';

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

    // TelemetrÃ­a: registramos el resultado del matcher para anÃ¡lisis offline.
    final logId = _ocrLogId;
    if (logId != null) {
      OcrLogService(Supabase.instance.client).updateMatcherResult(
        logId: logId,
        matcherResult: {
          'matched': result.toMarkPurchased.map((i) => i.name).toList(),
          'to_add': result.toAddAndMark.map((i) => i.name).toList(),
          'unrecognized': result.unrecognized,
          'dropped': result.dropped,
        },
      );
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
    final t = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    final cleanAmtStr =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amountParsed = double.tryParse(cleanAmtStr);
    if (amountParsed == null || amountParsed <= 0) {
      final t = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.expensesFormValidationAmountRequired)),
      );
      return;
    }

    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) {
      throw Exception(t.expensesFormValidationNoHousehold);
    }

    final members = await ref.read(householdMembersProvider.future);
    final financeMembers = _financeMembers(members);

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);

      String computedTitle = _titleController.text.trim();
      if (computedTitle.isEmpty) {
        if (_selectedShoppingItems.isNotEmpty) {
          computedTitle = t.expensesFormAutoTitleSupermarketShopping;
        } else {
          final selectedId = _selectedCategory!['id'] as String;
          computedTitle = _isIncome
              ? localizedIncomeCategoryName(t, selectedId)
              : localizedExpenseCategoryName(t, selectedId);
        }
      }

      final caps = ref.read(householdCapabilitiesProvider);
      final household = ref.read(currentHouseholdProvider).value;
      final showSplit = _shouldShowSplitControls(caps);
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
      final effectiveSplitType =
          !showSplit && household?.householdType == 'family'
              ? SplitType.fixed
              : (!caps.showExpensesSplit ? SplitType.personal : _splitMode);

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
        receiptPath = null;
        debugPrint(
          '[ExpenseForm] Ticket escaneado sin guardar imagen',
        );
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
        splitType: effectiveSplitType,
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

        // Paralelizamos todos los items: antes se hacÃ­a secuencial (add+toggle
        // por item) y con 14 artÃ­culos se iban ~5-6s. Con Future.wait todas las
        // operaciones salen a la vez y el tiempo total â‰ˆ la operaciÃ³n mÃ¡s lenta.
        final futures = _selectedShoppingItems.map((item) async {
          if (item.id.startsWith('temp_')) {
            final addResult = await shoppingRepo.addItem(
              name: item.name,
              category: (item.category != 'general')
                  ? item.category
                  : (_selectedCategory?['id'] ?? 'general'),
              emoji: item.emoji,
              userId: userId ?? '',
              householdId: householdId,
            );
            if (addResult.isRight()) {
              final newItem = addResult.getRight().toNullable()!;
              await shoppingRepo.toggleItem(
                itemId: newItem.id,
                completed: true,
                userId: userId,
              );
              return true;
            }
            return false;
          } else {
            final toggleResult = await shoppingRepo.toggleItem(
              itemId: item.id,
              completed: true,
              userId: userId,
            );
            return toggleResult.isRight();
          }
        });
        final results = await Future.wait(futures);
        shoppingItemsSynced = results.where((ok) => ok).length;
        ref.invalidate(shoppingItemsProvider);
      }

      ref.invalidate(expenseControllerProvider);
      ref.invalidate(combinedFeedControllerProvider);
      ref.invalidate(personalFinanceSummaryProvider);
      ref.invalidate(recentActivityProvider);
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(userBalanceProvider);

      // TelemetrÃ­a OCR: el usuario confirmÃ³ el gasto.
      if (_ocrLogId != null) {
        _ocrConfirmed = true;
        OcrLogService(Supabase.instance.client).updateUserAction(
          logId: _ocrLogId!,
          action: 'confirmed',
        );
      }

      if (mounted) {
        HapticFeedback.mediumImpact();
        setState(() => _showSuccessState = true);
        await Future<void>.delayed(const Duration(milliseconds: 420));
        if (!mounted) return;
        Navigator.pop(context);
        final baseMsg = widget.expense != null
            ? t.expensesFormUpdatedExpense
            : (_isIncome
                ? t.expensesFormSavedIncome
                : t.expensesFormSavedExpense);
        final shoppingMsg = shoppingItemsSynced > 0
            ? ' · ${t.expensesFormShoppingSynced(shoppingItemsSynced)} ?'
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
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.commonErrorWithDetails(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
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
    final t = AppLocalizations.of(context);
    final membersAsync = ref.watch(householdMembersProvider);
    final shoppingItemsAsync = ref.watch(shoppingItemsProvider);

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) {
        return Center(child: Text(t.commonErrorWithDetails(e.toString())));
      },
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Text(t.expensesFormMembersEmpty),
          );
        }
        final financeMembers = _financeMembers(members);

        final caps = ref.watch(householdCapabilitiesProvider);
        final showSplit = _shouldShowSplitControls(caps);

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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
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
                            eyebrow: t.expensesFormSectionDetailEyebrow,
                            title: _isIncome
                                ? t.expensesFormSectionDetailTitleIncome
                                : t.expensesFormSectionDetailTitleExpense,
                            subtitle: _isIncome
                                ? t.expensesFormSectionDetailSubtitleIncome
                                : t.expensesFormSectionDetailSubtitleExpense,
                          ),
                          const SizedBox(height: 14),
                          _buildTitleField(),
                          const SizedBox(height: 28),
                          _buildSectionIntro(
                            eyebrow: t.expensesFormSectionContextEyebrow,
                            title: _isIncome
                                ? t.expensesFormSectionContextTitleIncome
                                : t.expensesFormSectionContextTitleExpense,
                            subtitle: t.expensesFormSectionContextSubtitle,
                          ),
                          const SizedBox(height: 14),
                          _buildDateAndPayerRow(
                            context,
                            payer,
                            financeMembers,
                          ),
                          const SizedBox(height: 28),
                          _buildShoppingIntegration(
                            context,
                            shoppingItemsAsync,
                          ),
                          if (_unmatchedOcrItems.isNotEmpty &&
                              (ref.watch(premiumProvider).value ??
                                  false)) ...[
                            const SizedBox(height: 12),
                            NewItemsSuggestionBanner(
                              items: _unmatchedOcrItems,
                              householdId: ref
                                      .read(currentHouseholdProvider)
                                      .value
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
                            eyebrow: t.expensesFormSectionCategoryEyebrow,
                            title: _isIncome
                                ? t.expensesFormSectionCategoryTitleIncome
                                : t.expensesFormSectionCategoryTitleExpense,
                            subtitle: t.expensesFormSectionCategorySubtitle,
                          ),
                          const SizedBox(height: 14),
                          _buildCategorySelector(context),
                          const SizedBox(height: 28),
                          if (showSplit) ...[
                            _buildSectionIntro(
                              eyebrow: t.expensesFormSectionSplitEyebrow,
                              title: _isIncome
                                  ? t.expensesFormSectionSplitTitleIncome
                                  : t.expensesFormSectionSplitTitleExpense,
                              subtitle: t.expensesFormSectionSplitSubtitle,
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
      builder: (context) {
        final t = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text(
            t.expensesFormDeleteDialogTitle,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(t.expensesFormDeleteDialogBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                t.commonCancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.accentRed),
              child: Text(
                t.commonDelete,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
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
              .showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).commonErrorWithDetails('$e'),
                  ),
                ),
              );
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
  /// coma para decimal. Ej: 10666.5 â†’ "10.666,50"
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

  bool _shouldShowSplitControls(HouseholdCapabilities caps) {
    final household = ref.read(currentHouseholdProvider).value;
    if (household?.householdType == 'family' &&
        household?.financeMode != 'divided') {
      return false;
    }
    return caps.showExpensesSplit;
  }

  Widget _buildTypeToggle() {
    final t = AppLocalizations.of(context);
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
                  label: t.expensesFormTypeExpense,
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
                  label: t.expensesFormTypeIncome,
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
    final t = AppLocalizations.of(context);
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
                    ? t.expensesFormTitleHintIncome
                    : t.expensesFormTitleHintExpense,
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
    BuildContext context,
    MemberModel payer,
    List<MemberModel> members,
  ) {
    final caps = ref.watch(householdCapabilitiesProvider);
    final showPayer = caps.showExpensesSplit;
    final t = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.calendar_today_rounded,
            label: t.expensesFormFieldDate,
            value: DateFormat(
              'd MMM',
              Localizations.localeOf(context).toLanguageTag(),
            ).format(_selectedDate),
            onTap: _selectDate,
          ),
        ),
        if (showPayer) ...[
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionTile(
              icon: Icons.person_outline_rounded,
              label: t.expensesFormFieldPayer,
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

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return ExpenseActionTile(
      icon: icon,
      label: label,
      value: value,
      onTap: onTap,
    );
  }

  Widget _buildCategorySelector(BuildContext context) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => showExpenseCategorySelectorSheet(
        context: context,
        categories: _currentCategories,
        selectedCategory: _selectedCategory!,
        isIncome: _isIncome,
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
                  _selectedCategory!['id'],
                ),
                size: 24,
                color: _selectedCategory!['color'] as Color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.expensesFormFieldCategory,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _isIncome
                        ? localizedIncomeCategoryName(
                            t,
                            _selectedCategory!['id'] as String,
                          )
                        : localizedExpenseCategoryName(
                            t,
                            _selectedCategory!['id'] as String,
                          ),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShoppingIntegration(
    BuildContext context,
    AsyncValue<List<ShoppingItemModel>> shoppingItemsAsync,
  ) {
    if (_isIncome) return const SizedBox.shrink();

    final isPremium = ref.watch(premiumProvider).value ?? false;

    return shoppingItemsAsync.when(
      data: (allItems) {
        final ocrAutoAdded = _ocrMatchedShoppingItems
            .where((i) => i.id.startsWith('temp_'))
            .toSet();

        return ExpenseShoppingIntegrationCard(
          isPremium: isPremium,
          linkedItems: isPremium
              ? _selectedShoppingItems.toList()
              : _ocrMatchedShoppingItems.toList(),
          autoAddedItems: ocrAutoAdded,
          detectedItemNames:
              isPremium ? const [] : _scanResult?.detectedItems ?? [],
          onTap: isPremium
              ? () => _showShoppingItemsSelector(context)
              : () => PremiumPaywall.show(context),
          // Solo permitimos limpiar/quitar si hubo scan (caso tipico:
          // el usuario escaneÃ³ pero el ticket no es de un super â†’ quita todo).
          onClearAll: _scanResult != null
              ? () {
                  // Snapshot para deshacer.
                  final prevSelected =
                      Set<ShoppingItemModel>.from(_selectedShoppingItems);
                  final prevMatched =
                      Set<ShoppingItemModel>.from(_ocrMatchedShoppingItems);
                  final prevUnmatched = List<String>.from(_unmatchedOcrItems);

                  setState(() {
                    _selectedShoppingItems.clear();
                    _ocrMatchedShoppingItems.clear();
                    _unmatchedOcrItems = [];
                  });

                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context).expensesFormShoppingUnlinkedSnack,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: AppColors.textPrimary,
                        duration: const Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                        action: SnackBarAction(
                          label: AppLocalizations.of(context).expensesFormShoppingUnlinkedUndo,
                          textColor: AppColors.primary,
                          onPressed: () {
                            if (!mounted) return;
                            setState(() {
                              _selectedShoppingItems
                                ..clear()
                                ..addAll(prevSelected);
                              _ocrMatchedShoppingItems
                                ..clear()
                                ..addAll(prevMatched);
                              _unmatchedOcrItems = prevUnmatched;
                            });
                          },
                        ),
                      ),
                    );
                }
              : null,
          onRemoveItem: _scanResult != null
              ? (item) {
                  setState(() {
                    _selectedShoppingItems.remove(item);
                    _ocrMatchedShoppingItems.remove(item);
                  });
                }
              : null,
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
    BuildContext context,
    List<MemberModel> members,
  ) {
    final t = AppLocalizations.of(context);
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
                  label = t.expensesFormSplitShared;
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
                label = t.expensesFormSplitFixed;
                icon = Icons.calculate_rounded;
                break;
              case SplitType.gift:
                label = t.expensesFormSplitGift;
                icon = Icons.redeem_rounded;
                break;
              case SplitType.personal:
                label = t.expensesFormSplitPersonal;
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
    final t = AppLocalizations.of(context);
    if (_splitMode == SplitType.equal) {
      final household = ref.watch(currentHouseholdProvider).value;
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
                avatarUrl: m.avatarUrl,
                name: m.displayName,
                radius: 14,
                forceCircular: true,
              ),
              title: Text(m.displayName, style: const TextStyle(fontSize: 13)),
              trailing: Text(
                '${(memRatio * 100).toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.primary,
                ),
              ),
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
        'Este gasto no afectarÃ¡ el balance ${caps.actionMemberLabel(t)}.',
        AppColors.primary,
      );
    } else if (_splitMode == SplitType.personal) {
      return _buildInfoBox(
        'Registrado como gasto personal.',
        theme.textSecondary,
      );
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



