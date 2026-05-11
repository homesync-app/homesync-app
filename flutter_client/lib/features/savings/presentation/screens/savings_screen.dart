import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:intl/intl.dart';

final _fmt = NumberFormat.decimalPattern('es_AR');

class SavingsScreen extends ConsumerStatefulWidget {
  const SavingsScreen({super.key});

  @override
  ConsumerState<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends ConsumerState<SavingsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final goalsAsync = ref.watch(savingsGoalsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackground,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Volver',
          icon:
              Icon(Icons.arrow_back_ios_new_rounded, color: theme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Metas de Ahorro',
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: goalsAsync.when(
        data: (goals) => RefreshIndicator(
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
                    Text(
                      'Nuestras Metas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: theme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      '${goals.length} activas',
                      style:
                          TextStyle(color: theme.textSecondary, fontSize: 13),
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
                color: theme.surface,
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
            child:
                const Text('🎯', style: TextStyle(fontSize: 46)).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            'No hay metas activas aún',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Empezá a guardar para algo que de verdad les entusiasme.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.theme.textSecondary,
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
        gradient: LinearGradient(
          colors: [
            context.theme.surface,
            context.theme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: context.theme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            'Ahorro Total 🏦',
            style: TextStyle(
              color: context.theme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_fmt.format(total.round())}',
            style: TextStyle(
              color: context.theme.textPrimary,
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
                color: AppColors.sage,
              ),
              const SizedBox(width: 40),
              _buildSimpleStat(
                label: 'Cumplidas',
                value: goals.where((g) => g.progress >= 1).length.toString(),
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: context.theme.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildGoalCard(SavingsGoalModel goal) {
    final theme = context.theme;
    final progress = goal.progress.clamp(0.0, 1.0);
    final color = _parseColor(goal.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border),
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
              child: Text(goal.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          title: Text(
            goal.title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: theme.textPrimary,
            ),
          ),
          subtitle: Text(
            '\$${_fmt.format(goal.currentAmount.round())} de \$${_fmt.format(goal.targetAmount.round())}',
            style: TextStyle(color: theme.textSecondary, fontSize: 13),
          ),
          trailing: Text(
            '${(progress * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          children: [
            const Divider(),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Ingresar Ahorro'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Eliminar meta',
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
        Text(
          'Historial de Aportes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: context.theme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        contributionsAsync.when(
          data: (list) {
            if (list.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Aún no hay aportes en este pocito.',
                  style: TextStyle(
                    color: context.theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
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
                        forceCircular: true,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${contribution.userName?.split(' ')[0] ?? 'Alguien'} sumó \$${contribution.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.theme.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('dd MMM').format(contribution.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: context.theme.textSecondary,
                        ),
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
    if (!colorStr.startsWith('#')) return AppColors.primary;
    final parsed = int.tryParse(colorStr.replaceFirst('#', '0xFF'));
    return parsed != null ? Color(parsed) : AppColors.primary;
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
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(savingsGoalsProvider.notifier).removeGoal(goal.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
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
        decoration: BoxDecoration(
          color: context.theme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Cuánto querés aportar?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: context.theme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.theme.textPrimary,
              ),
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                filled: true,
                fillColor: context.theme.surfaceVariant,
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
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Confirmar Ahorro',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddGoalButton() {
    final theme = context.theme;
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton.icon(
        onPressed: _showAddGoalDialog,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Nueva Meta',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: theme.surface,
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
          final theme = context.theme;
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;

          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackground,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
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
                          color: theme.divider,
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
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nueva Meta',
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'Definí qué quieren lograr y cuánto necesitan juntar para hacerlo realidad.',
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.4,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'DETALLE',
                                style: TextStyle(
                                  color: theme.textMuted,
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
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: titleController,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: theme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Nombre',
                                  hintText: '¿Cuál es tu objetivo?',
                                  prefixIcon: const Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.primary,
                                  ),
                                  filled: true,
                                  fillColor: theme.surfaceVariant,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
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
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: theme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Monto objetivo',
                                  hintText: '¿Cuánto quieren juntar?',
                                  prefixText: '\$ ',
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: theme.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: theme.surfaceVariant,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.12),
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
                              Text(
                                'PERSONALIZACIÓN',
                                style: TextStyle(
                                  color: theme.textMuted,
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
                                        (e) => setModalState(
                                          () => selectedEmoji = e,
                                        ),
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
                                        (c) => setModalState(
                                          () => selectedColor = c,
                                        ),
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
                        decoration: BoxDecoration(
                          color: theme.surface,
                          border: Border(
                            top: BorderSide(color: theme.divider),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancelar',
                                style: TextStyle(
                                  color: theme.textMuted,
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
                                          amountController.text
                                              .replaceAll(',', '.'),
                                        ) ??
                                        0;
                                    if (title.isNotEmpty && amount > 0) {
                                      ref
                                          .read(savingsGoalsProvider.notifier)
                                          .addGoal(
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
    final theme = context.theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textMuted,
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
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.textMuted,
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
    final theme = context.theme;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackground,
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
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
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
                    color: theme.surface,
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
      backgroundColor: context.theme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Elegí un color',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: context.theme.textPrimary,
              ),
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
}
