import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/supabase_auth_repository.dart';
import '../../domain/models/user_model.dart';

// ── Auth state ────────────────────────────────────────────────────────────────

/// Whether there is a currently authenticated session.
final isAuthenticatedProvider = StreamProvider<bool>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges.map((state) =>
      state.event == AuthChangeEvent.signedIn ||
      state.event == AuthChangeEvent.tokenRefreshed ||
      state.event == AuthChangeEvent.userUpdated);
});

/// Current user profile from the database.
final currentUserProfileProvider = FutureProvider<UserModel?>((ref) async {
  final repo = ref.watch(authRepositoryProvider);
  final user = repo.currentUser;
  if (user == null) return null;
  
  final result = await repo.getUserProfile(user.id);
  
  return result.fold(
    (f) {
      log.e('Error loading user profile: ${f.message}');
      return null;
    },
    (userProfile) => userProfile,
  );
});
