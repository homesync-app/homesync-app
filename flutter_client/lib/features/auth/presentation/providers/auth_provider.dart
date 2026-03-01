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
  return repo.getUserProfile(user.id);
});
