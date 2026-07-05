import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/premium/data/repositories/premium_service_repository.dart';
import 'package:homesync_client/features/premium/domain/repositories/premium_repository.dart';
import 'package:homesync_client/features/premium/domain/usecases/buy_premium_product_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_products_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_status_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/restore_premium_purchases_usecase.dart';
import 'package:purchases_flutter/purchases_flutter.dart' as rc;

import '../services/premium_service.dart';

class PremiumNotifier extends AsyncNotifier<bool> {
  static const String _freeFallbackAvatar = '\u{1F431}';

  rc.CustomerInfoUpdateListener? _customerInfoUpdateListener;

  @override
  Future<bool> build() async {
    _registerCustomerInfoListener();

    ref.listen<AsyncValue<AppAuthState>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.isAuthenticated) {
          unawaited(refresh());
        } else {
          state = const AsyncData(false);
        }
      });
    });

    return _fetchPremiumStatus();
  }

  PremiumRepository get _repository => ref.read(premiumRepositoryProvider);

  void _registerCustomerInfoListener() {
    if (_customerInfoUpdateListener != null) return;

    _customerInfoUpdateListener = (customerInfo) {
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null) {
        state = const AsyncData(false);
        return;
      }

      final isPremium = PremiumService.customerInfoHasPremium(customerInfo);
      unawaited(_syncCustomerInfoStatus(isPremium));
    };

    rc.Purchases.addCustomerInfoUpdateListener(_customerInfoUpdateListener!);
    ref.onDispose(() {
      final listener = _customerInfoUpdateListener;
      if (listener != null) {
        rc.Purchases.removeCustomerInfoUpdateListener(listener);
      }
      _customerInfoUpdateListener = null;
    });
  }

  Future<bool> _fetchPremiumStatus() async {
    final snapshot =
        await ref.read(premiumServiceProvider).getPremiumStatusSnapshot();
    await _enforceFreeAvatarIfNeeded(
      snapshot.isPremium,
      confirmed: snapshot.isConfirmed,
    );
    return snapshot.isPremium;
  }

  Future<void> _syncCustomerInfoStatus(bool revenueCatPremium) async {
    if (revenueCatPremium) {
      await _setPremiumState(true);
      return;
    }

    final effectivePremium = await _fetchPremiumStatus();
    state = AsyncData(effectivePremium);
  }

  Future<void> _setPremiumState(bool isPremium) async {
    // Llega desde compras/restores con respuesta real de RevenueCat: es un
    // resultado confirmado, no un fallo de red.
    await _enforceFreeAvatarIfNeeded(isPremium, confirmed: true);
    state = AsyncData(isPremium);
  }

  bool _isPremiumAvatarValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    return trimmed.startsWith('premium://') ||
        trimmed.startsWith('assets/images/custom_avatars/') ||
        trimmed.contains('/storage/v1/object/public/custom-avatars/');
  }

  Future<void> _enforceFreeAvatarIfNeeded(
    bool isPremium, {
    required bool confirmed,
  }) async {
    if (isPremium) return;
    // Revertir el avatar es destructivo: solo con un false CONFIRMADO.
    // Un false por RevenueCat/RPC caidos no debe degradar a un premium real.
    if (!confirmed) {
      log.i(
        'PremiumNotifier: status no-premium sin confirmar (fuentes caidas); '
        'se omite el downgrade de avatar',
      );
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final client = ref.read(supabaseClientProvider);
    final profile = await client
        .from('users')
        .select('avatar_url')
        .eq('id', userId)
        .maybeSingle();

    final currentAvatar = profile?['avatar_url'] as String?;
    if (!_isPremiumAvatarValue(currentAvatar)) return;

    await client.rpc(
      'update_own_profile',
      params: {
        'p_full_name': null,
        'p_avatar_url': _freeFallbackAvatar,
      },
    );
    ref.invalidate(userProfileProvider);
    ref.invalidate(householdMembersProvider);
  }

  /// FOR DEMO/DEVELOPMENT ONLY: Toggles local mock premium
  Future<void> togglePremiumMock() async {
    await _repository.togglePremiumMock();
    await refresh();
  }

  Future<bool> buyProduct(rc.Package package) async {
    final isPremium = await ref.read(buyPremiumProductUseCaseProvider).call(
          package,
        );
    await _setPremiumState(isPremium);
    return isPremium;
  }

  Future<bool> restorePurchases() async {
    final isPremium =
        await ref.read(restorePremiumPurchasesUseCaseProvider).call();
    await _setPremiumState(isPremium);
    return isPremium;
  }

  Future<void> refresh() async {
    state = const AsyncLoading<bool>();
    state = await AsyncValue.guard(_fetchPremiumStatus);
  }
}

final premiumProvider = AsyncNotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumServiceRepository(ref.read(premiumServiceProvider));
});

final getPremiumStatusUseCaseProvider =
    Provider<GetPremiumStatusUseCase>((ref) {
  return GetPremiumStatusUseCase(ref.read(premiumRepositoryProvider));
});

final getPremiumProductsUseCaseProvider =
    Provider<GetPremiumProductsUseCase>((ref) {
  return GetPremiumProductsUseCase(ref.read(premiumRepositoryProvider));
});

final buyPremiumProductUseCaseProvider =
    Provider<BuyPremiumProductUseCase>((ref) {
  return BuyPremiumProductUseCase(ref.read(premiumRepositoryProvider));
});

final restorePremiumPurchasesUseCaseProvider =
    Provider<RestorePremiumPurchasesUseCase>((ref) {
  return RestorePremiumPurchasesUseCase(ref.read(premiumRepositoryProvider));
});

/// UI-facing provider for available products
final premiumProductsProvider = FutureProvider((ref) async {
  final household = await ref.watch(currentHouseholdProvider.future);
  final offeringId = switch (household?.householdType) {
    'family' => 'family',
    'friends' => 'household',
    'couple' => 'household',
    _ => 'solo',
  };
  return ref.read(getPremiumProductsUseCaseProvider).call(
        offeringId: offeringId,
      );
});

/// Gate para la integración OCR + lista de compras.
///
/// Regla de producto:
/// - Escanear ticket para pre-rellenar gasto: GRATIS para todos.
/// - Vincular el ticket con la lista de compras (auto-match, sugerencia de
///   items nuevos, flujo desde shopping): PREMIUM.
final canUseReceiptShoppingLinkProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).value ?? false;
});
