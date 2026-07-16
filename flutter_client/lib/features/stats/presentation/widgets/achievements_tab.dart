import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/concept_icon.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../shared/widgets/app_refresh_indicator.dart';
import '../../../../shared/widgets/design/app_progress_fill_card.dart';
import 'stats_shared_widgets.dart';

class AchievementsTab extends StatelessWidget {
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> taskStats;
  final bool isSolo;
  final Future<void> Function() onRefresh;

  const AchievementsTab({
    super.key,
    required this.memberStats,
    required this.taskStats,
    this.isSolo = false,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Definimos algunos logros predeterminados basados en las estadísticas
    final totalTasksByCategory = taskStats.fold<int>(
      0,
      (sum, item) => sum + ((item['completed_count'] as num?)?.toInt() ?? 0),
    );
    final totalTasksByMember = memberStats.fold<int>(
      0,
      (sum, item) => sum + ((item['tasks_completed'] as num?)?.toInt() ?? 0),
    );
    final totalTasks =
        totalTasksByCategory > 0 ? totalTasksByCategory : totalTasksByMember;
    final totalXp = memberStats.fold<int>(
      0,
      (sum, item) => sum + ((item['xp_earned'] as num?)?.toInt() ?? 0),
    );

    // Contar desafíos de conexión
    final connectionTasks = taskStats.firstWhere(
      (e) => e['category'] == 'Conexión',
      orElse: () => {'completed_count': 0},
    )['completed_count'] as int;

    if (isSolo) {
      return _buildSoloAchievements(
        context,
        totalTasks: totalTasks,
        totalXp: totalXp,
        onRefresh: onRefresh,
      );
    }

    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          SectionLabel(label: t.achievementsBadgesSection, icon: '🏅'),
          const SizedBox(height: 20),
          _buildAchievementCard(
            context,
            title: t.achievementsFirstStepsTitle,
            description: t.achievementsFirstStepsDesc,
            icon: '🌱',
            isUnlocked: totalTasks >= 1,
            progress: totalTasks >= 1 ? 1.0 : 0.0,
            progressText: totalTasks >= 1 ? '1/1' : '0/1',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsUnstoppableTitle,
            description: t.achievementsUnstoppableDesc,
            icon: '🚀',
            isUnlocked: totalTasks >= 50,
            progress: (totalTasks / 50).clamp(0.0, 1.0),
            progressText: '$totalTasks/50',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsHomeMastersTitle,
            description: t.achievementsHomeMastersDesc,
            icon: '👑',
            isUnlocked: totalXp >= 5000,
            progress: (totalXp / 5000).clamp(0.0, 1.0),
            progressText: '$totalXp/5000',
          ),
          const SizedBox(height: 32),
          SectionLabel(
            label: t.achievementsCoupleChallengesSection,
            icon: '💖',
          ),
          const SizedBox(height: 16),
          _buildAchievementCard(
            context,
            title: t.achievementsCollectorTitle,
            description: t.achievementsSpecialChallengesDesc(7),
            icon: '📸',
            isUnlocked: connectionTasks >= 7,
            progress: (connectionTasks / 7).clamp(0.0, 1.0),
            progressText: '$connectionTasks/7',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsLoveInMotionTitle,
            description: t.achievementsSpecialChallengesDesc(15),
            icon: '💃',
            isUnlocked: connectionTasks >= 15,
            progress: (connectionTasks / 15).clamp(0.0, 1.0),
            progressText: '$connectionTasks/15',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsDeepConnectionTitle,
            description: t.achievementsSpecialChallengesDesc(30),
            icon: '♾️',
            isUnlocked: connectionTasks >= 30,
            progress: (connectionTasks / 30).clamp(0.0, 1.0),
            progressText: '$connectionTasks/30',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsRomanceLegendsTitle,
            description: t.achievementsRomanceLegendsDesc,
            icon: '🏆',
            isUnlocked: connectionTasks >= 50,
            progress: (connectionTasks / 50).clamp(0.0, 1.0),
            progressText: '$connectionTasks/50',
          ),
          const SizedBox(height: 32),
          SectionLabel(label: t.achievementsIconicMomentsSection, icon: '✨'),
          const SizedBox(height: 16),
          _buildChallengeAchievement(
            context,
            title: t.achievementsLoveRootsTitle,
            description: t.achievementsLoveRootsDesc,
            icon: '❤️',
            isUnlocked: connectionTasks >= 1, // Heurístico
          ),
          _buildChallengeAchievement(
            context,
            title: t.achievementsBlindDateTitle,
            description: t.achievementsBlindDateDesc,
            icon: '🕯️',
            isUnlocked: false,
          ),
          _buildChallengeAchievement(
            context,
            title: t.achievementsDreamArchitectsTitle,
            description: t.achievementsDreamArchitectsDesc,
            icon: '✨',
            isUnlocked: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSoloAchievements(
    BuildContext context, {
    required int totalTasks,
    required int totalXp,
    required Future<void> Function() onRefresh,
  }) {
    final t = AppLocalizations.of(context);

    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
        children: [
          SectionLabel(
            label: t.achievementsSoloMilestonesSection,
            icon: '\u{1F331}',
          ),
          const SizedBox(height: 20),
          _buildAchievementCard(
            context,
            title: t.achievementsSoloFirstStepTitle,
            description: t.achievementsSoloFirstStepDesc,
            icon: '\u{1F331}',
            isUnlocked: totalTasks >= 1,
            progress: totalTasks >= 1 ? 1.0 : 0.0,
            progressText: totalTasks >= 1 ? '1/1' : '0/1',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsSoloRoutineTitle,
            description: t.achievementsSoloRoutineDesc,
            icon: '\u{1F9F9}',
            isUnlocked: totalTasks >= 50,
            progress: (totalTasks / 50).clamp(0.0, 1.0),
            progressText: '$totalTasks/50',
          ),
          _buildAchievementCard(
            context,
            title: t.achievementsSoloHomeClearTitle,
            description: t.achievementsSoloHomeClearDesc,
            icon: '\u{2728}',
            isUnlocked: totalXp >= 5000,
            progress: (totalXp / 5000).clamp(0.0, 1.0),
            progressText: '$totalXp/5000',
          ),
          const SizedBox(height: 32),
          SectionLabel(
            label: t.achievementsSoloNextSection,
            icon: '\u{1F4CD}',
          ),
          const SizedBox(height: 16),
          _buildChallengeAchievement(
            context,
            title: t.achievementsSoloWeekTitle,
            description: t.achievementsSoloWeekDesc,
            icon: '\u{1F4C6}',
            isUnlocked: totalTasks >= 7,
          ),
          _buildChallengeAchievement(
            context,
            title: t.achievementsSoloRhythmTitle,
            description: t.achievementsSoloRhythmDesc,
            icon: '\u{1F501}',
            isUnlocked: totalTasks >= 20,
          ),
          _buildChallengeAchievement(
            context,
            title: t.achievementsSoloOwnSpaceTitle,
            description: t.achievementsSoloOwnSpaceDesc,
            icon: '\u{1F3E0}',
            isUnlocked: totalXp >= 3000,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required bool isUnlocked,
    required double progress,
    required String progressText,
  }) {
    final theme = context.theme;
    final accentColor = isUnlocked ? AppColors.accentGold : AppColors.primary;

    // Contenido pintado dos veces (técnica drench de bunpod): la copia
    // [onFill] va con paleta invertida y se clipea al avance del relleno,
    // así el texto cambia de color justo donde lo cruza el progreso.
    Widget content({required bool onFill}) {
      final titleColor = onFill
          ? Colors.white
          : (isUnlocked ? theme.textPrimary : theme.textMuted);
      final bodyColor =
          onFill ? Colors.white.withValues(alpha: 0.85) : theme.textSecondary;
      final valueColor = onFill
          ? Colors.white
          : (isUnlocked ? AppColors.accentGold : AppColors.textMuted);

      return Row(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: ConceptIcon(emoji: icon, size: 52),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w500,
                    color: bodyColor,
                  ),
                ),
                const SizedBox(height: 10),
                _achievementProgressHint(
                  progress: progress,
                  color: onFill ? Colors.white : accentColor,
                  isUnlocked: isUnlocked,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            progressText,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      );
    }

    return AppProgressFillCard(
      progress: progress,
      accentColor: accentColor,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(20),
      borderColor: isUnlocked
          ? AppColors.accentGold.withValues(alpha: 0.2)
          : theme.border.withValues(alpha: 0.45),
      drenchedChild: content(onFill: true),
      child: content(onFill: false),
    );
  }

  Widget _achievementProgressHint({
    required double progress,
    required Color color,
    required bool isUnlocked,
  }) {
    final clamped = progress.clamp(0.0, 1.0).toDouble();
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: clamped,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isUnlocked ? 0.92 : 0.45),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
          ),
        ),
        if (isUnlocked) ...[
          const SizedBox(width: AppSpacing.xs),
          Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: color.withValues(alpha: 0.9),
          ),
        ],
      ],
    );
  }

  Widget _buildChallengeAchievement(
    BuildContext context, {
    required String title,
    required String description,
    required String icon,
    required bool isUnlocked,
  }) {
    final theme = context.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isUnlocked ? theme.surface : theme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          ConceptIcon(emoji: isUnlocked ? icon : '🔒', size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyStrong.copyWith(
                    color: isUnlocked ? theme.textPrimary : theme.textMuted,
                  ),
                ),
                if (isUnlocked)
                  Text(
                    description,
                    style: AppTypography.caption.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: theme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 20,
            )
          else
            const Icon(
              Icons.lock_outline_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
        ],
      ),
    );
  }
}
