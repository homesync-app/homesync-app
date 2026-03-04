import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_providers.dart';
import 'package:homesync_client/core/services/mercadopago_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  final _mpService = MercadoPagoService();

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<SavingsGoalModel>>>(savingsGoalsProvider, (previous, next) {
      if (previous != null && previous.hasValue && next.hasValue) {
        final prevGoals = previous.value!;
        final nextGoals = next.value!;
        
        for (final goal in nextGoals) {
          final prevGoal = prevGoals.any((g) => g.id == goal.id) 
              ? prevGoals.firstWhere((g) => g.id == goal.id) 
              : null;
          
          if (prevGoal != null && prevGoal.progress < 1.0 && goal.progress >= 1.0) {
            _showGoalCompletionAnim(goal);
          }
        }
      }
    });

    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Metas de Ahorro',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5),
        ),
      ),
      body: goalsAsync.when(
        data: (List<SavingsGoalModel> goals) => RefreshIndicator(
          onRefresh: () => ref.refresh(savingsGoalsProvider.future),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalSavingsCard(goals),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Nuestras Metas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${goals.length} activas',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (goals.isEmpty)
                  _buildEmptyState()
                else
                  ...goals.map((goal) => _buildGoalCard(goal)),
                const SizedBox(height: 40),
                _buildAddGoalButton(),
              ],
            ),
          ),
        ),
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => ShimmerLoading(
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: const Column(
        children: [
          Text('🎯', style: TextStyle(fontSize: 60)),
          SizedBox(height: 16),
          Text(
            '¡Empiecen su primera meta!',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          SizedBox(height: 8),
          Text(
            'Viajes, ahorros, compras... ¡ustedes eligen!',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSavingsCard(List<SavingsGoalModel> goals) {
    final total =
        goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(36),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A4A4443),
            blurRadius: 40,
            offset: Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Ahorro Total',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${total.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSimpleStat(
                  label: 'Metas',
                  value: goals.length.toString(),
                  color: AppColors.accentTeal),
              const SizedBox(width: 40),
              _buildSimpleStat(
                  label: 'Cumplidas',
                  value: goals.where((g) => g.progress >= 1).length.toString(),
                  color: AppColors.accentGold),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(
      {required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 18)),
        Text(label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildGoalCard(SavingsGoalModel goal) {
    final progress = goal.progress.clamp(0.0, 1.0);
    final color = _parseColor(goal.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.divider),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.all(20),
          childrenPadding:
              const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                Center(child: Text(goal.icon, style: const TextStyle(fontSize: 24))),
          ),
          title: Text(goal.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          subtitle: Text(
              '\$${goal.currentAmount.toStringAsFixed(0)} de \$${goal.targetAmount.toStringAsFixed(0)}',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          trailing: Text('${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 15)),
          children: [
            const Divider(),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 20),
            _buildContributionHistory(goal),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showContributionDialog(goal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Ahorrar con MP 💳'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(goal),
                  icon: const Icon(Icons.delete_outline,
                      color: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionHistory(SavingsGoalModel goal) {
    final contributionsAsync = ref.watch(goalContributionsProvider(goal.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Historial de Aportes',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),
        contributionsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text('Aún no hay aportes en este pocito.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length > 3 ? 3 : list.length,
              itemBuilder: (context, index) {
                final contribution = list[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      CustomUserAvatar(
                        name: contribution.userName ?? '?',
                        avatarUrl: contribution.userAvatar,
                        radius: 12,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${contribution.userName?.split(' ')[0] ?? 'Alguien'} sumó \$${contribution.amount.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(contribution.createdAt),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error al cargar historial'),
        ),
      ],
    );
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        return Color(int.parse(colorStr.replaceFirst('#', '0xFF')));
      }
      return AppColors.primary;
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _confirmDelete(SavingsGoalModel goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar meta?'),
        content: Text('Se perderá el registro de "${goal.title}".'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              ref.read(savingsGoalsProvider.notifier).removeGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showContributionDialog(SavingsGoalModel goal) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          top: 32,
          left: 32,
          right: 32,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '¿Cuánto querés aportar?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _handleMPContribution(goal, controller.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF009EE3), // Mercado Pago Blue
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Pagar con Mercado Pago',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMPContribution(SavingsGoalModel goal, String amountStr) async {
    final amount = double.tryParse(amountStr);
    if (amount == null || amount <= 0) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Navigator.pop(context); // Close sheet

    // Show loading
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generando link de ahorro...')),
    );

    // external_reference: savings|householdId|goalId|userId|amount
    final extRef = 'savings|${goal.householdId}|${goal.id}|${user.id}|$amount';

    final url = await _mpService.createPaymentPreference(
      title: 'Ahorro: ${goal.title}',
      amount: amount,
      externalReference: extRef,
    );

    if (url != null) {
      await _mpService.launchCheckout(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al generar el link de pago')),
      );
    }
  }

  Widget _buildAddGoalButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: OutlinedButton.icon(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nueva Meta',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Meta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: '¿Para qué es?'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Monto objetivo'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              final title = titleController.text;
              final amount = double.tryParse(amountController.text) ?? 0;
              if (title.isNotEmpty && amount > 0) {
                ref
                    .read(savingsGoalsProvider.notifier)
                    .addGoal(title, amount, '#FF7E67', '🎯');
                Navigator.pop(context);
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }
  void _showGoalCompletionAnim(SavingsGoalModel goal) {
    SuccessCelebration.show(
      context,
      title: '¡META CUMPLIDA! 🎯',
      message: '¡Increíble! Han logrado llegar al objetivo de "${goal.title}". ¡A disfrutarlo juntos!',
      icon: goal.icon,
    );
  }
}
