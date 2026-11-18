import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/household_art.dart';
import 'package:homesync_client/shared/widgets/premium_avatar_art.dart';

/// Compact couple timeline log that contrasts with primary "Hoy en casa" cards
/// and highlights who performed each action.
class CoupleActivityTile extends ConsumerWidget {
  final Map<String, dynamic> activity;
  final String? currentUserId;

  const CoupleActivityTile({
    super.key,
    required this.activity,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final data = (activity['data'] as Map<String, dynamic>?) ?? {};
    final type = activity['type'] as String?;
    final category = data['category'] as String?;
    final isExpense = type == 'expense';
    final settlement = activityIsSettlement(data);
    final title = activityDisplayTitle(
      t,
      localizedActivityTitle(t, data),
      category,
      isExpense: isExpense,
    );
    final members = ref.watch(householdMembersProvider).value;
    final member = members
        ?.where((member) => member.userId == activity['creator_id'])
        .firstOrNull;
    final isMe =
        activity['creator_id'] != null && activity['creator_id'] == currentUserId;
    final rawName = (data['user_name'] as String?)?.trim();
    final partnerFirstName = member?.displayName.trim().split(' ').first ??
        (rawName?.isNotEmpty == true ? rawName!.split(' ').first : null) ??
        t.familyTasksActorFallback;
    final actor = isMe ? t.coupleWeekYou : partnerFirstName;
    final avatarUrl = (data['avatar_url'] as String?) ?? member?.avatarUrl;
    final portraitName = member?.displayName ?? rawName ?? actor;

    final status = isExpense
        ? settlement
            ? t.activitySettlementTitle
            : t.activityBubbleHouseholdExpense
        : type == 'task_pending_approval'
            ? t.tasksPillInReview
            : type == 'task'
                ? t.taskDetailStatusCompleted
                : null;
    final amount = activityParseAmount(data['amount']);
    final actorColor = isMe ? theme.primary : AppColors.accentTeal;
    final artKind = isExpense
        ? HouseholdArtKind.wallet
        : type == 'couple_challenge'
            ? HouseholdArtKind.medal
            : HouseholdArt.forCategory(category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: CoupleSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 10,
        ),
        color: theme.surface.withValues(alpha: 0.72),
        radius: AppRadii.lg,
        onTap: activityHasDetail(activity)
            ? () => openActivityDetail(context, ref, activity)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: MemberPortrait(
                name: portraitName,
                avatarUrl: avatarUrl,
                size: 36,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final amountInline = constraints.maxWidth >= 210;
                  final amountLabel = isExpense && amount != null
                      ? ref.watch(currencyProvider).format(amount)
                      : null;
                  final amountText = amountLabel == null
                      ? null
                      : Text(
                          amountLabel,
                          style: AppTypography.bodyStrong.copyWith(
                            color: theme.textPrimary,
                            fontFeatures: kTabularFigures,
                          ),
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.bodyStrong.copyWith(
                                color: theme.textPrimary,
                              ),
                            ),
                          ),
                          if (amountInline && amountText != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            amountText,
                          ] else if (amountText == null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Opacity(
                              opacity: 0.85,
                              child: HouseholdArt(kind: artKind, size: 24),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 2,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: actorColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(AppRadii.xs),
                            ),
                            child: Text(
                              actor,
                              style: AppTypography.caption.copyWith(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: actorColor,
                              ),
                            ),
                          ),
                          if (status != null)
                            Text(
                              status,
                              style: AppTypography.caption.copyWith(
                                fontSize: 11.5,
                                color: theme.textSecondary,
                              ),
                            ),
                          Text(
                            '· ${formatTaskActivityTimeLabel(t, activity)}',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11.5,
                              color: theme.textMuted,
                            ),
                          ),
                        ],
                      ),
                      if (!amountInline && amountText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xxs),
                          child: amountText,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
