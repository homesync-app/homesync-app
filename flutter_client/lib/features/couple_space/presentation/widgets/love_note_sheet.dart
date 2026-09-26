import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';

/// Escribir una nota corta para la pareja. Le llega como un sobre en el Home.
Future<void> showLoveNoteSheet(
  BuildContext context, {
  required MemberModel partner,
  required String householdId,
  required String senderName,
}) {
  return AppSheet.show<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _LoveNoteSheet(
      partner: partner,
      householdId: householdId,
      senderName: senderName,
    ),
  );
}

class _LoveNoteSheet extends ConsumerStatefulWidget {
  final MemberModel partner;
  final String householdId;
  final String senderName;

  const _LoveNoteSheet({
    required this.partner,
    required this.householdId,
    required this.senderName,
  });

  @override
  ConsumerState<_LoveNoteSheet> createState() => _LoveNoteSheetState();
}

class _LoveNoteSheetState extends ConsumerState<_LoveNoteSheet> {
  final _controller = TextEditingController();
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _partnerFirstName =>
      widget.partner.displayName.trim().split(RegExp(r'\s+')).first;

  Future<void> _send() async {
    final content = _controller.text.trim();
    final currentUserId = ref.read(currentUserIdProvider);
    if (content.isEmpty || currentUserId == null || _sending) return;

    final t = AppLocalizations.of(context);
    setState(() {
      _sending = true;
      _error = null;
    });

    // El toast se muestra desde el contexto del navigator: el del sheet ya no
    // existe cuando termina el pop.
    final navigator = Navigator.of(context);
    try {
      await ref.read(loveNotesProvider.notifier).sendNote(
            content: content,
            fromUserId: currentUserId,
            toUserId: widget.partner.userId,
            householdId: widget.householdId,
            pushTitle: t.loveNotePushTitle(widget.senderName),
            pushBody: t.loveNotePushBody,
          );
      if (!mounted) return;
      AppHaptics.success();
      navigator.pop();
      final hostContext = navigator.context;
      if (!hostContext.mounted) return;
      AppSnackBar.show(
        hostContext,
        message: t.loveNoteSent,
        type: AppSnackBarType.success,
      );
    } catch (error, stackTrace) {
      log.e('Love note send failed', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = friendlyErrorMessage(error, t: t);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppRadii.sheet,
        boxShadow: theme.modalShadow,
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        12,
        AppSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.border,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.coupleWeekNoteTitle(_partnerFirstName),
              style: AppTypography.screenTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              t.coupleWeekNoteBody,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _controller,
              autofocus: true,
              enabled: !_sending,
              minLines: 3,
              maxLines: 6,
              maxLength: LoveNotesNotifier.maxLength,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: t.loveNoteHint,
                errorText: _error,
                errorMaxLines: 3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: t.commonSend,
              icon: Icons.send_rounded,
              isFullWidth: true,
              isLoading: _sending,
              isDisabled: !hasText,
              onTap: _send,
            ),
          ],
        ),
      ),
    );
  }
}
