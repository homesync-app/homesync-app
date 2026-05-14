// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(currentUser)
final currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider extends $FunctionalProvider<User?, User?, User?>
    with $Provider<User?> {
  CurrentUserProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  $ProviderElement<User?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  User? create(Ref ref) {
    return currentUser(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(User? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<User?>(value),
    );
  }
}

String _$currentUserHash() => r'923f53c511f5753ea887cba4928231b3ba1b85be';

/// Controller that manages the authentication state and actions.
/// It wraps the AuthRepository and provides a unified interface for the UI.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Controller that manages the authentication state and actions.
/// It wraps the AuthRepository and provides a unified interface for the UI.
final class AuthControllerProvider
    extends $StreamNotifierProvider<AuthController, AuthState> {
  /// Controller that manages the authentication state and actions.
  /// It wraps the AuthRepository and provides a unified interface for the UI.
  AuthControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'939c3808c8e20d3dd99ae6e3ea3e640965f9ef7e';

/// Controller that manages the authentication state and actions.
/// It wraps the AuthRepository and provides a unified interface for the UI.

abstract class _$AuthController extends $StreamNotifier<AuthState> {
  Stream<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState>, AuthState>,
        AsyncValue<AuthState>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provides the current authenticated user from Supabase.
/// Provides whether the user is currently authenticated.

@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = IsAuthenticatedProvider._();

/// Provides the current authenticated user from Supabase.
/// Provides whether the user is currently authenticated.

final class IsAuthenticatedProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Provides the current authenticated user from Supabase.
  /// Provides whether the user is currently authenticated.
  IsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isAuthenticatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isAuthenticatedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAuthenticated(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAuthenticatedHash() => r'ec00b59a417cdf6ce83dbc969f19d3af3ecf01fc';

/// Provides the user profile from the database, updated when the user changes.

@ProviderFor(currentUserProfile)
final currentUserProfileProvider = CurrentUserProfileProvider._();

/// Provides the user profile from the database, updated when the user changes.

final class CurrentUserProfileProvider extends $FunctionalProvider<
        AsyncValue<UserModel?>, UserModel?, FutureOr<UserModel?>>
    with $FutureModifier<UserModel?>, $FutureProvider<UserModel?> {
  /// Provides the user profile from the database, updated when the user changes.
  CurrentUserProfileProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'currentUserProfileProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$currentUserProfileHash();

  @$internal
  @override
  $FutureProviderElement<UserModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UserModel?> create(Ref ref) {
    return currentUserProfile(ref);
  }
}

String _$currentUserProfileHash() =>
    r'16556f335ab78200031efb7b9425013d70a8135b';
