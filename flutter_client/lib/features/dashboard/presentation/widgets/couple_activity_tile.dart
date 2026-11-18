import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/activity_presentation.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/household_art.dart';

/// Household history uses the same full-width surfaces as today's tasks.
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
    final name = (data['user_name'] as String?)?.trim();
    final actor = activity['creator_id'] != null &&
            activity['creator_id'] == currentUserId
        ? t.coupleWeekYou
        : name?.isNotEmpty == true
            ? name!
            : member?.displayName ?? t.familyTasksActorFallback;
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: CoupleSurface(
        padding: const EdgeInsets.all(AppSpacing.md),
        onTap: activityHasDetail(activity)
            ? () => openActivityDetail(context, ref, activity)
            : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HouseholdArt(
              kind: isExpense
                  ? HouseholdArtKind.wallet
                  : type == 'couple_challenge'
                      ? HouseholdArtKind.medal
                      : HouseholdArt.forCategory(category),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final amountInline = constraints.maxWidth >= 240;
                  final amountLabel = isExpense && amount != null
                      ? ref.watch(currencyProvider).format(amount)
                      : null;
                  final amountText = amountLabel == null
                      ? null
                      : Text(
                          amountLabel,
                          style: AppTypography.bodyStrong
                              .copyWith(color: theme.textPrimary),
                        );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: AppTypography.cardTitle
                                  .copyWith(color: theme.textPrimary),
                            ),
                          ),
                          if (amountInline && amountText != null) ...[
                            const SizedBox(width: AppSpacing.xs),
                            amountText,
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          Text(
                            '$actor · ${formatTaskActivityTimeLabel(t, activity)}',
                            style: AppTypography.caption
                                .copyWith(color: theme.textSecondary),
                          ),
                          if (status != null)
                            Text(
                              status,
                              style: AppTypography.caption
                                  .copyWith(color: theme.textSecondary),
                            ),
                        ],
                      ),
                      if (!amountInline && amountText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
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
