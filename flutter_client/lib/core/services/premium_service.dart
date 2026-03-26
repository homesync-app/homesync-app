import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/logger_service.dart';

class PremiumService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SupabaseClient _supabase = Supabase.instance.client;
  final Ref _ref;
  
  // Real IDs in store (change later if needed)
  static const String _monthlyId = 'premium_monthly';
  static const String _yearlyId = 'premium_yearly';
  
  static final Set<String> _productIds = { _monthlyId, _yearlyId };

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  
  // To update UI from outside
  final Function(bool isPremium)? onPremiumStatusChanged;

  PremiumService(this._ref, {this.onPremiumStatusChanged});

  void initialize() {
    final purchaseUpdated = _iap.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => log.e('IAP Error: $error'),
    );
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<List<ProductDetails>> getProducts() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      log.w('IAP not available on this device');
      return [];
    }

    final ProductDetailsResponse response = await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      log.w('IDs not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    // Non-consumables for subscriptions
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.pending) {
        log.i('Purchase pending: ${purchase.productID}');
      } else if (purchase.status == PurchaseStatus.error) {
        log.e('Purchase error: ${purchase.error}');
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.purchased || 
                 purchase.status == PurchaseStatus.restored) {
        
        final valid = await _verifyAndActivate(purchase);
        if (valid && purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
      }
    }
  }

  Future<bool> _verifyAndActivate(PurchaseDetails purchase) async {
    try {
      log.i('Verifying purchase ${purchase.productID}...');
      
      // Professional step: Verify current user
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Update Supabase
      // In a real app, this should be a backend function that verifies the store token
      await _supabase.from('users').update({
        'is_premium': true,
        'premium_until': purchase.status == PurchaseStatus.purchased 
            ? DateTime.now().add(const Duration(days: 30)).toIso8601String() // Simple mock logic for presentation
            : null,
      }).eq('id', user.id);

      onPremiumStatusChanged?.call(true);
      log.i('Premium activated for user ${user.id}');
      return true;
    } catch (e) {
      log.e('Verification failed: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final service = PremiumService(ref);
  service.initialize();
  return service;
});
