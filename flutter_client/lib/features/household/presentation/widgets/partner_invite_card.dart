import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/features/household/presentation/utils/invite_share.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

enum PartnerInviteVariant {
  /// Ocupa la pestaña Pareja mientras falta la otra persona.
  full,

  /// Tarjeta del Home: recordatorio con un solo botón.
  compact,
}

/// Invitar a la pareja cuando el hogar todavía tiene un solo miembro.
///
/// Es la pieza de la que depende todo lo demás: sin la segunda persona el
/// reparto, la plata entre los dos y las propuestas no tienen sentido. Por eso
/// muestra el código ya generado y deja compartirlo en un toque, con el link a
/// la tienda incluido en el mensaje.
class PartnerInviteCard extends ConsumerStatefulWidget {
  final PartnerInviteVariant variant;

  /// Dónde se mostró, para medir qué superficie convierte (`couple_tab`,
  /// `home`).
  final String source;

  const PartnerInviteCard({
    super.key,
    this.variant = PartnerInviteVariant.full,
    required this.source,
  });

  @override
  ConsumerState<PartnerInviteCard> createState() => _PartnerInviteCardState();
}

class _PartnerInviteCardState extends ConsumerState<PartnerInviteCard> {
  String? _code;
  bool _loading = false;
  bool _failed = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    // El servidor reutiliza un código vigente, así que pedirlo al montar no
    // invalida uno que la pareja ya tenga en la mano.
    Future.microtask(_loadCode);
  }

  Future<void> _loadCode() async {
    if (_loading || !mounted) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final result =
          await ref.read(generateInvitationCodeUseCaseProvider).call();
      if (!mounted) return;
      result.fold(
        (failure) {
          log.w('Partner invite code failed: ${failure.message}');
          setState(() => _failed = true);
        },
        (code) => setState(() => _code = code),
      );
    } catch (error, stackTrace) {
      log.w(
        'Partner invite code threw',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) setState(() => _failed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _track(String channel) {
    final mode = ref.read(householdCapabilitiesProvider).type.name;
    unawaited(
      ref.read(analyticsServiceProvider).trackInviteSent(
            mode: mode,
            channel: channel,
          ),
    );
    unawaited(
      ref.read(analyticsServiceProvider).logEvent(
        'partner_invite_action',
        parameters: {'source': widget.source, 'channel': channel},
      ),
    );
  }

  Future<void> _shareWhatsApp() async {
    final code = _code;
    if (code == null || _sharing) return;
    final t = AppLocalizations.of(context);
    setState(() => _sharing = true);
    AppHaptics.tap();
    _track('whatsapp');
    final outcome = await shareInviteViaWhatsApp(
      t,
      code: code,
      type: ref.read(householdCapabilitiesProvider).type,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (outcome == InviteShareOutcome.copiedFallback) {
      AppSnackBar.show(
        context,
        message: t.partnerInviteMessageCopied,
        type: AppSnackBarType.neutral,
      );
    }
  }

  Future<void> _shareOther() async {
    final code = _code;
    if (code == null || _sharing) return;
    final t = AppLocalizations.of(context);
    setState(() => _sharing = true);
    _track('share');
    final outcome = await shareInviteWithSystemSheet(
      t,
      code: code,
      type: ref.read(householdCapabilitiesProvider).type,
    );
    if (!mounted) return;
    setState(() => _sharing = false);
    if (outcome == InviteShareOutcome.copiedFallback) {
      AppSnackBar.show(
        context,
        message: t.partnerInviteMessageCopied,
        type: AppSnackBarType.neutral,
      );
    }
  }

  Future<void> _copyCode() async {
    final code = _code;
    if (code == null) return;
    final t = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: code));
    AppHaptics.selection();
    _track('copy');
    if (!mounted) return;
    AppSnackBar.show(
      context,
      message: t.invitationCopied,
      type: AppSnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      PartnerInviteVariant.full => _buildFull(context),
      PartnerInviteVariant.compact => _buildCompact(context),
    };
  }

  Widget _buildFull(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return AppCard(
      variant: AppCardVariant.hero,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _IconWell(icon: Icons.person_add_alt_1_rounded, size: 52),
          const SizedBox(height: AppSpacing.md),
          Text(
            t.partnerInviteTitle,
            style: AppTypography.screenTitle.copyWith(
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.partnerInviteBody,
            style: AppTypography.body.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          InviteCodeBox(
            label: t.partnerInviteCodeLabel,
            code: _code,
            failed: _failed,
            onCopy: _copyCode,
            onRetry: _loadCode,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: t.partnerInviteShare,
            icon: Icons.send_rounded,
            isFullWidth: true,
            isLoading: _sharing,
            isDisabled: _code == null,
            onTap: _shareWhatsApp,
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: _code == null || _sharing ? null : _shareOther,
              icon: const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(t.partnerInviteShareOther),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.partnerInviteHint,
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return AppCard(
      padding: AppInsets.compactCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const _IconWell(icon: Icons.person_add_alt_1_rounded, size: 44),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.partnerInviteHomeTitle,
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _failed ? t.invitationLoadError : t.partnerInviteHomeBody,
                  style: AppTypography.caption.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (_failed)
            TextButton(
              onPressed: _loadCode,
              child: Text(t.commonRetry),
            )
          else
            AppButton(
              label: t.partnerInviteHomeAction,
              size: AppButtonSize.small,
              isLoading: _sharing || _loading,
              isDisabled: _code == null,
              onTap: _shareWhatsApp,
            ),
        ],
      ),
    );
  }
}

class _IconWell extends StatelessWidget {
  final IconData icon;
  final double size;

  const _IconWell({required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: theme.primary.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: theme.primary, size: size * 0.46),
    );
  }
}

/// El código grande, legible de un vistazo y copiable con un toque.
class InviteCodeBox extends StatelessWidget {
  final String label;
  final String? code;
  final bool failed;
  final VoidCallback onCopy;
  final VoidCallback onRetry;

  const InviteCodeBox({
    super.key,
    required this.label,
    required this.code,
    required this.failed,
    required this.onCopy,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    if (failed) {
      return Row(
        children: [
          Expanded(
            child: Text(
              t.invitationLoadError,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            ),
          ),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(t.commonRetry),
          ),
        ],
      );
    }

    return Semantics(
      button: code != null,
      label: code == null ? null : t.partnerInviteCodeSemantics(code!),
      child: Material(
        color: theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          onTap: code == null ? null : onCopy,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.xs,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: theme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      if (code == null)
                        const ShimmerLoading(
                          width: 150,
                          height: 30,
                          borderRadius: AppRadii.xs,
                        )
                      else
                        ExcludeSemantics(
                          child: Text(
                            code!,
                            style: AppTypography.sectionTitle.copyWith(
                              fontSize: 26,
                              letterSpacing: 5,
                              fontFeatures: kTabularFigures,
                              color: theme.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: code == null ? null : onCopy,
                  tooltip: t.partnerInviteCopy,
                  icon: Icon(
                    Icons.copy_rounded,
                    color: theme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
