import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/domain/couple_proposal_ordering.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_money_card.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_proposal_sheets.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_week_widgets.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/love_note_sheet.dart';
import 'package:homesync_client/features/dashboard/presentation/main_navigation.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/couple_settlement_flow.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/partner_invite_card.dart';
import 'package:homesync_client/features/tasks/presentation/providers/category_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/design/app_section_header.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

/// La pestaña Pareja: el repaso de la semana de los dos.
///
/// Responde tres preguntas, en este orden: cómo se repartieron las tareas,
/// cómo está la plata entre los dos y qué quedó pendiente entre ustedes. Todo
/// lo que muestra sale de datos que el hogar ya genera; nada acá compra
/// conducta del otro ni genera deudas nuevas.
class CoupleWeekScreen extends ConsumerStatefulWidget {
  final String householdId;

  const CoupleWeekScreen({super.key, required this.householdId});

  @override
  ConsumerState<CoupleWeekScreen> createState() => _CoupleWeekScreenState();
}

class _CoupleWeekScreenState extends ConsumerState<CoupleWeekScreen> {
  bool _proposalBusy = false;

  @override
  void initState() {
    super.initState();
    // Idempotente; el Home lo registra al abrir Tareas, pero esta pestaña
    // puede abrirse antes.
    timeago.setLocaleMessages('es', timeago.EsMessages());
  }

  String _firstName(String? displayName, String fallback) {
    final first = displayName?.trim().split(RegExp(r'\s+')).first ?? '';
    return first.isEmpty ? fallback : first;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final membersAsync = ref.watch(householdMembersProvider);

    return membersAsync.when(
      skipLoadingOnReload: true,
      loading: () => const _ScreenSkeleton(),
      error: (_, __) => AppErrorState(
        message: t.coupleSpaceLoadError,
        onRetry: () => ref.invalidate(householdMembersProvider),
      ),
      data: (members) {
        final myMember =
            members.where((m) => m.userId == currentUserId).firstOrNull;
        final partner =
            members.where((m) => m.userId != currentUserId).firstOrNull;
        if (partner == null) return _buildWaitingForPartner();
        return _buildWeek(
          currentUserId: currentUserId,
          myMember: myMember,
          partner: partner,
        );
      },
    );
  }

  // ── Falta la pareja ────────────────────────────────────────────────────────

  Widget _buildWaitingForPartner() {
    return RefreshIndicator(
      color: context.theme.primary,
      onRefresh: () async {
        ref.invalidate(householdMembersProvider);
        await ref.read(householdMembersProvider.future);
      },
      child: ListView(
        primary: true,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          AppInsets.screenHorizontal,
          AppSpacing.xs,
          AppInsets.screenHorizontal,
          AppInsets.screenBottom + MediaQuery.viewPaddingOf(context).bottom,
        ),
        children: const [
          PartnerInviteCard(source: 'couple_tab'),
        ],
      ),
    );
  }

  // ── La semana ──────────────────────────────────────────────────────────────

  Widget _buildWeek({
    required String? currentUserId,
    required MemberModel? myMember,
    required MemberModel partner,
  }) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final partnerLabel =
        _firstName(partner.displayName, t.homeCouplePartnerFallback);
    final locale = Localizations.localeOf(context).toString();
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: AppFloatingActionButton(
        label: t.coupleSpaceProposeAction,
        icon: Icons.add_rounded,
        heroTag: 'couple_week_fab',
        margin: const EdgeInsets.only(bottom: 10),
        animateIn: true,
        onPressed: () => _createProposal(partner: partner, myMember: myMember),
      ),
      body: RefreshIndicator(
        color: theme.primary,
        onRefresh: _refresh,
        child: ListView(
          primary: true,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            AppInsets.screenHorizontal,
            AppSpacing.xxs,
            AppInsets.screenHorizontal,
            AppInsets.screenBottom +
                AppSpacing.xxl +
                MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: AppSpacing.xs),
              child: Text(
                t.coupleWeekOf(DateFormat.MMMMd(locale).format(monday)),
                style: AppTypography.caption.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ),
            _buildSplit(
              currentUserId: currentUserId,
              myMember: myMember,
              partner: partner,
              partnerLabel: partnerLabel,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: t.coupleWeekMoneyTitle,
              actionLabel: t.coupleWeekMoneySeeAll,
              onAction: () => _goToTab(MainTab.expenses),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMoney(
              currentUserId: currentUserId,
              partner: partner,
              partnerLabel: partnerLabel,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppSectionHeader(
              title: t.coupleWeekAsksTitle,
              subtitle: t.coupleWeekAsksSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildAsks(
              currentUserId: currentUserId,
              myMember: myMember,
              partner: partner,
              partnerLabel: partnerLabel,
            ),
            const SizedBox(height: AppSpacing.lg),
            CoupleNoteRow(
              partnerLabel: partnerLabel,
              onTap: () => showLoveNoteSheet(
                context,
                partner: partner,
                householdId: widget.householdId,
                senderName: _firstName(
                  myMember?.displayName,
                  t.commonUserFallback,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplit({
    required String? currentUserId,
    required MemberModel? myMember,
    required MemberModel partner,
    required String partnerLabel,
  }) {
    final t = AppLocalizations.of(context);
    final contributionAsync =
        ref.watch(householdContributionProvider(widget.householdId));
    final summary =
        ref.watch(coupleConnectionSummaryProvider(widget.householdId)).value;
    final categories = ref.watch(categoriesProvider).value ?? const [];

    return contributionAsync.when(
      skipLoadingOnReload: true,
      loading: () => const CoupleSplitCardSkeleton(),
      error: (_, __) => AppInlineError(
        message: t.coupleSpaceLoadError,
        onRetry: () => ref.invalidate(
          householdContributionProvider(widget.householdId),
        ),
      ),
      data: (contribution) {
        final reading = CoupleWeekReading.from(
          contribution,
          currentUserId: currentUserId,
        );
        final mine = contribution.members
            .where((m) => m.userId == currentUserId)
            .firstOrNull;
        final theirs = contribution.members
            .where((m) => m.userId == partner.userId)
            .firstOrNull;
        final categoryLabel = reading.category == null
            ? null
            : localizedTaskCategoryFromKey(t, categories, reading.category);

        return CoupleSplitCard(
          contribution: contribution,
          me: CoupleSplitPerson(
            userId: currentUserId ?? '',
            label: t.coupleWeekYou,
            avatarName: myMember?.displayName,
            avatarUrl: myMember?.avatarUrl,
            tasksDone: mine?.tasksDone ?? 0,
            demandingDone: mine?.demandingDone ?? 0,
          ),
          partner: CoupleSplitPerson(
            userId: partner.userId,
            label: partnerLabel,
            avatarName: partner.displayName,
            avatarUrl: partner.avatarUrl,
            tasksDone: theirs?.tasksDone ?? 0,
            demandingDone: theirs?.demandingDone ?? 0,
          ),
          reading: reading,
          categoryLabel: categoryLabel,
          tasksRemaining: summary?.tasksRemaining,
          overdue: summary?.needsAttention ?? 0,
          actionBusy: _proposalBusy,
          onPropose: () => _proposeFromReading(
            reading: reading,
            categoryLabel: categoryLabel,
            partner: partner,
          ),
          onSeeTasks: () => _seeTasks(reading),
        );
      },
    );
  }

  Widget _buildMoney({
    required String? currentUserId,
    required MemberModel partner,
    required String partnerLabel,
  }) {
    final t = AppLocalizations.of(context);
    final household = ref.watch(currentHouseholdProvider).value;
    final sharedEconomy = household?.financeMode == 'shared';
    final balancesAsync = ref.watch(expenseBalancesProvider);
    final monthAsync = ref.watch(coupleMonthMoneyProvider);
    final currency = ref.watch(currencyProvider);

    if (monthAsync.hasError && !monthAsync.hasValue ||
        !sharedEconomy && balancesAsync.hasError && !balancesAsync.hasValue) {
      return AppInlineError(
        message: t.coupleWeekMoneyError,
        onRetry: () {
          ref.invalidate(expenseBalancesProvider);
          ref.invalidate(coupleMonthMoneyProvider);
        },
      );
    }

    final myBalance = balancesAsync.value
        ?.where((balance) => balance.userId == currentUserId)
        .firstOrNull
        ?.balance;
    final balance = balancesAsync.hasValue
        ? CoupleBalanceView.fromMyBalance(myBalance ?? 0)
        : null;

    return CoupleMoneyCard(
      sharedEconomy: sharedEconomy,
      balance: balance,
      month: monthAsync.value,
      partnerLabel: partnerLabel,
      formatAmount: currency.format,
      onSettle: () => _settle(
        partner: partner,
        partnerLabel: partnerLabel,
        amount: balance?.amount ?? 0,
        isOwedByMe: true,
      ),
      onRecordPayment: () => _settle(
        partner: partner,
        partnerLabel: partnerLabel,
        amount: balance?.amount ?? 0,
        isOwedByMe: false,
      ),
    );
  }

  Widget _buildAsks({
    required String? currentUserId,
    required MemberModel? myMember,
    required MemberModel partner,
    required String partnerLabel,
  }) {
    final t = AppLocalizations.of(context);
    final proposalsAsync =
        ref.watch(coupleProposalsProvider(widget.householdId));
    final languageCode = Localizations.localeOf(context).languageCode;

    return proposalsAsync.when(
      skipLoadingOnReload: true,
      loading: () =>
          const ShimmerLoading(height: 68, borderRadius: AppRadii.xl),
      error: (_, __) => AppInlineError(
        message: t.coupleSpaceLoadError,
        onRetry: () =>
            ref.invalidate(coupleProposalsProvider(widget.householdId)),
      ),
      data: (proposals) {
        if (proposals.isEmpty) {
          return CoupleAsksEmpty(actionLabel: t.coupleSpaceProposeAction);
        }
        final ordered = orderCoupleProposals(proposals, currentUserId);
        return Column(
          children: [
            for (var index = 0; index < ordered.length; index++) ...[
              if (index > 0) const SizedBox(height: AppSpacing.xs),
              CoupleAskTile(
                key: ValueKey(ordered[index].id),
                proposal: ordered[index],
                stage: coupleProposalStage(ordered[index], currentUserId),
                isMine: ordered[index].isMine(currentUserId),
                partnerLabel: partnerLabel,
                whenLabel: timeago.format(
                  ordered[index].createdAt,
                  locale: languageCode,
                ),
                onTap: _proposalBusy
                    ? null
                    : () => _openProposal(
                          proposal: ordered[index],
                          myMember: myMember,
                          partner: partner,
                        ),
              ),
            ],
          ],
        );
      },
    );
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    ref.invalidate(householdContributionProvider(widget.householdId));
    ref.invalidate(coupleConnectionSummaryProvider(widget.householdId));
    ref.invalidate(coupleProposalsProvider(widget.householdId));
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(coupleMonthMoneyProvider);
    try {
      await Future.wait([
        ref.read(householdContributionProvider(widget.householdId).future),
        ref.read(coupleConnectionSummaryProvider(widget.householdId).future),
      ]);
    } catch (error, stackTrace) {
      // Cada bloque muestra su propio error con reintento.
      log.w('Couple week refresh failed', error: error, stackTrace: stackTrace);
    }
  }

  void _goToTab(MainTab tab) {
    final caps = ref.read(householdCapabilitiesProvider);
    final index = indexForMainTab(caps, tab);
    if (index >= 0) {
      AppHaptics.selection();
      ref.read(bottomNavIndexProvider.notifier).setIndex(index);
    }
  }

  void _seeTasks(CoupleWeekReading reading) {
    final category = reading.kind == CoupleWeekReadingKind.categorySkew
        ? reading.category
        : null;
    _goToTab(MainTab.tasks);
    // Después del cambio de pestaña: el filtro vive mientras Tareas lo mira.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final filter = ref.read(taskCategoryFilterProvider.notifier);
      if (category == null) {
        filter.clear();
      } else {
        filter.showOnly(CategoryMapping.normaliseCategory(category));
      }
    });
  }

  void _settle({
    required MemberModel partner,
    required String partnerLabel,
    required double amount,
    required bool isOwedByMe,
  }) {
    if (amount <= 0) return;
    showCoupleSettlementDialog(
      context: context,
      ref: ref,
      partnerId: partner.userId,
      partnerName: partnerLabel,
      amount: amount,
      isOwedByMe: isOwedByMe,
      onSettled: () {
        if (mounted) ref.invalidate(coupleMonthMoneyProvider);
      },
    );
  }

  Future<void> _proposeFromReading({
    required CoupleWeekReading reading,
    required String? categoryLabel,
    required MemberModel partner,
  }) async {
    final t = AppLocalizations.of(context);
    final category = categoryLabel?.toLowerCase();
    final String title;
    if (reading.kind == CoupleWeekReadingKind.categorySkew &&
        category != null) {
      title = reading.leaderIsMe
          ? t.coupleWeekTurnsProposalTitle(category)
          : t.coupleWeekOfferProposalTitle(category);
    } else {
      title = reading.leaderIsMe
          ? t.coupleWeekTurnsProposalTitleGeneral
          : t.coupleWeekOfferProposalTitleGeneral;
    }
    final members = ref.read(householdMembersProvider).value ?? const [];
    final myMember = members
        .where((m) => m.userId == ref.read(currentUserIdProvider))
        .firstOrNull;
    await _createProposal(
      partner: partner,
      myMember: myMember,
      initialTitle: title,
      initialCategory: CoupleProposalCategory.support,
    );
  }

  Future<void> _createProposal({
    required MemberModel partner,
    required MemberModel? myMember,
    String? initialTitle,
    CoupleProposalCategory initialCategory = CoupleProposalCategory.talk,
  }) async {
    if (_proposalBusy) return;
    final draft = await showCoupleProposalEditor(
      context,
      initialTitle: initialTitle,
      initialCategory: initialCategory,
    );
    if (draft == null || !mounted) return;
    final t = AppLocalizations.of(context);
    final myName = _firstName(myMember?.displayName, t.commonUserFallback);

    await _runProposalMutation(
      action: () => ref.read(coupleSpaceRepositoryProvider).createProposal(
            householdId: widget.householdId,
            title: draft.title,
            description: draft.description,
            category: draft.category,
          ),
      successMessage: t.coupleSpaceProposalCreated,
      pushToUserId: partner.userId,
      pushTitle: t.coupleProposalPushTitle(myName),
      pushBody: draft.title,
    );
  }

  Future<void> _openProposal({
    required CoupleProposal proposal,
    required MemberModel? myMember,
    required MemberModel partner,
  }) async {
    final currentUserId = ref.read(currentUserIdProvider);
    final decision = await showCoupleProposalDecisionSheet(
      context,
      proposal: proposal,
      isMine: proposal.isMine(currentUserId),
    );
    if (decision == null || !mounted) return;

    final repo = ref.read(coupleSpaceRepositoryProvider);
    final t = AppLocalizations.of(context);
    final myName = _firstName(myMember?.displayName, t.commonUserFallback);

    Future<void> respond(
      CoupleProposalStatus status,
      String toast,
      String answerLabel,
    ) {
      return _runProposalMutation(
        action: () => repo.respondToProposal(
          proposalId: proposal.id,
          response: status,
        ),
        successMessage: toast,
        pushToUserId: proposal.createdBy,
        pushTitle: t.coupleProposalAnsweredPushTitle(myName),
        pushBody: t.coupleProposalAnsweredPushBody(answerLabel, proposal.title),
      );
    }

    switch (decision) {
      case CoupleProposalDecision.accept:
        await respond(
          CoupleProposalStatus.accepted,
          t.coupleSpaceProposalAcceptedToast,
          t.coupleSpaceProposalAccept,
        );
      case CoupleProposalDecision.defer:
        await respond(
          CoupleProposalStatus.deferred,
          t.coupleSpaceProposalDeferredToast,
          t.coupleSpaceProposalDefer,
        );
      case CoupleProposalDecision.decline:
        await respond(
          CoupleProposalStatus.declined,
          t.coupleSpaceProposalDeclinedToast,
          t.coupleSpaceProposalDecline,
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
    String? pushToUserId,
    String? pushTitle,
    String? pushBody,
  }) async {
    if (_proposalBusy) return;
    setState(() => _proposalBusy = true);
    try {
      await action();
      ref.invalidate(coupleProposalsProvider(widget.householdId));
      AppHaptics.success();
      if (pushToUserId != null && pushTitle != null && pushBody != null) {
        // Best-effort: la propuesta ya quedó guardada aunque el push falle.
        unawaited(
          ref.read(notificationServiceProvider).notifyMember(
                toUserId: pushToUserId,
                title: pushTitle,
                body: pushBody,
                type: 'couple_proposal',
              ),
        );
      }
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
        message: friendlyErrorMessage(error, t: AppLocalizations.of(context)),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _proposalBusy = false);
    }
  }
}

class _ScreenSkeleton extends StatelessWidget {
  const _ScreenSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppInsets.screenHorizontal,
        AppSpacing.lg,
        AppInsets.screenHorizontal,
        AppInsets.screenBottom,
      ),
      children: const [
        CoupleSplitCardSkeleton(),
        SizedBox(height: AppSpacing.xl),
        ShimmerLoading(height: 72, borderRadius: AppRadii.xl),
        SizedBox(height: AppSpacing.xl),
        ShimmerLoading(height: 68, borderRadius: AppRadii.xl),
      ],
    );
  }
}
