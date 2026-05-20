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
          log.i('$context: Offline action failed - $e');
          log.d('Stack: $stack');
          return left(const NetworkFailure('Sin conexion a internet.'));
        }
      }
      log.i('$context: Offline Guard - Refusing request while disconnected');
      return left(
        const NetworkFailure('Sin conexion a internet. Verifica tu red.'),
      );
    }

    try {
      final result = await action();
      return right(result);
    } on Failure catch (e, stack) {
      // log.i: las Failure ya son resultados esperados del dominio (mostradas
      // al usuario como snackbar/UI). No es ruido reportable a Crashlytics.
      log.i('$context: Domain Failure - ${e.message}');
      log.d('Stack: $stack');
      return left(e);
    } on AuthException catch (e, stack) {
      log.i('$context: Auth Error (Supabase) - ${e.message}');
      log.d('Stack: $stack');
      return left(AuthFailure(e.message));
    } on fa.FirebaseAuthException catch (e, stack) {
      // Errores conocidos de Firebase Auth = flujo válido, no ruido.
      log.i('$context: Auth Error (Firebase) - [${e.code}] ${e.message}');
      log.d('Stack: $stack');
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
      // RLS (42501), 406, 409, etc. son del dominio del negocio: el caller
      // los mapea a UI. No los enviamos a Crashlytics — antes inflaban issues
      // como 68638317 (rewards RLS) y 8dc90b97 (user_feedback RLS).
      log.i('$context: DB Error - [${e.code}] ${e.message}');
      log.d('Stack: $stack');
      return left(ServerFailure('Error en la base de datos: ${e.message}'));
    } on OfflineException {
      if (onOffline != null) {
        try {
          log.i('$context: Offline exception queued/fallback');
          final offlineResult = await onOffline();
          return right(offlineResult);
        } catch (e, stack) {
          // Sin red Y sin cache: log.i porque es expected en flujo offline.
          log.i('$context: Offline fallback also failed - $e');
          log.d('Stack: $stack');
          return left(const NetworkFailure('No hay conexion a internet.'));
        }
      }
      log.i('$context: Offline requested');
      return left(const NetworkFailure('No hay conexion a internet.'));
    } on NetworkException catch (e, stack) {
      // Sin red es estado esperado, no warning. log.i lo deja en la consola
      // pero no lo manda a Crashlytics.
      log.i('$context: Network issue - ${e.message}');
      log.d('Stack: $stack');
      return left(NetworkFailure('Error de red: ${e.message}'));
    } on Exception catch (e, stack) {
      // Excepción NO categorizada — sí es algo que necesitamos ver.
      log.e('$context: Unexpected Exception - $e', error: e, stackTrace: stack);
      final msg = e.toString();
      if (msg.contains('429') || msg.contains('rate limit')) {
        return left(
          const ServerFailure(
            'Demasiadas solicitudes. Reintenta en un momento.',
          ),
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
              const NetworkFailure(
                'No se pudo establecer conexion. (Sin cache)',
              ),
            );
          }
        }
        return left(
          const NetworkFailure(
            'No se pudo establecer conexion con el servidor.',
          ),
        );
      }
      return left(
        ServerFailure(
          'Error inesperado: ${e.toString().split(':').last.trim()}',
        ),
      );
    } catch (e, stack) {
      log.f('$context: Fatal Error - $e', error: e, stackTrace: stack);
      return left(const ServerFailure('Ocurrio un error critico inesperado.'));
    }
  }
}
