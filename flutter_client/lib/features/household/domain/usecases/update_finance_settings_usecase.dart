import 'package:fpdart/fpdart.dart';
import 'package:homesync_client/core/errors/failures.dart';
import 'package:homesync_client/features/household/domain/repositories/household_repository.dart';

class UpdateFinanceSettingsUseCase {
  final HouseholdRepository _repository;

  const UpdateFinanceSettingsUseCase(this._repository);

  Future<Either<Failure, void>> call(
    String householdId, {
    required String financeMode,
    required double defaultSplitRatio,
  }) {
    return _repository.updateFinanceSettings(
      householdId,
      financeMode: financeMode,
      defaultSplitRatio: defaultSplitRatio,
    );
  }
}
