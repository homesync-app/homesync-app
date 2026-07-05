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

  /// IDs de los productos de suscripción premium (todos los planes de la app
  /// son premium). Sirven de red de seguridad: si el entitlement `premium` no
  /// está mapeado en el dashboard de RevenueCat, una suscripción activa a
  /// cualquiera de estos igual cuenta como premium.
  static const Set<String> premiumProductIds = {
    'premium_solo',
    'premium_household',
    'premium_family',
  };

  /// True si el usuario es premium según RevenueCat. Acepta el entitlement
  /// `premium` (camino normal) O una suscripción activa a un producto premium
  /// conocido (robusto ante un entitlement mal configurado en el dashboard).
  static bool customerInfoHasPremium(rc.CustomerInfo customerInfo) {
    if (customerInfo.entitlements.active.containsKey(premiumEntitlementId)) {
      return true;
    }
    // `activeSubscriptions` trae ids con o sin sufijo de base plan; comparar
    // por prefijo cubre 'premium_household:annual' y similares.
    return customerInfo.activeSubscriptions.any(
      (sub) => premiumProductIds.any((id) => sub.startsWith(id)),
    );
  }

  bool _hasPremium(rc.CustomerInfo customerInfo) =>
      customerInfoHasPremium(customerInfo);

  Future<bool> getPremiumStatus() async =>
      (await getPremiumStatusSnapshot()).isPremium;

  /// Status premium con nivel de confianza: [PremiumStatusSnapshot.isConfirmed]
  /// solo es true cuando las fuentes consultadas RESPONDIERON (sin
  /// excepciones). Un `false` no confirmado (RevenueCat caido, RPC caido)
  /// no debe disparar acciones destructivas como revertir el avatar premium.
  Future<PremiumStatusSnapshot> getPremiumStatusSnapshot() async {
    var sourcesAnswered = true;

    try {
      // _ensureConfigured() == false (sin API key / sin usuario) no es un
      // error: en esa plataforma la DB es la unica fuente de verdad.
      if (await _ensureConfigured()) {
        final customerInfo = await rc.Purchases.getCustomerInfo();
        if (_hasPremium(customerInfo)) {
          return const PremiumStatusSnapshot(
            isPremium: true,
            isConfirmed: true,
          );
        }
        // Diagnostico: hay compra pero no el entitlement esperado => casi
        // seguro el producto no esta vinculado al entitlement 'premium' en
        // el dashboard de RevenueCat (o el fallback de plan_tier no corrio).
        if (customerInfo.activeSubscriptions.isNotEmpty ||
            customerInfo.entitlements.active.isNotEmpty) {
          log.e(
            'RevenueCat: subs activas sin entitlement "$premiumEntitlementId" '
            '(entitlements=${customerInfo.entitlements.active.keys.toList()} '
            'subs=${customerInfo.activeSubscriptions})',
          );
        }
      }
    } catch (e, stack) {
      sourcesAnswered = false;
      log.w(
        'RevenueCat premium status failed, falling back to Supabase',
        error: e,
        stackTrace: stack,
      );
    }

    final userId = AppIdentityService.instance.currentUserId;
    if (userId == null) {
      return const PremiumStatusSnapshot(isPremium: false, isConfirmed: false);
    }

    try {
      final effective = await _supabase.rpc('get_effective_premium_status');
      if (effective is bool) {
        return PremiumStatusSnapshot(
          isPremium: effective,
          isConfirmed: sourcesAnswered,
        );
      }
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

      return PremiumStatusSnapshot(
        isPremium: data != null && data['is_premium'] == true,
        isConfirmed: sourcesAnswered,
      );
    } catch (e, stack) {
      log.e('Error fetching premium status: $e', error: e, stackTrace: stack);
      return const PremiumStatusSnapshot(isPremium: false, isConfirmed: false);
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

/// Resultado de la consulta de status premium.
class PremiumStatusSnapshot {
  final bool isPremium;

  /// true solo si todas las fuentes consultadas respondieron sin errores.
  /// Un `false` con isConfirmed=false es "no sabemos", no "no es premium".
  final bool isConfirmed;

  const PremiumStatusSnapshot({
    required this.isPremium,
    required this.isConfirmed,
  });
}

final premiumServiceProvider = Provider<PremiumService>((ref) {
  return PremiumService(
    supabase: ref.watch(supabaseClientProvider),
    analytics: ref.watch(analyticsServiceProvider),
  );
});
