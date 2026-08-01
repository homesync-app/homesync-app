import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/services/template_service.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';
import 'package:homesync_client/features/tasks/presentation/utils/task_localization.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';

import '../setup_widgets.dart';

/// Paso 7: elegir las tareas iniciales del hogar.
class SetupTaskSelectionStep extends ConsumerWidget {
  final bool isLoadingTemplates;
  final bool hasTemplatesError;
  final bool isSaving;
  final List<Category> categories;
  final Map<String, List<TaskTemplate>> templatesByCategory;
  final VoidCallback onRetryTemplates;
  final VoidCallback onFinish;

  const SetupTaskSelectionStep({
    required this.isLoadingTemplates,
    required this.hasTemplatesError,
    required this.isSaving,
    required this.categories,
    required this.templatesByCategory,
    required this.onRetryTemplates,
    required this.onFinish,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    if (isLoadingTemplates) {
      return const AppLoadingState();
    }
    if (hasTemplatesError) {
      return AppErrorState(
        message: t.setupTemplatesLoadError,
        onRetry: onRetryTemplates,
      );
    }

    final theme = context.theme;
    final wizard = ref.watch(setupWizardControllerProvider);
    final modeKey = wizard.selectedMode ?? 'couple';
    final accent = wizard.modeDesign.accent;

    return Column(
      key: const ValueKey('tasks_v2'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              SetupStepEyebrow(text: t.setupFirstTasksEyebrow, accent: accent),
              const SizedBox(height: 10),
              SetupHeading(
                title: t.setupFirstTasksTitle(modeKey),
                subtitle: t.setupFirstTasksSubtitle(modeKey),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            itemCount: categories.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final category = categories[index];
              final templates = templatesByCategory[category.id] ?? [];
              if (templates.isEmpty) return const SizedBox.shrink();
              final categoryName = localizedTaskCatalogText(
                t,
                category.translationKey,
                category.name,
              );

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 24, bottom: 16, left: 4),
                    child: Text(
                      '${category.icon}  ${categoryName.toUpperCase()}',
                      style: AppTypography.eyebrow.copyWith(
                        fontSize: 12,
                        color: theme.textSecondary.withValues(alpha: 0.82),
                      ),
                    ),
                  ),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: templates
                        .map(
                          (template) => _TaskChip(
                            template: template,
                            accent: accent,
                            isSelected: wizard.selectedTemplateIds
                                .contains(template.id),
                            onTap: () {
                              AppHaptics.selection();
                              ref
                                  .read(setupWizardControllerProvider.notifier)
                                  .toggleTemplate(template.id);
                            },
                          ),
                        )
                        .toList(),
                  ),
                ],
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.96),
            boxShadow: [
              BoxShadow(
                color: theme.shadowBase.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SetupPrimaryButton(
              text: t.setupFinishButton,
              isLoading: isSaving,
              onPressed:
                  wizard.selectedTemplateIds.isNotEmpty ? onFinish : null,
              accent: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskChip extends StatelessWidget {
  final TaskTemplate template;
  final bool isSelected;
  final Color accent;
  final VoidCallback onTap;

  const _TaskChip({
    required this.template,
    required this.isSelected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final title = localizedTaskTemplateTitle(
      AppLocalizations.of(context),
      template,
    );

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accent.withValues(alpha: 0.14)
              : theme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: isSelected
                ? accent.withValues(alpha: 0.28)
                : theme.border.withValues(alpha: 0.9),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: AppTypography.body.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? accent : theme.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_rounded,
                color: accent,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
