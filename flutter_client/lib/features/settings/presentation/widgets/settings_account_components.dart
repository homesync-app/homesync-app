import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsDangerZone extends StatelessWidget {
  final VoidCallback onResetPressed;
  final VoidCallback? onDeletePressed;

  const SettingsDangerZone({
    super.key,
    required this.onResetPressed,
    this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            t.settingsDangerZoneEyebrow,
            style: AppTypography.eyebrow.copyWith(
              letterSpacing: 1.5,
              color: theme.error,
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
                borderRadius: BorderRadius.circular(AppRadii.lg),
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
                  style: AppTypography.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (onDeletePressed != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextButton(
              onPressed: onDeletePressed,
              style: TextButton.styleFrom(
                foregroundColor: theme.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_rounded, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    t.settingsDeleteAccountButton,
                    style: AppTypography.cardTitle.copyWith(
                      fontSize: 15,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
              style: AppTypography.eyebrow.copyWith(
                fontSize: 10,
                letterSpacing: 2,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                final info = snapshot.data;
                return Text(
                  info == null
                      ? ''
                      : 'Version ${info.version}+${info.buildNumber}',
                  style: AppTypography.caption.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: theme.textSecondary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog de confirmación destructiva compartido por logout, reset y borrado
/// de cuenta: un solo estilo (el de logout) en vez de tres AlertDialogs
/// distintos conviviendo en la misma pantalla.
Future<bool?> _showDestructiveConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String body,
  required String confirmLabel,
}) {
  final t = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final theme = dialogContext.theme;
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
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(icon, color: theme.error, size: 23),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.heroAmount.copyWith(
                            fontSize: 24,
                            color: theme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          body,
                          style: AppTypography.body.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            height: 1.38,
                            color: theme.textSecondary,
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
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 15,
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
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            confirmLabel,
                            maxLines: 1,
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
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

Future<bool?> showSettingsLogoutDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return _showDestructiveConfirmDialog(
    context,
    icon: Icons.logout_rounded,
    title: t.settingsLogoutDialogTitle,
    body: t.settingsLogoutDialogBody,
    confirmLabel: t.settingsLogoutDialogConfirm,
  );
}

Future<bool?> showSettingsResetAccountDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return _showDestructiveConfirmDialog(
    context,
    icon: Icons.delete_forever_rounded,
    title: t.settingsResetDialogTitle,
    body: t.settingsResetDialogBody,
    confirmLabel: t.settingsResetDialogConfirm,
  );
}

Future<bool?> showSettingsDeleteAccountDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  return _showDestructiveConfirmDialog(
    context,
    icon: Icons.person_off_rounded,
    title: t.settingsDeleteAccountDialogTitle,
    body: t.settingsDeleteAccountDialogBody,
    confirmLabel: t.settingsDeleteAccountConfirm,
  );
}
