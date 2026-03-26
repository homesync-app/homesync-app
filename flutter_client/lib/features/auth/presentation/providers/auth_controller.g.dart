// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isAuthenticatedHash() => r'56ad6feb139dd11c5a56805e5e292cd07f4abf52';

/// Provides the current authenticated user from Supabase.
/// Provides whether the user is currently authenticated.
///
/// Copied from [isAuthenticated].
@ProviderFor(isAuthenticated)
final isAuthenticatedProvider = AutoDisposeProvider<bool>.internal(
  isAuthenticated,
  name: r'isAuthenticatedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isAuthenticatedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsAuthenticatedRef = AutoDisposeProviderRef<bool>;
String _$currentUserProfileHash() =>
    r'30eb7061bc5c697b74960a043c1455f2500b4893';

/// Provides the user profile from the database, updated when the user changes.
///
/// Copied from [currentUserProfile].
@ProviderFor(currentUserProfile)
final currentUserProfileProvider =
    AutoDisposeFutureProvider<UserModel?>.internal(
  currentUserProfile,
  name: r'currentUserProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentUserProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentUserProfileRef = AutoDisposeFutureProviderRef<UserModel?>;
String _$authControllerHash() => r'36203c35b491189c38ab0ea3ad329e0acc397003';

/// Controller that manages the authentication state and actions.
/// It wraps the AuthRepository and provides a unified interface for the UI.
///
/// Copied from [AuthController].
@ProviderFor(AuthController)
final authControllerProvider =
    AutoDisposeStreamNotifierProvider<AuthController, AuthState>.internal(
  AuthController.new,
  name: r'authControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$authControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthController = AutoDisposeStreamNotifier<AuthState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
