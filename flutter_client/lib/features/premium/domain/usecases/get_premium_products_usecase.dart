import 'package:in_app_purchase/in_app_purchase.dart';

import '../repositories/premium_repository.dart';

class GetPremiumProductsUseCase {
  final PremiumRepository _repository;

  const GetPremiumProductsUseCase(this._repository);

  Future<List<ProductDetails>> call() {
    return _repository.getProducts();
  }
}
