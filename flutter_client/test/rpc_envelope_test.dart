import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/core/errors/rpc_envelope.dart';

void main() {
  group('assertRpcEnvelopeSuccess', () {
    test('throws ServerFailure with the server message on success:false', () {
      expect(
        () => assertRpcEnvelopeSuccess(
          {'success': false, 'message': 'amount must be greater than 0'},
          fallbackMessage: 'fallback',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            'amount must be greater than 0',
          ),
        ),
      );
    });

    test('uses the fallback when the envelope has no usable message', () {
      expect(
        () => assertRpcEnvelopeSuccess(
          {'success': false, 'message': '   '},
          fallbackMessage: 'No se pudo registrar el equilibrio.',
        ),
        throwsA(
          isA<ServerFailure>().having(
            (f) => f.message,
            'message',
            'No se pudo registrar el equilibrio.',
          ),
        ),
      );
    });

    test('does not throw on success:true', () {
      expect(
        () => assertRpcEnvelopeSuccess(
          {'success': true, 'expense_id': 'abc'},
          fallbackMessage: 'fallback',
        ),
        returnsNormally,
      );
    });

    test('treats non-Map responses (bare uuid / null) as success', () {
      expect(
        () => assertRpcEnvelopeSuccess('a-uuid', fallbackMessage: 'fallback'),
        returnsNormally,
      );
      expect(
        () => assertRpcEnvelopeSuccess(null, fallbackMessage: 'fallback'),
        returnsNormally,
      );
    });
  });
}
