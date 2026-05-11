import 'package:flutter/material.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class SettingsNoHouseholdCard extends StatelessWidget {
  final VoidCallback onJoin;

  const SettingsNoHouseholdCard({
    super.key,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.group_add_rounded, size: 40, color: theme.primary),
          ),
          const SizedBox(height: 24),
          Text(
            t.settingsHouseholdEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            t.settingsHouseholdEmptyBody,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 15,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: onJoin,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.login_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  t.settingsHouseholdJoinWithCodeButton,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsHouseholdCard extends StatelessWidget {
  final String householdName;
  final String householdTypeLabel;
  final Widget membersContent;
  final VoidCallback onEdit;
  final bool tasksEnabled;
  final bool showTasksToggle;
  final ValueChanged<bool>? onTasksEnabledChanged;

  const SettingsHouseholdCard({
    super.key,
    required this.householdName,
    required this.householdTypeLabel,
    required this.membersContent,
    required this.onEdit,
    required this.tasksEnabled,
    this.showTasksToggle = true,
    this.onTasksEnabledChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primary.withValues(alpha: 0.08),
                  theme.primary.withValues(alpha: 0.00),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      Icon(Icons.home_rounded, color: theme.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        householdName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: theme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          householdTypeLabel.toUpperCase(),
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: theme.primary,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: theme.border.withValues(alpha: 0.28),
            indent: 18,
            endIndent: 18,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                membersContent,
                if (showTasksToggle) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackground,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: theme.border.withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: theme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.task_alt_rounded,
                            color: theme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.settingsHouseholdTasksToggleTitle,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: theme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tasksEnabled
                                    ? t.settingsHouseholdTasksToggleOnSubtitle
                                    : t.settingsHouseholdTasksToggleOffSubtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  height: 1.35,
                                  color: theme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: tasksEnabled,
                          onChanged: onTasksEnabledChanged,
                        ),
                      ],
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

class SettingsHouseholdMembersSection extends StatelessWidget {
  final int memberCount;
  final List<Widget> memberRows;

  const SettingsHouseholdMembersSection({
    super.key,
    required this.memberCount,
    required this.memberRows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              t.settingsHouseholdMembersEyebrow,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: theme.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              t.settingsHouseholdMembersCount(memberCount),
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...memberRows,
      ],
    );
  }
}

class SettingsHouseholdMemberRow extends StatelessWidget {
  final String name;
  final String roleLabel;
  final String? avatarUrl;
  final bool isCurrentUser;
  final bool showOwnerStar;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onQaDelete;

  const SettingsHouseholdMemberRow({
    super.key,
    required this.name,
    required this.roleLabel,
    required this.avatarUrl,
    required this.isCurrentUser,
    required this.showOwnerStar,
    this.onEdit,
    this.onRemove,
    this.onQaDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final hasActions = onEdit != null || onRemove != null || onQaDelete != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? theme.primary.withValues(alpha: 0.035)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            CustomUserAvatar(
              name: name,
              avatarUrl: avatarUrl,
              radius: 17,
              forceCircular: true,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight:
                              isCurrentUser ? FontWeight.w800 : FontWeight.w700,
                          fontSize: 14,
                          color:
                              isCurrentUser ? theme.primary : theme.textPrimary,
                        ),
                      ),
                      if (isCurrentUser)
                        _SettingsMemberTinyChip(
                          label: t.settingsHouseholdMemberSelfChip,
                          color: theme.primary,
                        ),
                      if (showOwnerStar)
                        _SettingsMemberTinyChip(
                          label: t.settingsHouseholdMemberAdminChip,
                          color: Colors.amber.shade700,
                          icon: Icons.star_rounded,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (hasActions)
              PopupMenuButton<String>(
                tooltip: t.settingsHouseholdMemberMenuTooltip,
                icon: Icon(
                  Icons.more_horiz_rounded,
                  color: theme.textSecondary,
                  size: 22,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: theme.surface,
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'remove') onRemove?.call();
                  if (value == 'qa_delete') onQaDelete?.call();
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(t.settingsHouseholdMemberMenuEditRole),
                    ),
                  if (onRemove != null)
                    PopupMenuItem(
                      value: 'remove',
                      child: Text(t.settingsHouseholdMemberMenuRemove),
                    ),
                  if (onQaDelete != null)
                    PopupMenuItem(
                      value: 'qa_delete',
                      child: Text(t.settingsHouseholdMemberMenuDeleteDummyQa),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMemberTinyChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _SettingsMemberTinyChip({
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsHouseholdMemberData {
  final String name;
  final String roleLabel;
  final String? avatarUrl;
  final bool isCurrentUser;
  final bool showOwnerStar;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;
  final VoidCallback? onQaDelete;

  const SettingsHouseholdMemberData({
    required this.name,
    required this.roleLabel,
    required this.avatarUrl,
    required this.isCurrentUser,
    required this.showOwnerStar,
    this.onEdit,
    this.onRemove,
    this.onQaDelete,
  });
}

List<SettingsHouseholdMemberData> buildSettingsHouseholdMemberData({
  required BuildContext context,
  required List<Map<String, dynamic>> members,
  required String? currentUserId,
  required bool isAdminQaUser,
  required String Function(Map<String, dynamic> member, String? role)
      roleLabelBuilder,
  required void Function(Map<String, dynamic> member) onEditRole,
  required void Function(String userId, String name) onRemoveMember,
  required void Function(String userId, String name) onDeleteDummyMember,
  required bool isOwner,
}) {
  return members.map((member) {
    final userData = (member['users'] is Map) ? member['users'] as Map : {};
    final t = AppLocalizations.of(context);
    final rawName = (userData['full_name'] as String?) ??
        (userData['email'] as String?)?.split('@').first ??
        t.settingsHouseholdMemberFallbackName;
    final email = userData['email'] as String?;
    final avatarUrl = userData['avatar_url'] as String?;
    final role = member['role'] ?? 'member';
    final isCurrentUser = member['user_id'] == currentUserId;
    final isQaDummy = AppEnvironment.enableAdminTesting &&
        isAdminQaUser &&
        (email?.startsWith('qa.') ?? false) &&
        (email?.endsWith('@homesync.local') ?? false);

    return SettingsHouseholdMemberData(
      name: rawName,
      roleLabel: roleLabelBuilder(member, role),
      avatarUrl: avatarUrl,
      isCurrentUser: isCurrentUser,
      showOwnerStar: role == 'owner',
      onEdit: (isCurrentUser || isOwner) ? () => onEditRole(member) : null,
      onRemove: (isOwner && !isCurrentUser)
          ? () => onRemoveMember(member['user_id'], rawName)
          : null,
      onQaDelete: (isQaDummy && !isCurrentUser)
          ? () => onDeleteDummyMember(member['user_id'], rawName)
          : null,
    );
  }).toList();
}

Widget buildSettingsCombinedHouseholdCard(
  BuildContext context, {
  required String householdName,
  required String householdTypeLabel,
  required int memberCount,
  required VoidCallback onEdit,
  required List<SettingsHouseholdMemberData> members,
  required bool tasksEnabled,
  bool showTasksToggle = true,
  ValueChanged<bool>? onTasksEnabledChanged,
}) {
  return SettingsHouseholdCard(
    householdName: householdName,
    householdTypeLabel: householdTypeLabel,
    onEdit: onEdit,
    tasksEnabled: tasksEnabled,
    showTasksToggle: showTasksToggle,
    onTasksEnabledChanged: onTasksEnabledChanged,
    membersContent: SettingsHouseholdMembersSection(
      memberCount: memberCount,
      memberRows: members
          .map(
            (member) => SettingsHouseholdMemberRow(
              name: member.name,
              roleLabel: member.roleLabel,
              avatarUrl: member.avatarUrl,
              isCurrentUser: member.isCurrentUser,
              showOwnerStar: member.showOwnerStar,
              onEdit: member.onEdit,
              onRemove: member.onRemove,
              onQaDelete: member.onQaDelete,
            ),
          )
          .toList(),
    ),
  );
}

Future<void> showSettingsJoinHouseholdDialog(
  BuildContext context, {
  required Future<String?> Function(String code) onJoin,
}) async {
  final codeController = TextEditingController();
  String? errorText;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => StatefulBuilder(
      builder: (dialogCtx, setDialogState) {
        bool isLoading = false;

        Future<void> doJoin() async {
          final code = codeController.text.trim().toUpperCase();
          if (code.length != 6) {
            setDialogState(
              () => errorText = 'El codigo debe tener 6 caracteres',
            );
            return;
          }

          setDialogState(() {
            isLoading = true;
            errorText = null;
          });

          final joinError = await onJoin(code);
          if (!dialogCtx.mounted) return;

          if (joinError == null) {
            Navigator.pop(dialogCtx);
            return;
          }

          setDialogState(() {
            isLoading = false;
            errorText = joinError;
          });
        }

        return AlertDialog(
          backgroundColor: context.theme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                Icons.login_rounded,
                color: context.theme.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(AppLocalizations.of(context).settingsHouseholdJoinDialogTitle),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).settingsHouseholdJoinDialogBody,
                style: TextStyle(
                  color: context.theme.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                textAlign: TextAlign.center,
                enabled: !isLoading,
                style: TextStyle(
                  fontSize: 28,
                  letterSpacing: 10,
                  fontWeight: FontWeight.w800,
                  color: context.theme.primary,
                ),
                maxLength: 6,
                onChanged: (_) => setDialogState(() => errorText = null),
                onSubmitted: (_) => doJoin(),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'ABC123',
                  hintStyle: TextStyle(
                    letterSpacing: 4,
                    color: context.theme.textMuted,
                    fontSize: 22,
                  ),
                  filled: true,
                  fillColor: context.theme.primary.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: context.theme.primary,
                      width: 2,
                    ),
                  ),
                  errorText: errorText,
                ),
                textCapitalization: TextCapitalization.characters,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogCtx),
              child: Text(AppLocalizations.of(context).commonCancel),
            ),
            ElevatedButton(
              onPressed: isLoading ? null : doJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.theme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(100, 48),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context)
                          .settingsHouseholdJoinDialogConfirm,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ],
        );
      },
    ),
  );
}

void showSettingsEditHouseholdMenu(
  BuildContext context, {
  required String householdName,
  required String? invitationCode,
  required String? householdType,
  required VoidCallback onEditName,
  required VoidCallback onInvitationCode,
  required VoidCallback onCoupleSplit,
}) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                householdName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_rounded, color: AppColors.primary),
              ),
              title: Text(t.settingsHouseholdEditMenuRenameTitle),
              subtitle: Text(t.settingsHouseholdEditMenuRenameSubtitle),
              onTap: () {
                Navigator.pop(ctx);
                onEditName();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.share_rounded,
                  color: AppColors.accentBlue,
                ),
              ),
              title: Text(t.settingsHouseholdEditMenuInviteTitle),
              subtitle: Text(
                invitationCode != null
                    ? t.settingsHouseholdEditMenuInviteSubtitleExisting
                    : t.settingsHouseholdEditMenuInviteSubtitleNone,
              ),
              onTap: () {
                Navigator.pop(ctx);
                onInvitationCode();
              },
            ),
            if (householdType == 'couple' || householdType == 'family')
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.balance_rounded,
                    color: AppColors.accentTeal,
                  ),
                ),
                title: Text(
                  t.settingsHouseholdEditMenuSplitTitle(
                    householdType ?? 'couple',
                  ),
                ),
                subtitle: Text(
                  t.settingsHouseholdEditMenuSplitSubtitle(
                    householdType ?? 'couple',
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  onCoupleSplit();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

void showSettingsInvitationCodeSheet(
  BuildContext context, {
  required String? invitationCode,
  required Future<void> Function(VoidCallback refreshSheet) onGenerateCode,
  required VoidCallback onShareWhatsApp,
  required VoidCallback onCopyCode,
}) {
  final theme = context.theme;

  showModalBottomSheet(
    context: context,
    backgroundColor: theme.surface,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setSheetState) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.share_rounded, color: theme.primary),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context)
                        .settingsHouseholdInviteSheetTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)
                    .settingsHouseholdInviteSheetSubtitle,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 24),
              if (invitationCode != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: Text(
                            invitationCode,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              color: theme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onShareWhatsApp,
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'WhatsApp',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          elevation: 0,
                          minimumSize: const Size(120, 48),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: AppLocalizations.of(context)
                            .settingsHouseholdInviteSheetCopyTooltip,
                        onPressed: onCopyCode,
                        icon: Icon(Icons.copy_rounded, color: theme.primary),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.primary.withValues(alpha: 0.1),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)
                          .settingsHouseholdInviteSheetEmpty,
                      style: TextStyle(color: theme.textMuted),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await onGenerateCode(() => setSheetState(() {}));
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(
                    invitationCode == null
                        ? AppLocalizations.of(context)
                            .settingsHouseholdInviteSheetGenerate
                        : AppLocalizations.of(context)
                            .settingsHouseholdInviteSheetRegenerate,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primary,
                    side: BorderSide(color: theme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool?> showSettingsRemoveMemberDialog(
  BuildContext context, {
  required String memberName,
}) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        t.settingsHouseholdRemoveMemberTitle,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: Text(t.settingsHouseholdRemoveMemberBody(memberName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(t.commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(100, 48),
          ),
          child: Text(t.settingsHouseholdRemoveMemberConfirm),
        ),
      ],
    ),
  );
}

Future<bool?> showSettingsDeleteDummyMemberDialog(
  BuildContext context, {
  required String memberName,
}) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Text(
        t.settingsHouseholdDeleteDummyTitle,
        style: const TextStyle(fontWeight: FontWeight.w900),
      ),
      content: Text(t.settingsHouseholdDeleteDummyBody(memberName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(t.commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(128, 48),
          ),
          child: Text(t.settingsHouseholdDeleteDummyConfirm),
        ),
      ],
    ),
  );
}

Future<String?> showSettingsRenameHouseholdDialog(
  BuildContext context, {
  required String? initialName,
}) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialName);

  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        t.settingsHouseholdRenameDialogTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          labelText: t.settingsHouseholdRenameDialogLabel,
          filled: true,
          fillColor: theme.primary.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(t.commonCancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(100, 48),
          ),
          child: Text(t.commonSave),
        ),
      ],
    ),
  );
}
