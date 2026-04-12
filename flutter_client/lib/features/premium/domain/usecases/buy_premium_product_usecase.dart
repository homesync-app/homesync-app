import 'package:in_app_purchase/in_app_purchase.dart';

import '../repositories/premium_repository.dart';

class BuyPremiumProductUseCase {
  final PremiumRepository _repository;

  const BuyPremiumProductUseCase(this._repository);

  Future<void> call(ProductDetails product) {
    return _repository.buyProduct(product);
  }
}
