import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';

import '../models/feed_item_model.dart';

class GetCombinedFeedUseCase {
  final ExpenseRepository _repository;

  GetCombinedFeedUseCase(this._repository);

  Future<Either<Failure, List<FeedItemModel>>> call(String householdId) async {
    if (householdId.isEmpty) {
      return left(
        const ValidationFailure('El ID del hogar no puede estar vacío'),
      );
    }
    return await _repository.getCombinedFeed(householdId);
  }
}
