import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/premium/data/repositories/premium_service_repository.dart';
import 'package:homesync_client/features/premium/domain/repositories/premium_repository.dart';
import 'package:homesync_client/features/premium/domain/usecases/buy_premium_product_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_products_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/get_premium_status_usecase.dart';
import 'package:homesync_client/features/premium/domain/usecases/restore_premium_purchases_usecase.dart';

import '../services/premium_service.dart';

class PremiumNotifier extends AsyncNotifier<bool> {
  static const String _freeFallbackAvatar = '\u{1F431}';

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
    final isPremium = await ref.read(getPremiumStatusUseCaseProvider).call();
    await _enforceFreeAvatarIfNeeded(isPremium);
    return isPremium;
  }

  bool _isPremiumAvatarValue(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return false;
    return trimmed.startsWith('premium://') ||
        trimmed.startsWith('assets/images/custom_avatars/') ||
        trimmed.contains('/storage/v1/object/public/custom-avatars/');
  }

  Future<void> _enforceFreeAvatarIfNeeded(bool isPremium) async {
    if (isPremium) return;

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
    ref.invalidate(householdMembersNotifierProvider);
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
  return ref.read(getPremiumProductsUseCaseProvider).call();
});

/// Gate para la integración OCR + lista de compras.
///
/// Regla de producto:
/// - Escanear ticket para pre-rellenar gasto: GRATIS para todos.
/// - Vincular el ticket con la lista de compras (auto-match, sugerencia de
///   items nuevos, flujo desde shopping): PREMIUM.
final canUseReceiptShoppingLinkProvider = Provider<bool>((ref) {
  return ref.watch(premiumProvider).valueOrNull ?? false;
});
