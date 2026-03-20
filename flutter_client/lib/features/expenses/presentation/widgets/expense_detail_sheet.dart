import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';

class ExpenseDetailSheet {
  static String _primaryBadgeLabel(ExpenseModel expense) {
    if (expense.isIncome) return 'Ingreso';
    if (expense.isSettlement) return 'Liquidación';
    if (expense.splitType == 'gift') return 'Regalo';
    if (expense.splitType == 'equal') return 'Dividido Equitativamente';
    if (expense.splitType == 'fixed') return 'División';
    if (expense.splitType == 'personal') return 'Gasto Solo';
    if (expense.isShared) return 'Compartido';
    return 'Gasto Solo';
  }

  static void show(BuildContext context, ExpenseModel expense) {
    final accentColor = AppColors.getSmartExpenseDisplayColor(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );
    final displayIcon = AppColors.getSmartExpenseDisplayIcon(
      expense.category,
      title: expense.title,
      description: expense.description,
      transactionType: expense.type,
      splitType: expense.splitType,
    );

    bool isShoppingList = expense.title.toLowerCase().contains('compra') ||
        (expense.description?.toLowerCase().contains('lista') ?? false) ||
        expense.category == 'shopping';

    final String displayTitle = expense.title.startsWith('Compras:')
        ? expense.categoryLabel
        : expense.title;

    final bool hasSimpleDescription = expense.description != null &&
        expense.description!.isNotEmpty &&
        !expense.description!.contains('\n') &&
        !expense.description!.contains('- ') &&
        !isShoppingList;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.isIncome
                              ? 'Detalle de Ingreso'
                              : (expense.isSettlement
                                  ? 'Detalle de Liquidación'
                                  : 'Detalle de Gasto'),
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          DateFormat('EEEE, d \'de\' MMMM', 'es')
                              .format(expense.paidAt),
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800),
                        ),
                      ],
                    ).animateEntrance(),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            color: AppColors.primary),
                        onPressed: () {
                          Navigator.pop(context);
                          ExpenseFormSheet.show(context, expense: expense);
                        },
                      ),
                    ).animateScaleIn(delay: 100),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Resumen Principal
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                              color: AppColors.divider.withValues(alpha: 0.5)),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(displayIcon,
                                      size: 26, color: accentColor),
                                ).animateScaleIn(delay: 200),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    displayTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                        letterSpacing: -0.3),
                                  ).animateEntrance(delay: 250),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '\$ ${_formatCurrency(expense.amount)}',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: expense.isIncome
                                    ? AppColors.success
                                    : const Color(0xFF1E3A8A),
                                letterSpacing: -1.0,
                              ),
                            ).animateScaleIn(delay: 300),
                            const SizedBox(height: 6),
                            // Badges compactos
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildTypeBadge(
                                  _primaryBadgeLabel(expense),
                                  expense.splitType == 'gift'
                                      ? Colors.pinkAccent
                                      : accentColor,
                                  isSmall: true,
                                ),
                                if (expense.payerDisplayName != 'Alguien')
                                  _buildTypeBadge(
                                    'Pagó ${expense.payerDisplayName}',
                                    AppColors.accentBlue,
                                    isSmall: true,
                                  ),
                              ],
                            ).animateEntrance(delay: 350),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (hasSimpleDescription) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Nota:',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.divider)),
                          child: Text(expense.description!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  height: 1.5)),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (isShoppingList && expense.description != null) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Ítems Comprados',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptView(expense.description!),
                        const SizedBox(height: 24),
                      ] else if (expense.description != null &&
                          expense.description!.contains('\n')) ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Detalle',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 8),
                        _buildReceiptView(expense.description!),
                        const SizedBox(height: 24),
                      ],

                      if (expense.splits != null &&
                          expense.splits!.isNotEmpty &&
                          expense.splitType != 'personal') ...[
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('División',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            children: expense.splits!.map((split) {
                              final isPayer = split.userId == expense.paidBy;
                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 8),
                                leading: CustomUserAvatar(
                                  avatarUrl: split.avatarUrl,
                                  name: split.fullName ?? 'Usuario',
                                  radius: 20,
                                ),
                                title: Text(
                                    (split.fullName ?? 'Usuario')
                                        .split(' ')
                                        .first,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14)),
                                subtitle: isPayer
                                    ? Text('Pagó',
                                        style: TextStyle(
                                            color: accentColor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600))
                                    : const Text('Su parte',
                                        style: TextStyle(
                                            color: AppColors.textMuted,
                                            fontSize: 12)),
                                trailing: Text(
                                  '\$ ${_formatCurrency(split.amount)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: isPayer
                                        ? AppColors.textPrimary
                                        : const Color(0xFFF97316),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ).animateEntrance(delay: 400),
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCurrency(num amount) {
    return NumberFormat.decimalPattern('es_AR').format(amount);
  }

  static Widget _buildTypeBadge(String label, Color color,
      {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 12, vertical: isSmall ? 4 : 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
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

  static Widget _buildReceiptView(String text) {
    final lines = text.split(RegExp(r'\n'));
    final items = lines
        .map((e) => e.trim().replaceAll(RegExp(r'^[-*•]\\s*'), ''))
        .where(
            (e) => e.isNotEmpty && !e.toLowerCase().contains('lista de compra'))
        .toList();

    if (items.isEmpty) {
      // Fallback for non-newline but comma separated or single item
      if (text.isNotEmpty && !text.toLowerCase().contains('lista')) {
        items.add(text);
      } else {
        return const SizedBox.shrink();
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.asMap().entries.map((entry) {
          final isLast = entry.key == items.length - 1;
          final item = entry.value;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 8),
                Divider(
                    color: AppColors.divider.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 12),
              ],
            ],
          );
        }).toList(),
      ),
    );
  }
}
