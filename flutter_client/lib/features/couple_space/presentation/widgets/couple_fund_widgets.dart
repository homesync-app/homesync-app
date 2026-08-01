import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_fund.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';

/// Título localizado de una meta del catálogo. Las metas a medida traen su
/// propio título escrito por la pareja, así que caen al valor guardado.
String fundGoalTitle(AppLocalizations t, String? catalogKey, String stored) {
  return switch (catalogKey) {
    'movie_night' => t.coupleFundCatalogMovieNight,
    'picnic' => t.coupleFundCatalogPicnic,
    'dinner_out' => t.coupleFundCatalogDinnerOut,
    'day_trip' => t.coupleFundCatalogDayTrip,
    'weekend_away' => t.coupleFundCatalogWeekendAway,
    _ => stored,
  };
}

class FundGoalDraft {
  final String title;
  final int cost;
  final String icon;
  final String? catalogKey;

  const FundGoalDraft({
    required this.title,
    required this.cost,
    required this.icon,
    required this.catalogKey,
  });
}

/// El bloque "Nuestro fondo".
///
/// Muestra un solo número para los dos: sin desglose por persona y sin "vos
/// aportaste X". Esa conversación pertenece al reparto de la semana, en tareas
/// y tiempo, no acá.
class CoupleFundCard extends StatelessWidget {
  final HouseholdFund fund;
  final String? currentUserId;
  final bool isBusy;
  final VoidCallback onChooseGoal;
  final VoidCallback onConfirm;
  final VoidCallback onWithdrawConfirmation;

  const CoupleFundCard({
    super.key,
    required this.fund,
    required this.currentUserId,
    required this.isBusy,
    required this.onChooseGoal,
    required this.onConfirm,
    required this.onWithdrawConfirmation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final goal = fund.goal;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.coupleFundEyebrow,
            style: AppTypography.eyebrow.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('🪙', style: AppTypography.body.copyWith(fontSize: 26)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${fund.balance}',
                  style: AppTypography.heroAmount.copyWith(
                    color: theme.textPrimary,
                    fontFeatures: kTabularFigures,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (goal == null)
            _NoGoal(onChooseGoal: isBusy ? null : onChooseGoal)
          else ...[
            _GoalProgress(fund: fund, goal: goal),
            const SizedBox(height: AppSpacing.md),
            if (goal.isReady)
              _UnlockRitual(
                fund: fund,
                goal: goal,
                currentUserId: currentUserId,
                isBusy: isBusy,
                onConfirm: onConfirm,
                onWithdraw: onWithdrawConfirmation,
              )
            else
              _SecondaryAction(
                label: t.coupleFundChangeGoal,
                onPressed: isBusy ? null : onChooseGoal,
              ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            '${t.coupleFundWeekAdded(fund.weekEarned)} · '
            '${t.coupleFundRhythm(fund.rhythmWeeks, fund.rhythmWindow)}',
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _NoGoal extends StatelessWidget {
  final VoidCallback? onChooseGoal;

  const _NoGoal({required this.onChooseGoal});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.coupleFundNoGoalTitle,
          style: AppTypography.cardTitle.copyWith(color: theme.textPrimary),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          t.coupleFundNoGoalBody,
          style: AppTypography.body.copyWith(color: theme.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: AppControlSizes.buttonHeight,
          child: FilledButton.icon(
            onPressed: onChooseGoal,
            icon: const Icon(Icons.flag_rounded, size: 19),
            label: Text(t.coupleFundChooseGoal),
          ),
        ),
      ],
    );
  }
}

class _GoalProgress extends StatelessWidget {
  final HouseholdFund fund;
  final FundGoal goal;

  const _GoalProgress({required this.fund, required this.goal});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final title = fundGoalTitle(t, goal.catalogKey, goal.title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          child: SizedBox(
            height: 8,
            child: LinearProgressIndicator(
              value: fund.progress,
              backgroundColor: theme.surfaceContainer,
              valueColor: AlwaysStoppedAnimation(
                goal.isReady ? AppColors.accentGold : AppColors.sage,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Text(goal.icon, style: AppTypography.body.copyWith(fontSize: 16)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                t.coupleFundToGoal(fund.balance, goal.cost, title),
                style: AppTypography.caption.copyWith(
                  color: theme.textSecondary,
                  fontFeatures: kTabularFigures,
                ),
              ),
            ),
          ],
        ),
        if (!goal.isReady && fund.remaining > 0) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            t.coupleFundRemaining(fund.remaining),
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// La cerradura de dos llaves. Nadie puede gastar el fondo solo, así que el
/// momento se vuelve compartido en vez de una transacción.
class _UnlockRitual extends StatelessWidget {
  final HouseholdFund fund;
  final FundGoal goal;
  final String? currentUserId;
  final bool isBusy;
  final VoidCallback onConfirm;
  final VoidCallback onWithdraw;

  const _UnlockRitual({
    required this.fund,
    required this.goal,
    required this.currentUserId,
    required this.isBusy,
    required this.onConfirm,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final alreadyConfirmed = goal.confirmedBy(currentUserId);
    final pending = fund.pendingConfirmations;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accentGold.withValues(alpha: 0.10),
        borderRadius: AppRadii.inner(AppRadii.modal, AppSpacing.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.coupleFundReadyTitle,
            style: AppTypography.cardTitle.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            t.coupleFundReadyBody,
            style: AppTypography.body.copyWith(color: theme.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          if (alreadyConfirmed) ...[
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.sage,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    pending > 0
                        ? t.coupleFundWaitingOthers(pending)
                        : t.coupleFundConfirmed,
                    style: AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            _SecondaryAction(
              label: t.coupleFundWithdrawConfirm,
              onPressed: isBusy ? null : onWithdraw,
            ),
          ] else
            SizedBox(
              width: double.infinity,
              height: AppControlSizes.buttonHeight,
              child: FilledButton.icon(
                onPressed: isBusy ? null : onConfirm,
                icon: const Icon(Icons.lock_open_rounded, size: 19),
                label: Text(t.coupleFundConfirm),
              ),
            ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _SecondaryAction({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(onPressed: onPressed, child: Text(label)),
    );
  }
}

/// Elegir la meta. Una sola activa por vez: evita que el fondo se vuelva un
/// grind sin horizonte y hace que el progreso se lea de un vistazo.
Future<FundGoalDraft?> showFundGoalPicker(BuildContext context) async {
  final titleController = TextEditingController();
  final costController = TextEditingController();
  var custom = false;
  String? validationError;

  final result = await AppSheet.show<FundGoalDraft>(
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
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.border,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    t.coupleFundPickerTitle,
                    style: AppTypography.screenTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    t.coupleFundPickerSubtitle,
                    style: AppTypography.body.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (!custom) ...[
                    for (final item in FundGoalCatalogItem.all)
                      _CatalogRow(
                        item: item,
                        onTap: () => Navigator.pop(
                          context,
                          FundGoalDraft(
                            title: fundGoalTitle(t, item.key, item.key),
                            cost: item.cost,
                            icon: item.icon,
                            catalogKey: item.key,
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    _SecondaryAction(
                      label: t.coupleFundCustomOption,
                      onPressed: () => setSheetState(() => custom = true),
                    ),
                  ] else ...[
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.sentences,
                      maxLength: 120,
                      decoration: InputDecoration(
                        labelText: t.coupleFundCustomTitleLabel,
                        errorText: validationError,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: t.coupleFundCustomCostLabel,
                        helperText: t.coupleFundCustomCostHelper,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: AppControlSizes.buttonHeight,
                      child: FilledButton(
                        onPressed: () {
                          final title = titleController.text.trim();
                          final cost = int.tryParse(costController.text.trim());
                          if (title.length < 3) {
                            setSheetState(
                              () => validationError =
                                  t.coupleFundCustomTitleLabel,
                            );
                            return;
                          }
                          if (cost == null || cost < 50 || cost > 2000) {
                            setSheetState(
                              () => validationError =
                                  t.coupleFundCustomCostHelper,
                            );
                            return;
                          }
                          Navigator.pop(
                            context,
                            FundGoalDraft(
                              title: title,
                              cost: cost,
                              icon: '🎯',
                              catalogKey: null,
                            ),
                          );
                        },
                        child: Text(t.coupleFundSave),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  costController.dispose();
  return result;
}

class _CatalogRow extends StatelessWidget {
  final FundGoalCatalogItem item;
  final VoidCallback onTap;

  const _CatalogRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.card,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Text(item.icon, style: AppTypography.body.copyWith(fontSize: 22)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                fundGoalTitle(t, item.key, item.key),
                style: AppTypography.cardTitle.copyWith(
                  color: theme.textPrimary,
                ),
              ),
            ),
            Text(
              '🪙 ${item.cost}',
              style: AppTypography.caption.copyWith(
                color: theme.textSecondary,
                fontFeatures: kTabularFigures,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
