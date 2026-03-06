import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import '../errors/failures.dart';
import 'logger_service.dart';

/// Mixin to wrap repository calls in a standardized error handler.
/// Centralizes the conversion of raw exceptions into typed Failures.
mixin RepositoryErrorHandler {
  Future<Either<Failure, T>> executeWithHandling<T>(
    Future<T> Function() action, {
    String context = 'Repository',
    bool? isOnline,
  }) async {
    // 1. Pre-fetch connectivity guard (Connectivity Guard rule)
    if (isOnline == false) {
      log.w('$context: Offline Guard - Refusing request while disconnected');
      return left(const NetworkFailure('Sin conexión a internet. Verificá tu red.'));
    }

    try {
      final result = await action();
      return right(result);
    } on AuthException catch (e, stack) {
      log.w('$context: Auth Error (Supabase) - ${e.message}', error: e, stackTrace: stack);
      return left(AuthFailure(e.message));
    } on fa.FirebaseAuthException catch (e, stack) {
      log.w('$context: Auth Error (Firebase) - [${e.code}] ${e.message}', error: e, stackTrace: stack);
      String userMessage = e.message ?? 'Error de autenticación';
      if (e.code == 'user-not-found') userMessage = 'Usuario no encontrado.';
      if (e.code == 'wrong-password') userMessage = 'Contraseña incorrecta.';
      if (e.code == 'email-already-in-use') userMessage = 'Este correo ya está registrado.';
      if (e.code == 'invalid-email') userMessage = 'Correo inválido.';
      if (e.code == 'weak-password') userMessage = 'La contraseña es muy débil.';
      return left(AuthFailure(userMessage));
    } on PostgrestException catch (e, stack) {
      log.w('$context: DB Error - ${e.message}', error: e, stackTrace: stack);
      return left(ServerFailure('Error en la base de datos: ${e.message}'));
    } on OfflineException {
      log.w('$context: Offline requested');
      return left(const NetworkFailure('No hay conexión a internet.'));
    } on NetworkException catch (e) {
      log.w('$context: Network issue - ${e.message}');
      return left(NetworkFailure('Error de red: ${e.message}'));
    } on Exception catch (e, stack) {
      log.e('$context: Unexpected Exception - $e', error: e, stackTrace: stack);
      final msg = e.toString();
      if (msg.contains('429') || msg.contains('rate limit')) {
        return left(const ServerFailure('Demasiadas solicitudes. Reintentá en un momento.'));
      }
      if (msg.contains('SocketException') || msg.contains('Connection refused') || msg.contains('Failed host lookup')) {
        return left(const NetworkFailure('No se pudo establecer conexión con el servidor.'));
      }
      return left(ServerFailure('Error inesperado: ${e.toString().split(':').last.trim()}'));
    } catch (e, stack) {
      log.f('$context: Fatal Error - $e', error: e, stackTrace: stack);
      return left(const ServerFailure('Ocurrió un error crítico inesperado.'));
    }
  }
}
