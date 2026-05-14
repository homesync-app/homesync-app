import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/providers/riverpod_retry.dart';

void main() {
  group('appRiverpodRetry', () {
    test('retries transient network failures with bounded backoff', () {
      expect(appRiverpodRetry(0, const NetworkFailure()), isNotNull);
      expect(
        appRiverpodRetry(
          0,
          const ServerFailure(
            'No se pudo establecer conexion con el servidor.',
          ),
        ),
        isNotNull,
      );
      expect(
        appRiverpodRetry(1, const ServerFailure('HTTP 503 unavailable')),
        isNotNull,
      );
      expect(
        appRiverpodRetry(2, const NetworkFailure()),
        isNull,
      );
    });

    test('does not retry business, auth, or validation failures', () {
      expect(
        appRiverpodRetry(0, const ValidationFailure('Monto invalido')),
        isNull,
      );
      expect(appRiverpodRetry(0, const AuthFailure()), isNull);
      expect(appRiverpodRetry(0, const HouseholdFailure()), isNull);
      expect(
        appRiverpodRetry(
          0,
          const InsufficientCoinsFailure(available: 1, required: 2),
        ),
        isNull,
      );
    });
  });
}
