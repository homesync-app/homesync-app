import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/failures.dart';
import 'logger_service.dart';

/// Mixin to wrap repository calls in a standardized error handler.
/// Centralizes the conversion of raw exceptions into typed Failures.
mixin RepositoryErrorHandler {
  Future<Either<Failure, T>> executeWithHandling<T>(
    Future<T> Function() action, {
    String context = 'Repository',
    bool? isOnline,
    Future<T> Function()? onOffline,
  }) async {
    if (isOnline == false) {
      if (onOffline != null) {
        try {
          log.i('$context: Offline queueing/fallback action');
          final offlineResult = await onOffline();
          return right(offlineResult);
        } catch (e, stack) {
          log.w(
            '$context: Offline action failed - $e',
            error: e,
            stackTrace: stack,
          );
          return left(const NetworkFailure('Sin conexion a internet.'));
        }
      }
      log.w('$context: Offline Guard - Refusing request while disconnected');
      return left(const NetworkFailure('Sin conexion a internet. Verifica tu red.'));
    }

    try {
      final result = await action();
      return right(result);
    } on AuthException catch (e, stack) {
      log.w(
        '$context: Auth Error (Supabase) - ${e.message}',
        error: e,
        stackTrace: stack,
      );
      return left(AuthFailure(e.message));
    } on fa.FirebaseAuthException catch (e, stack) {
      log.w(
        '$context: Auth Error (Firebase) - [${e.code}] ${e.message}',
        error: e,
        stackTrace: stack,
      );
      String userMessage = e.message ?? 'Error de autenticacion';
      if (e.code == 'user-not-found') userMessage = 'Usuario no encontrado.';
      if (e.code == 'wrong-password') userMessage = 'Contrasena incorrecta.';
      if (e.code == 'email-already-in-use') {
        userMessage = 'Este correo ya esta registrado.';
      }
      if (e.code == 'invalid-email') userMessage = 'Correo invalido.';
      if (e.code == 'weak-password') {
        userMessage = 'La contrasena es muy debil.';
      }
      return left(AuthFailure(userMessage));
    } on PostgrestException catch (e, stack) {
      log.w('$context: DB Error - ${e.message}', error: e, stackTrace: stack);
      return left(ServerFailure('Error en la base de datos: ${e.message}'));
    } on OfflineException {
      if (onOffline != null) {
        try {
          log.i('$context: Offline exception queued/fallback');
          final offlineResult = await onOffline();
          return right(offlineResult);
        } catch (e, stack) {
          log.w(
            '$context: Offline action failed after exception - $e',
            error: e,
            stackTrace: stack,
          );
          return left(const NetworkFailure('No hay conexion a internet.'));
        }
      }
      log.w('$context: Offline requested');
      return left(const NetworkFailure('No hay conexion a internet.'));
    } on NetworkException catch (e, stack) {
      log.w(
        '$context: Network issue - ${e.message}',
        error: e,
        stackTrace: stack,
      );
      return left(NetworkFailure('Error de red: ${e.message}'));
    } on Exception catch (e, stack) {
      log.e('$context: Unexpected Exception - $e', error: e, stackTrace: stack);
      final msg = e.toString();
      if (msg.contains('429') || msg.contains('rate limit')) {
        return left(
          const ServerFailure('Demasiadas solicitudes. Reintenta en un momento.'),
        );
      }
      if (msg.contains('SocketException') ||
          msg.contains('Connection refused') ||
          msg.contains('Failed host lookup')) {
        if (onOffline != null) {
          try {
            log.i('$context: SocketException mapped to offline fallback');
            final offlineResult = await onOffline();
            return right(offlineResult);
          } catch (fallbackError, fallbackStack) {
            log.w(
              '$context: Offline fallback failed after SocketException - $fallbackError',
              error: fallbackError,
              stackTrace: fallbackStack,
            );
            return left(
              const NetworkFailure('No se pudo establecer conexion. (Sin cache)'),
            );
          }
        }
        return left(
          const NetworkFailure('No se pudo establecer conexion con el servidor.'),
        );
      }
      return left(
        ServerFailure('Error inesperado: ${e.toString().split(':').last.trim()}'),
      );
    } catch (e, stack) {
      log.f('$context: Fatal Error - $e', error: e, stackTrace: stack);
      return left(const ServerFailure('Ocurrio un error critico inesperado.'));
    }
  }
}
