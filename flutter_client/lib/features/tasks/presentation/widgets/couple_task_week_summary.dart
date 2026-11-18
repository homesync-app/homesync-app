import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/premium_avatar_art.dart';

/// The useful weekly contribution summary lives with the tasks it describes.
class CoupleTaskWeekSummary extends ConsumerWidget {
  const CoupleTaskWeekSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final householdId = ref.watch(householdIdProvider).value;
    final members = ref.watch(householdMembersProvider).value;
    if (householdId == null || members == null || members.length < 2) {
      return const SizedBox.shrink();
    }
    ref.listen(tasksProvider, (previous, next) {
      if (previous?.hasValue != true || !next.hasValue) return;
      final before = previous!.value!
          .map(
            (task) => '${task.id}:${task.lastCompletionAt}:${task.completedBy}',
          )
          .join('|');
      final after = next.value!
          .map(
            (task) => '${task.id}:${task.lastCompletionAt}:${task.completedBy}',
          )
          .join('|');
      if (before != after) {
        ref.invalidate(householdContributionProvider(householdId));
      }
    });
    final t = AppLocalizations.of(context);
    final userId = ref.watch(currentUserIdProvider);
    final summary = ref.watch(householdContributionProvider(householdId));
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.sm,
        AppInsets.screenHorizontal,
        AppSpacing.xs,
      ),
      child: summary.when(
        skipLoadingOnReload: true,
        loading: () => const SizedBox.shrink(),
        error: (_, __) => AppInlineError(
          message: t.coupleTasksWeekError,
          onRetry: () =>
              ref.invalidate(householdContributionProvider(householdId)),
        ),
        data: (contribution) => CoupleSurface(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.coupleWeekDuoTitle,
                style: AppTypography.cardTitle
                    .copyWith(color: context.theme.textPrimary),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (var index = 0; index < members.length; index++) ...[
                if (index > 0) const SizedBox(height: AppSpacing.sm),
                Builder(
                  builder: (context) {
                    final member = members[index];
                    final done = contribution.members
                        .where((item) => item.userId == member.userId)
                        .firstOrNull;
                    return Row(
                      children: [
                        ExcludeSemantics(
                          child: MemberPortrait(
                            name: member.displayName,
                            avatarUrl: member.avatarUrl,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(
                            member.userId == userId
                                ? t.coupleWeekYou
                                : member.displayName.split(' ').first,
                            style: AppTypography.bodyStrong
                                .copyWith(color: context.theme.textPrimary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Flexible(
                          child: Text(
                            t.coupleTasksCompletedCount(done?.tasksDone ?? 0),
                            textAlign: TextAlign.end,
                            style: AppTypography.caption
                                .copyWith(color: context.theme.textSecondary),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
