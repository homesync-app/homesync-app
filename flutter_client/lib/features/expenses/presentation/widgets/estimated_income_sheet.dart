import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/presentation/providers/estimated_income_provider.dart';

class EstimatedIncomeSheet extends ConsumerStatefulWidget {
  const EstimatedIncomeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const EstimatedIncomeSheet(),
      ),
    );
  }

  @override
  ConsumerState<EstimatedIncomeSheet> createState() =>
      _EstimatedIncomeSheetState();
}

class _EstimatedIncomeSheetState extends ConsumerState<EstimatedIncomeSheet> {
  final _amountController = TextEditingController();
  int _dayOfMonth = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(estimatedIncomeNotifierProvider).value;
    if (current != null && current.isSet) {
      _amountController.text = current.amount.toStringAsFixed(0);
      _dayOfMonth = current.dayOfMonth;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final raw = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(raw);
    if (amount == null || amount <= 0) return;

    setState(() => _saving = true);
    await ref
        .read(estimatedIncomeNotifierProvider.notifier)
        .save(amount: amount, dayOfMonth: _dayOfMonth);
    setState(() => _saving = false);

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clear() async {
    await ref.read(estimatedIncomeNotifierProvider.notifier).clear();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final existing = ref.watch(estimatedIncomeNotifierProvider).value;

    return Container(
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: AppColors.success,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ingreso mensual estimado',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  Text(
                    'Solo para calcular tu balance. No crea movimientos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            'MONTO NETO MENSUAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -1,
            ),
            decoration: InputDecoration(
              prefixText: ref.watch(currencyProvider).inputPrefix(),
              prefixStyle: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: theme.textMuted,
              ),
              hintText: '0',
              hintStyle: TextStyle(color: theme.textMuted),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'DÍA DE COBRO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.textMuted,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          _DayPicker(
            selected: _dayOfMonth,
            onChanged: (d) => setState(() => _dayOfMonth = d),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          if (existing != null && existing.isSet) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _clear,
                child: Text(
                  'Quitar ingreso estimado',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayPicker extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onChanged;

  const _DayPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 28,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final day = index + 1;
          final isSelected = day == selected;
          return GestureDetector(
            onTap: () => onChanged(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.success
                    : AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$day',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isSelected ? Colors.white : AppColors.success,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
