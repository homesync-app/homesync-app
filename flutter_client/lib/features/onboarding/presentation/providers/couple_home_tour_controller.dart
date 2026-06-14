import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Storage key — bumped suffix invalidates older tours when redesigned.
/// v2: guía adaptativa (pareja + familia, finanzas según configuración,
/// CTA funcional de crear tarea).
const tourFlagKey = 'home_tour_seen_v2';

/// Whether the user already completed/skipped the home tour.
///
/// Reads SharedPreferences synchronously; this provider gets invalidated by
/// the controller after every persistence change so callers get a fresh
/// value instead of the first-build cache.
final coupleHomeTourSeenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(tourFlagKey) ?? false;
});

/// Lee el estado real del hogar para adaptar la guía. Usa los providers ya
/// calentados por el arranque; los valores faltantes degradan con defaults
/// seguros (la guía nunca debe romperse por datos a medio cargar).
HomeTourContext buildHomeTourContext(WidgetRef ref) {
  final household = ref.read(currentHouseholdProvider).value;
  final caps = ref.read(householdCapabilitiesProvider);
  final members = ref.read(householdMembersProvider).value ?? const [];
  final currentUserId = ref.read(currentUserIdProvider);
  final tasks = ref.read(todayTasksProvider).value;

  final partner = members
      .where((m) => m.userId != currentUserId)
      .map((m) => m.displayName)
      .firstOrNull;
  final adultCount = members.where((m) => m.isAdult).length;

  return HomeTourContext(
    isFamily: caps.usesFamilyRoles,
    hasTasks: tasks?.isNotEmpty ?? false,
    integratedFinances: household?.financeMode == 'shared',
    approvalsOn: (household?.taskApprovalMode ?? 'off') != 'off',
    hasFinanceSection: adultCount > 1,
    partnerName: partner,
  );
}

class CoupleHomeTourState {
  final bool isActive;
  final int currentStep;
  final HomeTourContext context;

  const CoupleHomeTourState({
    required this.isActive,
    required this.currentStep,
    required this.context,
  });

  const CoupleHomeTourState.initial()
      : isActive = false,
        currentStep = 0,
        context = const HomeTourContext(
          isFamily: false,
          hasTasks: false,
          integratedFinances: false,
        );

  CoupleHomeTourState copyWith({
    bool? isActive,
    int? currentStep,
    HomeTourContext? context,
  }) {
    return CoupleHomeTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      context: context ?? this.context,
    );
  }
}

class CoupleHomeTourController extends Notifier<CoupleHomeTourState> {
  @override
  CoupleHomeTourState build() => const CoupleHomeTourState.initial();

  /// Pasos de la guía, adaptados al estado real del hogar: modo (pareja o
  /// familia), si hay tareas hoy, y cómo configuraron las finanzas.
  List<CoachmarkStep> stepsFor(AppLocalizations t, HomeTourContext ctx) {
    return ctx.isFamily ? _familySteps(t, ctx) : _coupleSteps(t, ctx);
  }

  List<CoachmarkStep> _coupleSteps(AppLocalizations t, HomeTourContext ctx) {
    final financeMode = ctx.integratedFinances ? 'shared' : 'divided';
    return [
      CoachmarkStep(
        kind: CoachmarkStepKind.welcomeModal,
        eyebrow: t.tourWelcomeEyebrow,
        title: t.tourCoupleWelcomeTitle,
        body: ctx.partnerName != null
            ? t.tourCoupleWelcomeBodyNamed(ctx.partnerName!)
            : t.tourCoupleWelcomeBody,
        primaryCta: t.tourCtaStart,
        icon: Icons.auto_awesome_rounded,
      ),
      // Tareas: si el "Hoy en casa" está vacío, el CTA primario abre el flujo
      // real de creación — la guía deja el hogar andando, no solo lo muestra.
      if (ctx.hasTasks)
        CoachmarkStep(
          kind: CoachmarkStepKind.spotlight,
          title: t.tourTasksTitleHas,
          body: t.tourTasksBodyHas,
          primaryCta: t.tourCtaNext,
          target: TourTarget.tasksSection,
        )
      else
        CoachmarkStep(
          kind: CoachmarkStepKind.spotlight,
          title: t.tourTasksTitleEmpty,
          body: t.tourTasksBodyEmpty,
          primaryCta: t.tourTasksCtaCreate,
          primaryAction: CoachmarkAction.createTask,
          secondaryCta: t.tourCtaLater,
          target: TourTarget.tasksSection,
        ),
      // Balance: el widget y su explicación cambian según la configuración
      // de finanzas del hogar (integrada vs dividida).
      CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        title: t.tourBalanceTitle,
        body: t.tourBalanceBody(financeMode),
        primaryCta: t.tourCtaNext,
        target: TourTarget.balanceCard,
        bullets: [
          if (ctx.integratedFinances)
            CoachmarkBullet(
              icon: Icons.timeline_rounded,
              tint: AppColors.accentOrange,
              text: t.tourBalanceBulletMonth,
            )
          else
            CoachmarkBullet(
              icon: Icons.payment_rounded,
              tint: AppColors.accentOrange,
              text: t.tourBalanceBulletSettle,
            ),
          CoachmarkBullet(
            icon: Icons.star_rounded,
            tint: const Color(0xFFE8943A),
            text: t.tourBalanceBulletXp,
          ),
          CoachmarkBullet(
            icon: Icons.monetization_on_rounded,
            tint: AppColors.sage,
            text: t.tourBalanceBulletCoins,
          ),
        ],
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.infoModal,
        title: t.tourDuelTitle,
        body: t.tourDuelBody,
        primaryCta: t.tourCtaNext,
        icon: Icons.emoji_events_rounded,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        title: t.tourRewardsTitle,
        body: t.tourRewardsBody,
        primaryCta: t.tourCtaNext,
        target: TourTarget.rewardsTab,
        placement: TooltipPlacement.above,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        title: t.tourExpensesTitle(financeMode),
        body: t.tourExpensesBody(financeMode),
        primaryCta: t.tourCtaNext,
        target: TourTarget.expensesTab,
        placement: TooltipPlacement.above,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.finale,
        title: t.tourFinaleTitle,
        body: t.tourCoupleFinaleBody,
        primaryCta: t.tourFinaleCta,
        icon: Icons.favorite_rounded,
      ),
    ];
  }

  /// Guía de familia — la ven solo padres/tutores (gate en quien dispara).
  List<CoachmarkStep> _familySteps(AppLocalizations t, HomeTourContext ctx) {
    return [
      CoachmarkStep(
        kind: CoachmarkStepKind.welcomeModal,
        eyebrow: t.tourWelcomeEyebrow,
        title: t.tourFamilyWelcomeTitle,
        body: t.tourFamilyWelcomeBody,
        primaryCta: t.tourCtaStart,
        icon: Icons.family_restroom_rounded,
      ),
      if (ctx.hasTasks)
        CoachmarkStep(
          kind: CoachmarkStepKind.spotlight,
          title: t.tourFamilyTasksTitleHas,
          body: t.tourFamilyTasksBody(
            ctx.approvalsOn ? 'approvals' : 'direct',
          ),
          primaryCta: t.tourCtaNext,
          target: TourTarget.tasksSection,
        )
      else
        CoachmarkStep(
          kind: CoachmarkStepKind.spotlight,
          title: t.tourTasksTitleEmpty,
          body: t.tourTasksBodyEmpty,
          primaryCta: t.tourTasksCtaCreate,
          primaryAction: CoachmarkAction.createTask,
          secondaryCta: t.tourCtaLater,
          target: TourTarget.tasksSection,
        ),
      // Finanzas: solo si el home muestra la sección (2+ adultos).
      if (ctx.hasFinanceSection)
        CoachmarkStep(
          kind: CoachmarkStepKind.spotlight,
          title: t.tourFamilyFinanceTitle,
          body: t.tourFamilyFinanceBody,
          primaryCta: t.tourCtaNext,
          target: TourTarget.balanceCard,
        ),
      CoachmarkStep(
        kind: CoachmarkStepKind.infoModal,
        title: t.tourFamilyRankingTitle,
        body: t.tourFamilyRankingBody,
        primaryCta: t.tourCtaNext,
        icon: Icons.emoji_events_rounded,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        title: t.tourFamilyRewardsTitle,
        body: t.tourFamilyRewardsBody,
        primaryCta: t.tourCtaNext,
        target: TourTarget.rewardsTab,
        placement: TooltipPlacement.above,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.finale,
        title: t.tourFinaleTitle,
        body: t.tourFamilyFinaleBody,
        primaryCta: t.tourFinaleCta,
        icon: Icons.family_restroom_rounded,
      ),
    ];
  }

  void start(HomeTourContext context) {
    AppHaptics.tap();
    state = CoupleHomeTourState(
      isActive: true,
      currentStep: 0,
      context: context,
    );
  }

  /// Cantidad total de pasos del tour activo (para el progreso). Necesita el
  /// mismo AppLocalizations que usa el overlay.
  int stepCount(AppLocalizations t) => stepsFor(t, state.context).length;

  void next(AppLocalizations t) {
    AppHaptics.selection();
    final steps = stepsFor(t, state.context);
    final nextIndex = state.currentStep + 1;
    if (nextIndex >= steps.length) {
      _finishAndPersist();
      return;
    }
    state = state.copyWith(currentStep: nextIndex);
  }

  void back() {
    if (state.currentStep == 0) return;
    AppHaptics.selection();
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void skip() {
    AppHaptics.success();
    _finishAndPersist();
  }

  Future<void> _finishAndPersist() async {
    state = const CoupleHomeTourState.initial();
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(tourFlagKey, true);
    // Invalidate the seen-provider so subsequent reads recompute against the
    // freshly-persisted value instead of the cached `false`.
    ref.invalidate(coupleHomeTourSeenProvider);
  }

  /// Removes the persistence flag so the tour will fire again next time the
  /// user lands on the home. Used by Settings → "Ver guía de nuevo".
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(tourFlagKey);
    state = const CoupleHomeTourState.initial();
    ref.invalidate(coupleHomeTourSeenProvider);
  }
}

final coupleHomeTourControllerProvider =
    NotifierProvider<CoupleHomeTourController, CoupleHomeTourState>(
  CoupleHomeTourController.new,
);
