import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class PlannedExpensePaymentSheet extends ConsumerStatefulWidget {
  final FeedItemModel plannedExpense;

  const PlannedExpensePaymentSheet({super.key, required this.plannedExpense});

  @override
  ConsumerState<PlannedExpensePaymentSheet> createState() => _PlannedExpensePaymentSheetState();

  static Future<void> show(BuildContext context, FeedItemModel plannedExpense) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlannedExpensePaymentSheet(plannedExpense: plannedExpense),
    );
  }
}

class _PlannedExpensePaymentSheetState extends ConsumerState<PlannedExpensePaymentSheet> {
  final _amountController = TextEditingController();
  DateTime _paidAt = DateTime.now();
  String _paidBy = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Formatear el monto inicial con puntos
    final initialAmount = widget.plannedExpense.amount.toInt();
    _amountController.text = NumberFormat.decimalPattern('es_ES').format(initialAmount);
    _paidBy = widget.plannedExpense.payerId;
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

  Future<void> _confirmPayment() async {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text.replaceAll('.', '').replaceAll(',', ''));
      final result = await ref.read(combinedFeedControllerProvider.notifier).payPlannedExpense(
            plannedId: widget.plannedExpense.id,
            amount: amount,
            paidAt: _paidAt,
            paidBy: _paidBy,
          );

      if (mounted) {
        final templateUpdated = result['template_updated'] == true;
        
        // Primero cerramos el bottom sheet
        Navigator.pop(context);
        
        // Usamos el root navigator para mostrar el diálogo DESPUÉS de que el sheet se haya cerrado
        // para evitar conflictos de contextos y asegurar que el diálogo sea visible.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Buscamos un contexto válido que siga vivo después de cerrar el sheet (el de la app principal)
          // Si estamos usando Navigator.rootNavigator, usualmente se puede obtener del ScaffoldMessenger
          // o simplemente usando el context original si el widget padre sigue montado.
          _showSuccessDialog(templateUpdated);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(bool templateUpdated) {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                '¡Pago Registrado!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                'Se ha registrado el pago de "${widget.plannedExpense.title}" correctamente.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontWeight: FontWeight.w500),
              ),
              if (templateUpdated) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'He actualizado el monto de tu suscripción para los próximos meses.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary.withValues(alpha: 0.9),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo únicamente
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('ENTENDIDO', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: membersAsync.when(
        loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (members) {
          if (_paidBy.isEmpty && members.isNotEmpty) {
            _paidBy = members.first.userId;
          }

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 16),
                const Text(
                  'Confirmar Pago',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vas a marcar "${widget.plannedExpense.title}" como pagado.',
                  style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 24),
                _buildAmountField(),
                const SizedBox(height: 20),
                _buildDatePicker(context),
                const SizedBox(height: 20),
                _buildPayerSelector(members),
                const SizedBox(height: 32),
                _buildConfirmButton(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('MONTO EFECTIVO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          autofocus: true,
          controller: _amountController,
          onChanged: _onAmountChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixText: '\$ ',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FECHA DE PAGO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _paidAt,
              firstDate: DateTime.now().subtract(const Duration(days: 60)),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) setState(() => _paidAt = picked);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  DateFormat('EEEE d, MMMM', 'es').format(_paidAt),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                ),
                const Spacer(),
                const Icon(Icons.edit_calendar_rounded, size: 20, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayerSelector(List<dynamic> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿QUIÉN PAGÓ?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textMuted, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: members.map((m) {
            final isSelected = _paidBy == m.userId;
            return GestureDetector(
              onTap: () => setState(() => _paidBy = m.userId),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isSelected)
                        Container(width: 56, height: 56, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary)),
                      CustomUserAvatar(avatarUrl: m.avatarUrl, name: m.displayName, radius: 24),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    m.displayName.split(' ')[0],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _confirmPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.textPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Confirmar y Registrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      ),
    );
  }
}
