import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class CategoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  const CategoryBarChart({super.key, required this.taskStats});

  @override
  Widget build(BuildContext context) {
    if (taskStats.isEmpty) return const SizedBox.shrink();
    final theme = context.theme;

    final totalValue = taskStats.fold<double>(
        0, (sum, item) => sum + ((item['completed_count'] as num?)?.toDouble() ?? 0));

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: theme.cardShadow,
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DISTRIBUCIÓN DE IMPACTO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalValue.toInt()} TAREAS',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 56,
              child: Row(
                children: taskStats.map((stat) {
                  final category = stat['category'] as String? ?? 'general';
                  final count = (stat['completed_count'] as num?)?.toDouble() ?? 0;
                  final weight = totalValue > 0 ? count / totalValue : 0.0;
                  final color = AppColors.getCategoryColor(category);

                  if (weight < 0.01) return const SizedBox.shrink();

                  return Expanded(
                    flex: (weight * 1000).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Center(
                        child: weight > 0.08
                            ? Text(
                                AppColors.categoryIcons[category] ?? '📋',
                                style: const TextStyle(fontSize: 20),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: taskStats.take(5).map((stat) {
              final category = stat['category'] as String? ?? 'general';
              final color = AppColors.getCategoryColor(category);
              final name = AppColors.categoryNames[category] ?? category;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class CategoryDetailCard extends StatelessWidget {
  final Map<String, dynamic> stat;
  const CategoryDetailCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final category = stat['category'] as String? ?? 'general';
    final count = (stat['completed_count'] as num?)?.toInt() ?? 0;
    final xp = (stat['total_xp'] as num?)?.toInt() ?? 0;
    final color = AppColors.getCategoryColor(category);
    final icon = AppColors.categoryIcons[category] ?? '📋';
    final name = AppColors.categoryNames[category] ?? category;
    final theme = context.theme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: theme.cardShadow,
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0.04)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, size: 14, color: color.withValues(alpha: 0.5)),
                    const SizedBox(width: 4),
                    Text(
                      '$count completadas',
                      style: TextStyle(
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$xp',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: color,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'XP TOTAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: color.withValues(alpha: 0.5),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
