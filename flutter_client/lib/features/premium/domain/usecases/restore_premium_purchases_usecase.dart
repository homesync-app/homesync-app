import '../repositories/premium_repository.dart';

class RestorePremiumPurchasesUseCase {
  final PremiumRepository _repository;

  const RestorePremiumPurchasesUseCase(this._repository);

  Future<bool> call() {
    return _repository.restorePurchases();
  }
}
