import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/tasks/domain/models/weekly_family_summary.dart';
import 'package:homesync_client/features/tasks/presentation/providers/weekly_family_summary_provider.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

String _formatMoney(num value) {
  final rounded = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < rounded.length; i++) {
    final fromEnd = rounded.length - i;
    buffer.write(rounded[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) {
      buffer.write('.');
    }
  }
  return '\$${buffer.toString()}';
}

/// Sprint 4 Modo Padres: pantalla con el resumen semanal del hogar.
///
/// Cards verticales (estilo "story-lite") con: cumplimiento general,
/// MVP, slacker (con copy positivo), tarea olvidada, gastos vs semana
/// previa y top categoria. Si no hay datos para alguna seccion, esa card
/// se omite — preferimos resumen corto a placeholders vacios.
class WeeklyFamilySummaryScreen extends ConsumerWidget {
  const WeeklyFamilySummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final eligible = ref.watch(parentModeEligibleProvider);
    if (!eligible) {
      return Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(title: const Text('Resumen semanal')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Esta seccion es para administradores de hogares familiares.',
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
        appBar: AppBar(title: const Text('Resumen semanal')),
        body: const _LockedHero(),
      );
    }

    final summaryAsync = ref.watch(weeklyFamilySummaryProvider);

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text(
          'Resumen semanal',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(weeklyFamilySummaryProvider),
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar el resumen: $e',
              style: TextStyle(color: theme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (summary) {
          if (summary == null) return _EmptyState(theme: theme);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(weeklyFamilySummaryProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              children: [
                _WeeklyReadoutHero(summary: summary),
                const SizedBox(height: 16),
                _WeeklyMetrics(summary: summary),
                const SizedBox(height: 16),
                _CompletionCard(summary: summary),
                const SizedBox(height: 12),
                if (summary.mvp != null) ...[
                  _MvpCard(member: summary.mvp!),
                  const SizedBox(height: 12),
                ],
                if (summary.slacker != null) ...[
                  _SlackerCard(member: summary.slacker!),
                  const SizedBox(height: 12),
                ],
                if (summary.forgottenTask != null) ...[
                  _ForgottenCard(task: summary.forgottenTask!),
                  const SizedBox(height: 12),
                ],
                _SpendingCard(summary: summary),
                if (summary.topCategory != null) ...[
                  const SizedBox(height: 12),
                  _TopCategoryCard(top: summary.topCategory!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------- Cards -----------------------------------------------------------

class _WeeklyReadoutHero extends StatelessWidget {
  const _WeeklyReadoutHero({required this.summary});

  final WeeklyFamilySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final hasTasks = summary.tasksPlanned > 0;
    final hasSpending = summary.spendingTotal > 0;
    final hasAttention =
        summary.slacker != null || summary.forgottenTask != null;
    final pct = hasTasks ? (summary.completionRate * 100).round() : null;

    final title = hasAttention
        ? 'Semana con puntos a revisar'
        : hasTasks && pct != null && pct >= 80
            ? 'Buena coordinación'
            : hasSpending
                ? 'Semana tranquila con gastos'
                : 'Semana tranquila';
    final subtitle = hasTasks
        ? '${summary.tasksDone} de ${summary.tasksPlanned} tareas completadas.'
        : hasSpending
            ? 'Hubo gastos compartidos, pero todavía no hubo tareas planificadas.'
            : 'Todavía no hubo actividad suficiente para un cierre completo.';
    final accent = hasAttention
        ? AppColors.accentGold
        : hasTasks
            ? AppColors.accentGreen
            : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.16 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(Icons.auto_graph_rounded, color: accent, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.3,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyMetrics extends StatelessWidget {
  const _WeeklyMetrics({required this.summary});

  final WeeklyFamilySummary summary;

  @override
  Widget build(BuildContext context) {
    final hasTasks = summary.tasksPlanned > 0;
    final pct =
        hasTasks ? '${(summary.completionRate * 100).round()}%' : 'Sin datos';
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Tareas',
            value:
                hasTasks ? '${summary.tasksDone}/${summary.tasksPlanned}' : '0',
            icon: Icons.task_alt_rounded,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: 'Gastos',
            value: _formatMoney(summary.spendingTotal),
            icon: Icons.payments_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricTile(
            label: 'Cumpl.',
            value: pct,
            icon: Icons.insights_rounded,
            color: AppColors.accentBlue,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.075),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 9),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.textPrimary,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.textSecondary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.accent,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final Color accent;
  final IconData icon;
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 0.7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 10.5,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(color: theme.textSecondary, fontSize: 13),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.summary});
  final WeeklyFamilySummary summary;

  @override
  Widget build(BuildContext context) {
    final hasTasks = summary.tasksPlanned > 0;
    final pct = hasTasks ? (summary.completionRate * 100).round() : 0;
    final delta = summary.tasksDoneDelta;
    final accent = !hasTasks
        ? AppColors.accentBlue
        : pct >= 80
            ? AppColors.accentGreen
            : pct >= 50
                ? AppColors.accentGold
                : AppColors.accentRed;
    final trailingText = !hasTasks
        ? null
        : delta == 0
            ? null
            : delta > 0
                ? '+$delta vs sem. anterior'
                : '$delta vs sem. anterior';
    return _StoryCard(
      accent: accent,
      icon: Icons.task_alt_rounded,
      eyebrow: 'Cumplimiento',
      title: hasTasks
          ? '${summary.tasksDone} de ${summary.tasksPlanned} tareas - $pct%'
          : 'Sin tareas esta semana',
      subtitle: hasTasks
          ? trailingText ??
              'Buen ritmo: la semana cerró con lo planificado al día.'
          : 'Cuando asignen tareas, acá vas a ver cumplimiento real y comparación semanal.',
      trailing: hasTasks
          ? SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: summary.completionRate.clamp(0.0, 1.0),
                    strokeWidth: 5,
                    backgroundColor: accent.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation(accent),
                  ),
                  Text(
                    '$pct%',
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}

class _MvpCard extends StatelessWidget {
  const _MvpCard({required this.member});
  final SummaryMember member;

  @override
  Widget build(BuildContext context) {
    return _StoryCard(
      accent: AppColors.accentGold,
      icon: Icons.emoji_events_rounded,
      eyebrow: 'MVP',
      title: '${member.fullName} se llevo la semana',
      subtitle:
          'Completo ${member.count} tarea${member.count == 1 ? "" : "s"} en el hogar.',
      trailing: CustomUserAvatar(
        avatarUrl: member.avatarUrl,
        name: member.fullName,
        userId: member.userId,
        radius: 22,
      ),
    );
  }
}

class _SlackerCard extends StatelessWidget {
  const _SlackerCard({required this.member});
  final SummaryMember member;

  @override
  Widget build(BuildContext context) {
    return _StoryCard(
      accent: AppColors.accentBlue,
      icon: Icons.support_rounded,
      eyebrow: 'Necesita un empujon',
      title: '${member.fullName} se quedo con tareas pendientes',
      subtitle:
          '${member.count} tarea${member.count == 1 ? "" : "s"} atrasada${member.count == 1 ? "" : "s"}. Quiza esta semana puedas ayudarle a destrabar.',
      trailing: CustomUserAvatar(
        avatarUrl: member.avatarUrl,
        name: member.fullName,
        userId: member.userId,
        radius: 22,
      ),
    );
  }
}

class _ForgottenCard extends StatelessWidget {
  const _ForgottenCard({required this.task});
  final ForgottenTask task;

  @override
  Widget build(BuildContext context) {
    final days = (task.overdueSeconds / 86400).floor();
    final overdueLabel = days == 0
        ? 'venció hoy'
        : days == 1
            ? 'venció hace 1 día'
            : 'venció hace $days días';
    return _StoryCard(
      accent: AppColors.accentOrange,
      icon: Icons.bookmark_remove_rounded,
      eyebrow: 'La mas olvidada',
      title: task.title,
      subtitle: 'Esta recurrente quedo en el camino — $overdueLabel.',
    );
  }
}

class _SpendingCard extends StatelessWidget {
  const _SpendingCard({required this.summary});
  final WeeklyFamilySummary summary;

  @override
  Widget build(BuildContext context) {
    final delta = summary.spendingDelta;
    final accent = delta < 0
        ? AppColors.accentGreen
        : delta > 0
            ? AppColors.accentRed
            : AppColors.accentBlue;
    final deltaLabel = summary.spendingTotal == 0
        ? 'No hubo gastos compartidos esta semana.'
        : summary.spendingLastWeek == 0
            ? 'Primera semana con gastos compartidos.'
            : delta < 0
                ? 'Gastaron ${_formatMoney(delta.abs())} menos que la semana anterior.'
                : delta > 0
                    ? 'Gastaron ${_formatMoney(delta)} más que la semana anterior.'
                    : 'Mismo gasto que la semana anterior.';
    return _StoryCard(
      accent: accent,
      icon: Icons.payments_rounded,
      eyebrow: 'Gastos compartidos',
      title: '${_formatMoney(summary.spendingTotal)} esta semana',
      subtitle: deltaLabel,
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({required this.top});
  final TopCategorySpend top;

  @override
  Widget build(BuildContext context) {
    final categoryName = CategoryMapping.displayName(top.category);
    return _StoryCard(
      accent: AppColors.accentPurple,
      icon: Icons.category_rounded,
      eyebrow: 'Top categoría',
      title: categoryName,
      subtitle:
          '${_formatMoney(top.total)} en ${top.count} gasto${top.count == 1 ? "" : "s"}.',
    );
  }
}

// ---------- States ----------------------------------------------------------

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
              Icons.celebration_rounded,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Tu primer resumen viene en camino',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando empiecen a completar tareas y cargar gastos vamos a generar el reporte de la semana automaticamente.',
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
              'Resumen semanal',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Activa Modo Padres para recibir el resumen de la semana con cumplimiento, MVP y gastos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
