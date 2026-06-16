import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/ocr_log_service.dart';
import 'package:homesync_client/core/services/receipt_scan_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
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
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_shake.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/premium_paywall.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'allowance_sheet.dart';
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
  final ValueChanged<bool?>? onCloseWithResult;

  const ExpenseFormSheet({
    super.key,
    this.expense,
    this.defaultOnlyMe = false,
    this.triggerScanOnOpen = false,
    this.onCloseWithResult,
  });

  @override
  ConsumerState<ExpenseFormSheet> createState() => _ExpenseFormSheetState();

  static Future<void> show(
    BuildContext context, {
    ExpenseModel? expense,
    bool defaultOnlyMe = false,
    bool triggerScanOnOpen = false,
  }) async {
    final t = AppLocalizations.of(context);
    final deleted = await AppSheet.show<bool>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: 0.92,
          child: ExpenseFormSheet(
            expense: expense,
            defaultOnlyMe: defaultOnlyMe,
            triggerScanOnOpen: triggerScanOnOpen,
            onCloseWithResult: (result) {
              Navigator.of(sheetContext).pop(result);
            },
          ),
        ),
      ),
    );
    if (deleted == true && context.mounted) {
      AppSnackBar.show(
        context,
        message: t.expensesDeletedSnack,
        type: AppSnackBarType.success,
      );
    }
  }
}

enum _ShoppingRevealPhase { idle, preparing, revealing, revealed }

class _ExpenseFormSheetState extends ConsumerState<ExpenseFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _formScrollController = ScrollController();
  final _shoppingSectionKey = GlobalKey();
  // Incremented on failed validation to play the error shake (see AppShake).
  int _shakeTrigger = 0;
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
  int _amountRevealEpoch = 0;
  int _shoppingRevealEpoch = 0;
  _ShoppingRevealPhase _shoppingRevealPhase = _ShoppingRevealPhase.idle;
  bool _waitForAmountRevealBeforeShopping = false;
  bool _userTouchedScrollAfterScan = false;
  bool _isAutoScrollingToShopping = false;

  // TelemetrÃƒÂ­a OCR: id de la fila de log para asociar matcher_result + user_action.
  String? _ocrLogId;
  bool _ocrConfirmed = false;
  // El matcher corre apenas llega el scan, pero el id del log se inserta en
  // paralelo y puede no estar listo todavÃƒÂ­a. Guardamos el resultado del matcher
  // acÃƒÂ¡ y lo flusheamos en cuanto ambos (id + resultado) estÃƒÂ©n disponibles, sin
  // importar cuÃƒÂ¡l gane la carrera. Sin esto, matcher_result quedaba null en el
  // panel admin (match/nuevos/sin/drop todos en 0).
  Map<String, dynamic>? _pendingMatcherResult;

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
    // Si hubo scan y el usuario cerrÃƒÂ³ sin confirmar, lo marcamos como cancelled.
    if (_ocrLogId != null && !_ocrConfirmed) {
      OcrLogService(Supabase.instance.client).updateUserAction(
        logId: _ocrLogId!,
        action: 'cancelled',
      );
    }
    _titleController.removeListener(_onTitleChanged);
    _formScrollController.dispose();
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
    setState(() {
      _isScanningReceipt = true;
      _userTouchedScrollAfterScan = false;
      _shoppingRevealPhase = _ShoppingRevealPhase.idle;
    });
    try {
      final service = ReceiptScanService(Supabase.instance.client);
      final result = await service.scan(source: source);
      if (result == null || !mounted) return;
      _waitForAmountRevealBeforeShopping =
          result.amount != null && result.amount! > 0;
      _prefillFromScan(result);

      // El servidor ya insertó la fila de ocr_scan_logs (merchant, confianza,
      // items y telemetría) y devolvió su id; el cliente solo la actualiza con
      // el resultado del matcher y la acción final del usuario.
      final scanLogId = result.logId;
      if (scanLogId != null) {
        setState(() => _ocrLogId = scanLogId);
        _flushMatcherLog();
      }

      // Solo corremos el matcher para categorÃƒÂ­as donde tiene sentido vincular
      // con la lista de compras. Para cafeterÃƒÂ­as, transporte, servicios, etc.
      // el usuario no espera ver productos detectados.
      const shoppingRelevantCategories = {'supermarket', 'health'};
      if (shoppingRelevantCategories.contains(result.category)) {
        setState(() {
          _shoppingRevealPhase = _ShoppingRevealPhase.preparing;
        });
        _matchOcrItemsToShoppingList(result.rawItems);
        if (!_waitForAmountRevealBeforeShopping) {
          _scheduleShoppingReveal();
        }
      }
    } catch (e, st) {
      log.e('[ReceiptScan] error procesando scan', error: e, stackTrace: st);
      if (!mounted) return;
      final message = switch (e) {
        ScanRateLimitException() => t.expensesFormOcrRateLimited,
        ScanImageTooLargeException(:final sizeMb) =>
          t.expensesFormOcrImageTooLarge(sizeMb.toStringAsFixed(1)),
        ScanAuthException() => t.expensesFormOcrSessionExpired,
        ScanTimeoutException() => t.expensesFormOcrTimeout,
        _ => t.expensesFormOcrError(e.toString()),
      };
      AppSnackBar.show(
        context,
        message: message,
        type: AppSnackBarType.error,
        duration: const Duration(milliseconds: 3200),
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
        _amountRevealEpoch++;
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
      AppSnackBar.show(
        context,
        message: t.expensesFormOcrLowConfidence,
        type: AppSnackBarType.warning,
        duration: const Duration(milliseconds: 2400),
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

    final householdId = ref.read(currentHouseholdProvider).value?.id ?? '';

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

    // TelemetrÃƒÂ­a: registramos el resultado del matcher para anÃƒÂ¡lisis offline.
    // El insert del log corre en paralelo (puede no haber resuelto todavÃƒÂ­a),
    // asÃƒÂ­ que guardamos el resultado y lo flusheamos cuando haya logId.
    _pendingMatcherResult = {
      'matched': result.toMarkPurchased.map((i) => i.name).toList(),
      'to_add': result.toAddAndMark.map((i) => i.name).toList(),
      'unrecognized': result.unrecognized,
      'dropped': result.dropped,
    };
    _flushMatcherLog();

    if (result.allLinked.isEmpty && result.unrecognized.isEmpty) {
      setState(() => _shoppingRevealPhase = _ShoppingRevealPhase.idle);
    }
  }

  void _scheduleShoppingReveal() {
    Future<void>.delayed(Duration.zero, () async {
      if (!mounted) return;
      if (_shoppingRevealPhase == _ShoppingRevealPhase.idle) return;
      if (_userTouchedScrollAfterScan) {
        _revealShoppingProducts();
        return;
      }

      final targetContext = _shoppingSectionKey.currentContext;
      if (targetContext == null) {
        if (mounted) _revealShoppingProducts();
        return;
      }
      if (!targetContext.mounted) return;

      _isAutoScrollingToShopping = true;
      try {
        await Scrollable.ensureVisible(
          targetContext,
          duration: const Duration(milliseconds: 820),
          curve: Curves.easeOutCubic,
          alignment: 0.18,
          alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
        );
      } finally {
        _isAutoScrollingToShopping = false;
      }

      if (!mounted) return;
      _revealShoppingProducts();
    });
  }

  void _revealShoppingProducts() {
    if (_shoppingRevealPhase == _ShoppingRevealPhase.idle) return;
    setState(() {
      _shoppingRevealPhase = _ShoppingRevealPhase.revealing;
      _shoppingRevealEpoch++;
    });
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_shoppingRevealPhase == _ShoppingRevealPhase.revealing) {
        setState(() => _shoppingRevealPhase = _ShoppingRevealPhase.revealed);
      }
    });
  }

  void _onAmountRevealComplete() {
    if (!_waitForAmountRevealBeforeShopping) return;
    _waitForAmountRevealBeforeShopping = false;
    _scheduleShoppingReveal();
  }

  /// EnvÃƒÂ­a el resultado del matcher al log de OCR en cuanto estÃƒÂ©n disponibles
  /// tanto el id del log como el resultado. Idempotente: tras flushear limpia
  /// el pendiente para no reenviar.
  void _flushMatcherLog() {
    final logId = _ocrLogId;
    final pending = _pendingMatcherResult;
    if (logId == null || pending == null) return;
    _pendingMatcherResult = null;
    OcrLogService(Supabase.instance.client).updateMatcherResult(
      logId: logId,
      matcherResult: pending,
    );
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
    if (!_formKey.currentState!.validate()) {
      setState(() => _shakeTrigger++);
      return;
    }

    final cleanAmtStr =
        _amountController.text.replaceAll('.', '').replaceAll(',', '.');
    final amountParsed = double.tryParse(cleanAmtStr);
    if (amountParsed == null || amountParsed <= 0) {
      final t = AppLocalizations.of(context);
      setState(() => _shakeTrigger++);
      AppSnackBar.show(
        context,
        message: t.expensesFormValidationAmountRequired,
        type: AppSnackBarType.warning,
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
        splitRatioAnchorId: household?.splitRatioAnchorId,
      );

      if (splitResult.hasValidationError) {
        if (!mounted) return;
        AppSnackBar.show(
          context,
          message: splitResult.validationMessage!,
          type: AppSnackBarType.error,
        );
        setState(() => _isLoading = false);
        return;
      }

      final splits = splitResult.splits;
      final isSharedEconomy = household?.financeMode == 'shared';
      final effectiveSplitType = isSharedEconomy
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
        log.d('[ExpenseForm] Ticket escaneado sin guardar imagen');
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

        // Paralelizamos todos los items: antes se hacÃƒÂ­a secuencial (add+toggle
        // por item) y con 14 artÃƒÂ­culos se iban ~5-6s. Con Future.wait todas las
        // operaciones salen a la vez y el tiempo total Ã¢â€°Ë† la operaciÃƒÂ³n mÃƒÂ¡s lenta.
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
      ref.invalidate(recentActivityRemoteProvider);
      ref.invalidate(expenseBalancesProvider);
      ref.invalidate(userBalanceProvider);

      // TelemetrÃƒÂ­a OCR: el usuario confirmÃƒÂ³ el gasto.
      if (_ocrLogId != null) {
        _ocrConfirmed = true;
        OcrLogService(Supabase.instance.client).updateUserAction(
          logId: _ocrLogId!,
          action: 'confirmed',
        );
      }

      if (mounted) {
        AppHaptics.success();
        setState(() => _showSuccessState = true);
        await Future<void>.delayed(const Duration(milliseconds: 220));
        if (!mounted) return;
        Navigator.pop(context);
        final baseMsg = widget.expense != null
            ? t.expensesFormUpdatedExpense
            : (_isIncome
                ? t.expensesFormSavedIncome
                : t.expensesFormSavedExpense);
        final shoppingMsg = shoppingItemsSynced > 0
            ? ' Â· ${t.expensesFormShoppingSynced(shoppingItemsSynced)} ?'
            : '';
        AppSnackBar.show(
          context,
          message: '$baseMsg$shoppingMsg',
          type: AppSnackBarType.success,
          duration: const Duration(milliseconds: 1500),
        );
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        AppSnackBar.show(
          context,
          message: t.commonErrorWithDetails(e.toString()),
          type: AppSnackBarType.error,
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
      loading: () => const Center(child: AppLoader()),
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
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollStartNotification &&
                          notification.dragDetails != null &&
                          !_isAutoScrollingToShopping) {
                        _userTouchedScrollAfterScan = true;
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _formScrollController,
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      child: Form(
                        key: _formKey,
                        child: AppShake(
                          trigger: _shakeTrigger,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              _buildTypeToggle(),
                              if (ref.watch(allowanceEnabledProvider)) ...[
                                const SizedBox(height: 12),
                                _buildAllowanceEntry(context),
                              ],
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
                              KeyedSubtree(
                                key: _shoppingSectionKey,
                                child: _buildShoppingIntegration(
                                  context,
                                  shoppingItemsAsync,
                                ),
                              ),
                              if (_unmatchedOcrItems.isNotEmpty &&
                                  _shoppingRevealPhase !=
                                      _ShoppingRevealPhase.preparing &&
                                  (ref.watch(premiumProvider).value ??
                                      false)) ...[
                                const SizedBox(height: 12),
                                NewItemsSuggestionBanner(
                                  animationTrigger: _shoppingRevealEpoch,
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
                                      _ocrMatchedShoppingItems
                                          .addAll(addedItems);
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
                                _buildSplitConfiguration(
                                  context,
                                  financeMembers,
                                ),
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
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Entry to the allowance ("mesada") flow â€” shown only when the premium
  /// Parent Mode toggle is on (family + premium + allowance_enabled), via
  /// allowanceEnabledProvider. Opens the dedicated AllowanceSheet rather than
  /// reusing the expense form body (a transfer â‰  an expense).
  Widget _buildAllowanceEntry(BuildContext context) {
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final sent = await AllowanceSheet.show(context);
        if (sent == true && mounted) {
          _closeSheet(true);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.payments_rounded, color: AppColors.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t.allowanceEntryTitle,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return ExpenseFormHeader(
      isEditing: widget.expense != null,
      isIncome: _isIncome,
      onClose: () => _closeSheet(),
      onDelete: widget.expense != null ? _confirmDelete : null,
    );
  }

  void _closeSheet([bool? result]) {
    final close = widget.onCloseWithResult;
    if (close != null) {
      close(result);
      return;
    }
    Navigator.of(context).pop(result);
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
    FocusManager.instance.primaryFocus?.unfocus();
    unawaited(SystemChannels.textInput.invokeMethod<void>('TextInput.hide'));
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = AppLocalizations.of(context);
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.xxl),
          ),
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
      if (!mounted) return;
      final t = AppLocalizations.of(context);
      final container = ProviderScope.containerOf(context, listen: false);
      final client = container.read(supabaseClientProvider);
      final messenger = ScaffoldMessenger.of(context);
      final expenseId = widget.expense!.id;
      final successMessage = t.expensesDeletedSnack;
      String errorMessage(Object error) => t.commonErrorWithDetails('$error');

      container
          .read(combinedFeedControllerProvider.notifier)
          .removeRealExpenseLocally(expenseId);
      container.read(hiddenRecentExpenseIdsProvider.notifier).hide(expenseId);
      _closeSheet();
      unawaited(
        _deleteExpenseAfterClose(
          container: container,
          client: client,
          messenger: messenger,
          expenseId: expenseId,
          successMessage: successMessage,
          errorMessage: errorMessage,
        ),
      );
    }
  }

  Future<void> _deleteExpenseAfterClose({
    required ProviderContainer container,
    required SupabaseClient client,
    required ScaffoldMessengerState messenger,
    required String expenseId,
    required String successMessage,
    required String Function(Object error) errorMessage,
  }) async {
    try {
      await client.rpc(
        'delete_expense_v1',
        params: {'p_expense_id': expenseId},
      );
      container.invalidate(expenseControllerProvider);
      container.invalidate(combinedFeedControllerProvider);
      container.invalidate(personalFinanceSummaryProvider);
      container.invalidate(recentActivityRemoteProvider);
      container.invalidate(expenseBalancesProvider);
      container.invalidate(userBalanceProvider);

      _showDeleteResultSnackBar(
        messenger,
        message: successMessage,
        isError: false,
      );
    } catch (e, stack) {
      log.w(
        'Delete expense after close failed: $e',
        error: e,
        stackTrace: stack,
      );
      unawaited(
        container.read(adminRpcServiceProvider).logApplicationError(
          message: 'Delete expense after close failed: $e',
          stackTrace: stack.toString(),
          level: 'error',
          context: {
            'source': 'expense_form_sheet',
            'operation': 'delete_expense_after_close',
            'expense_id': expenseId,
          },
        ),
      );
      container
          .read(hiddenRecentExpenseIdsProvider.notifier)
          .restore(expenseId);
      container.invalidate(combinedFeedControllerProvider);
      container.invalidate(recentActivityRemoteProvider);
      _showDeleteResultSnackBar(
        messenger,
        message: errorMessage(e),
        isError: true,
      );
    }
  }

  void _showDeleteResultSnackBar(
    ScaffoldMessengerState messenger, {
    required String message,
    required bool isError,
  }) {
    AppSnackBar.show(
      messenger.context,
      message: message,
      type: isError ? AppSnackBarType.error : AppSnackBarType.success,
      duration: Duration(milliseconds: isError ? 3200 : 1500),
    );
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

  /// Formatea el monto detectado por OCR para el input del formulario.
  /// En ARS ocultamos centavos porque los tickets argentinos los muestran,
  /// pero para la carga diaria solo agregan ruido visual.
  String _formatAmountFromOcr(double amount) {
    if (amount <= 0) return '';
    final currency = ref.read(currencyProvider);
    if (currency.code == 'ARS') {
      return NumberFormat.decimalPattern('es_ES').format(amount.round());
    }

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
    // Integrated/shared economy (couple or family): expenses are logged for the
    // whole household and don't create debt, so split controls are hidden.
    if (household?.financeMode == 'shared') {
      return false;
    }
    return caps.showExpensesSplit;
  }

  Widget _buildTypeToggle() {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase
                .withValues(alpha: theme.isDarkMode ? 0.18 : 0.03),
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
                  borderRadius: BorderRadius.circular(AppRadii.lg),
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
      showScanAction: !_isIncome,
      isScanningReceipt: _isScanningReceipt,
      hasScanResult: _scanResult != null,
      ocrRevealTrigger: _amountRevealEpoch,
      onOcrRevealComplete: _onAmountRevealComplete,
      onScanReceipt:
          _isScanningReceipt ? null : () => _scanReceipt(ImageSource.camera),
    );
  }

  Widget _buildTitleField() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.82)),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          Icon(
            _isIncome
                ? Icons.account_balance_wallet_outlined
                : Icons.receipt_long_rounded,
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
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
    final theme = context.theme;
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
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.border.withValues(alpha: 0.85)),
          boxShadow: [
            BoxShadow(
              color: theme.shadowBase.withValues(
                alpha: theme.isDarkMode ? 0.18 : 0.02,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
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
                    style: TextStyle(
                      color: theme.textSecondary,
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
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textSecondary,
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
          animationTrigger: _shoppingRevealEpoch,
          isPreparing: _shoppingRevealPhase == _ShoppingRevealPhase.preparing,
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
          // el usuario escaneÃƒÂ³ pero el ticket no es de un super Ã¢â€ â€™ quita todo).
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

                  AppSnackBar.show(
                    context,
                    message: AppLocalizations.of(context)
                        .expensesFormShoppingUnlinkedSnack,
                    type: AppSnackBarType.neutral,
                    duration: const Duration(seconds: 4),
                    actionLabel: AppLocalizations.of(context)
                        .expensesFormShoppingUnlinkedUndo,
                    onAction: () {
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
    AppSheet.show(
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
      final anchorId = household?.splitRatioAnchorId;

      if (members.length == 2 && defaultRatio != 0.5 && anchorId != null) {
        return Column(
          children: members.map((m) {
            final isAnchor = m.userId == anchorId;
            final memRatio = isAnchor ? defaultRatio : (1.0 - defaultRatio);
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
        'Este gasto no afectarÃƒÂ¡ el balance ${caps.actionMemberLabel(t)}.',
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
    final t = AppLocalizations.of(context);
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
                                ? t.expensesFormSaveButtonUpdated
                                : (_isIncome
                                    ? t.expensesFormSavedIncome
                                    : t.expensesFormSavedExpense),
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
