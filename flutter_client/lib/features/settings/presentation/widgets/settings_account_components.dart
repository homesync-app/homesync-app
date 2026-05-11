import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/settings/presentation/widgets/feedback_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class SettingsNotificationsCard extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const SettingsNotificationsCard({
    super.key,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: theme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: theme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.settingsNotificationsTitle,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: theme.textPrimary,
                      ),
                    ),
                    Text(
                      t.settingsNotificationsSubtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isEnabled,
                activeTrackColor: theme.primary,
                onChanged: onChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SettingsFaqCard extends StatelessWidget {
  final VoidCallback onTap;

  const SettingsFaqCard({
    super.key,
    required this.onTap,
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
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: theme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.help_outline_rounded,
            color: theme.primary,
            size: 20,
          ),
        ),
        title: Text(
          t.settingsFaqTitle,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        subtitle: Text(
          t.settingsFaqSubtitle,
          style: TextStyle(color: theme.textSecondary, fontSize: 12),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
        onTap: onTap,
      ),
    );
  }
}

class SettingsLogoutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SettingsLogoutButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      height: 62,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: theme.error.withValues(alpha: 0.2),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          foregroundColor: theme.error,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 22),
            const SizedBox(width: 12),
            Text(
              t.settingsLogoutButton,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsDangerZone extends StatelessWidget {
  final VoidCallback onResetPressed;

  const SettingsDangerZone({
    super.key,
    required this.onResetPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            t.settingsDangerZoneEyebrow,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: theme.error,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 62,
          child: OutlinedButton(
            onPressed: onResetPressed,
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: theme.error.withValues(alpha: 0.2),
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              foregroundColor: theme.error,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.delete_forever_rounded, size: 22),
                const SizedBox(width: 12),
                Text(
                  t.settingsResetAccountButton,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SettingsVersionFooter extends StatelessWidget {
  final bool isAdminEnabled;
  final VoidCallback? onTap;

  const SettingsVersionFooter({
    super.key,
    required this.isAdminEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return GestureDetector(
      onTap: isAdminEnabled ? onTap : null,
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: [
            Text(
              'HOMESYNC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsFeedbackCard extends StatelessWidget {
  const SettingsFeedbackCard({super.key});

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
            color: theme.shadow.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  Icon(Icons.bug_report_outlined, color: theme.error, size: 20),
            ),
            title: Text(
              t.settingsFeedbackBugTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            subtitle: Text(
              t.settingsFeedbackBugSubtitle,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
            onTap: () {
              HapticFeedback.lightImpact();
              FeedbackSheet.show(context, type: FeedbackType.bug);
            },
          ),
          Divider(
            height: 1,
            color: theme.divider.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                color: theme.primary,
                size: 20,
              ),
            ),
            title: Text(
              t.settingsFeedbackSuggestionTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: theme.textPrimary,
              ),
            ),
            subtitle: Text(
              t.settingsFeedbackSuggestionSubtitle,
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: theme.textMuted),
            onTap: () {
              HapticFeedback.lightImpact();
              FeedbackSheet.show(context, type: FeedbackType.suggestion);
            },
          ),
        ],
      ),
    );
  }
}

Future<bool?> showSettingsLogoutDialog(BuildContext context) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 30),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: theme.border.withValues(alpha: 0.52)),
            boxShadow: [
              BoxShadow(
                color: theme.shadow.withValues(alpha: 0.14),
                blurRadius: 34,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: theme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: theme.error,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.settingsLogoutDialogTitle,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.settingsLogoutDialogBody,
                          style: TextStyle(
                            color: theme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.38,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.textPrimary,
                          side: BorderSide(
                            color: theme.border.withValues(alpha: 0.82),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          t.commonCancel,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.error.withValues(alpha: 0.9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          t.settingsLogoutDialogConfirm,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<bool?> showSettingsResetAccountDialog(BuildContext context) {
  final theme = context.theme;
  final t = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: theme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.error),
          const SizedBox(width: 12),
          Text(
            t.settingsResetDialogTitle,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: theme.error,
            ),
          ),
        ],
      ),
      content: Text(t.settingsResetDialogBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(
            t.commonCancel,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              t.settingsResetDialogConfirm,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    ),
  );
}
