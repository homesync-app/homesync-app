import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/portal_labs/reveal_copy_interaction.dart';
import 'package:url_launcher/url_launcher.dart';

class InvitationSheet extends ConsumerStatefulWidget {
  const InvitationSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const InvitationSheet(),
    );
  }

  @override
  ConsumerState<InvitationSheet> createState() => _InvitationSheetState();
}

class _InvitationSheetState extends ConsumerState<InvitationSheet> {
  String? _invitationCode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvitationCode();
  }

  Future<void> _loadInvitationCode() async {
    setState(() => _isLoading = true);
    try {
      final hId = await ref.read(householdIdProvider.future);
      if (hId == null) return;

      // Intentar buscar código existente o generar uno nuevo
      final result =
          await ref.read(generateInvitationCodeUseCaseProvider).call();
      result.fold(
        (failure) => _showError(failure.message),
        (code) => setState(() => _invitationCode = code),
      );
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  // Used by the WhatsApp-share fallback: copies to the clipboard and confirms.
  void _copyCode() {
    if (_invitationCode == null) return;
    Clipboard.setData(ClipboardData(text: _invitationCode!));
    _showCopiedFeedback();
  }

  // RevealCopyInteraction writes to the clipboard itself; this only surfaces
  // the confirmation feedback.
  void _showCopiedFeedback() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).invitationCopied),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _shareViaWhatsApp() async {
    if (_invitationCode == null) return;

    final t = AppLocalizations.of(context);
    final caps = ref.read(householdCapabilitiesProvider);
    String intro = t.invitationIntroDefault;

    if (caps.type == HouseholdType.couple) {
      intro = t.invitationIntroCouple;
    } else if (caps.type == HouseholdType.family) {
      intro = t.invitationIntroFamily;
    } else if (caps.type == HouseholdType.friends) {
      intro = t.invitationIntroFriends;
    }

    final text = t.invitationShareBody(intro, _invitationCode!);
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(text)}');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _copyCode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(AppLocalizations.of(context).invitationWhatsAppFailed),
            ),
          );
        }
      }
    } catch (e) {
      _copyCode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final caps = ref.watch(householdCapabilitiesProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.divider.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            t.invitationTitle,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caps.type == HouseholdType.family
                ? t.invitationSubtitleFamily
                : caps.type == HouseholdType.friends
                    ? t.invitationSubtitleFriends
                    : t.invitationSubtitleDefault,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: theme.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: AppLoader(),
            )
          else if (_invitationCode != null) ...[
            RevealCopyInteraction(
              value: _invitationCode!,
              maskCharacter: '•',
              revealDuration: const Duration(seconds: 30),
              successColor: AppColors.success,
              backgroundColor: theme.primary.withValues(alpha: 0.05),
              borderColor: theme.primary.withValues(alpha: 0.2),
              borderRadius: 20,
              textStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: theme.primary,
              ),
              maskedTextStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: theme.primary.withValues(alpha: 0.45),
              ),
              onCopied: _showCopiedFeedback,
            ),
            const SizedBox(height: 12),
            Text(
              t.invitationTapToCopy,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareViaWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                ),
                icon: const Icon(Icons.share_rounded),
                label: Text(
                  t.invitationShareWhatsApp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ] else
            TextButton.icon(
              onPressed: _loadInvitationCode,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(t.invitationRetry),
            ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              t.commonClose,
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
