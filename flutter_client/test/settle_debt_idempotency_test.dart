// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — Settle Debt Idempotency Tests
// Validates the request_id contract for settleDebt:
//   1. The use case always passes a non-empty UUID v4 to the repo.
//   2. Two consecutive use case calls generate DIFFERENT request_ids
//      (so the server-side idempotency is what protects against double-tap,
//      not client-side dedup).
//   3. The use case rejects invalid inputs BEFORE generating a request_id,
//      so we don't waste a UUID on validation failures.
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
    test('generates a UUID v4 and forwards it to the repo', () async {
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
          reason: 'request_id must be a UUID v4 to play nice with the server',);
      expect(spy.calls.first.householdId, 'house-1');
      expect(spy.calls.first.fromUserId, 'user-a');
      expect(spy.calls.first.toUserId, 'user-b');
      expect(spy.calls.first.amount, 1500.0);
    });

    test('two consecutive calls generate different request_ids', () async {
      final spy = _SpyExpenseRepository();
      final useCase = SettleDebtUseCase(spy);

      await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
      );
      await useCase(
        householdId: 'house-1',
        fromUserId: 'user-a',
        toUserId: 'user-b',
        amount: 100.0,
      );

      expect(spy.callCount, 2);
      expect(
        spy.calls[0].requestId == spy.calls[1].requestId,
        isFalse,
        reason: 'Each use case invocation must produce a fresh request_id; '
            'server-side idempotency handles the double-tap case.',
      );
      expect(_isUuidV4(spy.calls[0].requestId), isTrue);
      expect(_isUuidV4(spy.calls[1].requestId), isTrue);
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
