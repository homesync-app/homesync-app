import 'package:purchases_flutter/purchases_flutter.dart';

import '../repositories/premium_repository.dart';

class BuyPremiumProductUseCase {
  final PremiumRepository _repository;

  const BuyPremiumProductUseCase(this._repository);

  Future<bool> call(Package package) {
    return _repository.buyProduct(package);
  }
}
