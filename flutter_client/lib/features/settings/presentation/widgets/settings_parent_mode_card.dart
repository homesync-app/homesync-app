import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';
import 'package:homesync_client/features/tasks/presentation/providers/pending_approvals_provider.dart';
import 'package:homesync_client/features/tasks/presentation/screens/family_dashboard_screen.dart';
import 'package:homesync_client/features/tasks/presentation/screens/pending_approvals_screen.dart';
import 'package:homesync_client/features/tasks/presentation/screens/weekly_family_summary_screen.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Sprint 1 Modo Padres: card de configuracion del bundle "Modo Padres".
///
/// Solo se muestra a admins de un hogar familiar. Estados:
///  - admin sin premium → CTA al paywall.
///  - admin con premium → toggle de aprobacion + acceso a la bandeja.
///
/// Se inserta como un bloque opcional en la pantalla de Settings; si el
/// usuario no es admin de una familia, el widget devuelve `SizedBox.shrink()`
/// y no ocupa espacio.
class SettingsParentModeCard extends ConsumerStatefulWidget {
  const SettingsParentModeCard({super.key});

  @override
  ConsumerState<SettingsParentModeCard> createState() =>
      _SettingsParentModeCardState();
}

class _SettingsParentModeCardState
    extends ConsumerState<SettingsParentModeCard> {
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final eligible = ref.watch(parentModeEligibleProvider);
    if (!eligible) return const SizedBox.shrink();

    final available = ref.watch(parentModeAvailableProvider);
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settingsParentModeTitle,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.settingsParentModeSubtitle,
                      style:
                          TextStyle(color: theme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (!available)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    t.settingsPremiumBadge,
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (!available)
            _LockedBody(onUnlock: _openPaywall)
          else
            _UnlockedBody(
              saving: _saving,
              onChangeMode: _persistMode,
              onOpenInbox: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PendingApprovalsScreen(),
                ),
              ),
              onOpenDashboard: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const FamilyDashboardScreen(),
                ),
              ),
              onOpenSummary: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const WeeklyFamilySummaryScreen(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openPaywall() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PremiumPaywallScreen()),
    );
  }

  Future<void> _persistMode(String mode) async {
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(supabaseClientProvider).from('households').update(
        {'task_approval_mode': mode},
      ).eq('id', householdId);
      ref.invalidate(currentHouseholdProvider);
      ref.invalidate(pendingTaskApprovalsProvider);
    } catch (e, stack) {
      log.e(
        'Failed to update task_approval_mode',
        error: e,
        stackTrace: stack,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).settingsParentModeSaveError(
                e.toString(),
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _LockedBody extends StatelessWidget {
  const _LockedBody({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _bullet(theme, '✅', t.settingsParentModeBulletApproval),
        _bullet(theme, '👀', t.settingsParentModeBulletPerMember),
        _bullet(theme, '🔄', t.settingsParentModeBulletRotation),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onUnlock,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(t.settingsParentModeUnlockButton),
          ),
        ),
      ],
    );
  }

  Widget _bullet(AppThemeColors theme, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockedBody extends ConsumerWidget {
  const _UnlockedBody({
    required this.saving,
    required this.onChangeMode,
    required this.onOpenInbox,
    required this.onOpenDashboard,
    required this.onOpenSummary,
  });

  final bool saving;
  final Future<void> Function(String mode) onChangeMode;
  final VoidCallback onOpenInbox;
  final VoidCallback onOpenDashboard;
  final VoidCallback onOpenSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final householdAsync = ref.watch(currentHouseholdProvider);
    final mode = householdAsync.value?.taskApprovalMode ?? 'off';
    final pending = ref.watch(pendingTaskApprovalsProvider).value ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.settingsParentModeApprovalSectionTitle,
          style: TextStyle(
            color: theme.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t.settingsParentModeApprovalSectionSubtitle,
          style: TextStyle(color: theme.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _ModeOption(
          value: 'off',
          groupValue: mode,
          enabled: !saving,
          title: t.settingsParentModeApprovalOffTitle,
          subtitle: t.settingsParentModeApprovalOffSubtitle,
          onChanged: onChangeMode,
        ),
        _ModeOption(
          value: 'children_only',
          groupValue: mode,
          enabled: !saving,
          title: t.settingsParentModeApprovalChildrenOnlyTitle,
          subtitle: t.settingsParentModeApprovalChildrenOnlySubtitle,
          onChanged: onChangeMode,
        ),
        _ModeOption(
          value: 'all',
          groupValue: mode,
          enabled: !saving,
          title: t.settingsParentModeApprovalAllTitle,
          subtitle: t.settingsParentModeApprovalAllSubtitle,
          onChanged: onChangeMode,
        ),
        _ModeOption(
          value: 'per_member',
          groupValue: mode,
          enabled: !saving,
          title: t.settingsParentModeApprovalPerMemberTitle,
          subtitle: t.settingsParentModeApprovalPerMemberSubtitle,
          onChanged: onChangeMode,
        ),
        if (mode == 'per_member') ...[
          const SizedBox(height: 12),
          const _PerMemberToggleList(),
        ],
        const SizedBox(height: 12),
        InkWell(
          onTap: onOpenInbox,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.inbox_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    pending.isEmpty
                        ? t.settingsParentModeInboxIdle
                        : t.settingsParentModeInboxWithCount(pending.length),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onOpenDashboard,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentBlue.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.groups_rounded,
                  color: AppColors.accentBlue,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.settingsParentModeMemberView,
                    style: const TextStyle(
                      color: AppColors.accentBlue,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.accentBlue,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onOpenSummary,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.accentPurple.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.celebration_rounded,
                  color: AppColors.accentPurple,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.settingsParentModeWeeklySummary,
                    style: const TextStyle(
                      color: AppColors.accentPurple,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.accentPurple,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ModeOption extends StatelessWidget {
  const _ModeOption({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.subtitle,
    required this.onChanged,
    required this.enabled,
  });

  final String value;
  final String groupValue;
  final String title;
  final String subtitle;
  final Future<void> Function(String mode) onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final selected = value == groupValue;
    return InkWell(
      onTap: enabled && !selected ? () => onChanged(value) : null,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.4)
                : theme.divider,
            width: selected ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? AppColors.primary : theme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista de miembros con toggle individual de `requires_task_approval`.
/// Solo se muestra cuando `households.task_approval_mode = 'per_member'`.
/// Lee directo de `household_members` con join a `users` y persiste el
/// cambio con UPDATE — la RPC `should_require_task_approval` lo respeta.
class _PerMemberToggleList extends ConsumerStatefulWidget {
  const _PerMemberToggleList();

  @override
  ConsumerState<_PerMemberToggleList> createState() =>
      _PerMemberToggleListState();
}

class _PerMemberToggleListState extends ConsumerState<_PerMemberToggleList> {
  Future<List<_MemberApprovalRow>>? _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_MemberApprovalRow>> _load() async {
    final memberFallbackName =
        AppLocalizations.of(context).settingsHouseholdMemberFallbackName;
    final householdId = await ref.read(householdIdProvider.future);
    if (householdId == null) return const [];
    final client = ref.read(supabaseClientProvider);
    final rows = await client
        .from('household_members')
        .select(
          'id, user_id, role, member_type, requires_task_approval, '
          'users(full_name, email, avatar_url)',
        )
        .eq('household_id', householdId)
        .order('joined_at', ascending: true);
    return (rows as List)
        .map(
          (r) => _MemberApprovalRow.fromMap(
            Map<String, dynamic>.from(r as Map),
            memberFallbackName: memberFallbackName,
          ),
        )
        .toList();
  }

  Future<void> _toggle(_MemberApprovalRow row, bool requires) async {
    setState(() {
      row.requiresApproval = requires;
    });
    try {
      await ref.read(supabaseClientProvider).rpc(
        'update_member_task_approval',
        params: {
          'p_household_member_id': row.id,
          'p_requires_task_approval': requires,
        },
      );
    } catch (e, stack) {
      log.e(
        'Failed to toggle requires_task_approval',
        error: e,
        stackTrace: stack,
      );
      // Revert UI optimistic.
      setState(() {
        row.requiresApproval = !requires;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).settingsParentModeSaveError(
                e.toString(),
              ),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return FutureBuilder<List<_MemberApprovalRow>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final rows = snapshot.data ?? const <_MemberApprovalRow>[];
        if (rows.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              AppLocalizations.of(context).settingsParentModePerMemberEmpty,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
          );
        }
        return Column(
          children: [
            for (final row in rows)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.divider, width: 0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row.fullName,
                            style: TextStyle(
                              color: theme.textPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          Builder(
                            builder: (ctx) {
                              final label = row
                                  .localizedRoleLabel(AppLocalizations.of(ctx));
                              if (label == null) return const SizedBox.shrink();
                              return Text(
                                label,
                                style: TextStyle(
                                  color: theme.textSecondary,
                                  fontSize: 11.5,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: row.requiresApproval,
                      onChanged: (v) => _toggle(row, v),
                      activeThumbColor: AppColors.primary,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MemberApprovalRow {
  final String id;
  final String userId;
  final String fullName;
  final String memberType;
  final String role;
  bool requiresApproval;

  _MemberApprovalRow({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.memberType,
    required this.role,
    required this.requiresApproval,
  });

  factory _MemberApprovalRow.fromMap(
    Map<String, dynamic> map, {
    required String memberFallbackName,
  }) {
    final user = map['users'] is Map
        ? Map<String, dynamic>.from(map['users'] as Map)
        : const <String, dynamic>{};
    return _MemberApprovalRow(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      fullName: (user['full_name'] as String?) ??
          (user['email'] as String?) ??
          memberFallbackName,
      memberType: (map['member_type'] as String?) ?? 'adult',
      role: (map['role'] as String?) ?? 'member',
      requiresApproval: (map['requires_task_approval'] as bool?) ?? false,
    );
  }

  /// Localized role label, computed at render time so it stays in sync with
  /// the active locale.
  String? localizedRoleLabel(AppLocalizations t) {
    final type = switch (memberType) {
      'child' => t.settingsParentModeMemberTypeChild,
      'teen' => t.settingsParentModeMemberTypeTeen,
      'parent' => t.settingsParentModeMemberTypeAdult,
      'guardian' => t.settingsParentModeMemberTypeGuardian,
      _ => t.settingsParentModeMemberTypeAdult,
    };
    if (role == 'owner') {
      return '$type · ${t.settingsParentModeRoleOwnerSuffix}';
    }
    if (role == 'admin') {
      return '$type · ${t.settingsParentModeRoleAdminSuffix}';
    }
    return type;
  }
}
