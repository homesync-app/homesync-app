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
  }) async {
    try {
      final result = await action();
      return right(result);
    } on AuthException catch (e, stack) {
      log.w('$context: Auth Error - ${e.message}', error: e, stackTrace: stack);
      return left(AuthFailure(e.message));
    } on PostgrestException catch (e, stack) {
      log.w('$context: DB Error - ${e.message}', error: e, stackTrace: stack);
      // You can add more specific SQL error code handling here.
      return left(ServerFailure('Error en la base de datos: ${e.message}'));
    } on Exception catch (e, stack) {
      log.e('$context: Unexpected Exception - $e', error: e, stackTrace: stack);
      if (e.toString().contains('429') || e.toString().contains('rate limit')) {
        return left(
            const ServerFailure('Demasiadas solicitudes. Intentá en un rato.'));
      }
      return left(ServerFailure(
          'Ocurrió un error inesperado al procesar la solicitud.'));
    } catch (e, stack) {
      log.f('$context: Fatal Error - $e', error: e, stackTrace: stack);
      return left(ServerFailure('Ocurrió un error crítico inesperado.'));
    }
  }
}
