import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/stats/domain/utils/weekly_duel_period.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/design/app_pill.dart';
import 'package:homesync_client/shared/widgets/design/app_screen_scaffold.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class WeeklyWinnerScreen extends ConsumerStatefulWidget {
  final VoidCallback onClose;

  const WeeklyWinnerScreen({
    super.key,
    required this.onClose,
  });

  @override
  ConsumerState<WeeklyWinnerScreen> createState() => _WeeklyWinnerScreenState();
}

class _WeeklyWinnerScreenState extends ConsumerState<WeeklyWinnerScreen> {
  List<Map<String, dynamic>> _ranking = [];
  Map<String, dynamic>? _winner;
  bool _isLoading = true;
  int _coinsAwarded = 20;
  late final DateTime _weekStartDate;

  @override
  void initState() {
    super.initState();
    _weekStartDate = weeklyDuelTargetWeekStart();
    _loadData();
  }

  Future<void> _loadData() async {
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
          ref.invalidate(userBalanceProvider);
          ref.invalidate(statsControllerProvider);
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
    } catch (e) {
      log.e('Error loading winner: $e', error: e);
      if (!mounted) return;
      setState(() => _isLoading = false);
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _winner == null
                  ? _buildEmptyState(theme, t)
                  : _buildContent(theme, t),
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
              children: [
                _buildHero(theme, t),
                const SizedBox(height: 14),
                _buildWinnerCard(theme, t),
                if (_ranking.length > 1) ...[
                  const SizedBox(height: 14),
                  _buildRunnerUpCard(theme, t),
                  const SizedBox(height: 14),
                  _buildRanking(theme, t),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCloseButton(theme, label: t.weeklyWinnerContinue),
        ],
      ),
    );
  }

  Widget _buildHero(AppThemeColors theme, AppLocalizations t) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.elevatedSurface,
            AppColors.accentGold
                .withValues(alpha: theme.isDarkMode ? 0.20 : 0.16),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.xxl),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.22),
        ),
        boxShadow: AppElevation.card(
          color: theme.shadowBase,
          isDarkMode: theme.isDarkMode,
        ),
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
          const SizedBox(height: 22),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.28),
              ),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: AppColors.accentGold,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            t.weeklyWinnerTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.weeklyWinnerSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(AppThemeColors theme, AppLocalizations t) {
    final winnerName = _winner!['user_name'] ?? t.weeklyWinnerFallbackWinner;
    final winnerXp = (_winner!['xp_earned'] as num?)?.toInt() ?? 0;

    return AppCard(
      variant: AppCardVariant.standard,
      accentColor: AppColors.accentGold,
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
              ),
              CustomUserAvatar(
                name: winnerName,
                avatarUrl: _winner!['avatar_url'],
                radius: 50,
                showBorder: true,
                isPriority: true,
              ),
              Positioned(
                right: -2,
                bottom: 6,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.accentGold,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.surface, width: 3),
                  ),
                  child: const Icon(
                    Icons.military_tech_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            winnerName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.weeklyWinnerCardSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
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
                color: AppColors.success,
                selected: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunnerUpCard(AppThemeColors theme, AppLocalizations t) {
    final runnerUp = _ranking[1];
    final runnerXp = (runnerUp['xp_earned'] as num?)?.toInt() ?? 0;

    return AppCard(
      variant: AppCardVariant.subtle,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.background,
              shape: BoxShape.circle,
              border: Border.all(color: theme.border.withValues(alpha: 0.55)),
            ),
            child: Text(
              '2',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CustomUserAvatar(
            name: runnerUp['user_name'] ?? t.weeklyWinnerFallbackParticipant,
            avatarUrl: runnerUp['avatar_url'],
            radius: 26,
            forceCircular: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Segundo lugar',
                  style: TextStyle(
                    color: theme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  runnerUp['user_name'] ?? t.weeklyWinnerFallbackParticipant,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 16,
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
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRanking(AppThemeColors theme, AppLocalizations t) {
    return AppCard(
      variant: AppCardVariant.standard,
      accentColor: AppColors.sage,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.leaderboard_rounded,
                size: 19,
                color: theme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                t.weeklyWinnerRankingTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: theme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._ranking.asMap().entries.map((entry) {
            final index = entry.key;
            final player = entry.value;
            final xp = (player['xp_earned'] as num?)?.toInt() ?? 0;
            final isWinner = index == 0;

            return Container(
              margin: EdgeInsets.only(
                bottom: index == _ranking.length - 1 ? 0 : 12,
              ),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isWinner
                    ? AppColors.accentGold.withValues(alpha: 0.08)
                    : theme.background,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isWinner
                          ? AppColors.accentGold.withValues(alpha: 0.14)
                          : theme.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CustomUserAvatar(
                    name: player['user_name'] ?? t.weeklyWinnerFallbackPlayer,
                    avatarUrl: player['avatar_url'],
                    radius: 18,
                    forceCircular: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player['user_name'] ?? t.weeklyWinnerFallbackPlayer,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: theme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '$xp XP',
                    style: TextStyle(
                      color:
                          isWinner ? AppColors.accentGold : theme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            );
          }),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
