import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:homesync_client/core/services/premium_service.dart';
import 'package:homesync_client/features/premium/domain/repositories/premium_repository.dart';

class PremiumServiceRepository implements PremiumRepository {
  final PremiumService _service;

  PremiumServiceRepository(this._service);

  @override
  Future<void> buyProduct(ProductDetails product) {
    return _service.buyProduct(product);
  }

  @override
  Future<List<ProductDetails>> getProducts() {
    return _service.getProducts();
  }

  @override
  Future<bool> getPremiumStatus() {
    return _service.getPremiumStatus();
  }

  @override
  Future<void> restorePurchases() {
    return _service.restorePurchases();
  }

  @override
  Future<void> togglePremiumMock() {
    return _service.togglePremiumMock();
  }
}
