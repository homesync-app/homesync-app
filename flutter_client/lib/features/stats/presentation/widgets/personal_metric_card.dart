import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

class PersonalMetricCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String subtitle;
  final Color color;

  const PersonalMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        boxShadow: theme.cardShadow,
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(icon, style: AppTypography.body.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),),
              ),
              const SizedBox(width: 10),
              Text(
                label.toUpperCase(),
                style: AppTypography.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: theme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: AppTypography.heroAmount.copyWith(
              fontSize: 24,
              height: 1,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: color.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
