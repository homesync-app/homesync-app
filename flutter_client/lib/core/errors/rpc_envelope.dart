import 'failures.dart';

/// Throws a [ServerFailure] when a Postgres RPC returns a `{success: false}`
/// jsonb envelope.
///
/// Several finance RPCs (`settle_debt_v1`, `pay_planned_expense`,
/// `complete_couple_challenge_v1`, …) signal logical rejections by RETURNING
/// `{success: false, message: ...}` instead of raising. A caller that ignores
/// the response would silently treat a rejection (e.g. "amount must be greater
/// than 0") as success. Run every such RPC's result through this guard.
///
/// Non-Map responses (a bare UUID, a row set, `null`) are treated as success —
/// those RPCs surface failure by raising, which the repository error handler
/// already maps to a [Failure].
void assertRpcEnvelopeSuccess(
  Object? response, {
  required String fallbackMessage,
}) {
  if (response is Map && response['success'] == false) {
    final message = response['message'];
    throw ServerFailure(
      message is String && message.trim().isNotEmpty ? message : fallbackMessage,
    );
  }
}
