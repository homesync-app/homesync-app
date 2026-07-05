import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:motor/motor.dart';

class AppSegmentedTabs extends StatelessWidget {
  final TabController controller;
  final List<String> labels;
  final EdgeInsetsGeometry padding;

  const AppSegmentedTabs({
    super.key,
    required this.controller,
    required this.labels,
    this.padding = const EdgeInsets.all(6),
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return AnimatedBuilder(
      animation: controller.animation!,
      builder: (context, _) {
        return Container(
          padding: padding,
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: theme.border.withValues(alpha: 0.45),
            ),
            boxShadow: theme.cardShadow,
          ),
          child: Row(
            children: List.generate(labels.length, (index) {
              final isSelected = controller.index == index;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index == labels.length - 1 ? 0 : 6,
                  ),
                  child: AnimatedPress(
                    scale: 0.97,
                    haptic: AppPressHaptic.selection,
                    onTap: () => controller.animateTo(index),
                    child: SingleMotionBuilder(
                      motion: const MaterialSpringMotion.standardSpatialFast(),
                      value: isSelected ? 1.0 : 0.0,
                      builder: (context, value, child) {
                        final t = value.clamp(0.0, 1.0).toDouble();
                        final background = Color.lerp(
                          AppColors.primary.withValues(alpha: 0),
                          AppColors.primary.withValues(alpha: 0.12),
                          t,
                        )!;
                        final border = Color.lerp(
                          AppColors.primary.withValues(alpha: 0),
                          AppColors.primary.withValues(alpha: 0.18),
                          t,
                        )!;
                        final foreground = Color.lerp(
                          theme.textSecondary,
                          AppColors.primary,
                          t,
                        )!;
                        final weight = FontWeight.lerp(
                          FontWeight.w700,
                          FontWeight.w800,
                          t,
                        )!;

                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: background,
                            borderRadius: BorderRadius.circular(AppRadii.lg),
                            border: Border.all(color: border),
                          ),
                          child: Center(
                            child: Text(
                              labels[index],
                              style: TextStyle(
                                color: foreground,
                                fontSize: 14,
                                fontWeight: weight,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
