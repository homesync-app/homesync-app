// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Single source of truth for the SupabaseClient.
/// All repositories get the client via this provider, never via Supabase.instance.
///
/// keepAlive: wraps the global [Supabase.instance.client] singleton, which has
/// no disposable state and lives for the whole app. Marking it keepAlive lets
/// the many keepAlive repository providers depend on it without forcing an
/// auto-dispose provider to behave as keepAlive (riverpod_lint
/// only_use_keep_alive_inside_keep_alive).

@ProviderFor(supabaseClient)
final supabaseClientProvider = SupabaseClientProvider._();

/// Single source of truth for the SupabaseClient.
/// All repositories get the client via this provider, never via Supabase.instance.
///
/// keepAlive: wraps the global [Supabase.instance.client] singleton, which has
/// no disposable state and lives for the whole app. Marking it keepAlive lets
/// the many keepAlive repository providers depend on it without forcing an
/// auto-dispose provider to behave as keepAlive (riverpod_lint
/// only_use_keep_alive_inside_keep_alive).

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// Single source of truth for the SupabaseClient.
  /// All repositories get the client via this provider, never via Supabase.instance.
  ///
  /// keepAlive: wraps the global [Supabase.instance.client] singleton, which has
  /// no disposable state and lives for the whole app. Marking it keepAlive lets
  /// the many keepAlive repository providers depend on it without forcing an
  /// auto-dispose provider to behave as keepAlive (riverpod_lint
  /// only_use_keep_alive_inside_keep_alive).
  SupabaseClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'supabaseClientProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'2df5a38617329a3bb0a7e149189bea875722d7b8';
