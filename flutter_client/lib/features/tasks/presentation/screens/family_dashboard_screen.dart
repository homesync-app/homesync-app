import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/tasks/domain/models/family_member_dashboard.dart';
import 'package:homesync_client/features/tasks/presentation/providers/family_member_dashboard_provider.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Sprint 2 Modo Padres: dashboard parental.
///
/// Muestra una card por integrante del hogar con:
///  - tareas hechas vs pendientes en la ventana (semana/mes).
///  - cumplimiento (ring color).
///  - racha actual.
///  - coins ganados/gastados.
///  - top categorias del periodo.
///
/// Solo accesible para admins de hogares family con premium activo. Para
/// otros usuarios redirige al paywall (estado bloqueado), igual que la
/// PendingApprovalsScreen.
class FamilyDashboardScreen extends ConsumerStatefulWidget {
  const FamilyDashboardScreen({super.key});

  @override
  ConsumerState<FamilyDashboardScreen> createState() =>
      _FamilyDashboardScreenState();
}

class _FamilyDashboardScreenState
    extends ConsumerState<FamilyDashboardScreen> {
  DashboardPeriod _period = DashboardPeriod.week;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final eligible = ref.watch(parentModeEligibleProvider);
    if (!eligible) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: const Text('Familia')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Esta vista es para administradores de hogares familiares.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ),
        ),
      );
    }

    final available = ref.watch(parentModeAvailableProvider);
    if (!available) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: const Text('Familia')),
        body: const _LockedHero(),
      );
    }

    final dashboardAsync = ref.watch(familyMemberDashboardProvider(_period));

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('Vista por miembro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.invalidate(familyMemberDashboardProvider(_period)),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SegmentedButton<DashboardPeriod>(
              segments: const [
                ButtonSegment(
                  value: DashboardPeriod.week,
                  label: Text('Semana'),
                ),
                ButtonSegment(
                  value: DashboardPeriod.month,
                  label: Text('Mes'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: (s) =>
                  setState(() => _period = s.first),
            ),
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar el dashboard: $e',
              style: TextStyle(color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (dashboard) {
          if (dashboard == null || dashboard.members.isEmpty) {
            return _EmptyState(theme: theme);
          }
          return RefreshIndicator(
            onRefresh: () async =>
                ref.invalidate(familyMemberDashboardProvider(_period)),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: dashboard.members.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MemberCard(
                snapshot: dashboard.members[i],
                period: dashboard.period,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.snapshot, required this.period});
  final FamilyMemberSnapshot snapshot;
  final DashboardPeriod period;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final rate = snapshot.completionRate;
    final ringColor = _ringColor(rate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 56,
                height: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: CircularProgressIndicator(
                        value: rate.clamp(0.0, 1.0),
                        strokeWidth: 4,
                        backgroundColor: theme.divider,
                        valueColor: AlwaysStoppedAnimation(ringColor),
                      ),
                    ),
                    CustomUserAvatar(
                      avatarUrl: snapshot.avatarUrl,
                      name: snapshot.fullName,
                      userId: snapshot.userId,
                      radius: 22,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      snapshot.fullName,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _roleLabel(snapshot),
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ringColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(rate * 100).round()}%',
                  style: TextStyle(
                    color: ringColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Stat(
                icon: Icons.task_alt_rounded,
                color: AppColors.accentGreen,
                label: '${snapshot.tasksDone} hechas',
              ),
              if (snapshot.tasksOpen > 0)
                _Stat(
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.accentBlue,
                  label: '${snapshot.tasksOpen} pendientes',
                ),
              if (snapshot.tasksOverdue > 0)
                _Stat(
                  icon: Icons.error_outline_rounded,
                  color: AppColors.accentRed,
                  label: '${snapshot.tasksOverdue} atrasadas',
                ),
              if (snapshot.tasksPendingApproval > 0)
                _Stat(
                  icon: Icons.hourglass_top_rounded,
                  color: AppColors.accentGold,
                  label: '${snapshot.tasksPendingApproval} a aprobar',
                ),
              _Stat(
                icon: Icons.local_fire_department_rounded,
                color: AppColors.accentOrange,
                label: '${snapshot.streakDays} de racha',
              ),
              _Stat(
                icon: Icons.monetization_on_rounded,
                color: AppColors.accentYellow,
                label: '+${snapshot.coinsEarned} / -${snapshot.coinsSpent}',
              ),
            ],
          ),
          if (snapshot.topCategories.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              period == DashboardPeriod.week
                  ? 'Top categorias de la semana'
                  : 'Top categorias del mes',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final c in snapshot.topCategories)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${c.category} · ${c.count}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _ringColor(double rate) {
    if (rate >= 0.8) return AppColors.accentGreen;
    if (rate >= 0.5) return AppColors.accentGold;
    return AppColors.accentRed;
  }

  String _roleLabel(FamilyMemberSnapshot s) {
    if (s.displayRole != null && s.displayRole!.isNotEmpty) {
      return s.displayRole!;
    }
    if (s.isChild) return 'Hijo/a';
    if (s.isTeen) return 'Adolescente';
    return 'Adulto';
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.groups_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Todavia no hay datos',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando los miembros completen tareas o reciban coins, los vas a ver aca.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedHero extends StatelessWidget {
  const _LockedHero();

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shield_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Vista por miembro',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Activa Modo Padres para ver el progreso de cada integrante de la familia en un solo lugar.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
