import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/household/data/repositories/supabase_household_repository.dart';
import 'package:homesync_client/features/household/domain/models/family_role_option.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/invitation_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

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
          // Keep the member list visible while it refreshes after a role/nick
          // mutation instead of flashing a full-screen spinner.
          skipLoadingOnReload: true,
          data: (members) => _buildContent(members, theme),
          loading: () => const Center(child: AppLoader()),
          error: (error, stack) {
            log.e(
              'MembersScreen: failed to load household members',
              error: error,
              stackTrace: stack,
            );
            return AppErrorState(
              message: AppLocalizations.of(context).membersLoadError,
              onRetry: () => ref.invalidate(householdMembersProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(List<MemberModel> members, AppThemeColors theme) {
    final t = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final currentMember =
        members.where((m) => m.userId == currentUserId).firstOrNull;
    final isChild = currentMember?.isChild ?? false;
    final canEditRoles = currentMember?.canManageHousehold ?? false;

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(20),
      children: [
        _buildHeader(members.length, theme, t).animateEntrance(),
        const SizedBox(height: 24),
        ...members.asMap().entries.map(
              (entry) => _buildMemberCard(
                entry.value,
                theme,
                canEditRoles: canEditRoles,
                currentUserId: currentUserId,
              ).animateStaggered(entry.key),
            ),
        const SizedBox(height: 16),
        if (!isChild)
          _buildInviteCard(theme, t)
              .animateScaleIn(delay: (members.length * 40) + 100),
      ],
    );
  }

  Widget _buildHeader(int count, AppThemeColors theme, AppLocalizations t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.membersTitle,
          style: AppTypography.sectionTitle.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t.membersSubtitle(count),
          style: AppTypography.body.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    MemberModel member,
    AppThemeColors theme, {
    required bool canEditRoles,
    required String? currentUserId,
  }) {
    final t = AppLocalizations.of(context);
    // Owners and the current user can't be downgraded from this flow.
    final tappable =
        canEditRoles && !member.isOwner && member.userId != currentUserId;
    return AnimatedPress(
      onPressed: tappable ? () => _openRolePicker(member) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.xl),
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
                  Text(
                    member.fullDisplayName,
                    style: AppTypography.cardTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    member.visibleRoleLabel,
                    style: AppTypography.caption.copyWith(
                      fontSize: 13,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (member.isAdmin)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  t.membersAdminBadge,
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: theme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openRolePicker(MemberModel member) async {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final current = FamilyRoleOption.fromMember(
      displayRole: member.displayRole,
      type: member.type,
    );
    final selected = await AppSheet.show<FamilyRoleOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: BoxDecoration(
          color: theme.background,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadii.xxl)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.membersRolePickerTitle(member.displayName),
                style: AppTypography.sectionTitle.copyWith(
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.membersRolePickerSubtitle,
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              for (final option in FamilyRoleOption.values)
                _buildRoleOption(option, current, theme, t),
            ],
          ),
        ),
      ),
    );

    if (selected == null || selected == current) return;
    final repo = ref.read(householdRepositoryProvider);
    final result = await repo.updateMemberType(
      member.userId,
      selected.memberType.name,
      displayRole: selected.displayRole,
    );
    if (!mounted) return;
    result.fold(
      (failure) {
        log.e(
          'MembersScreen: failed to update role for ${member.userId}: '
          '${failure.message}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.membersRoleUpdateError),
            backgroundColor: AppColors.error,
          ),
        );
      },
      (_) {
        ref.invalidate(householdMembersProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.membersRoleUpdated)),
        );
      },
    );
  }

  Widget _buildRoleOption(
    FamilyRoleOption option,
    FamilyRoleOption? current,
    AppThemeColors theme,
    AppLocalizations t,
  ) {
    final isCurrent = current == option;
    final label = option.label(t);
    final subtitle = switch (option.memberType) {
      MemberType.parent ||
      MemberType.guardian =>
        t.membersRoleParentGuardianDesc,
      MemberType.teen => t.membersRoleTeenDesc,
      MemberType.child => t.membersRoleChildDesc,
    };
    return AnimatedPress(
      onPressed: () => Navigator.pop(context, option),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.xs),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? theme.primary.withValues(alpha: 0.08)
              : theme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppRadii.md),
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
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 15,
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w500,
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

  Widget _buildInviteCard(AppThemeColors theme, AppLocalizations t) {
    return AnimatedPress(
      onPressed: () {
        InvitationSheet.show(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.surfaceContainer.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.divider.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadii.md),
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
                    t.membersInviteTitle,
                    style: AppTypography.cardTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.membersInviteSubtitle,
                    style: AppTypography.caption.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
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
