import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/tasks/domain/models/weekly_family_summary.dart';
import 'package:homesync_client/features/tasks/presentation/providers/weekly_family_summary_provider.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

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
        title: const Text('Resumen de la semana'),
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
            onRefresh: () async =>
                ref.invalidate(weeklyFamilySummaryProvider),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
              children: [
                _CompletionCard(summary: summary),
                const SizedBox(height: 14),
                if (summary.mvp != null) ...[
                  _MvpCard(member: summary.mvp!),
                  const SizedBox(height: 14),
                ],
                if (summary.slacker != null) ...[
                  _SlackerCard(member: summary.slacker!),
                  const SizedBox(height: 14),
                ],
                if (summary.forgottenTask != null) ...[
                  _ForgottenCard(task: summary.forgottenTask!),
                  const SizedBox(height: 14),
                ],
                _SpendingCard(summary: summary),
                if (summary.topCategory != null) ...[
                  const SizedBox(height: 14),
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
                  style:
                      TextStyle(color: theme.textSecondary, fontSize: 13),
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
    final pct = (summary.completionRate * 100).round();
    final delta = summary.tasksDoneDelta;
    final accent = pct >= 80
        ? AppColors.accentGreen
        : pct >= 50
            ? AppColors.accentGold
            : AppColors.accentRed;
    final trailingText = delta == 0
        ? null
        : delta > 0
            ? '+$delta vs sem. anterior'
            : '$delta vs sem. anterior';
    return _StoryCard(
      accent: accent,
      icon: Icons.task_alt_rounded,
      eyebrow: 'Cumplimiento',
      title:
          '${summary.tasksDone} de ${summary.tasksPlanned} tareas — $pct%',
      subtitle: trailingText ??
          'Buen ritmo: la semana cerro con todo lo que se planearon.',
      trailing: SizedBox(
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
      ),
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
    final deltaLabel = summary.spendingLastWeek == 0
        ? 'Primera semana con gastos compartidos.'
        : delta < 0
            ? 'Gastaron \$${delta.abs().toStringAsFixed(0)} menos que la semana anterior.'
            : delta > 0
                ? 'Gastaron \$${delta.toStringAsFixed(0)} mas que la semana anterior.'
                : 'Mismo gasto que la semana anterior.';
    return _StoryCard(
      accent: accent,
      icon: Icons.payments_rounded,
      eyebrow: 'Gastos compartidos',
      title: '\$${summary.spendingTotal.toStringAsFixed(0)} esta semana',
      subtitle: deltaLabel,
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  const _TopCategoryCard({required this.top});
  final TopCategorySpend top;

  @override
  Widget build(BuildContext context) {
    return _StoryCard(
      accent: AppColors.accentPurple,
      icon: Icons.category_rounded,
      eyebrow: 'Top categoria',
      title: top.category,
      subtitle:
          '\$${top.total.toStringAsFixed(0)} en ${top.count} gasto${top.count == 1 ? "" : "s"}.',
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
