import 'package:purchases_flutter/purchases_flutter.dart';

import '../repositories/premium_repository.dart';

class GetPremiumProductsUseCase {
  final PremiumRepository _repository;

  const GetPremiumProductsUseCase(this._repository);

  Future<List<Package>> call({required String offeringId}) {
    return _repository.getProducts(offeringId: offeringId);
  }
}
