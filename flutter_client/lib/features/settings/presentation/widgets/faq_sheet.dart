import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/parent_mode_provider.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';

/// Audiencia del lector: decide qué preguntas se muestran y cómo se
/// redactan las respuestas role-aware (aprobaciones, tienda de premios).
/// `adult` cubre los hogares sin roles familiares (pareja/convivencia/solo).
enum _FaqRole { parent, teen, child, adult }

class _FaqEntry {
  final IconData icon;
  final String Function(AppLocalizations t) question;
  final String Function(AppLocalizations t, String mode, String role) answer;

  /// null = visible en todos los modos.
  final Set<HouseholdType>? modes;

  /// null = visible para todos los roles.
  final Set<_FaqRole>? roles;

  /// Solo tiene sentido si el hogar tiene tareas activas (XP, coins,
  /// duelos y premios derivan de completarlas).
  final bool needsTasks;

  const _FaqEntry({
    required this.icon,
    required this.question,
    required this.answer,
    this.modes,
    this.roles,
    this.needsTasks = false,
  });

  bool visibleFor(HouseholdCapabilities caps, _FaqRole role) {
    if (needsTasks && !caps.showTasks) return false;
    if (modes != null && !modes!.contains(caps.type)) return false;
    if (roles != null && !roles!.contains(role)) return false;
    return true;
  }
}

class _FaqCategory {
  final IconData icon;
  final Color color;
  final String Function(AppLocalizations t) title;
  final List<_FaqEntry> entries;

  const _FaqCategory({
    required this.icon,
    required this.color,
    required this.title,
    required this.entries,
  });
}

const Set<HouseholdType> _sharedModes = {
  HouseholdType.couple,
  HouseholdType.family,
  HouseholdType.friends,
};

final List<_FaqCategory> _faqCategories = [
  _FaqCategory(
    icon: Icons.home_rounded,
    color: AppColors.primary,
    title: (t) => t.faqCatHousehold,
    entries: [
      _FaqEntry(
        icon: Icons.home_rounded,
        question: (t) => t.faqHowSharedHome,
        answer: (t, mode, role) => t.faqHowSharedHomeAnswer(mode),
      ),
      _FaqEntry(
        icon: Icons.qr_code_rounded,
        question: (t) => t.faqInviteMembers,
        answer: (t, mode, role) => t.faqInviteMembersAnswer(mode),
        modes: _sharedModes,
        roles: {_FaqRole.parent, _FaqRole.adult},
      ),
      _FaqEntry(
        icon: Icons.family_restroom_rounded,
        question: (t) => t.faqFamilyRoles,
        answer: (t, mode, role) => t.faqFamilyRolesAnswer,
        modes: {HouseholdType.family},
      ),
      _FaqEntry(
        icon: Icons.visibility_rounded,
        question: (t) => t.faqWhoSeesWhat,
        answer: (t, mode, role) => t.faqWhoSeesWhatAnswer,
        modes: {HouseholdType.family},
        roles: {_FaqRole.parent, _FaqRole.teen},
      ),
    ],
  ),
  _FaqCategory(
    icon: Icons.task_alt_rounded,
    color: AppColors.accentTeal,
    title: (t) => t.faqCatTasks,
    entries: [
      _FaqEntry(
        icon: Icons.task_alt_rounded,
        question: (t) => t.faqTasksBasics,
        answer: (t, mode, role) => t.faqTasksBasicsAnswer,
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.fact_check_rounded,
        question: (t) => t.faqApprovals,
        answer: (t, mode, role) => t.faqApprovalsAnswer(role),
        modes: {HouseholdType.family},
        needsTasks: true,
      ),
    ],
  ),
  _FaqCategory(
    icon: Icons.emoji_events_rounded,
    color: AppColors.accentGold,
    title: (t) => t.faqCatRewards,
    entries: [
      _FaqEntry(
        icon: Icons.bolt_rounded,
        question: (t) => t.faqHowEarnXp,
        answer: (t, mode, role) => t.faqHowEarnXpAnswer,
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.monetization_on_rounded,
        question: (t) => t.faqWhatCoins,
        answer: (t, mode, role) => t.faqWhatCoinsAnswer(mode),
        modes: {HouseholdType.couple, HouseholdType.family},
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.sports_kabaddi_rounded,
        question: (t) => t.faqWhatWeeklyDuels,
        answer: (t, mode, role) => t.faqWhatWeeklyDuelsAnswer,
        modes: {HouseholdType.couple},
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.leaderboard_rounded,
        question: (t) => t.faqFamilyRanking,
        answer: (t, mode, role) => t.faqFamilyRankingAnswer,
        modes: {HouseholdType.family},
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.auto_awesome_rounded,
        question: (t) => t.faqWhatSpecialEvents,
        answer: (t, mode, role) => t.faqWhatSpecialEventsAnswer,
        modes: {HouseholdType.couple},
        needsTasks: true,
      ),
      _FaqEntry(
        icon: Icons.balance_rounded,
        question: (t) => t.faqContributionBalance,
        answer: (t, mode, role) => t.faqContributionBalanceAnswer,
        modes: {HouseholdType.friends},
      ),
      _FaqEntry(
        icon: Icons.storefront_rounded,
        question: (t) => t.faqRewardsStore,
        answer: (t, mode, role) => t.faqRewardsStoreAnswer(role),
        modes: {HouseholdType.family},
        needsTasks: true,
      ),
    ],
  ),
  _FaqCategory(
    icon: Icons.account_balance_wallet_rounded,
    color: AppColors.accentGreen,
    title: (t) => t.faqCatFinances,
    entries: [
      _FaqEntry(
        icon: Icons.account_balance_wallet_rounded,
        question: (t) => t.faqHowFinancesWork,
        answer: (t, mode, role) => t.faqHowFinancesWorkAnswer(mode),
        roles: {_FaqRole.parent, _FaqRole.teen, _FaqRole.adult},
      ),
      _FaqEntry(
        icon: Icons.event_repeat_rounded,
        question: (t) => t.faqHowRecurringCount,
        answer: (t, mode, role) => t.faqHowRecurringCountAnswer,
        roles: {_FaqRole.parent, _FaqRole.adult},
      ),
      _FaqEntry(
        icon: Icons.handshake_rounded,
        question: (t) => t.faqWhoCanPay,
        answer: (t, mode, role) => t.faqWhoCanPayAnswer,
        modes: _sharedModes,
        roles: {_FaqRole.parent, _FaqRole.adult},
      ),
      _FaqEntry(
        icon: Icons.savings_rounded,
        question: (t) => t.faqSavingsGoals,
        answer: (t, mode, role) => t.faqSavingsGoalsAnswer,
        roles: {_FaqRole.parent, _FaqRole.teen, _FaqRole.adult},
      ),
    ],
  ),
  _FaqCategory(
    icon: Icons.tune_rounded,
    color: AppColors.accentBlue,
    title: (t) => t.faqCatApp,
    entries: [
      _FaqEntry(
        icon: Icons.workspace_premium_rounded,
        question: (t) => t.faqPremium,
        answer: (t, mode, role) => t.faqPremiumAnswer,
        roles: {_FaqRole.parent, _FaqRole.adult},
      ),
      _FaqEntry(
        icon: Icons.palette_rounded,
        question: (t) => t.faqCustomization,
        answer: (t, mode, role) => t.faqCustomizationAnswer,
      ),
      _FaqEntry(
        icon: Icons.notifications_rounded,
        question: (t) => t.faqNotifications,
        answer: (t, mode, role) => t.faqNotificationsAnswer,
      ),
      _FaqEntry(
        icon: Icons.lock_rounded,
        question: (t) => t.faqAccountSafety,
        answer: (t, mode, role) => t.faqAccountSafetyAnswer,
      ),
    ],
  ),
];

class FAQSheet extends ConsumerStatefulWidget {
  const FAQSheet({super.key});

  static void show(BuildContext context) {
    AppSheet.show(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FAQSheet(),
    );
  }

  @override
  ConsumerState<FAQSheet> createState() => _FAQSheetState();
}

class _FAQSheetState extends ConsumerState<FAQSheet> {
  String _query = '';
  final Set<String> _expanded = {};

  _FaqRole _roleFor(HouseholdCapabilities caps, MemberModel? member) {
    if (caps.type != HouseholdType.family) return _FaqRole.adult;
    if (member == null) return _FaqRole.parent;
    if (member.isTeen) return _FaqRole.teen;
    if (member.isChild) return _FaqRole.child;
    return _FaqRole.parent;
  }

  /// Normaliza para buscar sin acentos ni mayúsculas.
  String _normalize(String input) {
    const accents = 'áéíóúüñÁÉÍÓÚÜÑ';
    const plain = 'aeiouunAEIOUUN';
    var out = input.toLowerCase();
    for (var i = 0; i < accents.length; i++) {
      out = out.replaceAll(accents[i], plain[i].toLowerCase());
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    final member = ref.watch(currentMemberProvider);
    final role = _roleFor(caps, member);
    final mode = caps.type.name;
    final roleParam = role.name;

    final query = _normalize(_query.trim());
    final searching = query.isNotEmpty;

    final visibleCategories = <(_FaqCategory, List<_FaqEntry>)>[];
    for (final category in _faqCategories) {
      final entries = category.entries
          .where((e) => e.visibleFor(caps, role))
          .where(
            (e) =>
                !searching ||
                _normalize(e.question(t)).contains(query) ||
                _normalize(e.answer(t, mode, roleParam)).contains(query),
          )
          .toList();
      if (entries.isNotEmpty) visibleCategories.add((category, entries));
    }

    final contextLabel = caps.type == HouseholdType.family && member != null
        ? '${t.setupModeName(mode)} · ${member.localizedRoleLabel(t)}'
        : t.setupModeName(mode);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackground,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    t.faqSheetTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.faqSheetSubtitle,
                    style: TextStyle(
                      color: theme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    t.faqContextPill(contextLabel),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintText: t.faqSearchHint,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 20,
                  color: theme.textMuted,
                ),
                isDense: true,
                filled: true,
                fillColor: theme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(color: theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide(
                    color: theme.border.withValues(alpha: 0.7),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: visibleCategories.isEmpty
                ? _buildEmptySearch(t, theme)
                : ListView(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      for (final (category, entries) in visibleCategories) ...[
                        _buildCategoryHeader(t, theme, category),
                        for (final entry in entries)
                          _buildFAQItem(
                            t,
                            theme,
                            category: category,
                            entry: entry,
                            mode: mode,
                            role: roleParam,
                            forceExpanded: searching,
                          ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(AppLocalizations t, AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: theme.textMuted.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              t.faqSearchEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
    AppLocalizations t,
    AppThemeColors theme,
    _FaqCategory category,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: 12),
      child: Row(
        children: [
          Icon(category.icon, size: 16, color: category.color),
          const SizedBox(width: 8),
          Text(
            category.title(t).toUpperCase(),
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    AppLocalizations t,
    AppThemeColors theme, {
    required _FaqCategory category,
    required _FaqEntry entry,
    required String mode,
    required String role,
    required bool forceExpanded,
  }) {
    final id = entry.question(t);
    final expanded = forceExpanded || _expanded.contains(id);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: forceExpanded
              ? null
              : () {
                  AppHaptics.selection();
                  setState(() {
                    if (!_expanded.add(id)) _expanded.remove(id);
                  });
                },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                      child: Icon(entry.icon, color: category.color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.question(t),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.expand_more_rounded,
                        size: 20,
                        color: theme.textMuted,
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            entry.answer(t, mode, role),
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: theme.textSecondary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
