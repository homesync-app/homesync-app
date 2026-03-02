import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_environment.dart';

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
    
    // Initialize GoogleSignIn for Web if needed
    try {
      if (kIsWeb) {
        await GoogleSignIn.instance.initialize();
      }
    } catch (e) {
      debugPrint('Error inicializando GoogleSignIn: $e');
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

    // 3. User is auto-inserted via database trigger "on_auth_user_created"
    
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
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Tag user in Crashlytics (mobile only)
    if (response.user != null && !kIsWeb) {
      await FirebaseCrashlytics.instance.setUserIdentifier(response.user!.id);
    }
    return response;
  }

  Future<bool> signInWithGoogle() async {
    try {
      // 1. Native flow with GoogleSignIn v7+
      final googleSignIn = GoogleSignIn.instance;
      
      // On Web/Chrome v7+ we use authenticate() instead of signIn()
      final googleUser = await googleSignIn.authenticate();
      if (googleUser == null) return false;

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;
      
      // Basic scopes for Supabase
      final authorization = await googleUser.authorizationClient.authorizeScopes(
        ['email', 'openid'],
      );
      final accessToken = authorization.accessToken;

      if (idToken != null) {
        await _client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
      } else {
        // 2. Fallback to OAuth if native flow doesn't return idToken
        await _client.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: 'homesync://login-callback',
        );
      }

      await ensureHouseholdExists();
      // Tag user in Crashlytics (mobile only)
      if (!kIsWeb) {
        final user = _client.auth.currentUser;
        if (user != null) {
          await FirebaseCrashlytics.instance.setUserIdentifier(user.id);
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error en Google Sign-In: $e');
      return false;
    }
  }

  Future<void> ensureHouseholdExists() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Check if already in a household
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
