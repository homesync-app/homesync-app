import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';

class CoupleProposalDraft {
  final String title;
  final String? description;
  final CoupleProposalCategory category;

  const CoupleProposalDraft({
    required this.title,
    required this.description,
    required this.category,
  });
}

enum CoupleProposalDecision { accept, defer, decline, withdraw, archive }

Future<CoupleProposalDraft?> showCoupleProposalEditor(
  BuildContext context,
) async {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  var selectedCategory = CoupleProposalCategory.talk;
  String? validationError;

  final result = await AppSheet.show<CoupleProposalDraft>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      final t = AppLocalizations.of(sheetContext);
      return StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: theme.surface,
              borderRadius: AppRadii.sheet,
              boxShadow: theme.modalShadow,
            ),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              12,
              AppSpacing.lg,
              MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SheetHandle(),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    t.coupleSpaceNewProposalTitle,
                    style: AppTypography.screenTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    t.coupleSpaceNewProposalBody,
                    style: AppTypography.body.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextField(
                    controller: titleController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 120,
                    decoration: InputDecoration(
                      labelText: t.coupleSpaceProposalTitleLabel,
                      hintText: t.coupleSpaceProposalTitleHint,
                      errorText: validationError,
                    ),
                    onChanged: (_) {
                      if (validationError != null) {
                        setSheetState(() => validationError = null);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descriptionController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: t.coupleSpaceProposalDescriptionLabel,
                      hintText: t.coupleSpaceProposalDescriptionHint,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    t.coupleSpaceProposalCategoryLabel,
                    style: AppTypography.bodyStrong.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final category in CoupleProposalCategory.values)
                        ChoiceChip(
                          selected: selectedCategory == category,
                          label: Text(_categoryLabel(t, category)),
                          avatar: Icon(
                            _categoryIcon(category),
                            size: 17,
                            color: selectedCategory == category
                                ? AppColors.primary
                                : AppColors.sage,
                          ),
                          onSelected: (_) => setSheetState(
                            () => selectedCategory = category,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: AppControlSizes.buttonHeight,
                    child: FilledButton.icon(
                      onPressed: () {
                        final title = titleController.text.trim();
                        if (title.length < 3) {
                          setSheetState(
                            () => validationError =
                                t.coupleSpaceProposalTitleValidation,
                          );
                          return;
                        }
                        final description = descriptionController.text.trim();
                        Navigator.pop(
                          context,
                          CoupleProposalDraft(
                            title: title,
                            description:
                                description.isEmpty ? null : description,
                            category: selectedCategory,
                          ),
                        );
                      },
                      icon: const Icon(Icons.send_rounded, size: 19),
                      label: Text(t.coupleSpaceProposalSend),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  descriptionController.dispose();
  return result;
}

Future<CoupleProposalDecision?> showCoupleProposalDecisionSheet(
  BuildContext context, {
  required CoupleProposal proposal,
  required bool isMine,
}) {
  return AppSheet.show<CoupleProposalDecision>(
    context: context,
    useSafeArea: true,
    builder: (sheetContext) {
      final theme = sheetContext.theme;
      final t = AppLocalizations.of(sheetContext);
      return Container(
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: AppRadii.sheet,
          boxShadow: theme.modalShadow,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          12,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: AppSpacing.md),
            Text(
              proposal.isAccepted
                  ? t.coupleSpaceProposalAccepted
                  : t.coupleSpaceProposalResponseTitle,
              style: AppTypography.screenTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              proposal.title,
              style: AppTypography.cardTitle.copyWith(
                color: theme.textPrimary,
              ),
            ),
            if (proposal.description?.isNotEmpty ?? false) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                proposal.description!,
                style: AppTypography.body.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              proposal.isAccepted
                  ? t.coupleSpacePlansSubtitle
                  : t.coupleSpaceProposalResponseBody,
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                color: theme.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (proposal.isAccepted)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(
                    sheetContext,
                    CoupleProposalDecision.archive,
                  ),
                  icon: const Icon(Icons.archive_outlined),
                  label: Text(t.coupleSpaceProposalArchive),
                ),
              )
            else if (isMine)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(
                    sheetContext,
                    CoupleProposalDecision.withdraw,
                  ),
                  icon: const Icon(Icons.undo_rounded),
                  label: Text(t.coupleSpaceProposalWithdraw),
                ),
              )
            else ...[
              SizedBox(
                width: double.infinity,
                height: AppControlSizes.buttonHeight,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(
                    sheetContext,
                    CoupleProposalDecision.accept,
                  ),
                  icon: const Icon(Icons.favorite_rounded, size: 19),
                  label: Text(t.coupleSpaceProposalAccept),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (!proposal.isDeferred) ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      sheetContext,
                      CoupleProposalDecision.defer,
                    ),
                    child: Text(t.coupleSpaceProposalDefer),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
              ],
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(
                    sheetContext,
                    CoupleProposalDecision.decline,
                  ),
                  child: Text(t.coupleSpaceProposalDecline),
                ),
              ),
            ],
          ],
        ),
      );
    },
  );
}

String coupleProposalCategoryLabel(
  AppLocalizations t,
  CoupleProposalCategory category,
) =>
    _categoryLabel(t, category);

IconData coupleProposalCategoryIcon(CoupleProposalCategory category) =>
    _categoryIcon(category);

String _categoryLabel(
  AppLocalizations t,
  CoupleProposalCategory category,
) {
  return switch (category) {
    CoupleProposalCategory.talk => t.coupleSpaceProposalCategoryTalk,
    CoupleProposalCategory.plan => t.coupleSpaceProposalCategoryPlan,
    CoupleProposalCategory.affection => t.coupleSpaceProposalCategoryAffection,
    CoupleProposalCategory.support => t.coupleSpaceProposalCategorySupport,
  };
}

IconData _categoryIcon(CoupleProposalCategory category) {
  return switch (category) {
    CoupleProposalCategory.talk => Icons.forum_outlined,
    CoupleProposalCategory.plan => Icons.calendar_month_outlined,
    CoupleProposalCategory.affection => Icons.favorite_border_rounded,
    CoupleProposalCategory.support => Icons.volunteer_activism_outlined,
  };
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: context.theme.border,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );
  }
}
