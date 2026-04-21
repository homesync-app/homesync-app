import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/invitation_sheet.dart';

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(householdMembersProvider.future),
        color: AppColors.primary,
        backgroundColor: theme.surface,
        child: membersAsync.when(
          data: (members) => _buildContent(members, theme),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildContent(List<MemberModel> members, AppThemeColors theme) {
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final canEditRoles = currentMember?.isAdmin ?? false;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(members.length, theme).animateEntrance(),
        const SizedBox(height: 24),
        ...members.asMap().entries.map(
              (entry) => _buildMemberCard(
                entry.value,
                theme,
                canEditRoles: canEditRoles,
              ).animateStaggered(entry.key),
            ),
        const SizedBox(height: 16),
        if (!isChild)
          _buildInviteCard(theme)
              .animateScaleIn(delay: (members.length * 40) + 100),
      ],
    );
  }

  Widget _buildHeader(int count, AppThemeColors theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Integrantes',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$count persona${count == 1 ? '' : 's'} en tu hogar',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    MemberModel member,
    AppThemeColors theme, {
    required bool canEditRoles,
  }) {
    // Owners can't be downgraded to minors (would lock the household out of
    // admin-only actions), so we only open the role picker for non-owners.
    final tappable = canEditRoles && !member.isOwner;
    return AnimatedPress(
      onPressed: tappable ? () => _openRolePicker(member) : null,
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CustomUserAvatar(
                avatarUrl: member.avatarUrl,
                name: member.fullDisplayName,
                radius: 26,
                showBorder: true,
              ),
              if (member.isAdmin)
                Positioned(
                  right: -1,
                  top: -1,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      size: 8,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.fullDisplayName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: theme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: member.isChild
                            ? AppColors.accentOrange.withValues(alpha: 0.1)
                            : theme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        member.typeLabel,
                        style: TextStyle(
                          color: member.isChild
                              ? AppColors.accentOrange
                              : theme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.visibleRoleLabel,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (member.isAdmin)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Admin',
                style: TextStyle(
                  color: theme.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Future<void> _openRolePicker(MemberModel member) async {
    final theme = context.theme;
    final selected = await showModalBottomSheet<MemberType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rol de ${member.displayName}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Los padres y tutores pueden aprobar tareas. Adolescentes y niños mandan sus tareas a revisión.',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              for (final type in MemberType.values)
                _buildRoleOption(type, member, theme),
            ],
          ),
        ),
      ),
    );

    if (selected == null || selected == member.type) return;
    final repo = ref.read(householdRepositoryProvider);
    final result = await repo.updateMemberType(member.userId, selected.name);
    if (!mounted) return;
    result.fold(
      (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No pudimos cambiar el rol: ${failure.message}'),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        ref.invalidate(householdMembersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rol actualizado')),
        );
      },
    );
  }

  Widget _buildRoleOption(
    MemberType type,
    MemberModel member,
    AppThemeColors theme,
  ) {
    final isCurrent = member.type == type;
    final label = switch (type) {
      MemberType.parent => 'Padre / Madre',
      MemberType.guardian => 'Tutor/a',
      MemberType.teen => 'Adolescente',
      MemberType.child => 'Hijo/a',
    };
    final subtitle = switch (type) {
      MemberType.parent ||
      MemberType.guardian =>
        'Aprueba tareas, gestiona el hogar.',
      MemberType.teen =>
        'Crea sus tareas, pero las completa bajo revisión.',
      MemberType.child =>
        'Solo completa sus tareas, siempre bajo revisión.',
    };
    return AnimatedPress(
      onPressed: () => Navigator.pop(context, type),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.primary.withValues(alpha: 0.08)
              : theme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrent
                ? theme.primary.withValues(alpha: 0.4)
                : theme.divider.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrent)
              Icon(Icons.check_rounded, color: theme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteCard(AppThemeColors theme) {
    return AnimatedPress(
      onPressed: () {
        InvitationSheet.show(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person_add_rounded,
                color: theme.primary,
              ),
            ).animatePulse(),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invitar integrante',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Suma otra persona al hogar con un codigo de invitacion.',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
