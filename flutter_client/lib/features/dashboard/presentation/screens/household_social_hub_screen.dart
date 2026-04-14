import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/invitation_sheet.dart';
import 'package:homesync_client/features/rewards/presentation/screens/family_rewards_screen.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class HouseholdSocialHubScreen extends ConsumerStatefulWidget {
  const HouseholdSocialHubScreen({super.key});

  @override
  ConsumerState<HouseholdSocialHubScreen> createState() =>
      _HouseholdSocialHubScreenState();
}

class _HouseholdSocialHubScreenState
    extends ConsumerState<HouseholdSocialHubScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(currentHouseholdProvider);
    await ref.read(householdMembersNotifierProvider.notifier).refresh();
  }

  Future<void> _editMemberRole(
    MemberModel member,
    HouseholdCapabilities caps,
  ) async {
    final theme = context.theme;
    final controller = TextEditingController(text: member.displayRole ?? '');
    final suggestions = _roleSuggestionsFor(member, caps);

    final String? selectedRole = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Rol visible de ${member.displayName}',
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Rol visible',
                  hintText: member.visibleRoleLabel,
                  filled: true,
                  fillColor: theme.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              if (suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Sugerencias',
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions
                      .map(
                        (suggestion) => ActionChip(
                          label: Text(suggestion),
                          onPressed: () => controller.text = suggestion,
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, controller.text.trim()),
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (!mounted || selectedRole == null) return;

    final newRole = selectedRole.trim();
    final repo = ref.read(householdRepositoryProvider);
    final result = await repo.updateMemberDisplayRole(
      member.userId,
      newRole.isEmpty ? null : newRole,
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No pudimos actualizar el rol: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) async {
        await _refreshData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rol actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }

  List<String> _roleSuggestionsFor(
    MemberModel member,
    HouseholdCapabilities caps,
  ) {
    if (caps.type == HouseholdType.family) {
      return member.isChild
          ? const ['Hijo', 'Hija']
          : const ['Padre', 'Madre', 'Tutor/a', 'Abuelo/a'];
    }
    if (caps.type == HouseholdType.friends) {
      return const ['Compañero', 'Roommate', 'Responsable'];
    }
    if (caps.type == HouseholdType.couple) {
      return const ['Pareja', 'Novio', 'Novia', 'Esposo', 'Esposa'];
    }
    return const ['Integrante'];
  }

  @override
  Widget build(BuildContext context) {
    final householdAsync = ref.watch(currentHouseholdProvider);
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final theme = context.theme;

    final members = membersAsync.valueOrNull ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;
    final canManageMembers = currentMember?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshData,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              132,
            ),
            children: [
              _HeaderCard(
                caps: caps,
                householdAsync: householdAsync,
                canManageMembers: canManageMembers,
                onInvite: () => InvitationSheet.show(context),
                onTasks: () {
                  final index = indexForMainTab(caps, MainTab.tasks);
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                onFinances: () {
                  final index = indexForMainTab(caps, MainTab.expenses);
                  if (index >= 0) {
                    ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                  }
                },
                onRewards: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyRewardsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              _FamilyStoreCard(
                caps: caps,
                onOpen: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyRewardsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),
              membersAsync.when(
                data: (resolvedMembers) => _MembersSection(
                  caps: caps,
                  currentUserId: currentUserId,
                  members: resolvedMembers,
                  canManageMembers: canManageMembers,
                  onEditRole: (member) => _editMemberRole(member, caps),
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: AppLoadingState(message: 'Cargando integrantes...'),
                ),
                error: (error, _) => AppErrorState(
                  message: 'No pudimos cargar los integrantes.\n$error',
                  onRetry: () =>
                      ref.invalidate(householdMembersNotifierProvider),
                ),
              ),
              const SizedBox(height: 18),
              _RolesAndAccessCard(
                caps: caps,
                canManageMembers: canManageMembers,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.caps,
    required this.householdAsync,
    required this.canManageMembers,
    required this.onInvite,
    required this.onTasks,
    required this.onFinances,
    required this.onRewards,
  });

  final HouseholdCapabilities caps;
  final AsyncValue<dynamic> householdAsync;
  final bool canManageMembers;
  final VoidCallback onInvite;
  final VoidCallback onTasks;
  final VoidCallback onFinances;
  final VoidCallback onRewards;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final household = householdAsync.valueOrNull;

    final title = switch (caps.type) {
      HouseholdType.family => 'Familia',
      HouseholdType.friends => 'Convivencia',
      HouseholdType.couple => 'Hogar',
      HouseholdType.solo => 'Mi espacio',
    };

    final subtitle = switch (caps.type) {
      HouseholdType.family =>
        'Integrantes, roles visibles y organización del hogar.',
      HouseholdType.friends =>
        'Compañeros, roles y organización de la convivencia.',
      _ => caps.socialHubSubtitle,
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.24 : 0.08),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(caps.partnerIcon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoChip(
                icon: Icons.home_work_outlined,
                label: household?.name ?? 'Mi hogar',
              ),
              _InfoChip(
                icon: Icons.group_outlined,
                label: canManageMembers ? 'Gestion activa' : 'Vista familiar',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (canManageMembers)
                _QuickActionButton(
                  icon: Icons.person_add_alt_1_outlined,
                  label: caps.type == HouseholdType.family
                      ? 'Invitar familia'
                      : 'Invitar',
                  onPressed: onInvite,
                ),
              _QuickActionButton(
                icon: Icons.task_alt_outlined,
                label: 'Tareas',
                onPressed: onTasks,
              ),
              _QuickActionButton(
                icon: Icons.account_balance_wallet_outlined,
                label: 'Finanzas',
                onPressed: onFinances,
              ),
              _QuickActionButton(
                icon: Icons.storefront_outlined,
                label: 'Tienda',
                onPressed: onRewards,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.caps,
    required this.currentUserId,
    required this.members,
    required this.canManageMembers,
    required this.onEditRole,
  });

  final HouseholdCapabilities caps;
  final String? currentUserId;
  final List<MemberModel> members;
  final bool canManageMembers;
  final ValueChanged<MemberModel> onEditRole;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    if (members.isEmpty) {
      return AppEmptyState(
        title: caps.type == HouseholdType.family
            ? 'Todavia no hay integrantes cargados'
            : 'Todavia no hay companeros cargados',
        subtitle: caps.type == HouseholdType.family
            ? 'Invita a tu familia para empezar a coordinar el hogar.'
            : 'Invita a tus companeros para empezar a organizar el piso.',
        icon: Icons.group_off_rounded,
        emoji: caps.type == HouseholdType.family ? '👨‍👩‍👧‍👦' : '🫶',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caps.type == HouseholdType.family
              ? 'Integrantes'
              : 'Personas del hogar',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          caps.type == HouseholdType.family
              ? 'Cada integrante muestra su rol visible, tipo y nivel de acceso dentro del hogar.'
              : 'Una vista clara de quienes forman parte del hogar.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        ...members.map((member) {
          final isCurrentUser = member.userId == currentUserId;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: theme.border.withValues(alpha: 0.72)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomUserAvatar(
                  avatarUrl: member.avatarUrl,
                  name: member.fullDisplayName,
                  radius: 24,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member.fullDisplayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                'Vos',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        member.visibleRoleLabel,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _RoleChip(
                            label: member.typeLabel,
                            color: member.isChild
                                ? AppColors.accentOrange
                                : AppColors.primary,
                            background: member.isChild
                                ? AppColors.accentOrange.withValues(alpha: 0.12)
                                : AppColors.primaryLight,
                          ),
                          if (member.isAdmin)
                            _RoleChip(
                              label: member.permissionLabel,
                              color: AppColors.success,
                              background:
                                  AppColors.success.withValues(alpha: 0.12),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canManageMembers)
                  IconButton(
                    onPressed: () => onEditRole(member),
                    icon: Icon(
                      Icons.edit_outlined,
                      color: theme.textSecondary,
                    ),
                    tooltip: 'Editar rol visible',
                  ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _RolesAndAccessCard extends StatelessWidget {
  const _RolesAndAccessCard({
    required this.caps,
    required this.canManageMembers,
  });

  final HouseholdCapabilities caps;
  final bool canManageMembers;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final title = switch (caps.type) {
      HouseholdType.family => 'Roles y acceso del hogar',
      HouseholdType.friends => 'Roles y convivencia',
      _ => 'Organizacion del hogar',
    };

    final bullets = switch (caps.type) {
      HouseholdType.family => const [
          'Los roles visibles muestran Padre, Madre, Hijo o Hija como identidad principal.',
          'Admin es un permiso de gestión, no el rol principal del integrante.',
          'Los adultos coordinan finanzas y hogar; los hijos participan con tareas y recompensas.',
        ],
      HouseholdType.friends => const [
          'La convivencia usa roles visibles claros para cada integrante.',
          'Las tareas y las compras se coordinan sin lenguaje de pareja.',
          'Admin indica quién puede ordenar la estructura del hogar.',
        ],
      _ => const [
          'Este espacio centraliza quienes forman parte del hogar.',
        ],
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              if (canManageMembers)
                const _RoleChip(
                  label: 'Gestion activa',
                  color: AppColors.primary,
                  background: AppColors.primaryLight,
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (bullet) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      bullet,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyStoreCard extends StatelessWidget {
  const _FamilyStoreCard({
    required this.caps,
    required this.onOpen,
  });

  final HouseholdCapabilities caps;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final title = switch (caps.type) {
      HouseholdType.family => 'Tienda del hogar',
      HouseholdType.friends => 'Tienda compartida',
      _ => 'Tienda',
    };
    final subtitle = switch (caps.type) {
      HouseholdType.family =>
        'Premios para chicos, adultos y planes familiares en un solo lugar.',
      HouseholdType.friends =>
        'Accede al catalogo de recompensas y propuestas compartidas.',
      _ => 'Accede al catalogo de recompensas del hogar.',
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: AppColors.accentGold,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 18,
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
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onOpen,
            child: const Text('Abrir'),
          ),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.border.withValues(alpha: 0.48)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
