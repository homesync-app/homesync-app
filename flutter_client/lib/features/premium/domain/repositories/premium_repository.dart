import 'package:purchases_flutter/purchases_flutter.dart';

abstract class PremiumRepository {
  Future<bool> getPremiumStatus();
  Future<List<Package>> getProducts({required String offeringId});
  Future<bool> buyProduct(Package package);
  Future<bool> restorePurchases();
  Future<void> togglePremiumMock();
}
