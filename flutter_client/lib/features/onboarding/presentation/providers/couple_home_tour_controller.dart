import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/theme_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/onboarding/domain/coachmark_step.dart';

/// Storage key — bumped suffix invalidates older tours when redesigned.
const _tourFlagKey = 'couple_home_tour_seen_v1';

/// Whether the user already completed/skipped the couple home tour.
final coupleHomeTourSeenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_tourFlagKey) ?? false;
});

class CoupleHomeTourState {
  final bool isActive;
  final int currentStep;
  final bool hasTasks;

  const CoupleHomeTourState({
    required this.isActive,
    required this.currentStep,
    required this.hasTasks,
  });

  const CoupleHomeTourState.initial()
      : isActive = false,
        currentStep = 0,
        hasTasks = false;

  CoupleHomeTourState copyWith({
    bool? isActive,
    int? currentStep,
    bool? hasTasks,
  }) {
    return CoupleHomeTourState(
      isActive: isActive ?? this.isActive,
      currentStep: currentStep ?? this.currentStep,
      hasTasks: hasTasks ?? this.hasTasks,
    );
  }
}

class CoupleHomeTourController extends Notifier<CoupleHomeTourState> {
  @override
  CoupleHomeTourState build() => const CoupleHomeTourState.initial();

  /// Returns the ordered list of steps. Some copy adapts to whether the user
  /// has any tasks yet.
  List<CoachmarkStep> stepsFor({required bool hasTasks}) {
    return [
      const CoachmarkStep(
        kind: CoachmarkStepKind.welcomeModal,
        eyebrow: 'Bienvenidos',
        title: 'Tu hogar, en 30 segundos',
        body:
            'Te muestro lo esencial: tareas, monedas, duelo y recompensas. Después, a disfrutar.',
        primaryCta: 'Empezar',
        icon: Icons.auto_awesome_rounded,
      ),
      CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        eyebrow: 'Paso 1',
        title: hasTasks ? 'Hacé tareas, ganá puntos' : 'Acá van tus tareas',
        body: hasTasks
            ? 'Tocá ✓ para completar. Cada tarea suma 🪙 monedas y ⚡ XP solo para vos.'
            : 'Cuando crees tareas, aparecen acá. Cada una te da 🪙 monedas y ⚡ XP al completarla.',
        primaryCta: 'Siguiente',
        target: TourTarget.tasksSection,
        placement: TooltipPlacement.auto,
      ),
      const CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        eyebrow: 'Paso 2',
        title: 'Tu balance personal',
        body:
            'Acá ves lo que ganaste vos. No se mezcla con tu pareja: cada uno acumula lo suyo.',
        primaryCta: 'Siguiente',
        target: TourTarget.balanceCard,
        bullets: [
          CoachmarkBullet(
            icon: Icons.monetization_on_rounded,
            tint: AppColors.accentGold,
            text: 'Monedas → para canjear recompensas',
          ),
          CoachmarkBullet(
            icon: Icons.bolt_rounded,
            tint: AppColors.primary,
            text: 'XP → para el duelo semanal',
          ),
        ],
      ),
      const CoachmarkStep(
        kind: CoachmarkStepKind.infoModal,
        eyebrow: 'Paso 3',
        title: 'Duelo semanal',
        body:
            'Cada semana compiten por XP. Quien sume más, gana. Se reinicia los lunes.',
        primaryCta: 'Siguiente',
        icon: Icons.emoji_events_rounded,
      ),
      const CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        eyebrow: 'Paso 4',
        title: 'Canjeá las monedas',
        body:
            'Acá viven las recompensas: peli, masaje, día libre. Vos y tu pareja arman la tienda.',
        primaryCta: 'Siguiente',
        target: TourTarget.rewardsTab,
        placement: TooltipPlacement.above,
      ),
      const CoachmarkStep(
        kind: CoachmarkStepKind.spotlight,
        eyebrow: 'Paso 5',
        title: 'Dividan los gastos',
        body:
            'Cuando lo necesiten, sumen gastos del hogar y la app calcula quién le debe a quién.',
        primaryCta: 'Siguiente',
        target: TourTarget.expensesTab,
        placement: TooltipPlacement.above,
      ),
      const CoachmarkStep(
        kind: CoachmarkStepKind.finale,
        title: '¡Listo!',
        body: 'Disfruten de su hogar.',
        primaryCta: 'Empezar a usar',
        icon: Icons.favorite_rounded,
      ),
    ];
  }

  void start({required bool hasTasks}) {
    HapticFeedback.lightImpact();
    state = CoupleHomeTourState(
      isActive: true,
      currentStep: 0,
      hasTasks: hasTasks,
    );
  }

  void next() {
    HapticFeedback.selectionClick();
    final steps = stepsFor(hasTasks: state.hasTasks);
    final nextIndex = state.currentStep + 1;
    if (nextIndex >= steps.length) {
      _finishAndPersist();
      return;
    }
    state = state.copyWith(currentStep: nextIndex);
  }

  void back() {
    if (state.currentStep == 0) return;
    HapticFeedback.selectionClick();
    state = state.copyWith(currentStep: state.currentStep - 1);
  }

  void skip() {
    HapticFeedback.mediumImpact();
    _finishAndPersist();
  }

  void _finishAndPersist() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_tourFlagKey, true);
    state = const CoupleHomeTourState.initial();
  }

  /// Removes the persistence flag so the tour will fire again next time the
  /// user lands on the couple home. Used by Settings → "Ver guía de nuevo".
  Future<void> reset() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_tourFlagKey);
    state = const CoupleHomeTourState.initial();
  }
}

final coupleHomeTourControllerProvider =
    NotifierProvider<CoupleHomeTourController, CoupleHomeTourState>(
  CoupleHomeTourController.new,
);
