import 'package:homesync_client/core/services/premium_service.dart';
import 'package:homesync_client/features/premium/domain/repositories/premium_repository.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PremiumServiceRepository implements PremiumRepository {
  final PremiumService _service;

  PremiumServiceRepository(this._service);

  @override
  Future<bool> buyProduct(Package package) {
    return _service.buyProduct(package);
  }

  @override
  Future<List<Package>> getProducts({required String offeringId}) {
    return _service.getProducts(offeringId: offeringId);
  }

  @override
  Future<bool> getPremiumStatus() {
    return _service.getPremiumStatus();
  }

  @override
  Future<bool> restorePurchases() {
    return _service.restorePurchases();
  }

  @override
  Future<void> togglePremiumMock() {
    return _service.togglePremiumMock();
  }
}
