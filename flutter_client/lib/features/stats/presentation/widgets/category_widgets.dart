import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class CategoryBarChart extends StatelessWidget {
  final List<Map<String, dynamic>> taskStats;
  const CategoryBarChart({super.key, required this.taskStats});

  @override
  Widget build(BuildContext context) {
    if (taskStats.isEmpty) return const SizedBox.shrink();
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final totalValue = taskStats.fold<double>(
      0,
      (sum, item) => sum + ((item['completed_count'] as num?)?.toDouble() ?? 0),
    );

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        boxShadow: theme.cardShadow,
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                t.categoriesImpactDistribution,
                style: AppTypography.eyebrow.copyWith(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  color: theme.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                child: Text(
                  t.categoriesTasksCount(totalValue.toInt()),
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              height: 56,
              child: Row(
                children: taskStats.map((stat) {
                  final category = stat['category'] as String? ?? 'general';
                  final count =
                      (stat['completed_count'] as num?)?.toDouble() ?? 0;
                  final weight = totalValue > 0 ? count / totalValue : 0.0;
                  final color = CategoryMapping.getCategoryColor(category);

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
                                CategoryMapping.categoryIcons[category] ?? '📋',
                                style: AppTypography.body.copyWith(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
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
              final color = CategoryMapping.getCategoryColor(category);
              final name = CategoryMapping.categoryNames[category] ?? category;

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
                    style: AppTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.textSecondary,
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
    final color = CategoryMapping.getCategoryColor(category);
    final icon = CategoryMapping.categoryIcons[category] ?? '📋';
    final name = CategoryMapping.categoryNames[category] ?? category;
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        boxShadow: theme.cardShadow,
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            child: Center(
              child: Text(icon, style: AppTypography.body.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.cardTitle.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: color.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      t.categoriesCompletedCount(count),
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: theme.textSecondary,
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
                style: AppTypography.sectionTitle.copyWith(
                  fontSize: 22,
                  color: color,
                ),
              ),
              Text(
                'XP TOTAL',
                style: AppTypography.eyebrow.copyWith(
                  fontSize: 9,
                  color: color.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
