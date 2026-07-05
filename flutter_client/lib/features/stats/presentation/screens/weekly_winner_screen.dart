import 'dart:math' show pi;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_animations.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/stats/domain/utils/weekly_duel_period.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/design/app_pill.dart';
import 'package:homesync_client/shared/widgets/design/app_screen_scaffold.dart';

class WeeklyWinnerScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final DateTime? weekStartDate;
  final bool refreshBalanceOnAward;
  final ValueChanged<Map<String, dynamic>>? onAwarded;

  const WeeklyWinnerScreen({
    super.key,
    required this.onClose,
    this.weekStartDate,
    this.refreshBalanceOnAward = true,
    this.onAwarded,
  });

  @override
  ConsumerState<WeeklyWinnerScreen> createState() => _WeeklyWinnerScreenState();
}

class _WeeklyWinnerScreenState extends ConsumerState<WeeklyWinnerScreen> {
  List<Map<String, dynamic>> _ranking = [];
  Map<String, dynamic>? _winner;
  bool _isLoading = true;
  int _coinsAwarded = 20;
  bool _awardSucceeded = false;
  bool _isLoadingData = false;
  late final DateTime _weekStartDate;
  late final ConfettiController _confettiController;
  bool _celebrated = false;

  @override
  void initState() {
    super.initState();
    _weekStartDate = widget.weekStartDate ?? weeklyDuelTargetWeekStart();
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1300),
    );
    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // The userProfileProvider listener in build() retriggers this; without a
    // guard a profile refresh while the screen is open awards the bonus twice
    // (the award RPC inserts a fresh ledger entry on every call).
    if (_isLoadingData || _awardSucceeded) return;
    _isLoadingData = true;
    try {
      final householdRpc = ref.read(householdRpcServiceProvider);
      final statsRpc = ref.read(statsRpcServiceProvider);
      final ranking = await statsRpc.getWeeklyRankingForWeek(_weekStartDate);

      if (ranking.isNotEmpty) {
        _winner = ranking.first;
        final awardResult =
            await statsRpc.awardWeeklyWinnerForWeek(_weekStartDate);
        _coinsAwarded =
            (awardResult['coins_awarded'] as num?)?.toInt() ?? _coinsAwarded;
        if (awardResult['success'] == true) {
          _awardSucceeded = true;
          widget.onAwarded?.call(awardResult);
          if (widget.refreshBalanceOnAward) {
            ref.invalidate(userBalanceProvider);
            ref.invalidate(statsControllerProvider);
          }
        }

        if (ranking.length >= 2) {
          final householdInfo = await householdRpc.getHouseholdInfo();
          final householdId = householdInfo['household_id'] as String?;

          if (householdId != null) {
            final winner = ranking.first;
            final loser = ranking[1];

            await ref.read(weeklyDuelResultSaveUseCaseProvider).call(
                  householdId: householdId,
                  weekStartDate: _weekStartDate,
                  winnerUserId: winner['user_id'] ?? '',
                  winnerName: winner['user_name'] ?? 'Ganador',
                  loserUserId: loser['user_id'] ?? '',
                  loserName: loser['user_name'] ?? 'Perdedor',
                  winnerXp: (winner['xp_earned'] as num?)?.toInt() ?? 0,
                  loserXp: (loser['xp_earned'] as num?)?.toInt() ?? 0,
                );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });
      // The big moment: confetti + the rising celebrate haptic, once.
      if (_winner != null && !_celebrated) {
        _celebrated = true;
        _confettiController.play();
        AppHaptics.celebrate();
      }
    } catch (e) {
      log.e('Error loading winner: $e', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
    } finally {
      _isLoadingData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileProvider, (previous, next) {
      _loadData();
    });

    final theme = context.theme;
    final t = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        widget.onClose();
      },
      child: AppScreenScaffold(
        body: SafeArea(
          child: Stack(
            children: [
              _isLoading
                  ? const Center(
                      child: AppLoader(color: AppColors.accentGold),
                    )
                  : _winner == null
                      ? _buildEmptyState(theme, t)
                      : _buildContent(theme, t),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.sizeOf(context).height * 0.66,
                child: IgnorePointer(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConfettiWidget(
                        confettiController: _confettiController,
                        blastDirection: pi / 2,
                        maxBlastForce: 5.2,
                        minBlastForce: 1.6,
                        emissionFrequency: 0.035,
                        numberOfParticles: 18,
                        gravity: 0.09,
                        shouldLoop: false,
                        colors: const [
                          AppColors.accentGold,
                          AppColors.sage,
                          AppColors.primary,
                          AppColors.accentOrange,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors theme, AppLocalizations t) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppInsets.screenHorizontal),
        child: AppCard(
          variant: AppCardVariant.hero,
          accentColor: AppColors.sage,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  size: 36,
                  color: AppColors.iconSage,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                t.weeklyWinnerEmptyTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                t.weeklyWinnerEmptyBody,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              _buildCloseButton(theme, label: t.weeklyWinnerClose),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeColors theme, AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildHero(theme, t).animateEntrance(delay: 40),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCloseButton(theme, label: t.weeklyWinnerContinue)
              .animateEntrance(delay: 340),
        ],
      ),
    );
  }

  Widget _buildHero(AppThemeColors theme, AppLocalizations t) {
    final winnerName = _winner!['user_name'] ?? t.weeklyWinnerFallbackWinner;
    final winnerXp = (_winner!['xp_earned'] as num?)?.toInt() ?? 0;

    return AppCard(
      variant: AppCardVariant.hero,
      accentColor: AppColors.accentGold,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.surface,
              AppColors.accentGold
                  .withValues(alpha: theme.isDarkMode ? 0.07 : 0.035),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadii.xxl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                AppPill(
                  label: t.weeklyWinnerWeeklyClose,
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.accentGold,
                  selected: true,
                  dense: true,
                ),
                const Spacer(),
                Text(
                  _getWeekRange(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.075),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.accentGold.withValues(alpha: 0.16),
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: theme.surface.withValues(alpha: 0.92),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withValues(alpha: 0.12),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                ),
                CustomUserAvatar(
                  name: winnerName,
                  avatarUrl: _winner!['avatar_url'],
                  radius: 42,
                  showBorder: true,
                  isPriority: true,
                  ambientMotion: AvatarMotion.victory,
                ),
                Positioned(
                  right: 2,
                  bottom: 6,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.accentGold,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.surface, width: 4),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ).animateScaleIn(delay: 420),
                ),
              ],
            ).animateScaleIn(delay: 120),
            const SizedBox(height: 14),
            Text(
              t.weeklyWinnerHeadline(winnerName),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.8,
                height: 1.05,
              ),
            ).animateEntrance(delay: 260),
            const SizedBox(height: 10),
            Text(
              t.weeklyWinnerSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
                height: 1.35,
              ),
            ).animateEntrance(delay: 340),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoPill(
                  icon: Icons.auto_awesome_rounded,
                  label: '$winnerXp XP',
                  color: AppColors.accentGold,
                  selected: true,
                ),
                _buildInfoPill(
                  icon: Icons.monetization_on_rounded,
                  label: t.weeklyWinnerCoinsAwarded(_coinsAwarded),
                  color: AppColors.sage,
                  selected: true,
                ),
              ],
            ).animateEntrance(delay: 420),
            if (_awardSucceeded) ...[
              const SizedBox(height: 12),
              Text(
                t.weeklyWinnerCardSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: theme.textMuted,
                  height: 1.25,
                ),
              ),
            ],
            if (_ranking.length > 1) ...[
              const SizedBox(height: 14),
              _buildRunnerUpStrip(theme, t).animateEntrance(delay: 500),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRunnerUpStrip(AppThemeColors theme, AppLocalizations t) {
    final runnerUp = _ranking[1];
    final runnerXp = (runnerUp['xp_earned'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 9, 11, 9),
      decoration: BoxDecoration(
        color: theme.surface.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: theme.border.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.background.withValues(alpha: 0.74),
              shape: BoxShape.circle,
            ),
            child: Text(
              '2',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CustomUserAvatar(
            name: runnerUp['user_name'] ?? t.weeklyWinnerFallbackParticipant,
            avatarUrl: runnerUp['avatar_url'],
            radius: 18,
            forceCircular: true,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.weeklyWinnerSecondPlace,
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  runnerUp['user_name'] ?? t.weeklyWinnerFallbackParticipant,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$runnerXp XP',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required Color color,
    bool selected = false,
  }) {
    return AppPill(
      label: label,
      icon: icon,
      color: color,
      selected: selected,
    );
  }

  Widget _buildCloseButton(AppThemeColors theme, {required String label}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  String _getWeekRange() {
    final monday = _weekStartDate;
    final sunday = monday.add(const Duration(days: 6));

    String formatDate(DateTime d) => '${d.day}/${d.month}';
    return '${formatDate(monday)} - ${formatDate(sunday)}';
  }
}
