import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_environment.dart';
import 'logger_service.dart';
import 'rpc/admin_rpc_service.dart';

class SupabaseAuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  late final SupabaseClient _client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: AppEnvironment.supabaseUrl,
      anonKey: AppEnvironment.supabaseAnonKey,
    );
    _client = Supabase.instance.client;

    // Inicializar GoogleSignIn con el Web Client ID (serverClientId)
    // Esto es necesario en google_sign_in v7+ para Credential Manager y Web.
    try {
      await GoogleSignIn.instance.initialize(
        clientId: kIsWeb ? '445710215227-go02kj7dh45nfk3q4fot1h8plo3csegu.apps.googleusercontent.com' : null,
        serverClientId: '445710215227-go02kj7dh45nfk3q4fot1h8plo3csegu.apps.googleusercontent.com',
      );
    } catch (e, stack) {
      log.e('Error inicializando GoogleSignIn: $e', error: e, stackTrace: stack);
      await AdminRpcService().logApplicationError(
        message: 'Error inicializando GoogleSignIn: $e',
        stackTrace: stack.toString(),
        level: 'warning',
      );
    }
  }

  SupabaseClient get client => _client;

  // Auth Methods

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
    String householdType = 'couple',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : {},
      );

      if (response.user != null) {
        await _createUserProfile(
            response.user!.id, email, fullName, householdType);
      }

      return response;
    } catch (e, stack) {
      log.e('Error en signUp: $e', error: e, stackTrace: stack);
      await AdminRpcService().logApplicationError(
        message: 'Error en signUp: $e',
        stackTrace: stack.toString(),
        context: {'email': email},
      );
      rethrow;
    }
  }

  Future<void> _createUserProfile(String userId, String email, String? fullName,
      String householdType) async {
    // 1. Generate household ID beforehand
    final householdId = const Uuid().v4();

    // 2. Insert household WITHOUT .select() (RLS restriction)
    await _client.from('households').insert({
      'id': householdId,
      'name': 'Mi Hogar',
      'household_type': householdType,
    });

    // 4. Assign user as owner
    await _client.from('household_members').insert({
      'household_id': householdId,
      'user_id': userId,
      'role': 'owner',
    });
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      // Tag user in Crashlytics (mobile only)
      if (response.user != null && !kIsWeb) {
        await FirebaseCrashlytics.instance.setUserIdentifier(response.user!.id);
      }
      return response;
    } catch (e, stack) {
      log.e('Error en signIn: $e', error: e, stackTrace: stack);
      await AdminRpcService().logApplicationError(
        message: 'Error en signIn: $e',
        stackTrace: stack.toString(),
        context: {'email': email},
      );
      rethrow;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // En Web, authenticate() no está soportado. Usamos OAuth directamente.
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: null,
        );
        return true;
      }

      // Flujo nativo para Android/iOS con google_sign_in
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      final googleUser = await googleSignIn.authenticate();
      
      if (googleUser != null) {
        // En esta versión authentication es un getter, no un Future.
        final googleAuth = googleUser.authentication;
        final idToken = googleAuth.idToken;

        if (idToken != null) {
          await _client.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
          );
          
          // Tag user in Crashlytics (mobile only)
          if (!kIsWeb) {
            final user = _client.auth.currentUser;
            if (user != null) {
              await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
            }
          }
          return true;
        }
      }

      // Fallback a OAuth
      log.w('Usando fallback de OAuth para Google Sign-In');
      
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'homesync://login-callback',
      );

      return true;
    } catch (e, stack) {
      final errorStr = e.toString().toLowerCase();
      // Ignores cancellations
      if (!errorStr.contains('canceled') &&
          !errorStr.contains('cancelled') &&
          !errorStr.contains('[16]')) {
        log.e('Error en Google Sign-In: $e', error: e, stackTrace: stack);
        await AdminRpcService().logApplicationError(
          message: 'Error en Google Sign-In: $e',
          stackTrace: stack.toString(),
          context: {'platform': kIsWeb ? 'web' : 'native'},
        );
      } else {
        log.i('Google Sign-In cancelado por el usuario o error ignorado [16]');
      }
      return false;
    }
  }

  Future<void> ensureHouseholdExists() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Check if already in a household
    try {
      final existing = await _client
          .from('household_members')
          .select('household_id')
          .eq('user_id', user.id)
          .maybeSingle();

      if (existing != null) return;

      // Create a new household
      final email = user.email ?? '';
      final fullName = user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String?;

      await _createUserProfile(user.id, email, fullName, 'couple');
    } catch (e, stack) {
      log.e('Error en ensureHouseholdExists: $e', error: e, stackTrace: stack);
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
    // Clear identity from Crashlytics (mobile only)
    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setUserIdentifier('');
    }
    await _client.auth.signOut();
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  Future<void> resetPasswordForEmail(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Session Management

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authState => _client.auth.onAuthStateChange;

  Future<bool> isAuthenticated() async {
    return _client.auth.currentUser != null;
  }

  // Token Management

  String? get accessToken => _client.auth.currentSession?.accessToken;

  Future<void> refreshSession() async {
    await _client.auth.refreshSession();
  }
}
