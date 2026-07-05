import 'package:homesync_client/core/theme/household_design.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'setup_wizard_controller.g.dart';

/// Pasos del wizard de setup. El orden de la declaración es el orden real del
/// flujo lineal; la navegación con saltos (solo, invitación) vive en el
/// controller, nunca en los widgets.
enum SetupStep {
  valueProp,
  welcome,
  identity,
  mode,
  teamOptions,
  inviteCode,
  householdConfig,
  taskSelection,
}

/// Estado del formulario + navegación del wizard. Inmutable; los widgets de
/// step leen esto y mutan solo a través de [SetupWizardController].
class SetupWizardState {
  final SetupStep step;
  final String? selectedMode;
  final bool createNew;
  final String? joinError;

  // Identidad
  final String selectedAvatarEmoji;
  final String? selectedAvatarUrl;

  // Configuración familia
  final String familyRole;
  final String creatorMemberType;

  // Configuración finanzas (couple/family)
  final String financeMode; // 'divided' | 'shared'
  final double splitRatio;

  // Selección de tareas iniciales
  final Set<String> selectedTemplateIds;

  const SetupWizardState({
    this.step = SetupStep.valueProp,
    this.selectedMode,
    this.createNew = true,
    this.joinError,
    this.selectedAvatarEmoji = '',
    this.selectedAvatarUrl,
    this.familyRole = 'Padre',
    this.creatorMemberType = 'parent',
    this.financeMode = 'divided',
    this.splitRatio = 0.5,
    this.selectedTemplateIds = const {},
  });

  /// Valor de avatar a persistir: URL si existe, si no el emoji elegido.
  String get resolvedAvatarValue => selectedAvatarUrl ?? selectedAvatarEmoji;

  /// Personalidad visual del modo elegido (`HouseholdModeDesign`): acentos y
  /// gradiente hero para teñir el wizard después de la elección de modo.
  /// Con modo sin elegir cae en couple (el default de `fromString`).
  HouseholdModeDesign get modeDesign =>
      HouseholdType.fromString(selectedMode).design;

  /// Pasos que este modo realmente recorre. Solo saltea equipo, invitación y
  /// configuración del hogar, así que su barra de progreso no debe contarlos.
  List<SetupStep> get effectiveRoute => selectedMode == 'solo'
      ? const [
          SetupStep.valueProp,
          SetupStep.welcome,
          SetupStep.identity,
          SetupStep.mode,
          SetupStep.taskSelection,
        ]
      : SetupStep.values;

  /// Segmentos visibles en la barra de progreso (la intro no cuenta).
  int get progressTotal => effectiveRoute.length - 1;

  /// Posición activa dentro de la ruta efectiva (0-based tras la intro);
  /// -1 durante la intro. Si el paso no pertenece a la ruta (p. ej. volver
  /// atrás tras cambiar de modo) se aproxima por el orden global.
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
    String? financeMode,
    double? splitRatio,
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
      financeMode: financeMode ?? this.financeMode,
      splitRatio: splitRatio ?? this.splitRatio,
      selectedTemplateIds: selectedTemplateIds ?? this.selectedTemplateIds,
    );
  }

  static const _sentinel = Object();
}

/// Dueño único de `currentStep` + estado del formulario del wizard de setup.
///
/// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
/// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
/// controller solo decide "en qué paso estamos y qué eligió el usuario",
/// que es lo que hace testeable el flujo de navegación.
@riverpod
class SetupWizardController extends _$SetupWizardController {
  @override
  SetupWizardState build() => const SetupWizardState();

  // -- Navegación -----------------------------------------------------------

  void goTo(SetupStep step) => state = state.copyWith(step: step);

  /// Vuelve un paso (comportamiento del botón back del sistema).
  /// Devuelve `false` si ya está en el primer paso (el pop debe propagarse).
  bool goBack() {
    if (state.step == SetupStep.valueProp) return false;
    state = state.copyWith(step: SetupStep.values[state.step.index - 1]);
    return true;
  }

  /// Confirmar el modo elegido: solo saltea equipo/invitación/config y va
  /// directo a tareas; el resto pasa a elegir crear/unirse.
  void confirmMode() {
    state = state.copyWith(
      step: state.selectedMode == 'solo'
          ? SetupStep.taskSelection
          : SetupStep.teamOptions,
    );
  }

  /// Continuar desde la pantalla del código de invitación.
  void continueFromInviteCode() {
    state = state.copyWith(
      step: state.selectedMode == 'solo'
          ? SetupStep.taskSelection
          : SetupStep.householdConfig,
    );
  }

  // -- Formulario -----------------------------------------------------------

  void selectMode(String modeId) => state = state.copyWith(selectedMode: modeId);

  void setCreateNew(bool createNew) =>
      state = state.copyWith(createNew: createNew, joinError: null);

  void setJoinError(String? error) =>
      state = state.copyWith(joinError: error);

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

  void setFinanceMode(String mode) =>
      state = state.copyWith(financeMode: mode);

  void setSplitRatio(double ratio) =>
      state = state.copyWith(splitRatio: ratio);

  void toggleTemplate(String templateId) {
    final ids = {...state.selectedTemplateIds};
    if (!ids.remove(templateId)) ids.add(templateId);
    state = state.copyWith(selectedTemplateIds: ids);
  }

  void seedSelectedTemplates(Iterable<String> templateIds) => state =
      state.copyWith(selectedTemplateIds: {...state.selectedTemplateIds, ...templateIds});
}
