import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/core/widgets/concept_icon.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/domain/models/redemption_model.dart';
import 'package:homesync_client/features/rewards/presentation/providers/reward_provider.dart';
import 'package:homesync_client/features/rewards/presentation/utils/reward_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:intl/intl.dart';

/// Bandeja de canjes pendientes del hogar (compartida entre pareja y familia).
///
/// Muestra los premios ya canjeados que todavía no se entregaron. Los adultos
/// ven todos los canjes del hogar y pueden marcar como entregados los ajenos
/// (RPC `fulfill_redemption`); el que canjeó ve el suyo "en camino". Los
/// chicos solo ven sus propios canjes. Sin canjes pendientes la sección se
/// colapsa a nada, [margin] incluido.
class PendingRedemptionsSection extends ConsumerStatefulWidget {
  const PendingRedemptionsSection({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  ConsumerState<PendingRedemptionsSection> createState() =>
      _PendingRedemptionsSectionState();
}

class _PendingRedemptionsSectionState
    extends ConsumerState<PendingRedemptionsSection> {
  final Set<String> _inFlight = {};

  @override
  Widget build(BuildContext context) {
    final redemptions = ref.watch(pendingRedemptionsProvider).value ??
        const <RedemptionModel>[];
    if (redemptions.isEmpty) return const SizedBox.shrink();

    final currentUserId = ref.watch(currentUserIdProvider);
    final members = ref.watch(householdMembersProvider).value;
    final currentMember =
        members?.where((m) => m.userId == currentUserId).firstOrNull;
    // Mientras el rol no cargó asumimos que no puede marcar: los chicos (y
    // los desconocidos) solo ven sus propios canjes.
    final canFulfill = currentMember?.isAdult ?? false;

    final visible = canFulfill
        ? redemptions
        : redemptions.where((r) => r.userId == currentUserId).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);

    String redeemerName(RedemptionModel redemption) =>
        members
            ?.where((m) => m.userId == redemption.userId)
            .firstOrNull
            ?.displayName ??
        t.rewardsMemberFallbackName;

    return Padding(
      padding: widget.margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(t, visible.length),
          const SizedBox(height: 14),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _buildCard(
              visible[i],
              canFulfill: canFulfill && visible[i].userId != currentUserId,
              isMine: visible[i].userId == currentUserId,
              redeemerName: redeemerName(visible[i]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations t, int count) {
    final theme = context.theme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.rewardsPendingRedemptionsTitle,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                t.rewardsPendingRedemptionsSubtitle,
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.accentGold.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    RedemptionModel redemption, {
    required bool canFulfill,
    required bool isMine,
    required String redeemerName,
  }) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final title = localizedRewardTitleByKey(
      t,
      redemption.rewardTitleKey,
      redemption.rewardTitle,
    );
    final locale = Localizations.localeOf(context).toString();
    final dateLabel = DateFormat('d MMM', locale)
        .format(redemption.createdAt ?? DateTime.now());

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.22),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Center(
              child: ConceptIcon(emoji: redemption.rewardIcon, size: 46),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isMine
                      ? t.rewardsRedeemedByYouOn(dateLabel)
                      : t.rewardsRedeemedByOn(redeemerName, dateLabel),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (canFulfill)
            _buildFulfillButton(redemption, title, redeemerName)
          else
            _buildWaitingPill(t),
        ],
      ),
    );
  }

  Widget _buildFulfillButton(
    RedemptionModel redemption,
    String title,
    String redeemerName,
  ) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final busy = _inFlight.contains(redemption.id);

    return ElevatedButton(
      onPressed:
          busy ? null : () => _confirmFulfill(redemption, title, redeemerName),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        minimumSize: const Size(0, 38),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      child: busy
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              t.rewardsMarkFulfilled,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }

  Widget _buildWaitingPill(AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            size: 14,
            color: AppColors.accentGold,
          ),
          const SizedBox(width: 6),
          Text(
            t.rewardsWaitingFulfillment,
            style: const TextStyle(
              color: AppColors.accentGold,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmFulfill(
    RedemptionModel redemption,
    String title,
    String redeemerName,
  ) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        title: Text(t.rewardsFulfillConfirmTitle),
        content: Text(t.rewardsFulfillConfirmBody(title, redeemerName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(t.commonCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.theme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
            ),
            child: Text(t.rewardsMarkFulfilled),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _inFlight.add(redemption.id));
    final result =
        await ref.read(pendingRedemptionsProvider.notifier).fulfill(
              redemption.id,
            );
    if (!mounted) return;
    setState(() => _inFlight.remove(redemption.id));

    result.fold(
      (failure) {
        AppHaptics.error();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
        // El fallo típico es "ya procesado" (el otro adulto llegó antes):
        // refrescar para sacar la fila vieja de la bandeja.
        ref.invalidate(pendingRedemptionsProvider);
      },
      (_) {
        AppHaptics.success();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.rewardsFulfilledSnack(title))),
        );
      },
    );
  }
}
