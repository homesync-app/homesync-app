import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:uuid/uuid.dart';

/// Settles an accumulated balance between two members.
///
/// Idempotency contract: [ExpenseRepository.settleDebt] is keyed by a
/// `request_id`. To actually protect against duplicates on retry (e.g. a retry
/// after an ambiguous network timeout), that key must be minted ONCE per
/// settlement *intent* and reused across attempts. Callers that can retry
/// should therefore pass a stable [requestId]; we only mint a fresh one as a
/// fallback for one-shot callers.
///
/// Note: the production path is `ExpenseController.settleDebt` (the UI talks to
/// the provider, which owns a per-intent [requestId]). This use case mirrors the
/// same contract so it stays correct if it is ever wired in.
class SettleDebtUseCase {
  final ExpenseRepository _repository;

  SettleDebtUseCase(this._repository);

  Future<Either<Failure, void>> call({
    required String householdId,
    required String fromUserId,
    required String toUserId,
    required double amount,
    String? requestId,
  }) async {
    if (householdId.isEmpty) {
      return left(
          const ValidationFailure('El ID del hogar no puede estar vacío'),);
    }
    if (toUserId.isEmpty) {
      return left(
          const ValidationFailure('El usuario destino no puede estar vacío'),);
    }
    if (amount <= 0) {
      return left(
          const ValidationFailure('El monto a saldar debe ser mayor a 0'),);
    }

    // Reuse the caller's per-intent key when provided; mint a fallback only for
    // one-shot callers that cannot retry.
    final effectiveRequestId = requestId ?? const Uuid().v4();

    return await _repository.settleDebt(
      householdId: householdId,
      fromUserId: fromUserId,
      toUserId: toUserId,
      amount: amount,
      requestId: effectiveRequestId,
    );
  }
}
