import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';

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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => controller.animateTo(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.18)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          labels[index],
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : theme.textSecondary,
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w700,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
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
