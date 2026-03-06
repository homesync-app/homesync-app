import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'logger_service.dart';
import 'rpc/admin_rpc_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';

class FirebaseAuthService {
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  final fa.FirebaseAuth _auth = fa.FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;

  fa.FirebaseAuth get auth => _auth;

  Future<void> _ensureInitialized() async {
    if (_googleSignIn == null) {
      _googleSignIn = GoogleSignIn.instance;
      
      await _googleSignIn!.initialize(
        clientId: kIsWeb ? null : '105041112830-i79qb8avlvfv38reurc3aa9hnti1k8vv.apps.googleusercontent.com',
        serverClientId: '105041112830-75q9ubotcf7i51cu8u9v9l9j1m6sdcga.apps.googleusercontent.com',
      );
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _ensureInitialized();
      
      final googleSignIn = _googleSignIn!;
      
      // For web, use OAuth flow through Supabase directly (recommended for web)
      if (kIsWeb) {
        log.i('Firebase Auth: Delegating Google login to Supabase for web');
        final supabaseClient = Supabase.instance.client;
        await supabaseClient.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: kIsWeb ? Uri.base.origin : null,
        );
        return true;
      }
      
      // For mobile, use native authenticate() (replaces signIn() in v7)
      GoogleSignInAccount? googleUser;
      try {
        await _ensureInitialized();
        googleUser = await _googleSignIn!.authenticate();
      } catch (e) {
        log.e('Google Sign-In error: $e', error: e);
        return false;
      }

      if (googleUser == null) return false;

      // In v7, authentication is a synchronous getter on the account
      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        log.e('Google Sign-In: No idToken obtained');
        return false;
      }

      final credential = fa.GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final fa.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final fa.User? user = userCredential.user;

      if (user != null) {
        log.i('Firebase Auth: Usuario logueado con Google: ${user.email}');
        
        if (!kIsWeb) {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
        }
        
        // Sync with Supabase using the raw Google ID Token
        await _syncSupabaseSessionWithFirebase(idToken: idToken);
        
        await _createUserProfileIfNeeded();
        log.i('Firebase Auth: signInWithGoogle finalizado con éxito.');
        return true;
      }
      
      return false;
    } catch (e, stack) {
      log.e('Firebase Auth Error (Google): $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> signInWithEmail({required String email, required String password}) async {
    try {
      final fa.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        log.i('Firebase Auth: Usuario logueado con Email: ${user.email}');
        
        if (!kIsWeb) {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
        }
        
        // Sync with Supabase using Firebase ID Token (requires Firebase to be configured as provider in Supabase)
        await _syncSupabaseSessionWithFirebase();
        
        await _createUserProfileIfNeeded();
        return true;
      }
      return false;
    } catch (e, stack) {
      log.e('Firebase Auth Error (Email): $e', error: e, stackTrace: stack);
      // Ensure we sign out from Firebase if sync fails to avoid inconsistent state
      await _auth.signOut();
      rethrow;
    }
  }

  Future<bool> signUpWithEmail({required String email, required String password}) async {
    try {
      final fa.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = userCredential.user;
      if (user != null) {
        log.i('Firebase Auth: Usuario registrado: ${user.email}');
        
        if (!kIsWeb) {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.uid);
        }
        
        // Sync with Supabase
        await _syncSupabaseSessionWithFirebase();
        
        await _createUserProfileIfNeeded();
        return true;
      }
      return false;
    } catch (e, stack) {
      log.e('Firebase Auth Error (SignUp): $e', error: e, stackTrace: stack);
      // Ensure we sign out from Firebase if sync fails
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      log.i('Firebase Auth: Email de reseteo enviado a $email');
    } catch (e) {
      log.e('Error enviando reseteo a $email: $e', error: e);
      rethrow;
    }
  }

  Future<void> _syncSupabaseSessionWithFirebase({String? idToken}) async {
    try {
      // Use provided token (e.g. Google ID Token) or fallback to Firebase ID Token
      final tokenToUse = idToken ?? await _auth.currentUser?.getIdToken();
      
      if (tokenToUse == null) {
        log.w('No se pudo obtener un token para sincronizar Supabase');
        throw Exception('No auth token available for Supabase sync');
      }

      log.i('Sincronizando con Supabase usando Token (${idToken != null ? "Google" : "Firebase"})...');
      
      final supabaseClient = Supabase.instance.client;
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: tokenToUse,
      );
      
      if (response.user != null) {
        log.i('💡 Sesión de Supabase sincronizada para: ${response.user!.email}');
      } else {
        log.w('Supabase sync finished but no user returned');
      }
    } catch (e, stack) {
      log.e('Error sincronizando sesión en Supabase: $e', error: e, stackTrace: stack);
      rethrow; 
    }
  }

  Future<void> _createUserProfileIfNeeded() async {
    try {
      final supabaseClient = Supabase.instance.client;
      
      // Get the Supabase user (after session sync)
      final supabaseUser = supabaseClient.auth.currentUser;
      
      if (supabaseUser == null) {
        log.e('No Supabase user found after session sync');
        return;
      }
      
      log.i('Verificando membresía de hogar para: ${supabaseUser.id}');
      
      final existing = await supabaseClient
          .from('household_members')
          .select('household_id')
          .eq('user_id', supabaseUser.id)
          .maybeSingle();

      if (existing != null) {
        log.i('Usuario ya pertenece a un hogar: ${existing['household_id']}');
        return;
      }

      log.i('Creando nuevo hogar por defecto para el usuario...');
      final householdId = const Uuid().v4();
      
      await supabaseClient.from('households').insert({
        'id': householdId,
        'name': 'Mi Hogar',
        'household_type': 'couple',
      });

      await supabaseClient.from('household_members').insert({
        'household_id': householdId,
        'user_id': supabaseUser.id,
        'role': 'owner',
      });
      log.i('Hogar creado exitosamente.');
    } catch (e, stack) {
      log.e('Error en _createUserProfileIfNeeded: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> signOut() async {
    try {
      // 1. Firebase Sign Out
      await _auth.signOut();
      
      // 2. Google Sign Out (Native)
      if (!kIsWeb) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e) {
          log.w('Error signing out from Google: $e');
        }
      }
      
      // 3. Supabase Sign Out (Vital para limpiar sesión sincronizada)
      await Supabase.instance.client.auth.signOut();

      if (!kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier('');
      }
      log.i('Sesión cerrada globalmente (Firebase + Supabase)');
    } catch (e) {
      log.e('Error signing out: $e', error: e);
    }
  }

  fa.User? get currentUser => _auth.currentUser;

  Stream<fa.User?> get authStateChanges => _auth.authStateChanges();

  Future<bool> isAuthenticated() async {
    return _auth.currentUser != null;
  }

  Future<String?> getIdToken() async {
    return await _auth.currentUser?.getIdToken();
  }

  Future<void> _signInWithSupabaseOAuth() async {
    final supabaseClient = Supabase.instance.client;
    await supabaseClient.auth.signInWithOAuth(
      OAuthProvider.google,
    );
  }
}
