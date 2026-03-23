import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';

import 'app_identity_service.dart';
import 'logger_service.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();

  factory FirebaseAuthService() => _instance;

  FirebaseAuthService._internal();

  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  fa.FirebaseAuth get auth => _auth;

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
        final idToken = await user.getIdToken(true);
        if (idToken == null) return false;

        await _prepareSupabaseAfterFirebaseSignIn(idToken: idToken);
        await _createUserProfileIfNeeded();
        await _ensureProvisionedAccess();
        return true;
      }

      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn!.authenticate();
      } catch (e) {
        log.e('Google Sign-In error: $e', error: e);
        return false;
      }

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

      await _prepareSupabaseAfterFirebaseSignIn(idToken: idToken);
      await _createUserProfileIfNeeded();
      await _ensureProvisionedAccess();
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

      await _prepareSupabaseAfterFirebaseSignIn();
      await _createUserProfileIfNeeded();
      await _ensureProvisionedAccess();
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

      await _prepareSupabaseAfterFirebaseSignIn();
      await _createUserProfileIfNeeded();
      await _ensureProvisionedAccess();
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
    } catch (e) {
      log.e('Error sending reset email to $email: $e', error: e);
      rethrow;
    }
  }

  Future<void> _prepareSupabaseAfterFirebaseSignIn({
    String? idToken,
    bool forceRefreshToken = true,
  }) async {
    await _syncSupabaseSessionWithFirebase(idToken: idToken);
    await AppIdentityService.instance.refresh();
  }

  Future<void> _syncSupabaseSessionWithFirebase({String? idToken}) async {
    try {
      final tokenToUse = idToken ?? await _auth.currentUser?.getIdToken();
      if (tokenToUse == null) {
        log.w('No token available to sync Supabase session');
        throw Exception('No auth token available for Supabase sync');
      }

      log.i('Syncing identity with Supabase via Third-Party Auth...');
      
      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: tokenToUse,
      );
      
      log.i('Identity synced successfully in Supabase (Auth Session active)');
    } catch (e, stack) {
      log.e(
        'Error syncing user identity in Supabase: $e',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _createUserProfileIfNeeded() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final appUserId = await _resolveCurrentAppUserId();
      if (appUserId == null) {
        log.e('No app user id available after login');
        return;
      }

      log.i('Checking household membership for: $appUserId');
      final existing = await supabaseClient
          .from('household_members')
          .select('household_id')
          .eq('user_id', appUserId)
          .maybeSingle();

      if (existing != null) {
        log.i('User already belongs to household: ${existing['household_id']}');
        return;
      }

      log.i('Creating default household for user');
      final householdId = const Uuid().v4();
      await supabaseClient.from('households').insert({
        'id': householdId,
        'name': 'Mi Hogar',
        'household_type': 'couple',
      });

      await supabaseClient.from('household_members').insert({
        'household_id': householdId,
        'user_id': appUserId,
        'role': 'owner',
      });
      log.i('Household created successfully');
    } catch (e, stack) {
      log.e('Error in _createUserProfileIfNeeded: $e',
          error: e, stackTrace: stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();

      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e) {
          log.w('Error signing out from Google: $e');
        }
      }

      if (!AppEnvironment.usesFirebaseJwtForSupabase) {
        await Supabase.instance.client.auth.signOut();
      }
      await AppIdentityService.instance.refresh();

      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier('');
      }
      log.i('Session closed globally (Firebase + Supabase)');
    } catch (e) {
      log.e('Error signing out: $e', error: e);
    }
  }

  Future<void> ensureHouseholdExists() async {
    try {
      final supabaseClient = Supabase.instance.client;
      final appUserId = await _resolveCurrentAppUserId();
      if (appUserId == null) {
        log.w('ensureHouseholdExists: no app user id available yet');
        return;
      }

      final existing = await supabaseClient
          .from('household_members')
          .select('id')
          .eq('user_id', appUserId)
          .maybeSingle();

      if (existing != null) return;

      log.i('ensureHouseholdExists: creating profile and household');
      await _createUserProfileIfNeeded();
    } catch (e) {
      log.e('Error in ensureHouseholdExists: $e');
    }
  }

  fa.User? get currentUser => _auth.currentUser;

  Stream<fa.User?> get authStateChanges => _auth.idTokenChanges();

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  Future<void> _ensureProvisionedAccess() async {
    final appUserId = await _resolveCurrentAppUserId();
    if (appUserId != null && appUserId.isNotEmpty) {
      return;
    }

    await signOut();
    throw StateError(
      'La cuenta pudo autenticarse en Firebase, pero todavia no esta provisionada para HomeSync.',
    );
  }

  Future<String?> _resolveCurrentAppUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }

    final supabaseUser = Supabase.instance.client.auth.currentUser;
    return supabaseUser?.id;
  }
}
