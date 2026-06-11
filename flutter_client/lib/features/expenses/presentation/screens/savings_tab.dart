import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/amount_input.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/features/savings/domain/models/savings_model.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/edge_fade.dart';

class SavingsTab extends ConsumerWidget {
  const SavingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsGoalsProvider);
    final t = AppLocalizations.of(context);

    return goalsAsync.when(
      loading: () => const Center(child: AppLoader()),
      error: (e, _) => Center(child: Text(t.savingsLoadError(e.toString()))),
      data: (goals) {
        if (goals.isEmpty) {
          return _buildEmptyState(
            t.savingsEmptyTitle,
            icon: '🎯',
            subtitle: t.savingsEmptySubtitle,
            fallbackSubtitle: t.savingsEmptyFallbackSubtitle,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(savingsGoalsProvider),
          child: EdgeFade(
            fadeStart: false,
            fadeEnd: true,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: goals.length,
              separatorBuilder: (context, index) => const SizedBox(height: 20),
              itemBuilder: (context, index) =>
                  _buildGoalCard(context, goals[index], ref)
                      .animateStaggered(index),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildEmptyState(
    String message, {
    String icon = '📉',
    String? subtitle,
    String? fallbackSubtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child:
                Text(icon, style: const TextStyle(fontSize: 48)).animatePulse(),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
            child: Text(
              subtitle ??
                  fallbackSubtitle ??
                  'Start organizing your household finances today.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animateEntrance();
  }

  static Widget _buildGoalCard(
    BuildContext context,
    SavingsGoalModel goal,
    WidgetRef ref,
  ) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return AnimatedPress(
      onTap: () => _showContributionDialog(context, goal, ref),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.modal),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.fromHex(goal.color).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(goal.icon, style: const TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t.savingsGoalTarget(
                          ref.read(currencyProvider).format(goal.targetAmount),
                        ),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      t.savingsGoalProgressCaption,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppColors.divider,
              valueColor: AlwaysStoppedAnimation(AppColors.fromHex(goal.color)),
              borderRadius: BorderRadius.circular(10),
              minHeight: 10,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.savingsGoalSaved(
                    ref.read(currencyProvider).format(goal.currentAmount),
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_circle_outline_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        t.savingsGoalContributeAction,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void showGoalSheet(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedEmoji = '🎯';
    Color selectedColor = AppColors.primary;

    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          final t = AppLocalizations.of(context);
          final theme = context.theme;

          return Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  color: context.theme.background,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(36)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 46,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.divider,
                          borderRadius: BorderRadius.circular(AppRadii.pill),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.xs,
                            AppSpacing.lg,
                            AppSpacing.lg + bottomInset,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 84,
                                    height: 84,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.1),
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.xxl),
                                    ),
                                    child: const Icon(
                                      Icons.flag_rounded,
                                      color: AppColors.primary,
                                      size: 38,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          t.savingsNewGoalTitle,
                                          style: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w900,
                                            color: theme.textPrimary,
                                            letterSpacing: -1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          t.savingsNewGoalSubtitle,
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.4,
                                            color: theme.textSecondary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Text(
                                t.savingsSectionDetail,
                                style: TextStyle(
                                  color: theme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.savingsSectionDetailTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: titleController,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: theme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .expensesSavingsGoalNameLabel,
                                  hintText: AppLocalizations.of(context)
                                      .expensesSavingsGoalNameHint,
                                  prefixIcon: const Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.primary,
                                  ),
                                  filled: true,
                                  fillColor: theme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: BorderSide(
                                      color: theme.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: BorderSide(
                                      color: theme.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [ThousandsInputFormatter()],
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 22,
                                  color: theme.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  labelText: AppLocalizations.of(context)
                                      .expensesSavingsGoalAmountLabel,
                                  hintText: AppLocalizations.of(context)
                                      .expensesSavingsGoalAmountHint,
                                  prefixText:
                                      ref.watch(currencyProvider).inputPrefix(),
                                  prefixStyle: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                    color: theme.textSecondary,
                                  ),
                                  filled: true,
                                  fillColor: theme.surface,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: BorderSide(
                                      color: theme.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: BorderSide(
                                      color: theme.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppRadii.xxl),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                t.savingsSectionPersonalization,
                                style: TextStyle(
                                  color: theme.textMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                t.savingsSectionPersonalizationTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: theme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  _buildGoalOption(
                                    context: context,
                                    label: t.savingsFieldEmoji,
                                    value: selectedEmoji,
                                    onTap: () {
                                      final emojis = [
                                        '🎯',
                                        '🏡',
                                        '✈️',
                                        '🚗',
                                        '💍',
                                        '🛋️',
                                        '🍼',
                                        '🎓',
                                        '🐶',
                                        '💻',
                                      ];
                                      _showSimplePicker(
                                        context,
                                        t.savingsPickIconTitle,
                                        emojis,
                                        (e) => setModalState(
                                          () => selectedEmoji = e,
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 14),
                                  _buildGoalOption(
                                    context: context,
                                    label: t.savingsFieldColor,
                                    value: '',
                                    customValue: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: selectedColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    onTap: () {
                                      final colors = [
                                        AppColors.primary,
                                        AppColors.accentTeal,
                                        AppColors.accentGold,
                                        AppColors.accentPurple,
                                        AppColors.accentRed,
                                        AppColors.success,
                                      ];
                                      _showColorPicker(
                                        context,
                                        t.savingsPickColorTitle,
                                        colors,
                                        (c) => setModalState(
                                          () => selectedColor = c,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          18,
                          24,
                          20 + MediaQuery.of(context).padding.bottom,
                        ),
                        decoration: BoxDecoration(
                          color: theme.surface,
                          border: Border(
                            top: BorderSide(color: theme.border),
                          ),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                t.commonCancel,
                                style: TextStyle(
                                  color: theme.textMuted,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: SizedBox(
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: () {
                                    final title = titleController.text.trim();
                                    final amount = parseAmountInput(
                                      amountController.text,
                                    );

                                    if (title.isNotEmpty && amount > 0) {
                                      ref
                                          .read(savingsGoalsProvider.notifier)
                                          .addGoal(
                                            title,
                                            amount,
                                            '#${selectedColor.toARGB32().toRadixString(16).substring(2)}',
                                            selectedEmoji,
                                          );
                                      Navigator.pop(context);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppRadii.xl),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    t.savingsCreateGoalAction,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static void _showContributionDialog(
    BuildContext context,
    SavingsGoalModel goal,
    WidgetRef ref,
  ) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = context.theme;
        final amountController = TextEditingController();
        final t = AppLocalizations.of(context);
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 24,
            right: 24,
          ),
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.modal),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color:
                          AppColors.fromHex(goal.color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child:
                        Text(goal.icon, style: const TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.savingsContributeTo,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          goal.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextField(
                controller: amountController,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsInputFormatter()],
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  prefixText: ref.watch(currencyProvider).inputPrefix(),
                  prefixStyle: const TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount = parseAmountInput(amountController.text);
                    if (amount > 0) {
                      await ref
                          .read(savingsGoalsProvider.notifier)
                          .contribute(goal.id, amount, goalTitle: goal.title);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    t.savingsConfirmContribution,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildGoalOption({
    required BuildContext context,
    required String label,
    required String value,
    Widget? customValue,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: theme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (customValue != null)
                    customValue
                  else
                    Text(
                      value,
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  const Spacer(),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: theme.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showSimplePicker(
    BuildContext context,
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    AppSheet.show(
      context: context,
      backgroundColor: context.theme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        final theme = context.theme;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: options.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () {
                    onSelect(options[index]);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: theme.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      options[index],
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showColorPicker(
    BuildContext context,
    String title,
    List<Color> colors,
    Function(Color) onSelect,
  ) {
    AppSheet.show(
      context: context,
      backgroundColor: context.theme.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
      ),
      builder: (context) {
        final theme = context.theme;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: colors
                    .map(
                      (c) => GestureDetector(
                        onTap: () {
                          onSelect(c);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.border, width: 2),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
