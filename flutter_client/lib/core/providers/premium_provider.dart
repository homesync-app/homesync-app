import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import '../services/premium_service.dart';
import 'package:homesync_client/features/premium/data/repositories/premium_service_repository.dart';
import 'package:homesync_client/features/premium/domain/repositories/premium_repository.dart';
import 'package:homesync_client/features/premium/domain/usecases/buy_premium_product_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_products_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_status_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/restore_premium_purchases_usecase.dart';

class PremiumNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
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

  Future<bool> _fetchPremiumStatus() async {
    return ref.read(getPremiumStatusUseCaseProvider).call();
  }

  /// FOR DEMO/DEVELOPMENT ONLY: Toggles local mock premium
  Future<void> togglePremiumMock() async {
    await _repository.togglePremiumMock();
    await refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<bool>().copyWithPrevious(state);
    state = await AsyncValue.guard(_fetchPremiumStatus);
  }
}

final premiumProvider = AsyncNotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});

final premiumRepositoryProvider = Provider<PremiumRepository>((ref) {
  return PremiumServiceRepository(ref.read(premiumServiceProvider));
});

final getPremiumStatusUseCaseProvider = Provider<GetPremiumStatusUseCase>((ref) {
  return GetPremiumStatusUseCase(ref.read(premiumRepositoryProvider));
});

final getPremiumProductsUseCaseProvider =
    Provider<GetPremiumProductsUseCase>((ref) {
  return GetPremiumProductsUseCase(ref.read(premiumRepositoryProvider));
});

final buyPremiumProductUseCaseProvider = Provider<BuyPremiumProductUseCase>((ref) {
  return BuyPremiumProductUseCase(ref.read(premiumRepositoryProvider));
});

final restorePremiumPurchasesUseCaseProvider =
    Provider<RestorePremiumPurchasesUseCase>((ref) {
  return RestorePremiumPurchasesUseCase(ref.read(premiumRepositoryProvider));
});

/// UI-facing provider for available products
final premiumProductsProvider = FutureProvider((ref) async {
  return ref.read(getPremiumProductsUseCaseProvider).call();
});
