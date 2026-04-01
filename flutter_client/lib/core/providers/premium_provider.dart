import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import '../services/premium_service.dart';
import '../services/logger_service.dart';

class PremiumNotifier extends AsyncNotifier<bool> {
  late final SupabaseClient _supabase;

  @override
  Future<bool> build() async {
    _supabase = ref.read(supabaseClientProvider);

    ref.listen<AsyncValue<AppAuthState>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.isAuthenticated) {
          unawaited(refresh());
        } else {
          state = const AsyncData(false);
        }
      });
    });

    return _fetchPremiumStatus();
  }

  Future<bool> _fetchPremiumStatus() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('is_premium')
          .eq('id', user.id)
          .maybeSingle();

      return data != null && data['is_premium'] == true;
    } catch (e) {
      log.e('Error fetching premium status: $e');
      return false;
    }
  }

  /// FOR DEMO/DEVELOPMENT ONLY: Toggles local mock premium
  Future<void> togglePremiumMock() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final currentPremium = state.valueOrNull ?? false;
    final newState = !currentPremium;
    await _supabase
        .from('users')
        .update({'is_premium': newState})
        .eq('id', user.id);
    state = AsyncData(newState);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<bool>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetchPremiumStatus);
  }
}

final premiumProvider = AsyncNotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});

/// UI-facing provider for available products
final premiumProductsProvider = FutureProvider((ref) async {
  final service = ref.read(premiumServiceProvider);
  return await service.getProducts();
});
