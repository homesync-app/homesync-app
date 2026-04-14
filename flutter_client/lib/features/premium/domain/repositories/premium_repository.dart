import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PremiumRepository {
  Future<bool> getPremiumStatus();
  Future<List<ProductDetails>> getProducts();
  Future<void> buyProduct(ProductDetails product);
  Future<void> restorePurchases();
  Future<void> togglePremiumMock();
}
