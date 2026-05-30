import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/admin_providers.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/services/performance_monitor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeBootstrapData {
  const HomeBootstrapData({
    required this.authenticated,
    required this.userId,
    required this.householdId,
    required this.memberOnboardingCompleted,
    required this.profile,
    required this.household,
    required this.members,
    required this.tasks,
    required this.expenseBalances,
    required this.userBalance,
    required this.combinedFeed,
    required this.recentActivities,
  });

  final bool authenticated;
  final String? userId;
  final String? householdId;
  final bool memberOnboardingCompleted;
  final Map<String, dynamic>? profile;
  final Map<String, dynamic>? household;
  final List<Map<String, dynamic>> members;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> expenseBalances;
  final Map<String, dynamic>? userBalance;
  final List<Map<String, dynamic>> combinedFeed;
  final List<Map<String, dynamic>> recentActivities;

  factory HomeBootstrapData.fromMap(Map<String, dynamic> map) {
    return HomeBootstrapData(
      authenticated: map['authenticated'] as bool? ?? false,
      userId: map['user_id']?.toString(),
      householdId: map['household_id']?.toString(),
      memberOnboardingCompleted:
          map['member_onboarding_completed'] as bool? ?? true,
      profile: _nullableMap(map['profile']),
      household: _nullableMap(map['household']),
      members: _mapList(map['members']),
      tasks: _mapList(map['tasks']),
      expenseBalances: _mapList(map['expense_balances']),
      userBalance: _nullableMap(map['user_balance']),
      combinedFeed: _mapList(map['combined_feed']),
      recentActivities: _mapList(map['recent_activity']),
    );
  }

  static Map<String, dynamic>? _nullableMap(Object? value) {
    if (value == null) return null;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static List<Map<String, dynamic>> _mapList(Object? value) {
    if (value is! List) return const <Map<String, dynamic>>[];
    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);
  }
}

/// Logical sections of the startup snapshot that derived providers seed from.
enum BootstrapSection {
  householdId,
  memberOnboarding,
  profile,
  userBalance,
  household,
  members,
  expenseBalances,
  combinedFeed,
}

/// One-shot seed gate for the startup snapshot.
///
/// The home bootstrap RPC loads everything (profile, balance, members, feed…)
/// in a single round-trip so the first frame is fast. Derived providers
/// (`userProfileProvider`, `userBalanceProvider`, …) read from that snapshot
/// ONLY on their first build via [consume]. After a section is consumed once,
/// [consume] returns false forever, so any later rebuild — e.g. triggered by
/// `ref.invalidate(userProfileProvider)` after a mutation — falls through to
/// the provider's own fresh fetch instead of replaying the stale snapshot.
///
/// This is what keeps the perf win of the bootstrap while fixing the class of
/// "I changed X but the UI still shows the old value" bugs.
class BootstrapSeedGate {
  BootstrapSeedGate._();
  static final BootstrapSeedGate instance = BootstrapSeedGate._();

  final Set<BootstrapSection> _consumed = <BootstrapSection>{};

  /// Returns true exactly once per section (until [reset]), signalling the
  /// caller may use the cached snapshot. Subsequent calls return false so the
  /// caller fetches fresh data.
  bool consume(BootstrapSection section) => _consumed.add(section);

  /// Clears the gate so the next bootstrap load can re-seed every section.
  /// Called whenever the snapshot itself is (re)loaded or the user changes.
  void reset() => _consumed.clear();
}

final homeBootstrapProvider = FutureProvider<HomeBootstrapData?>((ref) async {
  final admin = ref.watch(adminProvider);
  if (isAdminPreviewActive(admin)) return null;

  // A fresh snapshot load means derived providers may seed from it again.
  BootstrapSeedGate.instance.reset();

  final identity = AppIdentityService.instance;
  final userId = identity.currentUserId ?? await identity.refresh();
  if (userId == null || userId.isEmpty) return null;

  final client = ref.read(supabaseClientProvider);
  try {
    final response = await PerformanceMonitor.measureFuture(
      'provider.home_bootstrap',
      () => client.rpc(
        'get_home_bootstrap',
        params: {
          'p_tasks_limit': 50,
          'p_feed_limit': 200,
          'p_activity_limit': 30,
        },
      ),
      warnAfterMs: 900,
    );
    if (response is! Map) return null;
    return HomeBootstrapData.fromMap(Map<String, dynamic>.from(response));
  } on PostgrestException catch (error, stackTrace) {
    log.w(
      'Home bootstrap RPC unavailable, falling back to individual providers',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  } catch (error, stackTrace) {
    log.w(
      'Home bootstrap failed, falling back to individual providers',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
});
