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
      // Supabase interceptará automáticamente deep links con este host
      // para completar el flujo OAuth (Google Sign-In con browser).
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
    _client = Supabase.instance.client;
    // Firebase se inicializa en el main() antes de llamar a este método.
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

      // No creamos el hogar automáticamente aquí para permitir flujo de "Unirse" en SetupScreen
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
      if (!kIsWeb) {
        log.i('Google Sign-In: Intentando Auth Nativo con google_sign_in...');

        // El plugin google_sign_in lee automáticamente el client ID de google-services.json
        // en Android o de GoogleService-Info.plist en iOS. No necesitas pasar serverClientId
        // si tienes Firebase configurado porque usan los mismos archivos.
        final googleSignIn = GoogleSignIn();
        final googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          log.i('Google Sign-In cancelado por el usuario en flujo nativo.');
          return false;
        }

        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;

        if (accessToken == null || idToken == null) {
          final msg =
              'Google Sign-In: OAuth Token faltante tras auth nativa. idToken presente: ${idToken != null}, accessToken presente: ${accessToken != null}';
          log.e(msg);
          await AdminRpcService().logApplicationError(
              message: msg, level: 'error', context: {'platform': 'native'});
          // Si faltan tokens, forzamos el fallback web.
          throw Exception('Missing OAuth Token (posible problema de SHA-1)');
        }

        log.i('Google Sign-In: Tokens obtenidos. Enviando a Supabase...');
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        final user = _client.auth.currentUser;
        if (user != null) {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
          await ensureHouseholdExists();
        }
        return true;
      } else {
        // En Web usamos OAuth de Supabase directamente
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
        );
        return true;
      }
    } catch (e, stack) {
      final errorStr = e.toString().toLowerCase();

      // Cancelación del usuario — ignorar silenciosamente
      if (errorStr.contains('canceled') ||
          errorStr.contains('cancelled') ||
          errorStr.contains('sign_in_canceled') ||
          errorStr.contains('12501')) {
        log.i('Google Sign-In cancelado por el usuario');
        return false;
      }

      // IMPORTANTE: "no provider dependencies found" significa SHA-1 no registrado en Firebase/GCP.
      if (errorStr.contains('provider dependencies found') ||
          errorStr.contains('10')) {
        log.e('⚠️ SHA-1 RECHAZADO EN FIREBASE: $e');
        await AdminRpcService().logApplicationError(
          message:
              'Google Sign-In Bloqueado: SHA-1 inválido/faltante en Firebase (Error CredentialManager)',
          stackTrace: stack.toString(),
          level: 'critical',
          context: {
            'error': e.toString(),
            'action_required':
                'Eliminar app del proyecto Firebase viejo y agregar SHA-1 actual.'
          },
        );
      } else {
        log.w(
            'Fallo el login nativo de Google ($e). Intentando fallback OAuth...');
        await AdminRpcService().logApplicationError(
          message: 'Google Sign-In Nativo falló — usando fallback OAuth',
          stackTrace: stack.toString(),
          level: 'warning',
          context: {
            'error': e.toString(),
            'platform': kIsWeb ? 'web' : 'native'
          },
        );
      }

      // Intentar siempre el fallback usando el navegador IN-APP (mantiene al usuario en la app)
      try {
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'homesync://login-callback',
          authScreenLaunchMode: LaunchMode.inAppWebView, // UX más fluida
        );
        return false; // Retornamos false porque la sesión se establecerá vía deep link
      } catch (oauthError, oauthStack) {
        log.e('Error en fallback OAuth: $oauthError',
            error: oauthError, stackTrace: oauthStack);
        await AdminRpcService().logApplicationError(
          message: 'Error crítico en fallback OAuth: $oauthError',
          stackTrace: oauthStack.toString(),
          level: 'error',
          context: {'native_error': e.toString()},
        );
        return false;
      }
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
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
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
