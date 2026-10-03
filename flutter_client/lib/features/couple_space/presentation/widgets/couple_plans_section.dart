import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/errors/error_messages.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_plan.dart';
import 'package:homesync_client/features/couple_space/presentation/providers/couple_plans_providers.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/design/app_section_header.dart';
import 'package:homesync_client/shared/widgets/design/app_sheet_shell.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';

class CouplePlansSection extends ConsumerStatefulWidget {
  final String householdId;
  final Widget note;

  const CouplePlansSection({
    super.key,
    required this.householdId,
    required this.note,
  });

  @override
  ConsumerState<CouplePlansSection> createState() => _CouplePlansSectionState();
}

class _CouplePlansSectionState extends ConsumerState<CouplePlansSection> {
  CouplePlan _selected = CouplePlan.movies;
  bool _busy = false;

  @override
  void didUpdateWidget(covariant CouplePlansSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.householdId != widget.householdId) {
      _selected = CouplePlan.movies;
    }
  }

  Future<void> _act(CouplePlanAction action) async {
    if (_busy) return;
    final household = widget.householdId;
    setState(() => _busy = true);
    try {
      await ref
          .read(couplePlansRepositoryProvider)
          .act(household, _selected, action);
      if (!mounted || household != widget.householdId) return;
      ref.invalidate(couplePlanProgressProvider(household));
      await ref.read(couplePlanProgressProvider(household).future);
      if (mounted && action == CouplePlanAction.complete) AppHaptics.success();
    } catch (error) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: friendlyErrorMessage(error, t: AppLocalizations.of(context)),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSaved() {
    AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final t = AppLocalizations.of(context);
          final progress =
              ref.watch(couplePlanProgressProvider(widget.householdId));
          return AppSheetShell(
            title: t.couplePlansSavedTitle,
            child: progress.when(
              loading: () => const ShimmerLoading(height: 100),
              error: (_, __) => AppInlineError(
                message: t.couplePlansError,
                onRetry: () => ref
                    .invalidate(couplePlanProgressProvider(widget.householdId)),
              ),
              data: (rows) {
                final saved = CouplePlan.values.where(
                  (p) => rows.any((r) => r.planId == p.name && r.saved),
                );
                if (saved.isEmpty) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Text(
                      t.couplePlansSavedEmpty,
                      style: AppTypography.body
                          .copyWith(color: context.theme.textSecondary),
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final plan in saved)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: CoupleSurface(
                            onTap: () {
                              setState(() => _selected = plan);
                              Navigator.of(sheetContext).pop();
                            },
                            child: Row(
                              children: [
                                CoupleArt(
                                  kind: CoupleArtKind.values[plan.index],
                                  size: 52,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    plan.title(t),
                                    style: AppTypography.cardTitle.copyWith(
                                      color: context.theme.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: context.theme.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final progress = ref.watch(couplePlanProgressProvider(widget.householdId));
    return progress.when(
      skipLoadingOnReload: true,
      loading: () =>
          const ShimmerLoading(height: 340, borderRadius: AppRadii.xxl),
      error: (_, __) => Column(
        children: [
          AppInlineError(
            message: t.couplePlansError,
            onRetry: () =>
                ref.invalidate(couplePlanProgressProvider(widget.householdId)),
          ),
          const SizedBox(height: AppSpacing.sm),
          widget.note,
        ],
      ),
      data: (rows) => CouplePlansView(
        selected: _selected,
        progress: rows,
        note: widget.note,
        busy: _busy,
        onAction: _act,
        onNext: () => setState(
          () => _selected = CouplePlan
              .values[(_selected.index + 1) % CouplePlan.values.length],
        ),
        onSelect: (plan) => setState(() => _selected = plan),
        onSaved: _showSaved,
      ),
    );
  }
}

/// Network-independent view, also used for real Flutter visual previews.
class CouplePlansView extends StatelessWidget {
  final CouplePlan selected;
  final List<CouplePlanProgress> progress;
  final Widget note;
  final bool busy;
  final ValueChanged<CouplePlanAction> onAction;
  final VoidCallback onNext;
  final ValueChanged<CouplePlan> onSelect;
  final VoidCallback onSaved;

  const CouplePlansView({
    super.key,
    required this.selected,
    required this.progress,
    required this.note,
    required this.busy,
    required this.onAction,
    required this.onNext,
    required this.onSelect,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final current =
        progress.where((p) => p.planId == selected.name).firstOrNull;
    final completed = current?.completed ?? false;
    final saved = current?.saved ?? false;
    final count = CouplePlan.values
        .where((p) => progress.any((r) => r.planId == p.name && r.completed))
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: t.couplePlansTitle,
          subtitle: t.couplePlansSubtitle,
        ),
        const SizedBox(height: AppSpacing.md),
        CoupleSurface(
          radius: AppRadii.xxl,
          color: Color.alphaBlend(
            AppColors.accentPeach
                .withValues(alpha: theme.isDarkMode ? 0.12 : 0.10),
            theme.surface,
          ),
          borderColor: AppColors.accentPeach.withValues(alpha: 0.15),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: AppMotion.reduce(context)
                    ? Duration.zero
                    : AppMotion.normal,
                child: CoupleArt(
                  key: ValueKey('${selected.name}-$completed'),
                  kind: completed
                      ? CoupleArtKind.medal
                      : CoupleArtKind.values[selected.index],
                  size: 152,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                completed ? t.couplePlansUnlocked : selected.details(t),
                textAlign: TextAlign.center,
                style:
                    AppTypography.caption.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                selected.title(t),
                textAlign: TextAlign.center,
                style: AppTypography.sectionTitle
                    .copyWith(color: theme.textPrimary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                completed ? selected.stamp(t) : selected.description(t),
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(color: theme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _PlanButton(
                    label:
                        completed ? t.couplePlansUndo : t.couplePlansComplete,
                    icon: completed ? Icons.undo_rounded : Icons.check_rounded,
                    primary: !completed,
                    onTap: busy
                        ? null
                        : () => onAction(
                              completed
                                  ? CouplePlanAction.undo
                                  : CouplePlanAction.complete,
                            ),
                  ),
                  _PlanButton(
                    label: saved ? t.couplePlansSaved : t.couplePlansSave,
                    icon: saved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    selected: saved,
                    onTap: busy
                        ? null
                        : () => onAction(
                              saved
                                  ? CouplePlanAction.unsave
                                  : CouplePlanAction.save,
                            ),
                  ),
                ],
              ),
              if (busy) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primary,
                  ),
                ),
              ],
              TextButton.icon(
                onPressed: busy ? null : onNext,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: Text(t.couplePlansNext),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        note,
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: Text(
                t.couplePlansAlbum,
                style: AppTypography.sectionTitle
                    .copyWith(color: theme.textPrimary),
              ),
            ),
            Text(
              t.couplePlansCount(count, CouplePlan.values.length),
              style: AppTypography.caption.copyWith(color: theme.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.md,
          children: [
            for (final plan in CouplePlan.values)
              _AlbumStamp(
                plan: plan,
                earned:
                    progress.any((p) => p.planId == plan.name && p.completed),
                onTap: busy ? null : () => onSelect(plan),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          t.couplePlansAlbumHint,
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: theme.textSecondary),
        ),
        Align(
          alignment: Alignment.center,
          child: TextButton.icon(
            onPressed: busy ? null : onSaved,
            icon: const Icon(Icons.bookmark_border_rounded, size: 18),
            label: Text(t.couplePlansSavedTitle),
          ),
        ),
      ],
    );
  }
}

class _PlanButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final bool selected;
  final VoidCallback? onTap;
  const _PlanButton({
    required this.label,
    required this.icon,
    this.primary = false,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    // Warm dark ink keeps the brand orange readable in both themes (> 5:1).
    final foreground = primary
        ? AppColors.backgroundDark
        : selected
            ? theme.textPrimary
            : theme.textSecondary;
    return AnimatedPress(
      onTap: onTap,
      selected: selected,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: primary ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.bodyStrong.copyWith(color: foreground),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlbumStamp extends StatelessWidget {
  final CouplePlan plan;
  final bool earned;
  final VoidCallback? onTap;
  const _AlbumStamp({
    required this.plan,
    required this.earned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return AnimatedPress(
      onTap: onTap,
      semanticLabel:
          '${plan.stamp(t)}. ${earned ? t.couplePlansCompletedLabel : t.couplePlansDiscoverLabel}',
      child: ExcludeSemantics(
        child: SizedBox(
          width: MediaQuery.textScalerOf(context).scale(62),
          child: Column(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: earned
                      ? AppColors.accentGold.withValues(alpha: 0.15)
                      : theme.surface,
                  border: Border.all(
                    color: earned ? AppColors.accentGold : theme.border,
                    width: 2,
                  ),
                ),
                child: Opacity(
                  opacity: earned ? 1 : 0.32,
                  child: CoupleArt(
                    kind: CoupleArtKind.values[plan.index],
                    size: 54,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                plan.stamp(t),
                textAlign: TextAlign.center,
                style:
                    AppTypography.caption.copyWith(color: theme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
