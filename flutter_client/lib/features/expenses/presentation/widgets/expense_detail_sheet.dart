import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';

class ExpenseDetailSheet {
  static void show(BuildContext context, ExpenseModel expense) {
    final String displayTitle = expense.title.startsWith('Compras:') 
        ? expense.categoryLabel 
        : expense.title;
        
    final bool hasSimpleDescription = expense.description != null && 
                                      expense.description!.isNotEmpty && 
                                      !expense.description!.contains('\n') && 
                                      !expense.description!.contains('- ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.70, // Reducido para que ocupe mucho menos espacio base
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.isIncome ? 'Detalle de Ingreso' : 'Detalle de Gasto',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        DateFormat('EEEE, d \'de\' MMMM', 'es').format(expense.paidAt),
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
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
                      icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
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
                    // Resumen Principal (Mucho más compacto)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 8)),
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
                                  color: AppColors.getCategoryColor(expense.category).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(expense.categoryIcon, style: const TextStyle(fontSize: 28)),
                              ).animateScaleIn(delay: 200),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  displayTitle,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.3),
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
                              color: expense.isIncome ? AppColors.success : const Color(0xFF1E3A8A), // Navy blue
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
                                  expense.splitType == 'equal' ? 'Dividido Equitativamente' : 
                                  (expense.splitType == 'fixed' ? 'División Personalizada' : 'Gasto Personal'),
                                  AppColors.getCategoryColor(expense.category),
                                  isSmall: true
                               ),
                               if (expense.payerDisplayName != null)
                                  _buildTypeBadge('Pagó ${expense.payerDisplayName!.split(' ').first}', AppColors.accentBlue, isSmall: true),
                             ],
                           ).animateEntrance(delay: 350),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    if (hasSimpleDescription) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Nota:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.divider)),
                        child: Text(expense.description!, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                      ),
                      const SizedBox(height: 24),
                    ],

                    if (expense.description != null && (expense.description!.contains('\n') || expense.title.startsWith('Compras:'))) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Detalle del Gasto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 8),
                      _buildReceiptView(expense.description!),
                      const SizedBox(height: 24),
                    ],

                    if (expense.expenseSplits != null && expense.expenseSplits!.isNotEmpty && expense.splitType != 'personal') ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('División del Gasto', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          children: expense.expenseSplits!.map((split) {
                            final isPayer = split['user_id'] == expense.paidBy;
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              leading: CustomUserAvatar(
                                avatarUrl: split['users']?['avatar_url'],
                                name: split['users']?['full_name'] ?? 'Usuario',
                                radius: 20,
                              ),
                              title: Text((split['users']?['full_name'] ?? 'Usuario').toString().split(' ').first, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                              subtitle: isPayer 
                                ? Text('Pagó', style: TextStyle(color: AppColors.getCategoryColor(expense.category), fontSize: 12, fontWeight: FontWeight.w600))
                                : null,
                              trailing: Text(
                                '\$ ${_formatCurrency(split['amount'])}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900, 
                                  fontSize: 16, 
                                  color: isPayer ? AppColors.textPrimary : const Color(0xFFF97316),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ).animateEntrance(delay: 400),
                    ],
                    const SizedBox(height: 48), // Padding bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    return NumberFormat.decimalPattern('es_AR').format(amount.round());
  }

  static Widget _buildTypeBadge(String label, Color color, {bool isSmall = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 12, vertical: isSmall ? 4 : 6),
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
    final items = text.split(RegExp(r'\n'))
                .map((e) => e.trim().replaceAll(RegExp(r'^[\-\*•]\s*'), ''))
                .where((e) => e.isNotEmpty && !e.toLowerCase().contains('lista'))
                .toList();
                
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // Slight blueish tint like receipt paper
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
      ),
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
                  const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 18, height: 1.0)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (!isLast) ...[
                const SizedBox(height: 8),
                Divider(color: AppColors.divider.withValues(alpha: 0.5), height: 1),
                const SizedBox(height: 8),
              ]
            ],
          );
        }).toList(),
      ),
    );
  }
}
