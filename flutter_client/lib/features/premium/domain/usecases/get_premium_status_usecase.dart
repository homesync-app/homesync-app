import '../repositories/premium_repository.dart';

class GetPremiumStatusUseCase {
  final PremiumRepository _repository;

  const GetPremiumStatusUseCase(this._repository);

  Future<bool> call() {
    return _repository.getPremiumStatus();
  }
}
