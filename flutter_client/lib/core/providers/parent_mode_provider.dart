import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';

/// Sprint 0 Modo Padres: estado de premium a nivel hogar.
///
/// Este provider lee `get_household_premium_status`, la fuente de verdad del
/// premium (siempre a nivel hogar). `effectivePremiumProvider` deriva de aca.
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
  // Keep the household-scoped premium cache synchronized with the user-facing
  // premium refresh/toggle flow. Parent Mode reads household premium; shared
  // premium surfaces such as avatars/paywalls may still read premiumProvider.
  ref.watch(premiumProvider);

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

/// Premium efectivo del hogar.
///
/// El premium es SIEMPRE a nivel hogar: si alguien paga, todo el hogar es
/// premium. Lo que cambia entre miembros es QUE features premium ve cada uno
/// segun su rol (los adultos ven Modo Padres; las features compartidas como
/// avatares premium las ven todos) — ese split por rol lo resuelven los
/// providers de abajo, no este flag.
///
/// A proposito ya NO se mezcla el flag legacy por-usuario (`premiumProvider`):
/// eso causaba que la UI habilitara Modo Padres mientras el backend
/// (`should_require_task_approval` -> `is_household_premium`, que solo mira el
/// hogar) lo negaba, completando tareas en vez de mandarlas a aprobacion.
final effectivePremiumProvider = Provider<bool>((ref) {
  return ref.watch(householdPremiumStatusProvider).value?.isPremium ?? false;
});

/// Habilita el bundle "Modo Padres".
///
/// Reglas:
///  - Solo en hogares de tipo `family`.
///  - El miembro actual debe poder gestionar el hogar (adulto owner/admin).
///  - El hogar debe tener premium activo.
///
/// Las features de control parental (aprobacion de tareas, dashboard parental,
/// rotacion automatica, resumen semanal) consultan este flag.
final parentModeAvailableProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  final isPremium = ref.watch(effectivePremiumProvider);
  if (!isPremium) return false;

  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).value;
  if (currentUserId == null || members == null) return false;

  final me = members.where((m) => m.userId == currentUserId).firstOrNull;
  return me?.canManageHousehold ?? false;
});

/// Whether task approvals are actually enabled for the current household.
///
/// This is intentionally different from [parentModeAvailableProvider]:
/// children/teens need to know whether their completions should go to review,
/// but they are not allowed to manage Parent Mode. The feature is active only
/// when the household is family, premium is active, and the approval mode is
/// not off.
final taskApprovalEnabledProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  final isPremium = ref.watch(effectivePremiumProvider);
  if (!isPremium) return false;

  final mode = ref.watch(currentHouseholdProvider).value?.taskApprovalMode;
  return mode != null && mode != 'off';
});

/// Whether the allowance ("mesada", adult→teen transfer) feature is active.
///
/// Premium Parent Mode feature, OFF by default. Active only when the household
/// is family, premium is active, AND the `allowance_enabled` toggle is on.
/// Mirrors [taskApprovalEnabledProvider] — same single source of truth so the
/// "Mesada" UI never shows where the feature isn't actually enabled.
final allowanceEnabledProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  final isPremium = ref.watch(effectivePremiumProvider);
  if (!isPremium) return false;

  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).value;
  if (currentUserId == null || members == null) return false;

  final me = members.where((m) => m.userId == currentUserId).firstOrNull;
  if (me?.canManageHousehold != true) return false;

  return ref.watch(currentHouseholdProvider).value?.allowanceEnabled ?? false;
});

/// Misma logica que [parentModeAvailableProvider] pero sin exigir premium.
/// Sirve para mostrar la entrada al paywall: si el usuario puede gestionar un
/// hogar familiar y todavia no compro, ahi mostramos el CTA.
final parentModeEligibleProvider = Provider<bool>((ref) {
  final caps = ref.watch(householdCapabilitiesProvider);
  if (caps.type != HouseholdType.family) return false;

  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).value;
  if (currentUserId == null || members == null) return false;

  final me = members.where((m) => m.userId == currentUserId).firstOrNull;
  return me?.canManageHousehold ?? false;
});

/// [MemberModel] del usuario en sesion dentro del hogar activo.
///
/// Retorna `null` mientras los miembros aun no cargaron o si el usuario no
/// pertenece a ningun hogar. Usado para adaptar la UI segun el tipo de
/// miembro (parent, guardian, teen, child).
final currentMemberProvider = Provider<MemberModel?>((ref) {
  final currentUserId = ref.watch(currentUserIdProvider);
  final members = ref.watch(householdMembersProvider).value;
  if (currentUserId == null || members == null) return null;
  return members.where((m) => m.userId == currentUserId).firstOrNull;
});
