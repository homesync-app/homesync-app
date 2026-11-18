import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/premium_avatar_art.dart';

/// The same personal avatars as the rest of the app, with a compact welcome.
class CoupleHomeWelcome extends StatelessWidget {
  final MemberModel? me;
  final MemberModel? partner;
  final Widget? note;
  final VoidCallback? onTap;
  const CoupleHomeWelcome({
    super.key,
    this.me,
    this.partner,
    this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.coupleHomeWelcomeTitle,
          style: AppTypography.sectionTitle.copyWith(color: theme.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          partner == null
              ? t.coupleHomeWelcomeSolo
              : t.coupleHomeWelcomeWith(partner!.displayName.split(' ').first),
          style: AppTypography.body.copyWith(color: theme.textSecondary),
        ),
        if (partner != null && onTap != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  t.couplePlansTitle,
                  style: AppTypography.caption.copyWith(
                    color: theme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: theme.primary,
              ),
            ],
          ),
        ],
      ],
    );
    final duo = PremiumAvatarArt.duoFor(me?.avatarUrl, partner?.avatarUrl);
    final avatars = ExcludeSemantics(
      child: SizedBox(
        width: 132,
        height: 100,
        child: duo != null
            ? Image.asset(duo, fit: BoxFit.contain, cacheWidth: 396)
            : const Center(child: CoupleArt(kind: CoupleArtKind.home, size: 84)),
      ),
    );
    return CoupleSurface(
      onTap: onTap,
      color: Color.alphaBlend(
        AppColors.accentPeach.withValues(alpha: 0.13),
        theme.surface,
      ),
      borderColor: Colors.transparent,
      radius: AppRadii.xxl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 290;
              return Row(
                children: [
                  Expanded(child: copy),
                  const SizedBox(width: AppSpacing.xs),
                  SizedBox(
                    width: compact ? 96 : 132,
                    height: compact ? 80 : 100,
                    child: FittedBox(child: avatars),
                  ),
                ],
              );
            },
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: note,
            ),
        ],
      ),
    );
  }
}

/// One tappable task; the completion orchestration stays in the home screen.
class CoupleHomeTaskRow extends StatelessWidget {
  final TaskModel task;
  final MemberModel? assigned;
  final String? currentUserId;
  final bool busy;
  final VoidCallback onTap;
  const CoupleHomeTaskRow({
    super.key,
    required this.task,
    required this.assigned,
    required this.currentUserId,
    required this.busy,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final title = localizedTaskTitle(t, task);
    final owner = assigned == null
        ? t.familyTaskCardUnassignedToday
        : assigned!.userId == currentUserId
            ? t.coupleWeekYou
            : assigned!.displayName.split(' ').first;
    return AnimatedPress(
      onTap: busy ? null : onTap,
      semanticLabel: '${t.coupleHomeCompleteTask(title)}. $owner',
      excludeChildSemantics: true,
      child: CoupleSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            ExcludeSemantics(child: _HomeMemberFace(member: assigned)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.cardTitle
                        .copyWith(color: theme.textPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    owner,
                    style: AppTypography.caption
                        .copyWith(color: theme.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            SizedBox.square(
              dimension: 36,
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(7),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.primary,
                      ),
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.textMuted.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeMemberFace extends StatelessWidget {
  final MemberModel? member;
  const _HomeMemberFace({required this.member});
  @override
  Widget build(BuildContext context) {
    if (member == null) {
      return const CoupleArt(kind: CoupleArtKind.home, size: 44);
    }
    return MemberPortrait(
      name: member!.displayName,
      avatarUrl: member!.avatarUrl,
    );
  }
}

class CoupleHomeBalance extends StatelessWidget {
  final double balance;
  final String partnerName;
  final bool shared;
  final double? monthlySpent;
  final bool justSettled;
  final String Function(double) formatAmount;
  final VoidCallback? onSettle;
  final VoidCallback onMovements;
  const CoupleHomeBalance({
    super.key,
    required this.balance,
    required this.partnerName,
    required this.formatAmount,
    required this.onMovements,
    this.shared = false,
    this.monthlySpent,
    this.justSettled = false,
    this.onSettle,
  });
  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final even = balance.abs() <= 10;
    final label = shared
        ? t.coupleWeekMoneySharedLabel
        : justSettled || even
            ? t.coupleWeekMoneyEven
            : balance < 0
                ? t.coupleWeekMoneyYouOweLabel(partnerName)
                : t.coupleWeekMoneyTheyOweLabel(partnerName);
    final amount = shared
        ? (monthlySpent == null ? null : formatAmount(monthlySpent!))
        : even
            ? null
            : formatAmount(balance.abs());
    final summary = Row(
      children: [
        const CoupleArt(kind: CoupleArtKind.wallet, size: 48),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                    AppTypography.caption.copyWith(color: theme.textSecondary),
              ),
              if (amount != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    amount,
                    style: AppTypography.screenTitle.copyWith(
                      color: theme.textPrimary,
                      fontFeatures: kTabularFigures,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
    final canSettle = !shared && balance < -10 && onSettle != null;
    final settle = TextButton.icon(
      onPressed: onSettle,
      style: TextButton.styleFrom(
        backgroundColor: theme.primary.withValues(alpha: 0.08),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      icon: const Icon(Icons.payments_rounded, size: 18),
      label: Text(t.coupleWeekMoneySettle),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.coupleWeekMoneyTitle,
          style: AppTypography.sectionTitle.copyWith(color: theme.textPrimary),
        ),
        const SizedBox(height: AppSpacing.sm),
        CoupleSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  if (canSettle &&
                      constraints.maxWidth >= 330 &&
                      MediaQuery.textScalerOf(context).scale(14) <= 16) {
                    return Row(
                      children: [
                        Expanded(child: summary),
                        const SizedBox(width: AppSpacing.xs),
                        settle,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      summary,
                      if (canSettle) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Align(alignment: Alignment.centerRight, child: settle),
                      ],
                    ],
                  );
                },
              ),
              if (!shared && balance > 10) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  t.coupleSettleCreditorHint(partnerName),
                  style: AppTypography.caption
                      .copyWith(color: theme.textSecondary),
                ),
              ],
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onMovements,
          label: Text(t.coupleWeekMoneySeeAll),
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        ),
      ],
    );
  }
}
