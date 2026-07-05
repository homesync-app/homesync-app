import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/config/app_environment.dart';
import 'package:homesync_client/core/providers/service_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/logger_service.dart';

class PremiumService {
  static const String premiumEntitlementId = 'premium';

  final SupabaseClient _supabase;
  final AnalyticsService _analytics;

  bool _configured = false;
  String? _configuredAppUserId;

  PremiumService({
    required SupabaseClient supabase,
    required AnalyticsService analytics,
  })  : _supabase = supabase,
        _analytics = analytics;

  Future<bool> _ensureConfigured() async {
    if (kIsWeb) {
      log.i('PremiumService: RevenueCat is disabled on web');
      return false;
    }

    var userId = AppIdentityService.instance.currentUserId;
    userId ??= await AppIdentityService.instance.refresh();
    if (userId == null) {
      log.w('PremiumService: RevenueCat skipped, no app user id yet');
      return false;
    }

    final apiKey = switch (defaultTargetPlatform) {
      TargetPlatform.android => AppEnvironment.revenueCatAndroidPublicApiKey,
      TargetPlatform.iOS => AppEnvironment.revenueCatIosPublicApiKey,
      _ => '',
    };
    if (apiKey.isEmpty) {
      log.w('PremiumService: no RevenueCat API key for $defaultTargetPlatform');
      return false;
    }

    if (!_configured) {
      if (!AppEnvironment.isProduction) {
        await rc.Purchases.setLogLevel(rc.LogLevel.debug);
      }
      final configuration = rc.PurchasesConfiguration(apiKey)
        ..appUserID = userId;
      await rc.Purchases.configure(configuration);
      _configured = true;
      _configuredAppUserId = userId;
      log.i('RevenueCat configured for app user $userId');
      return true;
    }

    if (_configuredAppUserId != userId) {
      await rc.Purchases.logIn(userId);
      _configuredAppUserId = userId;
      log.i('RevenueCat logged in as app user $userId');
    }
    return true;
  }

  bool _hasPremium(rc.CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.containsKey(premiumEntitlementId);
  }

  Future<bool> getPremiumStatus() async {
    try {
      if (await _ensureConfigured()) {
        final customerInfo = await rc.Purchases.getCustomerInfo();
        if (_hasPremium(customerInfo)) return true;
      }
    } catch (e, stack) {
      log.w(
        'RevenueCat premium status failed, falling back to Supabase',
        error: e,
        stackTrace: stack,
      );
    }

    final userId = AppIdentityService.instance.currentUserId;
    if (userId == null) {
      return false;
    }

    try {
      final effective = await _supabase.rpc('get_effective_premium_status');
      if (effective is bool) return effective;
    } catch (e, stack) {
      log.w(
        'get_effective_premium_status failed, falling back to users.is_premium',
        error: e,
        stackTrace: stack,
      );
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

  Future<List<rc.Package>> getProducts({required String offeringId}) async {
    if (!await _ensureConfigured()) return [];

    final offerings = await rc.Purchases.getOfferings();
    final offering = offerings.getOffering(offeringId) ?? offerings.current;
    if (offering == null) {
      log.w('RevenueCat returned no offering for $offeringId');
      return [];
    }

    final packages = [...offering.availablePackages];
    packages.sort((a, b) {
      int rank(rc.Package package) {
        return switch (package.packageType) {
          rc.PackageType.annual => 0,
          rc.PackageType.monthly => 1,
          _ => 2,
        };
      }

      return rank(a).compareTo(rank(b));
    });
    return packages;
  }

  Future<bool> buyProduct(rc.Package package) async {
    if (!await _ensureConfigured()) {
      throw UnsupportedError('RevenueCat is not available on this platform');
    }

    await _analytics.trackPremiumPurchaseStarted(
      productId: package.storeProduct.identifier,
    );

    try {
      final result = await rc.Purchases.purchase(
        rc.PurchaseParams.package(package),
      );
      return _hasPremium(result.customerInfo);
    } on PlatformException catch (e, stack) {
      final code = rc.PurchasesErrorHelper.getErrorCode(e);
      if (code == rc.PurchasesErrorCode.purchaseCancelledError) {
        log.i('RevenueCat purchase cancelled by user');
        return false;
      }
      log.e('RevenueCat purchase failed: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<bool> restorePurchases() async {
    if (!await _ensureConfigured()) {
      log.w('Restore purchases skipped: RevenueCat unavailable');
      return false;
    }

    await _analytics.trackPremiumRestoreStarted();
    final customerInfo = await rc.Purchases.restorePurchases();
    if (_hasPremium(customerInfo)) return true;
    return getPremiumStatus();
  }

  Future<void> togglePremiumMock() async {
    if (AppEnvironment.isProduction) {
      throw UnsupportedError('Premium mock is disabled in production');
    }

    final userId = AppIdentityService.instance.currentUserId;
    if (userId == null) {
      log.w('togglePremiumMock skipped: no authenticated user');
      return;
    }

    try {
      final result = await _supabase.rpc('toggle_premium_mock');
      final next = result is Map && result['is_premium'] == true;
      log.i('Premium mock toggled for user $userId: $next');
    } catch (e, stack) {
      log.e('Error toggling premium mock: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService(
    supabase: ref.watch(supabaseClientProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});
