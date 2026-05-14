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
          isAutoDispose: true,
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
    r'c6e9a6bfb312b0655ac88d857f9b3760f001aee5';

@ProviderFor(resetAccountUseCase)
final resetAccountUseCaseProvider = ResetAccountUseCaseProvider._();

final class ResetAccountUseCaseProvider extends $FunctionalProvider<
    ResetAccountUseCase,
    ResetAccountUseCase,
    ResetAccountUseCase> with $Provider<ResetAccountUseCase> {
  ResetAccountUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'resetAccountUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$resetAccountUseCaseHash();

  @$internal
  @override
  $ProviderElement<ResetAccountUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ResetAccountUseCase create(Ref ref) {
    return resetAccountUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ResetAccountUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ResetAccountUseCase>(value),
    );
  }
}

String _$resetAccountUseCaseHash() =>
    r'a00a5c169f3e4cb4d5e1e20bc9131e02f59ff537';

@ProviderFor(updateAvatarUseCase)
final updateAvatarUseCaseProvider = UpdateAvatarUseCaseProvider._();

final class UpdateAvatarUseCaseProvider extends $FunctionalProvider<
    UpdateAvatarUseCase,
    UpdateAvatarUseCase,
    UpdateAvatarUseCase> with $Provider<UpdateAvatarUseCase> {
  UpdateAvatarUseCaseProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateAvatarUseCaseProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateAvatarUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateAvatarUseCase> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UpdateAvatarUseCase create(Ref ref) {
    return updateAvatarUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateAvatarUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateAvatarUseCase>(value),
    );
  }
}

String _$updateAvatarUseCaseHash() =>
    r'230cdeaef63a7b56a9053cb94e217b116e485e37';

@ProviderFor(NotificationEnabled)
final notificationEnabledProvider = NotificationEnabledProvider._();

final class NotificationEnabledProvider
    extends $NotifierProvider<NotificationEnabled, bool> {
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
    r'ee6e9c6286cbf1305c5e370a85d4ebc6252b2fd2';

abstract class _$NotificationEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
