import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class CategoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  const CategoryBarChart({super.key, required this.taskStats});

  @override
  Widget build(BuildContext context) {
    final sorted = [...taskStats]..sort((a, b) =>
        ((b['completed_count'] as num?) ?? 0)
            .compareTo((a['completed_count'] as num?) ?? 0));
    final top = sorted.take(6).toList();
    final maxVal = top.fold<double>(
      1,
      (m, e) => math.max(m, (e['completed_count'] as num?)?.toDouble() ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: top.map((stat) {
          final category = stat['category'] as String? ?? 'general';
          final count = (stat['completed_count'] as num?)?.toDouble() ?? 0;
          final xp = (stat['total_xp'] as num?)?.toInt() ?? 0;
          final pct = count / maxVal;
          final color = AppColors.getCategoryColor(category);
          final icon = AppColors.categoryIcons[category] ?? '📋';
          final name = AppColors.categoryNames[category] ?? category;

          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${count.toInt()} · $xp XP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: pct.clamp(0.02, 1.0),
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$count tareas completadas',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '⭐ $xp XP',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
