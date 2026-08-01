import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_connection_summary.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_fund.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_fund_widgets.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_proposal_sheets.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/domain/models/couple_challenge.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_challenge_provider.dart';
import 'package:homesync_client/features/rewards/presentation/widgets/couple_challenge_card.dart';
import 'package:homesync_client/features/rewards/presentation/widgets/couple_challenge_completion_mixin.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class CoupleConnectionScreen extends ConsumerStatefulWidget {
  final String householdId;

  const CoupleConnectionScreen({
    super.key,
    required this.householdId,
  });

  @override
  ConsumerState<CoupleConnectionScreen> createState() =>
      _CoupleConnectionScreenState();
}

class _CoupleConnectionScreenState extends ConsumerState<CoupleConnectionScreen>
    with CoupleChallengeCompletionMixin<CoupleConnectionScreen> {
  bool _specialHidden = false;
  bool _proposalMutationRunning = false;
  bool _fundMutationRunning = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final summaryAsync = ref.watch(
      coupleConnectionSummaryProvider(widget.householdId),
    );
    final proposalsAsync = ref.watch(
      coupleProposalsProvider(widget.householdId),
    );
    final fundAsync = ref.watch(householdFundProvider(widget.householdId));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _refresh,
        child: ListView(
          primary: true,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppInsets.screenHorizontal,
            AppSpacing.sm,
            AppInsets.screenHorizontal,
            AppSpacing.xxl,
          ),
          children: [
            summaryAsync.when(
              data: _buildWeekCard,
              loading: () => const _WeekCardLoading(),
              error: (error, _) => _LoadErrorCard(
                message: t.coupleSpaceLoadError,
                action: t.coupleSpaceRetry,
                onRetry: _refresh,
              ),
            ),
            const SizedBox(height: AppInsets.sectionGap),
            Text(
              t.coupleFundTitle,
              style: AppTypography.sectionTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            fundAsync.when(
              skipLoadingOnReload: true,
              data: _buildFund,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: AppLoader()),
              ),
              error: (error, _) => _LoadErrorCard(
                message: t.coupleSpaceLoadError,
                action: t.coupleSpaceRetry,
                onRetry: () async {
                  ref.invalidate(householdFundProvider(widget.householdId));
                },
              ),
            ),
            const SizedBox(height: AppInsets.sectionGap),
            Text(
              t.coupleSpaceForConnection,
              style: AppTypography.sectionTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (_specialHidden)
              _SkippedSpecialCard(
                onRestore: () => setState(() => _specialHidden = false),
              )
            else
              _buildWeeklySpecial(summaryAsync.value),
            const SizedBox(height: AppInsets.sectionGap),
            _buildPlansHeader(),
            const SizedBox(height: AppSpacing.sm),
            proposalsAsync.when(
              data: _buildProposals,
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(child: AppLoader()),
              ),
              error: (error, _) => _LoadErrorCard(
                message: t.coupleSpaceLoadError,
                action: t.coupleSpaceRetry,
                onRetry: () async {
                  ref.invalidate(
                    coupleProposalsProvider(widget.householdId),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              height: AppControlSizes.buttonHeight,
              child: FilledButton.icon(
                onPressed: _proposalMutationRunning ? null : _createProposal,
                icon: const Icon(Icons.add_rounded),
                label: Text(t.coupleSpaceProposeAction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(currentHouseholdProvider);
    ref.invalidate(coupleConnectionSummaryProvider(widget.householdId));
    ref.invalidate(coupleProposalsProvider(widget.householdId));
    ref.invalidate(coupleChallengeCompletedProvider);
    ref.invalidate(householdFundProvider(widget.householdId));
    await Future.wait([
      ref.read(currentHouseholdProvider.future),
      ref.read(
        coupleConnectionSummaryProvider(widget.householdId).future,
      ),
      ref.read(coupleProposalsProvider(widget.householdId).future),
      ref.read(householdFundProvider(widget.householdId).future),
    ]);
  }

  Widget _buildFund(HouseholdFund fund) {
    return CoupleFundCard(
      fund: fund,
      currentUserId: ref.watch(currentUserIdProvider),
      isBusy: _fundMutationRunning,
      onChooseGoal: _chooseFundGoal,
      onConfirm: () => _confirmFundGoal(fund),
      onWithdrawConfirmation: () => _withdrawFundConfirmation(fund),
    );
  }

  Future<void> _chooseFundGoal() async {
    if (_fundMutationRunning) return;
    AppHaptics.tap();
    final draft = await showFundGoalPicker(context);
    if (draft == null || !mounted) return;

    await _runFundMutation(
      action: () => ref.read(coupleSpaceRepositoryProvider).setActiveGoal(
            householdId: widget.householdId,
            title: draft.title,
            cost: draft.cost,
            icon: draft.icon,
            catalogKey: draft.catalogKey,
          ),
    );
  }

  Future<void> _confirmFundGoal(HouseholdFund fund) async {
    final goal = fund.goal;
    if (goal == null) return;

    await _runFundMutation(
      action: () => ref.read(coupleSpaceRepositoryProvider).confirmGoal(goal.id),
      onSuccess: (result) {
        // Llegar a la meta no compra el plan: abre una propuesta para acordarlo.
        if (result is FundConfirmationOutcome && result.unlocked) {
          ref.invalidate(coupleProposalsProvider(widget.householdId));
          return AppLocalizations.of(context).coupleFundUnlockedMessage;
        }
        return null;
      },
    );
  }

  Future<void> _withdrawFundConfirmation(HouseholdFund fund) async {
    final goal = fund.goal;
    if (goal == null) return;

    await _runFundMutation(
      action: () => ref
          .read(coupleSpaceRepositoryProvider)
          .withdrawGoalConfirmation(goal.id),
    );
  }

  Future<void> _runFundMutation({
    required Future<Object?> Function() action,
    String? Function(Object? result)? onSuccess,
  }) async {
    if (_fundMutationRunning) return;
    setState(() => _fundMutationRunning = true);
    try {
      final result = await action();
      ref.invalidate(householdFundProvider(widget.householdId));
      if (!mounted) return;
      final message = onSuccess?.call(result);
      if (message != null) {
        AppHaptics.success();
        AppSnackBar.show(
          context,
          message: message,
          type: AppSnackBarType.success,
        );
      } else {
        AppHaptics.tap();
      }
    } catch (error, stackTrace) {
      log.e('Couple fund mutation failed', error: error, stackTrace: stackTrace);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: friendlyErrorMessage(
          error,
          t: AppLocalizations.of(context),
        ),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _fundMutationRunning = false);
    }
  }

  Widget _buildWeekCard(CoupleConnectionSummary summary) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final hasTasks = summary.tasksPlanned > 0;

    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppRadii.hero,
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.sage.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.bolt_rounded,
                  color: AppColors.iconSage,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  t.coupleSpaceWeekEyebrow,
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.iconSage,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            hasTasks
                ? t.coupleSpaceTasksReady(
                    summary.tasksDone,
                    summary.tasksPlanned,
                  )
                : t.coupleSpaceNoTasksPlanned,
            style: AppTypography.heroAmount.copyWith(
              fontSize: 30,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Text(
                t.coupleSpaceRemainingTasks(summary.tasksRemaining),
                style: AppTypography.body.copyWith(
                  color: theme.textSecondary,
                ),
              ),
              if (summary.needsAttention > 0) ...[
                Text(
                  '·',
                  style: AppTypography.body.copyWith(
                    color: theme.textMuted,
                  ),
                ),
                Text(
                  t.coupleSpaceNeedsAttention(summary.needsAttention),
                  style: AppTypography.bodyStrong.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          _SharedProgressBar(
            progress: hasTasks ? summary.completionRate : 0,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.coupleSpaceWeekSupport,
            style: AppTypography.body.copyWith(
              fontSize: 15,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            onPressed: () => _showDistribution(summary),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.iconSage,
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded),
            label: Text(t.coupleSpaceDistributionAction),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySpecial(CoupleConnectionSummary? summary) {
    final t = AppLocalizations.of(context);
    final householdAsync = ref.watch(currentHouseholdProvider);

    return householdAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Center(child: AppLoader()),
      ),
      error: (_, __) => _LoadErrorCard(
        message: t.coupleSpaceLoadError,
        action: t.coupleSpaceRetry,
        onRetry: () async {
          ref.invalidate(currentHouseholdProvider);
        },
      ),
      data: (household) {
        if (household == null) {
          return _LoadErrorCard(
            message: t.coupleSpaceLoadError,
            action: t.coupleSpaceRetry,
            onRetry: () async {
              ref.invalidate(currentHouseholdProvider);
            },
          );
        }

        final challenge = CoupleChallenge.currentWeeklyChallenge(
          household.createdAt,
        );
        final challengeIndex = CoupleChallenge.currentWeeklyChallengeIndex(
          household.createdAt,
        );
        final weekIndex = CoupleChallenge.currentWeekIndex(household.createdAt);
        final completionKey = (
          householdId: widget.householdId,
          weekIndex: weekIndex,
        );
        final completionAsync = ref.watch(
          coupleChallengeCompletedProvider(completionKey),
        );

        return completionAsync.when(
          skipLoadingOnReload: true,
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Center(child: AppLoader()),
          ),
          error: (_, __) => _LoadErrorCard(
            message: t.coupleSpaceLoadError,
            action: t.coupleSpaceRetry,
            onRetry: () async {
              ref.invalidate(
                coupleChallengeCompletedProvider(completionKey),
              );
            },
          ),
          data: (completed) => CoupleChallengeCard(
            challenge: challenge,
            challengeNumber: challengeIndex + 1,
            totalChallenges: CoupleChallenge.allChallenges.length,
            completedCount: summary?.specialMoments ?? 0,
            isCompleted: completed,
            onSkip: () => _skipSpecial(),
            onComplete: () async {
              final outcome = await handleCoupleChallengeCompletion(
                challenge,
                widget.householdId,
                weekIndex,
              );
              if (outcome == CoupleChallengeOutcome.completed) {
                ref.invalidate(
                  coupleConnectionSummaryProvider(widget.householdId),
                );
              }
            },
          ),
        );
      },
    );
  }

  void _skipSpecial() {
    final t = AppLocalizations.of(context);
    setState(() => _specialHidden = true);
    AppSnackBar.show(
      context,
      message: t.coupleSpaceSkipToast,
      type: AppSnackBarType.neutral,
      actionLabel: t.coupleSpaceUndo,
      onAction: () {
        if (mounted) setState(() => _specialHidden = false);
      },
    );
  }

  Widget _buildPlansHeader() {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.coupleSpacePlansTitle,
          style: AppTypography.sectionTitle.copyWith(
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t.coupleSpacePlansSubtitle,
          style: AppTypography.caption.copyWith(
            fontSize: 13,
            color: theme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProposals(List<CoupleProposal> proposals) {
    final t = AppLocalizations.of(context);
    if (proposals.isEmpty) {
      return _ProposalEmptyState(
        title: t.coupleSpaceProposalsEmptyTitle,
        body: t.coupleSpaceProposalsEmptyBody,
      );
    }

    return Column(
      children: [
        for (var index = 0; index < proposals.length; index++) ...[
          if (index > 0) const SizedBox(height: AppSpacing.sm),
          _ProposalCard(
            proposal: proposals[index],
            currentUserId: ref.watch(currentUserIdProvider),
            onTap: _proposalMutationRunning
                ? null
                : () => _openProposal(proposals[index]),
          ),
        ],
      ],
    );
  }

  Future<void> _createProposal() async {
    final draft = await showCoupleProposalEditor(context);
    if (draft == null || !mounted) return;

    await _runProposalMutation(
      action: () => ref.read(coupleSpaceRepositoryProvider).createProposal(
            householdId: widget.householdId,
            title: draft.title,
            description: draft.description,
            category: draft.category,
          ),
      successMessage: AppLocalizations.of(context).coupleSpaceProposalCreated,
    );
  }

  Future<void> _openProposal(CoupleProposal proposal) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final decision = await showCoupleProposalDecisionSheet(
      context,
      proposal: proposal,
      isMine: proposal.isMine(currentUserId),
    );
    if (decision == null || !mounted) return;

    final repo = ref.read(coupleSpaceRepositoryProvider);
    final t = AppLocalizations.of(context);
    switch (decision) {
      case CoupleProposalDecision.accept:
        await _runProposalMutation(
          action: () => repo.respondToProposal(
            proposalId: proposal.id,
            response: CoupleProposalStatus.accepted,
          ),
          successMessage: t.coupleSpaceProposalAcceptedToast,
        );
      case CoupleProposalDecision.defer:
        await _runProposalMutation(
          action: () => repo.respondToProposal(
            proposalId: proposal.id,
            response: CoupleProposalStatus.deferred,
          ),
          successMessage: t.coupleSpaceProposalDeferredToast,
        );
      case CoupleProposalDecision.decline:
        await _runProposalMutation(
          action: () => repo.respondToProposal(
            proposalId: proposal.id,
            response: CoupleProposalStatus.declined,
          ),
          successMessage: t.coupleSpaceProposalDeclinedToast,
        );
      case CoupleProposalDecision.withdraw:
        await _runProposalMutation(
          action: () => repo.withdrawProposal(proposal.id),
          successMessage: t.coupleSpaceProposalWithdrawnToast,
        );
      case CoupleProposalDecision.archive:
        await _runProposalMutation(
          action: () => repo.archiveProposal(proposal.id),
          successMessage: t.coupleSpaceProposalArchivedToast,
        );
    }
  }

  Future<void> _runProposalMutation({
    required Future<Object?> Function() action,
    required String successMessage,
  }) async {
    if (_proposalMutationRunning) return;
    setState(() => _proposalMutationRunning = true);
    try {
      await action();
      ref.invalidate(coupleProposalsProvider(widget.householdId));
      AppHaptics.success();
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: successMessage,
        type: AppSnackBarType.success,
      );
    } catch (error, stackTrace) {
      log.e(
        'Couple proposal mutation failed',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: friendlyErrorMessage(
          error,
          t: AppLocalizations.of(context),
        ),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _proposalMutationRunning = false);
    }
  }

  void _showDistribution(CoupleConnectionSummary summary) {
    AppSheet.show<void>(
      context: context,
      useSafeArea: true,
      builder: (sheetContext) => _DistributionSheet(summary: summary),
    );
  }
}

class _SharedProgressBar extends StatelessWidget {
  final double progress;

  const _SharedProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: SizedBox(
        height: 8,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: context.theme.surfaceContainer,
          valueColor: const AlwaysStoppedAnimation(AppColors.sage),
        ),
      ),
    );
  }
}

class _ProposalCard extends StatelessWidget {
  final CoupleProposal proposal;
  final String? currentUserId;
  final VoidCallback? onTap;

  const _ProposalCard({
    required this.proposal,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final mine = proposal.isMine(currentUserId);
    final status = proposal.isAccepted
        ? t.coupleSpaceProposalAccepted
        : proposal.isDeferred
            ? t.coupleSpaceProposalDeferred
            : mine
                ? t.coupleSpaceProposalMine
                : t.coupleSpaceProposalRespond;
    final statusColor = proposal.isAccepted || proposal.isDeferred
        ? AppColors.iconSage
        : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Ink(
          padding: AppInsets.compactCard,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: AppRadii.card,
            border: Border.all(color: theme.border.withValues(alpha: 0.72)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  coupleProposalCategoryIcon(proposal.category),
                  color: AppColors.iconSage,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      proposal.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.cardTitle.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _ProposalPill(
                          label: coupleProposalCategoryLabel(
                            t,
                            proposal.category,
                          ),
                          color: AppColors.iconSage,
                        ),
                        if (proposal.isFromFund)
                          _ProposalPill(
                            label: t.coupleFundFromGoalBadge,
                            color: AppColors.accentGold,
                          ),
                        if (proposal.isPending && mine)
                          _ProposalPill(
                            label: t.coupleSpaceProposalAwaiting,
                            color: theme.textSecondary,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    status,
                    style: AppTypography.caption.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: statusColor,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProposalPill extends StatelessWidget {
  final String label;
  final Color color;

  const _ProposalPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 11,
          color: color,
        ),
      ),
    );
  }
}

class _ProposalEmptyState extends StatelessWidget {
  final String title;
  final String body;

  const _ProposalEmptyState({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      width: double.infinity,
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline_rounded,
            color: AppColors.iconSage,
            size: 28,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkippedSpecialCard extends StatelessWidget {
  final VoidCallback onRestore;

  const _SkippedSpecialCard({required this.onRestore});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Container(
      padding: AppInsets.compactCard,
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: theme.border.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          const Icon(Icons.favorite_border_rounded, color: AppColors.iconSage),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              t.coupleSpaceSkipToast,
              style: AppTypography.body.copyWith(color: theme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: onRestore,
            child: Text(t.coupleSpaceUndo),
          ),
        ],
      ),
    );
  }
}

class _DistributionSheet extends StatelessWidget {
  final CoupleConnectionSummary summary;

  const _DistributionSheet({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final maxTasks = summary.memberDistribution.fold<int>(
      1,
      (current, member) =>
          member.tasksDone > current ? member.tasksDone : current,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: AppRadii.sheet,
        boxShadow: theme.modalShadow,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        12,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
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
          const SizedBox(height: AppSpacing.lg),
          Text(
            t.coupleSpaceDistributionTitle,
            style: AppTypography.screenTitle.copyWith(
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            t.coupleSpaceDistributionSubtitle,
            style: AppTypography.body.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          for (var index = 0;
              index < summary.memberDistribution.length;
              index++) ...[
            if (index > 0) const SizedBox(height: AppSpacing.md),
            _ContributionRow(
              contribution: summary.memberDistribution[index],
              maxTasks: maxTasks,
            ),
          ],
        ],
      ),
    );
  }
}

class _ContributionRow extends StatelessWidget {
  final CoupleMemberContribution contribution;
  final int maxTasks;

  const _ContributionRow({
    required this.contribution,
    required this.maxTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        CustomUserAvatar(
          name: contribution.name,
          userId: contribution.userId,
          avatarUrl: contribution.avatarUrl,
          radius: 22,
          forceCircular: true,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      contribution.name,
                      style: AppTypography.bodyStrong.copyWith(
                        color: theme.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    t.coupleSpaceTasksDone(contribution.tasksDone),
                    style: AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: contribution.tasksDone / maxTasks,
                  backgroundColor: theme.surfaceContainer,
                  valueColor: const AlwaysStoppedAnimation(AppColors.sage),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekCardLoading extends StatelessWidget {
  const _WeekCardLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: AppRadii.hero,
        border: Border.all(color: context.theme.border),
      ),
      child: const Center(child: AppLoader()),
    );
  }
}

class _LoadErrorCard extends StatelessWidget {
  final String message;
  final String action;
  final Future<void> Function() onRetry;

  const _LoadErrorCard({
    required this.message,
    required this.action,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppInsets.card,
      decoration: BoxDecoration(
        color: context.theme.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: context.theme.border),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: AppTypography.body.copyWith(
              color: context.theme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: onRetry,
            child: Text(action),
          ),
        ],
      ),
    );
  }
}
