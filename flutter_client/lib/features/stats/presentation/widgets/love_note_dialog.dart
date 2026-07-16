import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

Future<void> showLoveNoteDialog({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final t = AppLocalizations.of(context);
  final theme = context.theme;
  final controller = TextEditingController();
  var isSending = false;

  return showDialog<void>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
          actionsPadding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.hero),
          backgroundColor: theme.surface,
          surfaceTintColor: Colors.transparent,
          title: Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFEF4444)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  t.loveNoteDialogTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.heroAmount.copyWith(
                    fontSize: 24,
                    color: theme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: TextField(
              controller: controller,
              minLines: 3,
              maxLines: 4,
              style: TextStyle(color: theme.textPrimary),
              decoration: InputDecoration(
                hintText: t.loveNoteHint,
                filled: true,
                fillColor: const Color(0xFFEF4444).withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.pop(ctx),
              child: Text(
                t.commonCancel,
                style: TextStyle(color: theme.textMuted),
              ),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      final content = controller.text.trim();
                      if (content.isEmpty) return;
                      setDialogState(() => isSending = true);

                      final currentUserId = ref.read(currentUserIdProvider);
                      final householdId =
                          await ref.read(householdIdProvider.future);
                      final members =
                          ref.read(householdMembersProvider).value ?? [];
                      final partner = members
                          .where((m) => m.userId != currentUserId)
                          .firstOrNull;

                      if (currentUserId == null ||
                          householdId == null ||
                          partner == null) {
                        if (ctx.mounted) {
                          setDialogState(() => isSending = false);
                        }
                        return;
                      }

                      await ref.read(loveNotesProvider.notifier).sendNote(
                            content: content,
                            fromUserId: currentUserId,
                            toUserId: partner.userId,
                            householdId: householdId,
                          );

                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(t.loveNoteSent),
                            backgroundColor: const Color(0xFFEF4444),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                minimumSize: const Size(124, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
              child: isSending
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(t.commonSend),
            ),
          ],
        );
      },
    ),
  ).whenComplete(controller.dispose);
}
