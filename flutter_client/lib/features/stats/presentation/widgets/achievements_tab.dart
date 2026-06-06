import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/concept_icon.dart';
import '../../../../l10n/generated/app_localizations.dart';
import 'stats_shared_widgets.dart';

class AchievementsTab extends StatelessWidget {
  final List<Map<String, dynamic>> memberStats;
  final List<Map<String, dynamic>> taskStats;
  final Future<void> Function() onRefresh;

  const AchievementsTab({
    super.key,
    required this.memberStats,
    required this.taskStats,
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

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.primary,
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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: theme.cardShadow,
        border: Border.all(
          color: isUnlocked
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : theme.border.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: Row(
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
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: isUnlocked ? theme.textPrimary : theme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.surfaceContainer,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isUnlocked
                          ? AppColors.accentGold
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            progressText,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isUnlocked ? AppColors.accentGold : AppColors.textMuted,
            ),
          ),
        ],
      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isUnlocked ? theme.surface : theme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
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
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: isUnlocked ? theme.textPrimary : theme.textMuted,
                  ),
                ),
                if (isUnlocked)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
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
