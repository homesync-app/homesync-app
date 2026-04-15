import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import '../services/logger_service.dart';

class PremiumService {
  final InAppPurchase _iap = InAppPurchase.instance;
  final SupabaseClient _supabase;
  final AnalyticsService _analytics;

  // Real IDs in store (change later if needed)
  static const String _monthlyId = 'premium_monthly';
  static const String _yearlyId = 'premium_yearly';

  static final Set<String> _productIds = {_monthlyId, _yearlyId};

  StreamSubscription<List<PurchaseDetails>>? _subscription;

  // To update UI from outside
  final Function(bool isPremium)? onPremiumStatusChanged;

  PremiumService({
    required SupabaseClient supabase,
    required AnalyticsService analytics,
    this.onPremiumStatusChanged,
  })  : _supabase = supabase,
        _analytics = analytics;

  void initialize() {
    if (kIsWeb) {
      log.i('PremiumService: skipping IAP initialization on web');
      return;
    }

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

  Future<bool> getPremiumStatus() async {
    final userId = AppIdentityService.instance.currentUserId;
    if (userId == null) {
      return false;
    }

    try {
      final data = await _supabase
          .from('users')
          .select('is_premium')
          .eq('id', userId)
          .maybeSingle();

      return data != null && data['is_premium'] == true;
    } catch (e, stack) {
      log.e('Error fetching premium status: $e', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<List<ProductDetails>> getProducts() async {
    if (kIsWeb) {
      log.w('IAP products are not available on web');
      return [];
    }

    final bool available = await _iap.isAvailable();
    if (!available) {
      log.w('IAP not available on this device');
      return [];
    }

    final ProductDetailsResponse response =
        await _iap.queryProductDetails(_productIds);
    if (response.notFoundIDs.isNotEmpty) {
      log.w('IDs not found: ${response.notFoundIDs}');
    }

    return response.productDetails;
  }

  Future<void> buyProduct(ProductDetails product) async {
    if (kIsWeb) {
      throw UnsupportedError('In-app purchases are not supported on web');
    }

    await _analytics.trackPremiumPurchaseStarted(productId: product.id);
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

      final userId = AppIdentityService.instance.currentUserId;
      if (userId == null) return false;

      // Update Supabase
      // In a real app, this should be a backend function that verifies the store token
      await _supabase.from('users').update({
        'is_premium': true,
        'premium_until': purchase.status == PurchaseStatus.purchased
            ? DateTime.now()
                .add(const Duration(days: 30))
                .toIso8601String() // Simple mock logic for presentation
            : null,
      }).eq('id', userId);

      onPremiumStatusChanged?.call(true);
      log.i('Premium activated for user $userId');
      return true;
    } catch (e, stack) {
      log.e('Verification failed: $e', error: e, stackTrace: stack);
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (kIsWeb) {
      log.w('Restore purchases is not supported on web');
      return;
    }

    await _analytics.trackPremiumRestoreStarted();
    await _iap.restorePurchases();
  }

  Future<void> togglePremiumMock() async {
    final userId = AppIdentityService.instance.currentUserId;
    if (userId == null) {
      log.w('togglePremiumMock skipped: no authenticated user');
      return;
    }

    try {
      final current = await getPremiumStatus();
      final next = !current;
      await _supabase.from('users').update({
        'is_premium': next,
        'premium_until': next
            ? DateTime.now().add(const Duration(days: 30)).toIso8601String()
            : null,
      }).eq('id', userId);

      onPremiumStatusChanged?.call(next);
      log.i('Premium mock toggled for user $userId: $next');
    } catch (e, stack) {
      log.e('Error toggling premium mock: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  final service = PremiumService(
    supabase: ref.watch(supabaseClientProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
  service.initialize();
  return service;
});
