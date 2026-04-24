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
    final isAdult = currentMember?.isAdult ?? false;
    final isChild = currentMember?.isChild ?? false;
    final isAdmin = currentMember?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(title: Text(isChild ? 'Mi tienda' : 'Tienda del hogar')),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showRewardComposer(context, ref, isAdmin),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Nuevo premio'),
            )
          : null,
      body: rewardsAsync.when(
        data: (rewards) {
          final activeRewards =
              rewards.where((reward) => reward.isActive).toList();
          final approvedRewards =
              activeRewards.where((reward) => reward.isApproved).toList();
          final pendingRewards =
              activeRewards.where((reward) => !reward.isApproved).toList();
          final childRewards = approvedRewards
              .where((reward) => reward.targetType == 'child')
              .toList();
          final adultRewards = approvedRewards
              .where((reward) => reward.targetType == 'adult')
              .toList();
          final familyRewards = approvedRewards
              .where((reward) => reward.targetType == 'all')
              .toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(rewardsProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                _BalanceHero(
                  balance: balance,
                  isAdult: isAdult,
                  isChild: isChild,
                ),
                const SizedBox(height: 18),
                _CoinsDivider(balance: balance),
                if (isAdmin && pendingRewards.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  _SectionTitle(
                    title: 'Pendientes de aprobacion',
                    subtitle:
                        'Premios propuestos que todavia necesitan decision.',
                    trailing: _CountPill(label: '${pendingRewards.length}'),
                  ),
                  const SizedBox(height: 12),
                  ...pendingRewards.map(
                    (reward) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _PendingRewardCard(
                        reward: reward,
                        onApprove: () => _approveReward(context, ref, reward),
                        onDelete: () =>
                            _confirmDelete(context, ref, reward, isAdmin),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                if (approvedRewards.isEmpty)
                  _EmptyBoutique(
                    isAdmin: isAdmin,
                    onSeed: () =>
                        ref.read(rewardsProvider.notifier).cloneTemplates(),
                    onCreate: isAdmin
                        ? () => _showRewardComposer(context, ref, isAdmin)
                        : null,
                  )
                else if (isAdult) ...[
                  _RewardSection(
                    title: 'Premios para chicos',
                    subtitle:
                        'Recompensas pensadas para motivar y celebrar avances.',
                    rewards: childRewards,
                    emptyText: 'Todavia no hay premios para chicos.',
                    canDelete: isAdmin,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    onDelete: (reward) =>
                        _confirmDelete(context, ref, reward, isAdmin),
                  ),
                  const SizedBox(height: 26),
                  _RewardSection(
                    title: 'Premios para adultos',
                    subtitle:
                        'Toman el lenguaje visual y emocional de la boutique de pareja.',
                    rewards: adultRewards,
                    emptyText: 'Todavia no hay premios para adultos.',
                    canDelete: isAdmin,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    onDelete: (reward) =>
                        _confirmDelete(context, ref, reward, isAdmin),
                  ),
                  const SizedBox(height: 26),
                  _RewardSection(
                    title: 'Planes familiares',
                    subtitle: 'Premios y salidas para disfrutar entre todos.',
                    rewards: familyRewards,
                    emptyText: 'Todavia no hay planes familiares cargados.',
                    canDelete: isAdmin,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    onDelete: (reward) =>
                        _confirmDelete(context, ref, reward, isAdmin),
                  ),
                ] else ...[
                  _RewardSection(
                    title: 'Premios para vos',
                    subtitle: 'Elegí qué querés conseguir con tus coins.',
                    rewards: childRewards,
                    emptyText: 'Todavia no hay premios en tu tienda.',
                    canDelete: false,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    onDelete: (_) {},
                  ),
                  const SizedBox(height: 26),
                  _RewardSection(
                    title: 'Planes en familia',
                    subtitle: 'Premios para disfrutar juntos.',
                    rewards: familyRewards,
                    emptyText: 'Todavia no hay planes familiares disponibles.',
                    canDelete: false,
                    onRedeem: (reward) => _confirmRedeem(context, ref, reward),
                    onDelete: (_) {},
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

  void _showRewardComposer(BuildContext context, WidgetRef ref, bool isAdmin) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final costController = TextEditingController();
    var targetType = 'all';
    var selectedIcon = '\uD83C\uDF81';

    const icons = [
      '\uD83C\uDF81',
      '\uD83C\uDF55',
      '\uD83C\uDFAC',
      '\uD83C\uDF66',
      '\u2B50',
      '\uD83E\uDDE9',
      '\uD83D\uDCF1',
      '\uD83C\uDFC6',
    ];

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
                        const InputDecoration(labelText: 'Titulo del premio'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 2,
                    decoration:
                        const InputDecoration(labelText: 'Descripcion breve'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: costController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Costo en monedas'),
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
                          child:
                              Text(icon, style: const TextStyle(fontSize: 24)),
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
                              isApproved: isAdmin,
                              targetType: targetType,
                            );
                        if (context.mounted) Navigator.pop(context);
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
        SnackBar(content: Text('"${reward.title}" quedo aprobado.')),
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
        const SnackBar(content: Text('No te alcanzan las monedas todavia.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canjear premio'),
        content: Text(
          'Queres canjear "${reward.title}" por ${reward.cost} monedas?',
        ),
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

class _BalanceHero extends StatelessWidget {
  const _BalanceHero({
    required this.balance,
    required this.isAdult,
    required this.isChild,
  });

  final int balance;
  final bool isAdult;
  final bool isChild;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isChild
              ? const [
                  Color(0xFFFFF2DF),
                  Color(0xFFEAF7F4),
                ]
              : [
                  AppColors.accentGold.withValues(alpha: 0.22),
                  AppColors.accentGold.withValues(alpha: 0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(isChild ? 28 : 24),
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
                  isChild
                      ? 'Tu bolsita de coins'
                      : isAdult
                          ? 'Balance actual'
                          : 'Tus monedas',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$balance monedas',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (isChild) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Cuando un adulto aprueba tus misiones, crece.',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoinsDivider extends StatelessWidget {
  const _CoinsDivider({required this.balance});

  final int balance;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: AppColors.accentGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$balance monedas disponibles',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _RewardSection extends StatelessWidget {
  const _RewardSection({
    required this.title,
    required this.subtitle,
    required this.rewards,
    required this.emptyText,
    required this.canDelete,
    required this.onRedeem,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final List<RewardModel> rewards;
  final String emptyText;
  final bool canDelete;
  final ValueChanged<RewardModel> onRedeem;
  final ValueChanged<RewardModel> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: title,
          subtitle: subtitle,
          trailing: _CountPill(label: '${rewards.length}'),
        ),
        const SizedBox(height: 14),
        if (rewards.isEmpty)
          _InlineEmptyState(message: emptyText)
        else
          _RewardGrid(
            rewards: rewards,
            onRedeem: onRedeem,
            canDelete: canDelete,
            onDelete: onDelete,
          ),
      ],
    );
  }
}

class _EmptyBoutique extends StatelessWidget {
  const _EmptyBoutique({
    required this.isAdmin,
    required this.onSeed,
    this.onCreate,
  });

  final bool isAdmin;
  final Future<dynamic> Function() onSeed;
  final VoidCallback? onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Icon(Icons.storefront_outlined, color: theme.textMuted, size: 40),
          const SizedBox(height: 14),
          Text(
            'Boutique vacia',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAdmin
                ? 'Carga premios sugeridos o crea el primer catalogo del hogar.'
                : 'Todavia no hay premios disponibles en la tienda del hogar.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => onSeed(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                foregroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cargar catalogo inicial',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            if (onCreate != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onCreate,
                child: const Text(
                  'O crear un premio personalizado',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _InlineEmptyState extends StatelessWidget {
  const _InlineEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border.withValues(alpha: 0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: theme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RewardGrid extends ConsumerWidget {
  const _RewardGrid({
    required this.rewards,
    required this.onRedeem,
    required this.canDelete,
    required this.onDelete,
  });

  final List<RewardModel> rewards;
  final ValueChanged<RewardModel> onRedeem;
  final bool canDelete;
  final ValueChanged<RewardModel> onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final userBalance = ref.watch(userBalanceProvider).value?['coins'] ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 40;
        final columns = viewportWidth >= 280 ? 2 : 1;
        final cardWidth =
            (viewportWidth - (12 * (columns - 1))).clamp(0, double.infinity) /
                columns;
        final cardHeight = columns == 2 ? 198.0 : 210.0;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: rewards.map((reward) {
            final canAfford = userBalance >= reward.cost;
            final accent = canAfford ? theme.primary : theme.textMuted;

            return SizedBox(
              width: cardWidth,
              height: cardHeight,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.surface, AppColors.surfaceVariant],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.border.withValues(alpha: 0.55),
                  ),
                  boxShadow: theme.cardShadow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onRedeem(reward),
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        if (canDelete)
                          Positioned(
                            top: -4,
                            right: 2,
                            child: IconButton(
                              onPressed: () => onDelete(reward),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              icon: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: theme.textMuted.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 52,
                                height: 52,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.accentGold.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Text(
                                  reward.icon,
                                  style: const TextStyle(fontSize: 29),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Expanded(
                                child: Center(
                                  child: Text(
                                    reward.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: theme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      height: 1.14,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: canAfford
                                      ? theme.primary.withValues(alpha: 0.12)
                                      : theme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: canAfford
                                        ? theme.primary.withValues(alpha: 0.18)
                                        : theme.border.withValues(alpha: 0.65),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.monetization_on_rounded,
                                      size: 13,
                                      color: accent,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${reward.cost} monedas',
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
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
          }).toList(),
        );
      },
    );
  }
}

class _PendingRewardCard extends StatelessWidget {
  const _PendingRewardCard({
    required this.reward,
    required this.onApprove,
    required this.onDelete,
  });

  final RewardModel reward;
  final VoidCallback onApprove;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final audience = switch (reward.targetType) {
      'adult' => 'Adultos',
      'child' => 'Chicos',
      _ => 'Familia',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(reward.icon, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      audience,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const _CountPill(label: 'Revisar'),
            ],
          ),
          if (reward.description != null && reward.description!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              reward.description!,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
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
  const _TargetChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : theme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : theme.divider.withValues(alpha: 0.4),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : theme.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
