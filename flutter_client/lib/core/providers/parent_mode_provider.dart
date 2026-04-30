import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';

/// Sprint 0 Modo Padres: estado de premium a nivel hogar.
///
/// Este provider lee `get_household_premium_status` y reemplaza progresivamente
/// al `premiumProvider` (por usuario). Mientras dura la migracion convive con
/// el flag legacy: `effectivePremiumProvider` devuelve true si cualquiera de
/// los dos lo es, asi ningun feature ya monetizado se rompe.
class HouseholdPremiumStatus {
  final bool isPremium;
  final String planTier;
  final DateTime? premiumUntil;
  final String? subscriptionOwnerUserId;
  final bool founderPriceApplied;

  const HouseholdPremiumStatus({
    required this.isPremium,
    required this.planTier,
    this.premiumUntil,
    this.subscriptionOwnerUserId,
    this.founderPriceApplied = false,
  });

  static const HouseholdPremiumStatus free = HouseholdPremiumStatus(
    isPremium: false,
    planTier: 'free',
  );

  bool get isCouplePlan =>
      planTier == 'couple_premium' || planTier == 'couple_premium_founder';
  bool get isGroupPlan =>
      planTier == 'group_premium' || planTier == 'group_premium_founder';

  factory HouseholdPremiumStatus.fromMap(Map<String, dynamic> map) {
    final until = map['premium_until'];
    return HouseholdPremiumStatus(
      isPremium: map['is_premium'] == true,
      planTier: (map['plan_tier'] as String?) ?? 'free',
      premiumUntil: until is String ? DateTime.tryParse(until) : null,
      subscriptionOwnerUserId: map['subscription_owner_user_id'] as String?,
      founderPriceApplied: map['founder_price_applied'] == true,
    );
  }
}

final householdPremiumStatusProvider =
    FutureProvider<HouseholdPremiumStatus>((ref) async {
  final householdId = await ref.watch(householdIdProvider.future);
  if (householdId == null) {
    return HouseholdPremiumStatus.free;
  }
  final client = ref.watch(supabaseClientProvider);
  try {
    final result = await client.rpc(
      'get_household_premium_status',
      params: {'p_household_id': householdId},
    );
    if (result is Map<String, dynamic>) {
      return HouseholdPremiumStatus.fromMap(result);
    }
    if (result is Map) {
      return HouseholdPremiumStatus.fromMap(
        Map<String, dynamic>.from(result),
      );
    }
    log.w(
      'get_household_premium_status returned unexpected shape: $result',
    );
    return HouseholdPremiumStatus.free;
  } catch (e, stack) {
    log.e(
      'get_household_premium_status failed, falling back to free',
      error: e,
      stackTrace: stack,
    );
    return HouseholdPremiumStatus.free;
  }
});

/// Premium efectivo: hogar premium O usuario premium (legacy).
///
/// Durante la migracion, los hogares con plan_tier seteado y los usuarios con
/// is_premium=true (no migrados aun) deben seguir viendo features pagas. Una
/// vez completada la migracion, podemos colapsar esto al valor del hogar.
final effectivePremiumProvider = Provider<bool>((ref) {
  final household = ref.watch(householdPremiumStatusProvider).valueOrNull;
  if (household != null && household.isPremium) return true;
  return ref.watch(premiumProvider).valueOrNull ?? false;
});

/// Habilita el bundle "Modo Padres".
///
/// Reglas:
///  - Solo en hogares de tipo `family`.
///  - El miembro actual debe ser admin (puede aprobar tareas, gestionar el
///    hogar, etc.).
///  - El hogar debe tener premium activo.
///
/// Las features de control parental (aprobacion de tareas, dashboard parental,
/// rotacion automatica, resumen semanal) consultan este flag.
final parentModeAvailableProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  // premiumProvider ya resuelve el acceso efectivo: usuario premium legacy
  // o plan premium heredado por el hogar. Asi Configuracion, Shopping y
  // Modo Padres se bloquean/desbloquean con la misma verdad de producto.
  final isPremium = ref.watch(premiumProvider).valueOrNull ?? false;
  if (!isPremium) return false;

  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).valueOrNull;
  if (currentUserId == null || members == null) return false;

  final me = members.where((m) => m.userId == currentUserId).firstOrNull;
  return me?.isAdmin ?? false;
});

/// Misma logica que [parentModeAvailableProvider] pero sin exigir premium.
/// Sirve para mostrar la entrada al paywall: si el usuario es admin de una
/// familia y todavia no compro, ahi mostramos el CTA.
final parentModeEligibleProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).valueOrNull;
  if (currentUserId == null || members == null) return false;

  final me = members.where((m) => m.userId == currentUserId).firstOrNull;
  return me?.isAdmin ?? false;
});
