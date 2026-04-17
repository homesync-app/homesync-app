import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'app_identity_service.dart';
import 'logger_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  factory FirebaseAuthService({SupabaseClient? supabaseClient}) {
    if (supabaseClient != null) {
      _instance._supabaseClient = supabaseClient;
    }
    return _instance;
  }

  FirebaseAuthService._internal();

  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  SupabaseClient? _supabaseClient;
  GoogleSignIn? _googleSignIn;

  fa.FirebaseAuth get auth => _auth;
  SupabaseClient get _client {
    final client = _supabaseClient;
    if (client == null) {
      throw StateError(
        'FirebaseAuthService requires a configured SupabaseClient before use.',
      );
    }
    return client;
  }

  Future<void> _ensureInitialized() async {
    if (!kIsWeb && _googleSignIn == null) {
      log.i('FirebaseAuthService: initializing GoogleSignIn for mobile');
      _googleSignIn = GoogleSignIn.instance;
      await _googleSignIn!
          .initialize(
            serverClientId: AppEnvironment.googleWebClientId,
          )
          .timeout(const Duration(seconds: 5));
      log.i('FirebaseAuthService: GoogleSignIn initialized');
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      await _ensureInitialized();

      if (kIsWeb) {
        log.i('Firebase Auth: starting Google sign-in popup for web');
        final googleProvider = fa.GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);
        final user = userCredential.user;

        if (user == null) return false;

        log.i('Firebase Auth Web: user logged in: ${user.email}');

        await _createUserProfileIfNeeded(
          firebaseUid: user.uid,
          email: user.email ?? '',
          fullName: user.displayName,
          avatarUrl: user.photoURL,
        );
        return true;
      }

      final GoogleSignInAccount googleUser;
      try {
        googleUser = await _googleSignIn!.authenticate();
      } catch (e, stack) {
        log.e('Google Sign-In error: $e', error: e, stackTrace: stack);
        return false;
      }

      final googlePhotoUrl = googleUser.photoUrl;
      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (idToken == null) {
        log.e('Google Sign-In: no idToken obtained');
        return false;
      }

      final credential = fa.GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return false;

      log.i('Firebase Auth: user logged in with Google: ${user.email}');
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      }

      // With accessToken mode, Supabase uses the Firebase JWT automatically.
      // No manual session sync needed — just provision the user profile.
      await _createUserProfileIfNeeded(
        firebaseUid: user.uid,
        email: user.email ?? '',
        fullName: user.displayName,
        avatarUrl: googlePhotoUrl,
      );
      log.i('Firebase Auth: signInWithGoogle finished successfully');
      return true;
    } catch (e, stack) {
      log.e('Firebase Auth Error (Google): $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return false;

      log.i('Firebase Auth: user logged in with email: ${user.email}');
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      }

      await _createUserProfileIfNeeded(
        firebaseUid: user.uid,
        email: user.email ?? '',
      );
      return true;
    } catch (e, stack) {
      log.e('Firebase Auth Error (Email): $e', error: e, stackTrace: stack);
      await _auth.signOut();
      rethrow;
    }
  }

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) return false;

      log.i('Firebase Auth: user registered: ${user.email}');
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
      }

      await user.getIdToken(true);

      await _createUserProfileIfNeeded(
        firebaseUid: user.uid,
        email: user.email ?? '',
      );
      return true;
    } catch (e, stack) {
      log.e('Firebase Auth Error (SignUp): $e', error: e, stackTrace: stack);
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log.i('Firebase Auth: reset email sent to $email');
    } catch (e, stack) {
      log.e(
        'Error sending reset email to $email: $e',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<void> _createUserProfileIfNeeded({
    required String firebaseUid,
    required String email,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      log.i('Ensuring user profile for Firebase UID: $firebaseUid');
      // ensure_user_profile is security-definer and returns the user's UUID.
      // We use the return value directly instead of a follow-up anon query
      // (which would fail RLS since there is no Supabase auth session).
      final result = await _client.rpc<dynamic>('ensure_user_profile', params: {
        'p_firebase_uid': firebaseUid,
        'p_email': email,
        'p_full_name': fullName,
        'p_avatar_url': avatarUrl,
      },);

      final userId = result?.toString();
      if (userId != null && userId.isNotEmpty) {
        AppIdentityService.instance.setDirectUserId(userId);
        log.i('User profile ensured successfully (id: $userId)');
      } else {
        // Fallback: try the standard refresh in case the RPC returned null
        await AppIdentityService.instance.refresh();
        log.i('User profile ensured successfully (via refresh fallback)');
      }
    } catch (e, stack) {
      log.e('Error in _createUserProfileIfNeeded: $e',
          error: e, stackTrace: stack,);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e, stack) {
          log.w('Error signing out from Google: $e',
              error: e, stackTrace: stack,);
        }
      }

      // In Third-Party Auth mode there is no Supabase session to sign out from.
      // The Firebase sign-out above already invalidates the JWT that Supabase uses.
      await AppIdentityService.instance.refresh();

      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier('');
      }
      log.i('Session closed (Firebase + Supabase)');
    } catch (e, stack) {
      log.e('Error signing out: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> ensureHouseholdExists() async {
    try {
      final appUserId = AppIdentityService.instance.currentUserId;
      if (appUserId == null || appUserId.isEmpty) {
        log.w('ensureHouseholdExists: no app user id available yet');
        return;
      }

      final existing = await _client
          .from('household_members')
          .select('id')
          .eq('user_id', appUserId)
          .maybeSingle();

      if (existing != null) return;

      log.i('ensureHouseholdExists: creating profile and household');
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return;

      await _createUserProfileIfNeeded(
        firebaseUid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        fullName: firebaseUser.displayName,
        avatarUrl: firebaseUser.photoURL,
      );
    } catch (e, stack) {
      log.e('Error in ensureHouseholdExists: $e', error: e, stackTrace: stack);
    }
  }

  fa.User? get currentUser => _auth.currentUser;

  Stream<fa.User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }
}
