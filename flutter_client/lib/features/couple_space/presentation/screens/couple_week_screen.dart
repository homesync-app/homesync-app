import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_plans_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_space_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_money_card.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_plans_section.dart';
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
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:intl/intl.dart';

/// Planes para compartir, recuerdos y un resumen del hogar.
class CoupleWeekScreen extends ConsumerStatefulWidget {
  final String householdId;

  const CoupleWeekScreen({super.key, required this.householdId});

  @override
  ConsumerState<CoupleWeekScreen> createState() => _CoupleWeekScreenState();
}

class _CoupleWeekScreenState extends ConsumerState<CoupleWeekScreen> {
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
    final mePerson = CouplePerson(
      userId: currentUserId ?? '',
      label: t.coupleWeekYou,
      avatarName: myMember?.displayName,
      avatarUrl: myMember?.avatarUrl,
    );
    final partnerPerson = CouplePerson(
      userId: partner.userId,
      label: partnerLabel,
      avatarName: partner.displayName,
      avatarUrl: partner.avatarUrl,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
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
            AppSpacing.xs,
            AppInsets.screenHorizontal,
            AppInsets.screenBottom +
                AppSpacing.xxl +
                MediaQuery.viewPaddingOf(context).bottom,
          ),
          children: [
            CouplePlansSection(
              key: ValueKey(widget.householdId),
              householdId: widget.householdId,
              note: CoupleNoteRow(
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
            ).animateEntrance(),
            const SizedBox(height: AppSpacing.xl),
            _buildSplit(
              currentUserId: currentUserId,
              myMember: myMember,
              partner: partner,
              partnerLabel: partnerLabel,
            ).animateEntrance(),
            const SizedBox(height: AppSpacing.xl),
            CoupleMoneySectionHeader(
              onAction: () => _goToTab(MainTab.expenses),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildMoney(
              currentUserId: currentUserId,
              me: mePerson,
              partner: partner,
              partnerPerson: partnerPerson,
            ).animateEntrance(delay: 60),
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
        final locale = Localizations.localeOf(context).toString();
        final now = DateTime.now();
        final monday = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: now.weekday - DateTime.monday));

        return CoupleSplitCard(
          contribution: contribution,
          weekLabel: t.coupleWeekOf(DateFormat.MMMMd(locale).format(monday)),
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
          onSeeTasks: () => _seeTasks(reading),
        );
      },
    );
  }

  Widget _buildMoney({
    required String? currentUserId,
    required CouplePerson me,
    required MemberModel partner,
    required CouplePerson partnerPerson,
  }) {
    final partnerLabel = partnerPerson.label;
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
      me: me,
      partner: partnerPerson,
      formatAmount: currency.format,
      onSettle: () => _settle(
        partner: partner,
        partnerLabel: partnerLabel,
        amount: balance?.amount ?? 0,
      ),
    );
  }

  // ── Acciones ───────────────────────────────────────────────────────────────

  Future<void> _refresh() async {
    ref.invalidate(householdContributionProvider(widget.householdId));
    ref.invalidate(coupleConnectionSummaryProvider(widget.householdId));
    ref.invalidate(couplePlanProgressProvider(widget.householdId));
    ref.invalidate(expenseBalancesProvider);
    ref.invalidate(coupleMonthMoneyProvider);
    try {
      await Future.wait([
        ref.read(householdContributionProvider(widget.householdId).future),
        ref.read(coupleConnectionSummaryProvider(widget.householdId).future),
        ref.read(couplePlanProgressProvider(widget.householdId).future),
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
  }) {
    if (amount <= 0) return;
    showCoupleSettlementDialog(
      context: context,
      ref: ref,
      partnerId: partner.userId,
      partnerName: partnerLabel,
      amount: amount,
      onSettled: () {
        if (mounted) ref.invalidate(coupleMonthMoneyProvider);
      },
    );
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
        ShimmerLoading(height: 128, borderRadius: AppRadii.xl),
        SizedBox(height: AppSpacing.xl),
        ShimmerLoading(height: 150, borderRadius: AppRadii.lg),
      ],
    );
  }
}
