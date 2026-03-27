import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/domain/models/reward_model.dart';
import 'package:homesync_client/features/rewards/presentation/providers/reward_provider.dart';

class FamilyRewardsScreen extends ConsumerWidget {
  const FamilyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final rewardsAsync = ref.watch(filteredRewardsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final balance = ref.watch(userBalanceProvider).value?['coins'] ?? 0;

    final currentMember = membersAsync.valueOrNull
        ?.where((member) => member.userId == currentUserId)
        .firstOrNull;
    final isAdult = currentMember?.isAdult ?? true;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(isAdult ? 'Tienda familiar' : 'Mis recompensas'),
      ),
      floatingActionButton: isAdult
          ? FloatingActionButton.extended(
              onPressed: () => _showRewardComposer(context, ref, isAdult),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo premio'),
            )
          : null,
      body: rewardsAsync.when(
        data: (rewards) {
          final approvedRewards =
              rewards.where((reward) => reward.isApproved).toList();
          final pendingRewards =
              rewards.where((reward) => !reward.isApproved).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(rewardsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _BalanceCard(balance: balance, isAdult: isAdult),
                const SizedBox(height: 24),
                _SectionTitle(
                  title: isAdult ? 'Premios activos' : 'Lo que podés canjear',
                  subtitle: isAdult
                      ? 'Gestioná premios para adultos, chicos o toda la familia.'
                      : 'Tus monedas se convierten en premios del hogar.',
                ),
                const SizedBox(height: 12),
                if (approvedRewards.isEmpty)
                  _EmptyPanel(
                    title: 'Todavía no hay premios disponibles',
                    subtitle: isAdult
                        ? 'Creá el primer premio para empezar la economía del hogar.'
                        : 'Todavía no hay premios para canjear.',
                  )
                else
                  _RewardGrid(
                    rewards: approvedRewards,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    canDelete: isAdult,
                    onDelete: (reward) =>
                        _confirmDelete(context, ref, reward, isAdult),
                  ),
                if (isAdult && pendingRewards.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const _SectionTitle(
                    title: 'Pendientes de aprobación',
                    subtitle: 'Revisá lo que propusieron antes de publicarlo.',
                  ),
                  const SizedBox(height: 12),
                  ...pendingRewards.map(
                    (reward) => _PendingRewardTile(
                      reward: reward,
                      onApprove: () => _approveReward(context, ref, reward),
                      onDelete: () =>
                          _confirmDelete(context, ref, reward, isAdult),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showRewardComposer(BuildContext context, WidgetRef ref, bool isAdult) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    var targetType = 'all';
    var selectedIcon = '🎁';

    const icons = ['🎁', '🍕', '🎬', '🍦', '⭐', '🧩', '📱', '🏆'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final theme = context.theme;

          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.divider,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Nuevo premio familiar',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: titleController,
                    decoration:
                        const InputDecoration(labelText: 'Título del premio'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Descripción breve',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Costo en monedas',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Dirigido a',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _TargetChip(
                        label: 'Toda la familia',
                        selected: targetType == 'all',
                        onTap: () => setState(() => targetType = 'all'),
                      ),
                      _TargetChip(
                        label: 'Adultos',
                        selected: targetType == 'adult',
                        onTap: () => setState(() => targetType = 'adult'),
                      ),
                      _TargetChip(
                        label: 'Chicos',
                        selected: targetType == 'child',
                        onTap: () => setState(() => targetType = 'child'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Icono',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: icons.map((icon) {
                      final selected = selectedIcon == icon;
                      return GestureDetector(
                        onTap: () => setState(() => selectedIcon = icon),
                        child: Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : theme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : theme.divider.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(icon, style: const TextStyle(fontSize: 24)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final description = descriptionController.text.trim();
                        final cost = int.tryParse(costController.text) ?? 0;
                        if (title.isEmpty || cost <= 0) return;

                        await ref.read(rewardsProvider.notifier).suggestReward(
                              title: title,
                              description:
                                  description.isEmpty ? null : description,
                              cost: cost,
                              icon: selectedIcon,
                              category: 'familia',
                              isApproved: isAdult,
                              targetType: targetType,
                            );
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Guardar premio'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _approveReward(
    BuildContext context,
    WidgetRef ref,
    RewardModel reward,
  ) async {
    final result = await ref.read(rewardsProvider.notifier).approveReward(
          reward.id,
        );
    result.fold(
      (failure) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      ),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${reward.title}" quedó aprobado.')),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RewardModel reward,
    bool canDelete,
  ) async {
    if (!canDelete) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar premio'),
        content: Text('Se va a quitar "${reward.title}" de la tienda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(rewardsProvider.notifier).deleteReward(reward.id);
    }
  }

  Future<void> _confirmRedeem(
    BuildContext context,
    WidgetRef ref,
    RewardModel reward,
  ) async {
    final balance = ref.read(userBalanceProvider).value?['coins'] ?? 0;
    if (balance < reward.cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No te alcanzan las monedas todavía.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canjear premio'),
        content: Text('¿Querés canjear "${reward.title}" por ${reward.cost} monedas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(rewardsProvider.notifier).redeem(reward.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Canjeaste "${reward.title}".')),
        );
      }
    }
  }
}

class _BalanceCard extends StatelessWidget {
  final int balance;
  final bool isAdult;

  const _BalanceCard({required this.balance, required this.isAdult});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentGold.withValues(alpha: 0.22),
            AppColors.accentGold.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.monetization_on_rounded,
            color: AppColors.accentGold,
            size: 34,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAdult ? 'Balance actual' : 'Tus monedas',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$balance monedas',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyPanel({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(Icons.storefront_outlined, color: theme.textMuted, size: 36),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RewardGrid extends StatelessWidget {
  final List<RewardModel> rewards;
  final ValueChanged<RewardModel> onRedeem;
  final bool canDelete;
  final ValueChanged<RewardModel> onDelete;

  const _RewardGrid({
    required this.rewards,
    required this.onRedeem,
    required this.canDelete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: rewards.map((reward) {
        return SizedBox(
          width: (MediaQuery.sizeOf(context).width - 52) / 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.divider.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reward.icon, style: const TextStyle(fontSize: 28)),
                    const Spacer(),
                    if (canDelete)
                      InkWell(
                        onTap: () => onDelete(reward),
                        child: Icon(
                          Icons.close_rounded,
                          color: theme.textMuted,
                          size: 18,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  reward.title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (reward.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    reward.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => onRedeem(reward),
                    child: Text('${reward.cost} monedas'),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PendingRewardTile extends StatelessWidget {
  final RewardModel reward;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  const _PendingRewardTile({
    required this.reward,
    required this.onApprove,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final audience = switch (reward.targetType) {
      'adult' => 'Adultos',
      'child' => 'Chicos',
      _ => 'Toda la familia',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.divider.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reward.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  reward.title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                audience,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (reward.description != null) ...[
            const SizedBox(height: 8),
            Text(
              reward.description!,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDelete,
                  child: const Text('Quitar'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onApprove,
                  child: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TargetChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : context.theme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : context.theme.divider.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : context.theme.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
