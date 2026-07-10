// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Settle Debt Idempotency Tests
// Validates the request_id contract for settleDebt:
//   1. With no requestId, the use case mints a fallback UUID v4 and forwards it.
//   2. A caller-provided requestId is forwarded UNCHANGED, and reused verbatim
//      across retries — this is what makes server-side idempotency actually
//      protect the retry-after-timeout case (the key must be per-intent, not
//      per-call).
//   3. The use case rejects invalid inputs BEFORE touching the repo.
//   4. A repo that returns Left propagates that failure cleanly.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/domain/usecases/settle_debt_usecase.dart';

class _SpyExpenseRepository implements ExpenseRepository {
  final List<({String requestId, String householdId, String fromUserId, String toUserId, double amount})> calls = [];
  final Either<Failure, void> Function() responder;
  int callCount = 0;

  _SpyExpenseRepository({Either<Failure, void> Function()? responder})
      : responder = responder ?? (() => const Right<Failure, void>(null));

  @override
  Future<Either<Failure, void>> settleDebt({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    required String requestId,
    String? poolId,
  }) async {
    callCount++;
    calls.add((
      requestId: requestId,
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
    ),);
    return responder();
  }

  @override
  noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('Stubbed repo missing: ${invocation.memberName}');
}

bool _isUuidV4(String value) {
  final regex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );
  return regex.hasMatch(value);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettleDebtUseCase', () {
    test('mints a fallback UUID v4 when no requestId is provided', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);

      final result = await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 1500.0,
      );

      expect(result.isRight(), isTrue);
      expect(spy.callCount, 1);
      expect(spy.calls.first.requestId, isNotEmpty);
      expect(_isUuidV4(spy.calls.first.requestId), isTrue,
          reason: 'fallback request_id must be a UUID v4',);
      expect(spy.calls.first.householdId, 'house-1');
      expect(spy.calls.first.fromUserId, 'user-a');
      expect(spy.calls.first.toUserId, 'user-b');
      expect(spy.calls.first.amount, 1500.0);
    });

    test('forwards a caller-provided requestId unchanged', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);
      const intentKey = 'fixed-intent-key-123';

      final result = await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
        requestId: intentKey,
      );

      expect(result.isRight(), isTrue);
      expect(spy.calls.single.requestId, intentKey);
    });

    test('reuses the same requestId across retries of one intent', () async {
      // A failed first attempt followed by a retry must carry the SAME key, so
      // the server resolves both to a single settlement instead of duplicating.
      var first = true;
      final spy = _SpyExpenseRepository(
        responder: () {
          if (first) {
            first = false;
            return const Left<Failure, void>(ServerFailure('timeout'));
          }
          return const Right<Failure, void>(null);
        },
      );
      final useCase = SettleDebtUseCase(spy);
      const intentKey = 'retry-intent-key-abc';

      await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
        requestId: intentKey,
      );
      await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
        requestId: intentKey,
      );

      expect(spy.callCount, 2);
      expect(spy.calls[0].requestId, intentKey);
      expect(spy.calls[1].requestId, intentKey,
          reason: 'retries of the same intent must reuse the same key',);
    });

    test('rejects empty householdId without touching the repo', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);

      final result = await useCase(
        householdId: '',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected a Left<ValidationFailure>'),
      );
      expect(spy.callCount, 0);
    });

    test('rejects empty toUserId without touching the repo', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);

      final result = await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: '',
        amount: 100.0,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ValidationFailure>()),
        (_) => fail('Expected a Left<ValidationFailure>'),
      );
      expect(spy.callCount, 0);
    });

    test('rejects non-positive amount without touching the repo', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);

      for (final bad in [0.0, -1.0, -500.0]) {
        final result = await useCase(
          householdId: 'house-1',
          fromUserId: 'user-a',
          toUserId: 'user-b',
          amount: bad,
        );

        expect(result.isLeft(), isTrue,
            reason: 'Amount $bad must be rejected',);
      }
      expect(spy.callCount, 0,
          reason: 'No repo call should happen on validation failure',);
    });

    test('propagates repo failures via Left', () async {
      final spy = _SpyExpenseRepository(
        responder: () => const Left<Failure, void>(
          ServerFailure('Settle RPC down'),
        ),
      );
      final useCase = SettleDebtUseCase(spy);

      final result = await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, 'Settle RPC down'),
        (_) => fail('Expected Left with ServerFailure'),
      );
      // request_id was generated and passed through, so the server still
      // gets called and can record the attempt in audit_logs.
      expect(spy.callCount, 1);
      expect(_isUuidV4(spy.calls.first.requestId), isTrue);
    });
  });
}
