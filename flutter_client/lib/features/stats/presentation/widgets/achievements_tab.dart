import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
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
    // Definimos algunos logros predeterminados basados en las estadísticas
    final totalTasks = taskStats.fold<int>(
      0,
      (sum, item) => sum + ((item['completed_count'] as num?)?.toInt() ?? 0),
    );
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
          const SectionLabel(label: 'Tus Medallas', icon: '🏅'),
          const SizedBox(height: 20),
          _buildAchievementCard(
            context,
            title: 'Primeros Pasos',
            description: 'Completaste tu primera tarea en pareja.',
            icon: '🌱',
            isUnlocked: totalTasks >= 1,
            progress: totalTasks >= 1 ? 1.0 : 0.0,
            progressText: totalTasks >= 1 ? '1/1' : '0/1',
          ),
          _buildAchievementCard(
            context,
            title: 'Equipo Imparable',
            description: 'Completaron 50 tareas juntos.',
            icon: '🚀',
            isUnlocked: totalTasks >= 50,
            progress: (totalTasks / 50).clamp(0.0, 1.0),
            progressText: '$totalTasks/50',
          ),
          _buildAchievementCard(
            context,
            title: 'Maestros del Hogar',
            description: 'Llegaron a los 5000 XP acumulados.',
            icon: '👑',
            isUnlocked: totalXp >= 5000,
            progress: (totalXp / 5000).clamp(0.0, 1.0),
            progressText: '$totalXp/5000',
          ),
          const SizedBox(height: 32),
          const SectionLabel(label: 'Desafíos de Pareja', icon: '💖'),
          const SizedBox(height: 16),
          _buildAchievementCard(
            context,
            title: 'Coleccionista de Citas',
            description: 'Completaron 7 desafíos especiales.',
            icon: '📸',
            isUnlocked: connectionTasks >= 7,
            progress: (connectionTasks / 7).clamp(0.0, 1.0),
            progressText: '$connectionTasks/7',
          ),
          _buildAchievementCard(
            context,
            title: 'Amor en Movimiento',
            description: 'Completaron 15 desafíos especiales.',
            icon: '💃',
            isUnlocked: connectionTasks >= 15,
            progress: (connectionTasks / 15).clamp(0.0, 1.0),
            progressText: '$connectionTasks/15',
          ),
          _buildAchievementCard(
            context,
            title: 'Conexión Profunda',
            description: 'Completaron 30 desafíos especiales.',
            icon: '♾️',
            isUnlocked: connectionTasks >= 30,
            progress: (connectionTasks / 30).clamp(0.0, 1.0),
            progressText: '$connectionTasks/30',
          ),
          _buildAchievementCard(
            context,
            title: 'Leyendas del Romance',
            description: '¡Completaron los 50 desafíos del año!',
            icon: '🏆',
            isUnlocked: connectionTasks >= 50,
            progress: (connectionTasks / 50).clamp(0.0, 1.0),
            progressText: '$connectionTasks/50',
          ),
          const SizedBox(height: 32),
          const SectionLabel(label: 'Momentos Icónicos', icon: '✨'),
          const SizedBox(height: 16),
          _buildChallengeAchievement(
            title: 'Raíces del Amor',
            description: 'Recrearon su primera cita.',
            icon: '❤️',
            isUnlocked: connectionTasks >= 1, // Heurístico
          ),
          _buildChallengeAchievement(
            title: 'Cita a Ciegas',
            description: 'Completaron una cena a ciegas o sensorial.',
            icon: '🕯️',
            isUnlocked: false,
          ),
          _buildChallengeAchievement(
            title: 'Arquitectos de Sueños',
            description: 'Diseñaron su lista de metas compartidas.',
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: theme.cardShadow,
        border: Border.all(
          color: isUnlocked
              ? AppColors.accentGold.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.02),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.accentGold.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Opacity(
                opacity: isUnlocked ? 1.0 : 0.4,
                child: Text(
                  icon,
                  style: const TextStyle(
                    fontSize: 28,
                  ),
                ),
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
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textPrimary.withValues(alpha: 0.4),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildChallengeAchievement({
    required String title,
    required String description,
    required String icon,
    required bool isUnlocked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isUnlocked ? Colors.white : Colors.black.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Text(
            isUnlocked ? icon : '🔒',
            style: const TextStyle(fontSize: 20),
          ),
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
                    color: isUnlocked
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                if (isUnlocked)
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 20,)
          else
            const Icon(Icons.lock_outline_rounded,
                color: AppColors.textMuted, size: 18,),
        ],
      ),
    );
  }
}
