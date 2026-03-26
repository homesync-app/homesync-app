import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/premium_service.dart';
import '../services/logger_service.dart';

class PremiumNotifier extends Notifier<bool> {
  late final SupabaseClient _supabase;
  
  @override
  bool build() {
    _supabase = Supabase.instance.client;
    
    // Initial fetch from current user metadata or session
    // But better to fetch from DB
    _refreshFromDb();
    
    // Also listen to auth changes to refresh
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _refreshFromDb();
      } else {
        state = false;
      }
    });

    return false;
  }

  Future<void> _refreshFromDb() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      state = false;
      return;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('is_premium')
          .eq('id', user.id)
          .maybeSingle();
      
      if (data != null && data['is_premium'] == true) {
        state = true;
      } else {
        state = false;
      }
    } catch (e) {
      log.e('Error fetching premium status: $e');
    }
  }

  /// FOR DEMO/DEVELOPMENT ONLY: Toggles local mock premium
  Future<void> togglePremiumMock() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final newState = !state;
    await _supabase.from('users').update({'is_premium': newState}).eq('id', user.id);
    state = newState;
  }

  Future<void> refresh() async {
    await _refreshFromDb();
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});

/// UI-facing provider for available products
final premiumProductsProvider = FutureProvider((ref) async {
  final service = ref.read(premiumServiceProvider);
  return await service.getProducts();
});
