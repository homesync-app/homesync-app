import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/widgets/offline_indicator.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/tasks/presentation/providers/task_provider.dart';
import 'package:homesync_client/features/tasks/domain/models/task_model.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/balance_card.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/shared/widgets/avatar_picker_sheet.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import 'package:homesync_client/core/services/supabase_auth_service.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final SupabaseAuthService auth;
  final SupabaseRpcService rpc;
  final SharedPreferences? prefs;

  const HomeScreen({
    super.key,
    required this.auth,
    required this.rpc,
    this.prefs,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late ConfettiController _confettiController;
  final Set<String> _completedTaskIds = {};

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    _setupTaskCompletionListener(ref);
    final householdAsync = ref.watch(householdIdProvider);

    return householdAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $e')),
      ),
      data: (householdId) {
        if (householdId == null) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(child: Text('No pertenecés a un hogar aún.')),
          );
        }
        return Stack(
          children: [
            _buildMainContent(householdId),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.primary,
                  AppColors.success,
                  AppColors.accentOrange,
                  Colors.blue,
                  Colors.pink,
                ],
                numberOfParticles: 30,
                gravity: 0.1,
              ),
            ),
          ],
        );
      },
    );
  }

  void _setupTaskCompletionListener(WidgetRef ref) {
    ref.listen(todayTasksProvider, (previous, next) {
      if (previous?.asData?.value.isNotEmpty == true &&
          next.asData?.value.isEmpty == true &&
          !next.isLoading &&
          !next.hasError) {
        _confettiController.play();
        HapticFeedback.heavyImpact();
      }
    });
  }

  Widget _buildMainContent(String householdId) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async => _refreshHome(),
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 28),
                    _buildFinancialSummary(householdId),
                    const SizedBox(height: 32),
                    _buildTasksSection(),
                    const SizedBox(height: 32),
                    _buildActivitySection(),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickActionMenu(householdId),
        backgroundColor: AppColors.primary,
        elevation: 12,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text(
          'Nueva Acción',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            letterSpacing: -0.2,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  Future<void> _refreshHome() async {
    ref.invalidate(todayTasksProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(personalFinanceSummaryProvider);
    ref.invalidate(expenseBalancesProvider);
  }

  Widget _buildHeader() {
    final profileAsync = ref.watch(userProfileProvider);
    final dateStr = DateFormat('EEEE, d MMM', 'es').format(DateTime.now());
    final capitalizedDate = dateStr.isEmpty ? '' : dateStr[0].toUpperCase() + dateStr.substring(1);

    final displayName = profileAsync.whenOrNull(
          data: (p) => (p?['full_name'] as String?)?.split(' ').first ?? 'Usuario',
        ) ?? 'Usuario';

    final avatarUrl = profileAsync.whenOrNull(data: (p) => p?['avatar_url'] as String?);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, $displayName 👋',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ).animateEntrance(),
            const SizedBox(height: 4),
            Text(
              capitalizedDate,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        _buildCircularAvatar(displayName, avatarUrl).animateScaleIn(delay: 150),
      ],
    );
  }

  Widget _buildCircularAvatar(String displayName, String? avatarUrl) {
    return AnimatedPress(
      onTap: () => AvatarPickerSheet.show(context),
      child: CustomUserAvatar(
        name: displayName,
        avatarUrl: avatarUrl,
        radius: 28,
        showBorder: true,
      ),
    );
  }

  Widget _buildFinancialSummary(String householdId) {
    final summaryAsync = ref.watch(personalFinanceSummaryProvider);
    final balanceAsync = ref.watch(userBalanceProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    final coins = balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;
    final xp = balanceAsync.whenOrNull(data: (b) => b?['xp'] as int?) ?? 0;

    double myBalance = 0;
    summaryAsync.whenData((s) => myBalance = (s['balance'] ?? 0).toDouble());

    final partner = membersAsync.whenOrNull(
      data: (members) => members.where((m) => m.userId != currentUserId).firstOrNull,
    );

    return BalanceCard(
      coins: coins,
      xp: xp,
      userBalance: myBalance,
      partnerName: partner?.displayName,
      onSettle: partner != null && myBalance.abs() > 10.0
          ? () => _showSettlementDialog(
                householdId: householdId,
                partnerId: partner.userId,
                partnerName: partner.displayName,
                amount: myBalance.abs(),
                isOwedByMe: myBalance < 0,
                alias: partner.mercadopagoAlias,
              )
          : null,
    ).animateEntrance(delay: 100);
  }

  Widget _buildTasksSection() {
    final tasksAsync = ref.watch(todayTasksProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tareas de hoy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            TextButton(
              onPressed: () => ref.read(bottomNavIndexProvider.notifier).setIndex(1),
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        tasksAsync.when(
          loading: () => _buildTasksShimmer(),
          error: (e, _) => Text('Error: $e'),
          data: (tasks) {
            final visibleTasks = tasks.where((t) => !t.isCompleted && !_completedTaskIds.contains(t.id)).toList();
            if (visibleTasks.isEmpty) return _buildEmptyState('¡Todo listo por hoy!');
            
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildTaskCard(visibleTasks[index]).animateStaggered(index),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final categoryColor = AppColors.getCategoryColor(task.category);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(AppColors.getCategoryMaterialIcon(task.category), color: categoryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  AppColors.categoryNames[task.category?.toLowerCase()] ?? task.category ?? 'General',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _completeTask(task),
            icon: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary, size: 28),
          ),
        ],
      ),
    );
  }

  Future<void> _completeTask(TaskModel task) async {
    HapticFeedback.mediumImpact();
    setState(() => _completedTaskIds.add(task.id));
    
    try {
      await ref.read(tasksProvider.notifier).completeTask(task);
    } catch (e) {
      if (mounted) {
        setState(() => _completedTaskIds.remove(task.id));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildActivitySection() {
    final activityAsync = ref.watch(recentActivityProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actividad reciente',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        activityAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Error al cargar actividad: $e'),
          data: (activities) {
            if (activities.isEmpty) return _buildEmptyState('No hay actividad aún');
            return _buildActivityTimeline(activities);
          },
        ),
      ],
    );
  }

  Widget _buildActivityTimeline(List<Map<String, dynamic>> activities) {
    return Column(
      children: List.generate(activities.length, (index) {
        final activity = activities[index];
        final id = activity['id'] ?? index.toString();
        return _buildActivityItem(activity, key: ValueKey(id)).animateStaggered(index);
      }),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity, {Key? key}) {
    final type = activity['type'] as String;
    final data = activity['data'] as Map<String, dynamic>;
    final time = DateTime.tryParse(activity['created_at'] ?? '') ?? DateTime.now();
    final timeStr = DateFormat('HH:mm').format(time);

    IconData icon;
    Color color;
    String title;

    if (type == 'task') {
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
      title = '${data['user_name']} completó "${data['task_title']}"';
    } else if (type == 'expense') {
      icon = Icons.shopping_bag_rounded;
      color = AppColors.accentOrange;
      title = '${data['user_name']} cargó un gasto: \$${data['amount']}';
    } else {
      icon = Icons.info_rounded;
      color = AppColors.textSecondary;
      title = 'Evento desconocido';
    }

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: Icon(icon, color: color, size: 16),
                ),
                Expanded(child: Container(width: 2, color: AppColors.divider.withValues(alpha: 0.5))),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(timeStr, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksShimmer() {
    return Column(
      children: List.generate(2, (_) => ShimmerLoading(
        child: Container(
          height: 80,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        ),
      )),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Text(message, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
      ),
    );
  }

  void _showQuickActionMenu(String householdId) {
    // Basic implementation of the quick action menu
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Acciones Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            // Actions like "Cargar Gasto", "Nueva Tarea", etc.
            ElevatedButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettlementDialog({
    required String householdId,
    required String partnerId,
    required String partnerName,
    required double amount,
    required bool isOwedByMe,
    String? alias,
  }) {
    // Basic settlement dialog implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isOwedByMe ? 'Pagar a $partnerName' : 'Cobrar a $partnerName'),
        content: Text('Monto: \$${amount.toStringAsFixed(2)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(expenseControllerProvider.notifier).settleDebt(
                toUserId: partnerId,
                amount: amount,
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
