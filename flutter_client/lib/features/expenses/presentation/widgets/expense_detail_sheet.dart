import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/expenses/presentation/utils/finance_localization.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/shopping/presentation/widgets/shopping_icon.dart';
import 'package:homesync_client/features/shopping/utils/shopping_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:intl/intl.dart';

class ExpenseDetailSheet {
  static void show(BuildContext context, ExpenseModel expense) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExpenseDetailSheetContent(initialExpense: expense),
    );
  }
}

class _ExpenseDetailSheetContent extends ConsumerStatefulWidget {
  final ExpenseModel initialExpense;

  const _ExpenseDetailSheetContent({required this.initialExpense});

  @override
  ConsumerState<_ExpenseDetailSheetContent> createState() =>
      _ExpenseDetailSheetContentState();
}

class _ExpenseDetailSheetContentState
    extends ConsumerState<_ExpenseDetailSheetContent> {
  late ExpenseModel _expense;
  bool _isRefreshingDetails = false;

  @override
  void initState() {
    super.initState();
    _expense = widget.initialExpense;
    _refreshIfNeeded();
  }

  bool get _needsFullExpense =>
      _expense.splits == null ||
      _expense.splits!.isEmpty ||
      _expense.splits!.any(
        (split) =>
            (split.fullName == null || split.fullName!.trim().isEmpty) &&
            (split.email == null || split.email!.trim().isEmpty),
      ) ||
      (_expense.description?.isEmpty ?? true);

  Future<void> _refreshIfNeeded() async {
    if (!_needsFullExpense || _isRefreshingDetails) return;

    setState(() => _isRefreshingDetails = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final result = await repo.getExpenseWithSplits(_expense.id);
      result.fold(
        (failure) => log
            .w('Expense detail fallback kept partial data: ${failure.message}'),
        (fullData) {
          if (!mounted) return;
          setState(() => _expense = ExpenseModel.fromJson(fullData));
        },
      );
    } catch (e) {
      log.e('Error enriching expense detail: $e', error: e);
    } finally {
      if (mounted) {
        setState(() => _isRefreshingDetails = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final expense = _expense;
    final accentColor = CategoryMapping.getSmartExpenseDisplayColor(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );
    final displayIcon = CategoryMapping.getSmartExpenseDisplayIcon(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );

    final bool isShoppingList =
        expense.title.toLowerCase().contains('compra') ||
            (expense.description?.toLowerCase().contains('lista') ?? false) ||
            expense.category == 'shopping';

    final String displayTitle = localizedFinanceTitle(
      t,
      title: expense.title.startsWith('Compras:') ? '' : expense.title,
      titleKey: expense.titleKey,
      category: expense.category,
      transactionType: expense.type,
    );

    final bool hasSimpleDescription = expense.description != null &&
        expense.description!.isNotEmpty &&
        !expense.description!.contains('\n') &&
        !expense.description!.contains('- ') &&
        !isShoppingList;
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.isIncome
                          ? t.expensesDetailHeaderIncome
                          : (expense.isSettlement
                              ? t.expensesDetailHeaderSettlement
                              : t.expensesDetailHeaderExpense),
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, d MMMM',
                        Localizations.localeOf(context).toString(),
                      ).format(expense.paidAt),
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ).animateEntrance(),
                Row(
                  children: [
                    if (_isRefreshingDetails)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accentColor,
                          ),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: theme.border),
                      ),
                      child: IconButton(
                        tooltip: t.commonEdit,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 22,
                          color: AppColors.primary,
                        ),
                        onPressed: () {
                          final rootContext =
                              Navigator.of(context, rootNavigator: true)
                                  .context;
                          Navigator.pop(context);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!rootContext.mounted) return;
                            ExpenseFormSheet.show(
                              rootContext,
                              expense: expense,
                            );
                          });
                        },
                      ),
                    ).animateScaleIn(delay: 100),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 0, 24, 20 + bottomPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Color.alphaBlend(
                        accentColor.withValues(alpha: 0.018),
                        theme.surface,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: theme.border.withValues(alpha: 0.72),
                      ),
                      boxShadow: theme.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(AppRadii.md),
                              ),
                              child: Center(
                                child: isShoppingList
                                    ? ShoppingIcon(
                                        categoryId: 'general',
                                        fallbackEmoji: '\u{1F6D2}',
                                        allowCategoryFallback: true,
                                        size: 27,
                                        color: accentColor,
                                      )
                                    : Icon(
                                        displayIcon,
                                        size: 24,
                                        color: accentColor,
                                      ),
                              ),
                            ).animateScaleIn(delay: 200),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                      color: theme.textPrimary,
                                      letterSpacing: -0.2,
                                      height: 1.12,
                                    ),
                                  ).animateEntrance(delay: 250),
                                  const SizedBox(height: 8),
                                  Text(
                                    _formatCurrency(expense.amount),
                                    style: TextStyle(
                                      fontSize: 29,
                                      fontWeight: FontWeight.w900,
                                      color: expense.isIncome
                                          ? AppColors.success
                                          : accentColor,
                                      letterSpacing: -0.8,
                                      height: 1,
                                    ),
                                  ).animateScaleIn(delay: 300),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _buildTypeBadge(
                                        _primaryBadgeLabel(expense, t),
                                        expense.splitType == 'gift'
                                            ? Colors.pinkAccent
                                            : accentColor,
                                        isSmall: true,
                                      ),
                                      if (expense.payerDisplayName != 'Alguien')
                                        _buildTypeBadge(
                                          t.expensesDetailPaidBy(
                                            expense.payerDisplayName,
                                          ),
                                          AppColors.sage,
                                          isSmall: true,
                                        ),
                                    ],
                                  ).animateEntrance(delay: 350),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animateEntrance(delay: 150),
                  const SizedBox(height: 18),
                  if (hasSimpleDescription) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.expensesDetailNoteLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        border: Border.all(color: theme.border),
                      ),
                      child: Text(
                        expense.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  if (isShoppingList && expense.description != null) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.expensesDetailPurchasedItems,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    _buildReceiptView(context, expense.description!),
                    const SizedBox(height: 20),
                  ] else if (expense.description != null &&
                      expense.description!.contains('\n')) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.expensesDetailLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildReceiptView(context, expense.description!),
                    const SizedBox(height: 24),
                  ],
                  if (expense.splits != null &&
                      expense.splits!.isNotEmpty &&
                      expense.splitType != 'personal') ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        t.expensesDetailSplitLabel,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 9),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.surface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: theme.border),
                      ),
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                      child: Column(
                        children: expense.splits!.map((split) {
                          final isPayer = split.userId == expense.paidBy;
                          final displayName = split.displayName;
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            child: Row(
                              children: [
                                CustomUserAvatar(
                                  avatarUrl: split.avatarUrl,
                                  name: displayName,
                                  radius: 18,
                                  forceCircular: true,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: theme.textPrimary,
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        isPayer
                                            ? t.expensesDetailPaidLabel
                                            : t.expensesDetailTheirPartLabel,
                                        style: TextStyle(
                                          color: isPayer
                                              ? accentColor
                                              : theme.textMuted,
                                          fontSize: 12,
                                          fontWeight: isPayer
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatCurrency(split.amount),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 17,
                                    color: isPayer
                                        ? theme.textPrimary
                                        : const Color(0xFFF97316),
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ).animateEntrance(delay: 400),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _primaryBadgeLabel(ExpenseModel expense, AppLocalizations t) {
    if (expense.isIncome) return t.expensesFormTypeIncome;
    if (expense.isSettlement) return t.expensesFormCategorySettlement;
    if (expense.splitType == 'gift') return t.expensesFormSplitGift;
    if (expense.splitType == 'equal') return t.expensesDetailSplitEqual;
    if (expense.splitType == 'fixed') return t.expensesDetailSplitLabel;
    if (expense.splitType == 'personal') return t.expensesDetailSplitPersonal;
    if (expense.isShared) return t.expensesFormSplitShared;
    return t.expensesDetailSplitPersonal;
  }

  String _formatCurrency(num amount) {
    return ref.read(currencyProvider).format(amount);
  }

  static Widget _buildTypeBadge(
    String label,
    Color color, {
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 10 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: isSmall ? 10 : 12,
        ),
      ),
    );
  }

  static final RegExp _receiptBulletPattern = RegExp(r'^[-*]\s*');
  static final RegExp _leadingEmojiPattern = RegExp(
    r'^\s*(?:[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}]\u{FE0F}?\s*)+',
    unicode: true,
  );

  static String _cleanReceiptItem(String value) {
    return value
        .trim()
        .replaceFirst(_receiptBulletPattern, '')
        .replaceFirst(_leadingEmojiPattern, '')
        .trim();
  }

  static String? _leadingEmoji(String value) {
    final match = _leadingEmojiPattern.firstMatch(value.trim());
    final emoji = match?.group(0)?.trim();
    return emoji == null || emoji.isEmpty ? null : emoji;
  }

  static Widget _buildReceiptView(BuildContext context, String text) {
    final theme = context.theme;
    final lines = text.split(RegExp(r'\n'));
    final items = lines
        .map((e) => e.trim().replaceFirst(_receiptBulletPattern, ''))
        .where(
          (e) => e.isNotEmpty && !e.toLowerCase().contains('lista de compra'),
        )
        .toList();

    if (items.isEmpty) {
      if (text.isNotEmpty && !text.toLowerCase().contains('lista')) {
        items.add(text);
      } else {
        return const SizedBox.shrink();
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((rawItem) {
          final item = _cleanReceiptItem(rawItem);
          final productKey = shoppingCatalogKeyForName(item);
          final fallbackEmoji = _leadingEmoji(rawItem) ?? '\u{1F6D2}';

          return Container(
            constraints: const BoxConstraints(minHeight: 44, maxWidth: 188),
            padding: const EdgeInsets.fromLTRB(7, 6, 12, 6),
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                AppColors.sage.withValues(alpha: 0.025),
                theme.surface,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.sage.withValues(alpha: 0.18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.012),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: theme.background.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Center(
                    child: ShoppingIcon(
                      productKey: productKey,
                      fallbackEmoji: fallbackEmoji,
                      allowProductAsset: true,
                      allowCategoryFallback: true,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    item.isEmpty ? rawItem : item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
