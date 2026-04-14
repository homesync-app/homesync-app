import '../repositories/premium_repository.dart';

class RestorePremiumPurchasesUseCase {
  final PremiumRepository _repository;

  const RestorePremiumPurchasesUseCase(this._repository);

  Future<void> call() {
    return _repository.restorePurchases();
  }
}
