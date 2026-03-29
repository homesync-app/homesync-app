import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_animations.dart';

final _fmt = NumberFormat.decimalPattern('es_AR');

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<SavingsGoalModel>>>(savingsGoalsProvider,
        (previous, next) {
      if (previous != null && previous.hasValue && next.hasValue) {
        final prevGoals = previous.value!;
        final nextGoals = next.value!;

        for (final goal in nextGoals) {
          final prevGoal = prevGoals.any((g) => g.id == goal.id)
              ? prevGoals.firstWhere((g) => g.id == goal.id)
              : null;

          if (prevGoal != null &&
              prevGoal.progress < 1.0 &&
              goal.progress >= 1.0) {
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
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Text('🎯', style: TextStyle(fontSize: 46)).animatePulse(),
          ),
          const SizedBox(height: 24),
          const Text(
            'No hay metas activas aún',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Empezá a guardar para algo que de verdad les entusiasme.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ).animateEntrance();
  }

  Widget _buildTotalSavingsCard(List<SavingsGoalModel> goals) {
    final total =
        goals.fold<double>(0, (sum, goal) => sum + goal.currentAmount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF8F2), Color(0xFFFFF3E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
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
            'Ahorro Total 🏦',
            style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_fmt.format(total.round())}',
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
                  color: AppColors.sage),
              const SizedBox(width: 40),
              _buildSimpleStat(
                  label: 'Cumplidas',
                  value: goals.where((g) => g.progress >= 1).length.toString(),
                  color: AppColors.primary),
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
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
            child: Center(
                child: Text(goal.icon, style: const TextStyle(fontSize: 24))),
          ),
          title: Text(goal.title,
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.textPrimary)),
          subtitle: Text(
              '\$${_fmt.format(goal.currentAmount.round())} de \$${_fmt.format(goal.targetAmount.round())}',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
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
                    child: const Text('Ingresar Ahorro'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _confirmDelete(goal),
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.error),
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
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
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
                          style: const TextStyle(
                              fontSize: 13, color: AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(contribution.createdAt),
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textSecondary),
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
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
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
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  ref.read(savingsGoalsProvider.notifier).contribute(
                    goal.id, 
                    amount,
                    goalTitle: goal.title,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Confirmar Ahorro',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGoalButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton.icon(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text('Nueva Meta',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.12),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
      ),
    );
  }

  void _showAddGoalDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedEmoji = '🎯';
    Color selectedColor = AppColors.primary;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 46,
                        height: 6,
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            24,
                            8,
                            24,
                            24 + bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Icon(
                                      Icons.flag_rounded,
                                      color: AppColors.primary,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nueva Meta',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.textPrimary,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Definí qué quieren lograr y cuánto necesitan juntar para hacerlo realidad.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.4,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'DETALLE',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Qué quieren alcanzar',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: titleController,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: '¿Cuál es tu objetivo?',
                                  prefixIcon: const Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.primary,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Monto objetivo',
                                  hintText: '¿Cuánto quieren juntar?',
                                  prefixText: '\$ ',
                                  prefixStyle: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: AppColors.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'PERSONALIZACIÓN',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Dale personalidad',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  _buildGoalOption(
                                    label: 'Emoji',
                                    value: selectedEmoji,
                                    onTap: () {
                                      final emojis = [
                                        '🎯',
                                        '🏡',
                                        '✈️',
                                        '🚗',
                                        '💍',
                                        '🛋️',
                                        '🍼',
                                        '🎓',
                                        '🐶',
                                        '💻',
                                      ];
                                      _showSimplePicker(
                                        context,
                                        'Elegí un ícono',
                                        emojis,
                                        (e) => setModalState(() => selectedEmoji = e),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  _buildGoalOption(
                                    label: 'Color',
                                    value: '',
                                    customValue: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: selectedColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    onTap: () {
                                      final colors = [
                                        AppColors.primary,
                                        AppColors.accentTeal,
                                        AppColors.accentGold,
                                        AppColors.accentPurple,
                                        AppColors.accentRed,
                                        AppColors.success,
                                      ];
                                      _showColorPicker(
                                        context,
                                        colors,
                                        (c) => setModalState(() => selectedColor = c),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          18,
                          24,
                          20 + MediaQuery.of(context).padding.bottom,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(
                            top: BorderSide(color: AppColors.divider),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final title = titleController.text.trim();
                                    final amount = double.tryParse(
                                          amountController.text.replaceAll(',', '.'),
                                        ) ??
                                        0;
                                    if (title.isNotEmpty && amount > 0) {
                                      ref.read(savingsGoalsProvider.notifier).addGoal(
                                            title,
                                            amount,
                                            '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                                            selectedEmoji,
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'Crear Meta',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalOption({
    required String label,
    required String value,
    Widget? customValue,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (customValue != null)
                    customValue
                  else
                    Text(value, style: const TextStyle(fontSize: 18)),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSimplePicker(
    BuildContext context,
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: options.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  onSelect(options[index]);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    options[index],
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    List<Color> colors,
    Function(Color) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Elegí un color',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: colors
                  .map(
                    (color) => GestureDetector(
                      onTap: () {
                        onSelect(color);
                        Navigator.pop(context);
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showGoalCompletionAnim(SavingsGoalModel goal) {
    SuccessCelebration.show(
      context,
      title: '¡META CUMPLIDA! 🎯',
      message:
          '¡Increíble! Han logrado llegar al objetivo de "${goal.title}". ¡A disfrutarlo juntos!',
      icon: goal.icon,
    );
  }
}
