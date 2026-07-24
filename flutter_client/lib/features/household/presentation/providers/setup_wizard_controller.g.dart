// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_wizard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Dueño único de `currentStep` + estado del formulario del wizard de setup.
///
/// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
/// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
/// controller solo decide "en qué paso estamos y qué eligió el usuario",
/// que es lo que hace testeable el flujo de navegación.

@ProviderFor(SetupWizardController)
final setupWizardControllerProvider = SetupWizardControllerProvider._();

/// Dueño único de `currentStep` + estado del formulario del wizard de setup.
///
/// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
/// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
/// controller solo decide "en qué paso estamos y qué eligió el usuario",
/// que es lo que hace testeable el flujo de navegación.
final class SetupWizardControllerProvider
    extends $NotifierProvider<SetupWizardController, SetupWizardState> {
  /// Dueño único de `currentStep` + estado del formulario del wizard de setup.
  ///
  /// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
  /// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
  /// controller solo decide "en qué paso estamos y qué eligió el usuario",
  /// que es lo que hace testeable el flujo de navegación.
  SetupWizardControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'setupWizardControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$setupWizardControllerHash();

  @$internal
  @override
  SetupWizardController create() => SetupWizardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetupWizardState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetupWizardState>(value),
    );
  }
}

String _$setupWizardControllerHash() =>
    r'9b101dc4581a8cb0f54a391318a1db8af2f408fc';

/// Dueño único de `currentStep` + estado del formulario del wizard de setup.
///
/// Los side effects (crear hogar, unirse, clonar tareas, guardar perfil)
/// siguen en `SetupScreen` porque necesitan `BuildContext`/snackbars; este
/// controller solo decide "en qué paso estamos y qué eligió el usuario",
/// que es lo que hace testeable el flujo de navegación.

abstract class _$SetupWizardController extends $Notifier<SetupWizardState> {
  SetupWizardState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SetupWizardState, SetupWizardState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SetupWizardState, SetupWizardState>,
        SetupWizardState,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
