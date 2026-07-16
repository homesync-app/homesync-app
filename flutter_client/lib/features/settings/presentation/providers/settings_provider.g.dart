// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

final class SettingsRepositoryProvider extends $FunctionalProvider<
    SettingsRepository,
    SettingsRepository,
    SettingsRepository> with $Provider<SettingsRepository> {
  SettingsRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'settingsRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'bc6023891d7bc0990e7cadf8222450b6caa559b4';

@ProviderFor(deleteAccountUseCase)
final deleteAccountUseCaseProvider = DeleteAccountUseCaseProvider._();

final class DeleteAccountUseCaseProvider extends $FunctionalProvider<
    DeleteAccountUseCase,
    DeleteAccountUseCase,
    DeleteAccountUseCase> with $Provider<DeleteAccountUseCase> {
  DeleteAccountUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'deleteAccountUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$deleteAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteAccountUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeleteAccountUseCase create(Ref ref) {
    return deleteAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteAccountUseCase>(value),
    );
  }
}

String _$deleteAccountUseCaseHash() =>
    r'3206b4aafca491afa492c0cf9d25bed922dbf093';

/// Preferencia de notificaciones. Lee el estado persistido (misma clave que
/// usa NotificationService al inicializar) y al togglear aplica el efecto
/// real: alta de permisos/token FCM al activar, borrado del token al apagar.

@ProviderFor(NotificationEnabled)
final notificationEnabledProvider = NotificationEnabledProvider._();

/// Preferencia de notificaciones. Lee el estado persistido (misma clave que
/// usa NotificationService al inicializar) y al togglear aplica el efecto
/// real: alta de permisos/token FCM al activar, borrado del token al apagar.
final class NotificationEnabledProvider
    extends $NotifierProvider<NotificationEnabled, bool> {
  /// Preferencia de notificaciones. Lee el estado persistido (misma clave que
  /// usa NotificationService al inicializar) y al togglear aplica el efecto
  /// real: alta de permisos/token FCM al activar, borrado del token al apagar.
  NotificationEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'notificationEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$notificationEnabledHash();

  @$internal
  @override
  NotificationEnabled create() => NotificationEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$notificationEnabledHash() =>
    r'6b5dd462e06b598eec763dca258723d25724e76e';

/// Preferencia de notificaciones. Lee el estado persistido (misma clave que
/// usa NotificationService al inicializar) y al togglear aplica el efecto
/// real: alta de permisos/token FCM al activar, borrado del token al apagar.

abstract class _$NotificationEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
