import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/errors/failures.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('returns the domain message for a Failure (no runtimeType prefix)', () {
      const failure = ServerFailure('Error en la base de datos: detalle');
      expect(friendlyErrorMessage(failure), 'Error en la base de datos: detalle');
      // Must NOT leak the "ServerFailure: " prefix that toString() would add.
      expect(friendlyErrorMessage(failure), isNot(contains('ServerFailure')));
    });

    test('never surfaces a raw Riverpod dispose stack trace', () {
      final raw = Exception(
        'Cannot use the Ref of expenseControllerProvider after it has been '
        'disposed. This typically happens if: ...',
      );
      final msg = friendlyErrorMessage(raw);
      expect(msg, kGenericErrorMessage);
      expect(msg, isNot(contains('Ref')));
      expect(msg, isNot(contains('disposed')));
    });

    test('maps connectivity errors to a friendly network message', () {
      expect(
        friendlyErrorMessage(const NetworkException('boom')),
        contains('conexión'),
      );
      expect(
        friendlyErrorMessage(Exception('SocketException: Failed host lookup')),
        contains('servidor'),
      );
    });

    test('maps rate limiting to a retry message', () {
      expect(
        friendlyErrorMessage(Exception('HTTP 429 too many requests')),
        contains('Reintentá'),
      );
    });

    test('falls back to the generic message for unknown errors and null', () {
      expect(friendlyErrorMessage(Exception('weird internal thing')),
          kGenericErrorMessage);
      expect(friendlyErrorMessage(null), kGenericErrorMessage);
    });

    test('uses a blank Failure message fallback', () {
      expect(friendlyErrorMessage(const ServerFailure('   ')),
          kGenericErrorMessage);
    });
  });
}
