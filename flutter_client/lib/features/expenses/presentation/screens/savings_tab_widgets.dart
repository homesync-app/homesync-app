part of 'savings_tab.dart';

/// Widgets de visualización del historial de aportes de una meta de ahorro,
/// extraídos de `savings_tab.dart` (god file) para reducir su tamaño. Son
/// `part of` la misma librería, así que comparten imports.

class _ContributionHistory extends ConsumerWidget {
  final String goalId;
  const _ContributionHistory({required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final contributionsAsync = ref.watch(goalContributionsProvider(goalId));

    return contributionsAsync.maybeWhen(
      orElse: () => const SizedBox.shrink(),
      data: (list) {
        if (list.isEmpty) return const SizedBox.shrink();
        final visible = list.take(3).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Divider(height: 1, color: context.theme.divider),
            const SizedBox(height: 12),
            Text(
              t.savingsHistoryTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            for (final c in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Builder(
                  builder: (context) {
                    final participants = c.isSharedContribution
                        ? c.participants
                        : <SavingsContributionParticipant>[
                            SavingsContributionParticipant(
                              userId: c.userId,
                              name: c.userName ?? t.savingsContributionSomeone,
                              avatarUrl: c.userAvatar,
                            ),
                          ];
                    final names = _formatParticipantNames(
                      participants,
                      t.savingsContributionSomeone,
                    );
                    return Row(
                      children: [
                        _ContributionParticipantAvatars(
                          participants: participants,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            c.isSharedContribution
                                ? t.savingsSharedContributionLine(
                                    names,
                                    currency.format(c.amount),
                                  )
                                : t.savingsContributionLine(
                                    names,
                                    currency.format(c.amount),
                                  ),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM').format(c.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  String _formatParticipantNames(
    List<SavingsContributionParticipant> participants,
    String fallback,
  ) {
    final names = participants
        .map((participant) => participant.name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
    if (names.isEmpty) return fallback;
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names.first} y ${names.last}';
    return '${names.take(names.length - 1).join(', ')} y ${names.last}';
  }
}

class _ContributionParticipantAvatars extends StatelessWidget {
  final List<SavingsContributionParticipant> participants;

  const _ContributionParticipantAvatars({required this.participants});

  @override
  Widget build(BuildContext context) {
    final visible = participants.take(3).toList();
    if (visible.isEmpty) {
      return const CustomUserAvatar(
        name: '?',
        radius: 11,
        forceCircular: true,
      );
    }

    return SizedBox(
      width: 22.0 + ((visible.length - 1) * 13),
      height: 24,
      child: Stack(
        children: [
          for (var i = 0; i < visible.length; i++)
            Positioned(
              left: i * 13,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: context.theme.surface,
                    width: 1.5,
                  ),
                ),
                child: CustomUserAvatar(
                  name: visible[i].name,
                  avatarUrl: visible[i].avatarUrl,
                  radius: 11,
                  forceCircular: true,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompletedGoalDetailSheet extends ConsumerWidget {
  final SavingsGoalModel goal;

  const _CompletedGoalDetailSheet({required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final safePadding = MediaQuery.paddingOf(context);

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.78,
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadii.modal),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 46,
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.divider,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.savingsCompletedGoalsHistoryTitle,
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: theme.textSecondary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg + safePadding.bottom,
                    ),
                    child: SavingsTab._buildGoalCard(context, goal, ref),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small "¡Cumplida!" pill shown on reached goals.
class _CompletedBadge extends StatelessWidget {
  final Color color;
  final String label;
  const _CompletedBadge({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

/// Overflow menu (edit / archive / delete) on a goal card. Only built when the
/// current member [SavingsPermissions.canManage].
class _GoalMenu extends ConsumerWidget {
  final SavingsGoalModel goal;
  final bool reached;
  const _GoalMenu({required this.goal, required this.reached});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
      onSelected: (value) async {
        switch (value) {
          case 'edit':
            SavingsTab.showGoalSheet(context, ref, existing: goal);
          case 'auto':
            await GoalAutoContributionSheet.show(context, ref, goal);
          case 'archive':
            await _confirmArchive(context, ref);
          case 'delete':
            await _confirmDelete(context, ref);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 18),
              const SizedBox(width: 10),
              Text(t.savingsEditAction),
            ],
          ),
        ),
        // Aporte automático mensual: solo tiene sentido con la meta viva.
        if (!reached)
          PopupMenuItem(
            value: 'auto',
            child: Row(
              children: [
                const Icon(Icons.autorenew_rounded, size: 18),
                const SizedBox(width: 10),
                Text(t.goalAutoMenuAction),
              ],
            ),
          ),
        if (reached)
          PopupMenuItem(
            value: 'archive',
            child: Row(
              children: [
                const Icon(Icons.archive_outlined, size: 18),
                const SizedBox(width: 10),
                Text(t.savingsArchiveAction),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(
                Icons.delete_outline_rounded,
                size: 18,
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              Text(
                t.savingsDeleteAction,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmArchive(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.savingsArchiveConfirmTitle),
        content: Text(t.savingsArchiveConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.savingsArchiveAction),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(savingsGoalsProvider.notifier).archiveGoal(goal.id);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.savingsDeleteConfirmTitle),
        content: Text(t.savingsDeleteConfirmBody(goal.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              t.savingsDeleteAction,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(savingsGoalsProvider.notifier).removeGoal(goal.id);
    }
  }
}

/// "Ahorro Total" header summarising every active goal.
class _TotalSavingsHeader extends ConsumerWidget {
  final List<SavingsGoalModel> goals;
  const _TotalSavingsHeader({required this.goals});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final total = goals.fold<double>(0, (sum, g) => sum + g.currentAmount);
    final completed = goals.where((g) => g.isReached).length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 22,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.surface, theme.surfaceVariant],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.modal),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        children: [
          Text(
            t.savingsTotalLabel,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currency.format(total),
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 37,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stat(
                theme,
                t.savingsStatGoals,
                '${goals.length}',
                AppColors.sage,
              ),
              const SizedBox(width: 34),
              _stat(
                theme,
                t.savingsStatCompleted,
                '$completed',
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(AppThemeColors theme, String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Optional surplus-based nudge to keep saving. Hidden when there is nothing
/// relevant to suggest.
class _SavingsSuggesterCard extends ConsumerWidget {
  const _SavingsSuggesterCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionAsync = ref.watch(savingsSuggesterProvider);
    final suggestion = suggestionAsync.value;
    if (suggestion == null) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final currency = ref.watch(currencyProvider);
    final perms = ref.watch(savingsPermissionsProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.savingsSuggesterMessage(
                    currency.format(suggestion.surplus),
                    suggestion.percentageBoost.toStringAsFixed(1),
                    suggestion.goal.title,
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (perms.canContribute) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => SavingsTab._showContributionDialog(
                      context,
                      suggestion.goal,
                      ref,
                    ),
                    child: Text(
                      t.savingsSuggesterCta,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet to add money to a goal, with a "solo yo / entre todos"
/// attribution selector (hidden when the household has no split economy or the
/// member is not part of the finance split).
class _ContributionSheet extends ConsumerStatefulWidget {
  final SavingsGoalModel goal;
  const _ContributionSheet({required this.goal});

  @override
  ConsumerState<_ContributionSheet> createState() => _ContributionSheetState();
}

class _ContributionSheetState extends ConsumerState<_ContributionSheet> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  _ContributionSplit _split = _ContributionSplit.solo;
  bool _submitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<MemberModel> _financeMembers(
    List<MemberModel> members,
    HouseholdType type,
  ) {
    if (type != HouseholdType.family) return members;
    final adults = members.where((m) => m.isAdult).toList();
    return adults.isNotEmpty ? adults : members;
  }

  Future<void> _submit() async {
    final amount = parseAmountInput(_amountController.text);
    if (amount <= 0 || _submitting) return;
    setState(() => _submitting = true);

    // Capture navigation handles up front so we never touch a BuildContext
    // across an async gap (the sheet's own context is also defunct after pop).
    final navigator = Navigator.of(context);
    final navigatorContext = navigator.context;

    final note = _noteController.text.trim();
    SplitType splitType = SplitType.personal;
    List<Map<String, dynamic>>? splits;

    if (_split == _ContributionSplit.shared) {
      final caps = ref.read(householdCapabilitiesProvider);
      final household = ref.read(currentHouseholdProvider).value;
      final members = await ref.read(householdMembersProvider.future);
      final financeMembers = _financeMembers(members, caps.type);
      final isSharedEconomy = household?.financeMode == 'shared';
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.equal,
        amount: amount,
        paidByUserId: ref.read(currentUserIdProvider) ?? '',
        financeMembers: financeMembers,
        selectedMembers: financeMembers.map((m) => m.userId).toSet(),
        fixedAmounts: const {},
        defaultRatio: household?.defaultSplitRatio ?? 0.5,
        currentUserId: ref.read(currentUserIdProvider),
        splitRatioAnchorId: household?.splitRatioAnchorId,
      );
      splits = result.splits;
      splitType = isSharedEconomy ? SplitType.fixed : SplitType.equal;
    }

    final wasReached = widget.goal.isReached;
    await ref.read(savingsGoalsProvider.notifier).contribute(
          widget.goal.id,
          amount,
          note: note.isEmpty ? null : note,
          goalTitle: widget.goal.title,
          splitType: splitType,
          savingsSplitType: _split == _ContributionSplit.shared
              ? SplitType.equal
              : SplitType.personal,
          splits: splits,
        );

    if (!mounted) return;
    // Celebrate the first time a contribution crosses the finish line. The
    // Navigator (captured pre-await) stays mounted after the sheet closes.
    final nowReached =
        widget.goal.currentAmount + amount >= widget.goal.targetAmount;
    navigator.pop();
    if (!wasReached && nowReached && navigatorContext.mounted) {
      _showCelebration(navigatorContext);
    }
  }

  void _showCelebration(BuildContext context) {
    final t = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)).animatePulse(),
            const SizedBox(height: 12),
            Text(
              t.savingsCompletedCelebrationTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t.savingsCompletedCelebrationBody(widget.goal.title),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.savingsCelebrationDismiss),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final goal = widget.goal;
    final caps = ref.watch(householdCapabilitiesProvider);
    final member = ref.watch(currentMemberProvider);
    // The split selector only makes sense when the household has a shared
    // economy AND the contributor participates in finance splits (adults in
    // family; everyone in couple/friends).
    final isFinanceMember =
        caps.type != HouseholdType.family || (member?.isAdult ?? true);
    final showSplitSelector = caps.showExpensesSplit && isFinanceMember;
    final modeKey = caps.type.name;

    final viewInsets = MediaQuery.viewInsetsOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    return AnimatedPadding(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: showSplitSelector ? 0.72 : 0.62,
          child: Container(
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadii.modal),
              ),
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    width: 46,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.divider,
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.md,
                        AppSpacing.lg,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.fromHex(goal.color)
                                      .withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: ConceptIcon(emoji: goal.icon, size: 30),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.savingsContributeTo,
                                      style: TextStyle(
                                        color: theme.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      goal.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 22,
                                        height: 1.05,
                                        color: theme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                            height: 86,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: theme.surface,
                              borderRadius: BorderRadius.circular(AppRadii.xxl),
                              border: Border.all(
                                color:
                                    AppColors.primary.withValues(alpha: 0.35),
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: _amountController,
                              autofocus: true,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              textInputAction: TextInputAction.done,
                              inputFormatters: [ThousandsInputFormatter()],
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: theme.textPrimary,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                prefixText:
                                    ref.watch(currencyProvider).inputPrefix(),
                                prefixStyle: TextStyle(
                                  color: theme.textMuted,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                hintStyle: TextStyle(
                                  color:
                                      theme.textMuted.withValues(alpha: 0.28),
                                ),
                              ),
                            ),
                          ),
                          if (showSplitSelector) ...[
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              t.savingsContributeSplitTitle,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: theme.textMuted,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                _splitOption(
                                  selected: _split == _ContributionSplit.solo,
                                  icon: Icons.card_giftcard_rounded,
                                  label: t.savingsContributeSoloLabel,
                                  desc: t.savingsContributeSoloDesc,
                                  onTap: () => setState(
                                    () => _split = _ContributionSplit.solo,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _splitOption(
                                  selected: _split == _ContributionSplit.shared,
                                  icon: Icons.group_rounded,
                                  label: t.savingsContributeSharedLabel(
                                    modeKey,
                                  ),
                                  desc: t.savingsContributeSharedDesc(modeKey),
                                  onTap: () => setState(
                                    () => _split = _ContributionSplit.shared,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: AppSpacing.md),
                          TextField(
                            controller: _noteController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              labelText: t.savingsNoteLabel,
                              hintText: t.savingsNoteHint,
                              filled: true,
                              fillColor: theme.surface,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                                borderSide: BorderSide(color: theme.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(AppRadii.lg),
                                borderSide: BorderSide(color: theme.border),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.sm + safePadding.bottom,
                    ),
                    decoration: BoxDecoration(
                      color: theme.surface,
                      border: Border(top: BorderSide(color: theme.border)),
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: AppControlSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.xl),
                          ),
                          elevation: 0,
                        ),
                        child: _submitting
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                t.savingsConfirmContribution,
                                style: const TextStyle(
                                  color: Colors.white,
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
          ),
        ),
      ),
    );
  }

  Widget _splitOption({
    required bool selected,
    required IconData icon,
    required String label,
    required String desc,
    required VoidCallback onTap,
  }) {
    final theme = context.theme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.1)
                : theme.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(
              color: selected ? AppColors.primary : theme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Create / edit goal sheet.
class _GoalFormSheet extends ConsumerStatefulWidget {
  final SavingsGoalModel? existing;
  const _GoalFormSheet({this.existing});

  @override
  ConsumerState<_GoalFormSheet> createState() => _GoalFormSheetState();
}

class _GoalFormSheetState extends ConsumerState<_GoalFormSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late String _selectedEmoji;
  late Color _selectedColor;
  DateTime? _targetDate;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e != null ? e.targetAmount.toStringAsFixed(0) : '',
    );
    _selectedEmoji = e?.icon ?? '🎯';
    _selectedColor = e != null ? AppColors.fromHex(e.color) : AppColors.primary;
    _targetDate = e?.targetDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final amount = parseAmountInput(_amountController.text);
    if (title.isEmpty || amount <= 0) return;
    final colorHex =
        '#${_selectedColor.toARGB32().toRadixString(16).substring(2)}';
    final notifier = ref.read(savingsGoalsProvider.notifier);
    if (_isEditing) {
      notifier.editGoal(
        widget.existing!.id,
        title: title,
        targetAmount: amount,
        color: colorHex,
        icon: _selectedEmoji,
        targetDate: _targetDate,
      );
    } else {
      notifier.addGoal(
        title,
        amount,
        colorHex,
        _selectedEmoji,
        targetDate: _targetDate,
      );
    }
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 90)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final modeKey = ref.watch(householdCapabilitiesProvider).type.name;

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: Container(
          decoration: BoxDecoration(
            color: theme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
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
                                color: AppColors.primary.withValues(alpha: 0.1),
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing
                                        ? t.savingsEditGoalTitle
                                        : t.savingsNewGoalTitle,
                                    style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w900,
                                      color: theme.textPrimary,
                                      letterSpacing: -1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    t.savingsNewGoalSubtitle(modeKey),
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
                        _sectionLabel(theme, t.savingsSectionDetail),
                        const SizedBox(height: 12),
                        Text(
                          t.savingsSectionDetailTitle(modeKey),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: theme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _textField(
                          theme,
                          controller: _titleController,
                          label: t.expensesSavingsGoalNameLabel,
                          hint: t.expensesSavingsGoalNameHint,
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: 16),
                        _textField(
                          theme,
                          controller: _amountController,
                          label: t.expensesSavingsGoalAmountLabel,
                          hint: t.expensesSavingsGoalAmountHint,
                          number: true,
                          prefixText: ref.watch(currencyProvider).inputPrefix(),
                        ),
                        const SizedBox(height: 16),
                        _DateField(
                          label: t.savingsTargetDateLabel,
                          value: _targetDate,
                          onPick: _pickDate,
                          onClear: () => setState(() => _targetDate = null),
                          clearLabel: t.savingsTargetDateClear,
                        ),
                        const SizedBox(height: 32),
                        _sectionLabel(theme, t.savingsSectionPersonalization),
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
                              value: _selectedEmoji,
                              onTap: () {
                                const emojis = [
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
                                  '🏖️',
                                  '🎄',
                                  '🚲',
                                  '📱',
                                  '⚽',
                                ];
                                _showSimplePicker(
                                  context,
                                  t.savingsPickIconTitle,
                                  emojis,
                                  (e) => setState(() => _selectedEmoji = e),
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
                                  color: _selectedColor,
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
                                  (c) => setState(() => _selectedColor = c),
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
                    border: Border(top: BorderSide(color: theme.border)),
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
                            onPressed: _save,
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
                              _isEditing
                                  ? t.savingsSaveChangesAction
                                  : t.savingsCreateGoalAction,
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
  }

  Widget _sectionLabel(AppThemeColors theme, String text) => Text(
        text,
        style: TextStyle(
          color: theme.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      );

  Widget _textField(
    AppThemeColors theme, {
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    bool number = false,
    String? prefixText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      inputFormatters: number ? [ThousandsInputFormatter()] : null,
      style: TextStyle(
        fontWeight: number ? FontWeight.w900 : FontWeight.w800,
        fontSize: number ? 22 : 18,
        color: theme.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon, color: AppColors.primary) : null,
        prefixText: prefixText,
        prefixStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: theme.textSecondary,
        ),
        filled: true,
        fillColor: theme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
        border: _border(theme.border),
        enabledBorder: _border(theme.border),
        focusedBorder: _border(AppColors.primary, width: 1.5),
      ),
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        borderSide: BorderSide(color: color, width: width),
      );

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
                    ConceptIcon(emoji: value, size: 24),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
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
                    child: ConceptIcon(emoji: options[index], size: 40),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
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

/// Small field that shows the picked target date (or a placeholder) and lets
/// the user choose / clear it.
class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String clearLabel;

  const _DateField({
    required this.label,
    required this.value,
    required this.onPick,
    required this.onClear,
    required this.clearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return GestureDetector(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xxl),
          border: Border.all(color: theme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_rounded, color: AppColors.primary),
            const SizedBox(width: 14),
            Expanded(
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
                  const SizedBox(height: 2),
                  Text(
                    value != null
                        ? DateFormat('dd MMM yyyy').format(value!)
                        : clearLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (value != null)
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: theme.textMuted,
                onPressed: onClear,
              ),
          ],
        ),
      ),
    );
  }
}
