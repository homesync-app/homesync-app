import 'dart:async';

import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/household_design.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_wizard_controller.g.dart';

/// Pasos del onboarding. Pocos a propósito: cada paso extra antes del primer
/// dato propio es gente que se queda en el camino.
///
/// - [start]: qué es la app + empezar un hogar o unirse con un código (quien
///   fue invitado termina acá, en un solo paso).
/// - [household]: con quién vivís, tu nombre y tu avatar. Al continuar se crea
///   el hogar.
/// - [tasks]: las primeras tareas, ya sugeridas.
/// - [invite]: sumar a la otra persona (no aplica a solo).
enum SetupStep {
  start,
  household,
  tasks,
  invite,
}

/// Estado del formulario + navegación del wizard. Inmutable; los widgets de
/// step leen esto y mutan solo a través de [SetupWizardController].
class SetupWizardState {
  final SetupStep step;
  final String selectedMode;

  /// false mientras el panel "Tengo un código" está abierto.
  final bool createNew;
  final String? joinError;

  // Identidad
  final String selectedAvatarEmoji;
  final String? selectedAvatarUrl;

  // Configuración familia
  final String familyRole;
  final String creatorMemberType;

  // Selección de tareas iniciales
  final Set<String> selectedTemplateIds;

  const SetupWizardState({
    this.step = SetupStep.start,
    this.selectedMode = 'couple',
    this.createNew = true,
    this.joinError,
    this.selectedAvatarEmoji = '',
    this.selectedAvatarUrl,
    this.familyRole = 'Padre',
    this.creatorMemberType = 'parent',
    this.selectedTemplateIds = const {},
  });

  /// Valor de avatar a persistir: URL si existe, si no el emoji elegido.
  String get resolvedAvatarValue => selectedAvatarUrl ?? selectedAvatarEmoji;

  HouseholdType get householdType => HouseholdType.fromString(selectedMode);

  bool get isSolo => householdType == HouseholdType.solo;

  /// Personalidad visual del modo elegido (`HouseholdModeDesign`): acentos
  /// para teñir el wizard.
  HouseholdModeDesign get modeDesign => householdType.design;

  /// Pasos que este modo realmente recorre. Solo no invita a nadie.
  List<SetupStep> get effectiveRoute => isSolo
      ? const [SetupStep.start, SetupStep.household, SetupStep.tasks]
      : SetupStep.values;

  /// Segmentos visibles en la barra de progreso (la bienvenida no cuenta).
  int get progressTotal => effectiveRoute.length - 1;

  /// Posición activa dentro de la ruta efectiva (0-based tras la bienvenida);
  /// -1 en la bienvenida.
  int get progressIndex {
    final routeIndex = effectiveRoute.indexOf(step);
    final position = (routeIndex >= 0 ? routeIndex : step.index) - 1;
    return position.clamp(-1, progressTotal - 1);
  }

  SetupWizardState copyWith({
    SetupStep? step,
    String? selectedMode,
    bool? createNew,
    Object? joinError = _sentinel,
    String? selectedAvatarEmoji,
    Object? selectedAvatarUrl = _sentinel,
    String? familyRole,
    String? creatorMemberType,
    Set<String>? selectedTemplateIds,
  }) {
    return SetupWizardState(
      step: step ?? this.step,
      selectedMode: selectedMode ?? this.selectedMode,
      createNew: createNew ?? this.createNew,
      joinError: joinError == _sentinel ? this.joinError : joinError as String?,
      selectedAvatarEmoji: selectedAvatarEmoji ?? this.selectedAvatarEmoji,
      selectedAvatarUrl: selectedAvatarUrl == _sentinel
          ? this.selectedAvatarUrl
          : selectedAvatarUrl as String?,
      familyRole: familyRole ?? this.familyRole,
      creatorMemberType: creatorMemberType ?? this.creatorMemberType,
      selectedTemplateIds: selectedTemplateIds ?? this.selectedTemplateIds,
    );
  }

  static const _sentinel = Object();
}

/// Dueño único del paso actual + estado del formulario del wizard de setup.
///
/// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
/// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
/// controller solo decide "en qué paso estamos y qué eligió el usuario",
/// que es lo que hace testeable el flujo de navegación.
@riverpod
class SetupWizardController extends _$SetupWizardController {
  @override
  SetupWizardState build() {
    // El primer paso no pasa por _goToStep, así que se emite acá. En microtask
    // para no disparar un side effect durante el build del provider.
    scheduleMicrotask(() => _trackStep(SetupStep.start));
    return const SetupWizardState();
  }

  // -- Navegación -----------------------------------------------------------

  /// Único punto de cambio de paso. Todas las transiciones pasan por acá para
  /// que `setup_step_viewed` no dependa de que alguien se acuerde de emitirlo.
  void _goToStep(SetupStep step) {
    state = state.copyWith(step: step);
    _trackStep(step);
  }

  void _trackStep(SetupStep step) {
    unawaited(
      ref.read(analyticsServiceProvider).trackSetupStepViewed(
            step: step.name,
            mode: state.selectedMode,
          ),
    );
  }

  void goTo(SetupStep step) => _goToStep(step);

  /// Vuelve un paso (botón back del sistema). Devuelve `false` en la
  /// bienvenida, para que el pop se propague.
  ///
  /// En la invitación no retrocede: las tareas ya se guardaron y volver a
  /// confirmarlas las duplicaría. Se sale con "Lo hago después".
  bool goBack() {
    switch (state.step) {
      case SetupStep.start:
        return false;
      case SetupStep.household:
        _goToStep(SetupStep.start);
        return true;
      case SetupStep.tasks:
        _goToStep(SetupStep.household);
        return true;
      case SetupStep.invite:
        return true;
    }
  }

  /// Empezar un hogar nuevo desde la bienvenida.
  void startCreate() {
    state = state.copyWith(createNew: true, joinError: null);
    _goToStep(SetupStep.household);
  }

  /// El hogar ya existe: sigue la elección de tareas.
  void householdReady() => _goToStep(SetupStep.tasks);

  /// Las tareas quedaron guardadas. Devuelve `true` si todavía falta el paso
  /// de invitación; `false` si el setup terminó (modo solo).
  bool tasksSaved() {
    if (state.isSolo) return false;
    _goToStep(SetupStep.invite);
    return true;
  }

  // -- Formulario -----------------------------------------------------------

  void selectMode(String modeId) =>
      state = state.copyWith(selectedMode: modeId);

  /// Abre (false) o cierra (true) el panel para unirse con un código.
  void setCreateNew(bool createNew) =>
      state = state.copyWith(createNew: createNew, joinError: null);

  void setJoinError(String? error) => state = state.copyWith(joinError: error);

  void setAvatarEmoji(String emoji) => state =
      state.copyWith(selectedAvatarEmoji: emoji, selectedAvatarUrl: null);

  void setAvatarUrl(String url) =>
      state = state.copyWith(selectedAvatarUrl: url);

  /// El id interno queda en español por compat con backend
  /// (`p_display_role`); el member type se deriva del rol.
  void setFamilyRole(String roleId) => state = state.copyWith(
        familyRole: roleId,
        creatorMemberType: roleId == 'Adolescente' ? 'teen' : 'parent',
      );

  void toggleTemplate(String templateId) {
    final ids = {...state.selectedTemplateIds};
    if (!ids.remove(templateId)) ids.add(templateId);
    state = state.copyWith(selectedTemplateIds: ids);
  }

  void seedSelectedTemplates(Iterable<String> templateIds) =>
      state = state.copyWith(
        selectedTemplateIds: {...state.selectedTemplateIds, ...templateIds},
      );
}
