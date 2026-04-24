import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/providers/rpc_providers.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final householdRpc = ref.read(householdRpcServiceProvider);
      final ranking = await ref.read(weeklyRankingUseCaseProvider).call();

      if (ranking.isNotEmpty) {
        _winner = ranking.first;
        await ref.read(weeklyWinnerAwardUseCaseProvider).call();

        if (ranking.length >= 2) {
          final householdInfo = await householdRpc.getHouseholdInfo();
          final householdId = householdInfo['household_id'] as String?;

          if (householdId != null) {
            final winner = ranking.first;
            final loser = ranking[1];
            final weekStart = DateTime.now();
            final weekStartDate =
                DateTime(weekStart.year, weekStart.month, weekStart.day)
                    .subtract(Duration(days: weekStart.weekday - 1));

            await ref.read(weeklyDuelResultSaveUseCaseProvider).call(
                  householdId: householdId,
                  weekStartDate: weekStartDate,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        widget.onClose();
      },
      child: Scaffold(
        backgroundColor: theme.background,
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : _winner == null
                  ? _buildEmptyState(theme)
                  : _buildContent(theme),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppThemeColors theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: theme.border.withValues(alpha: 0.45)),
            boxShadow: theme.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_outlined,
                  size: 38,
                  color: AppColors.iconSage,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Todavía no hay ganador semanal',
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
                'Completen tareas esta semana y el duelo va a empezar a tomar forma.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 22),
              _buildCloseButton(theme, label: 'Cerrar'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(AppThemeColors theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildHeader(theme),
                const SizedBox(height: 18),
                _buildWinnerCard(theme),
                if (_ranking.length > 1) ...[
                  const SizedBox(height: 18),
                  _buildRunnerUpCard(theme),
                  const SizedBox(height: 18),
                  _buildRanking(theme),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildCloseButton(theme, label: 'Seguir'),
        ],
      ),
    );
  }

  Widget _buildHeader(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFBF7),
            Color(0xFFFFF4EB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  size: 14,
                  color: AppColors.accentGold,
                ),
                SizedBox(width: 6),
                Text(
                  'CIERRE SEMANAL',
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ganador de la semana',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Así quedó definido el duelo semanal entre ustedes.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
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
    );
  }

  Widget _buildWinnerCard(AppThemeColors theme) {
    final winnerName = _winner!['user_name'] ?? 'Ganador';
    final winnerXp = (_winner!['xp_earned'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.accentGold.withValues(alpha: 0.28),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '🏆',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          const SizedBox(height: 18),
          CustomUserAvatar(
            name: winnerName,
            avatarUrl: _winner!['avatar_url'],
            radius: 54,
            showBorder: true,
            isPriority: true,
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
            'Terminó arriba en XP y se llevó el cierre semanal.',
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
              ),
              _buildInfoPill(
                icon: Icons.monetization_on_rounded,
                label: '+20 coins',
                color: AppColors.success,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRunnerUpCard(AppThemeColors theme) {
    final runnerUp = _ranking[1];
    final runnerXp = (runnerUp['xp_earned'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          CustomUserAvatar(
            name: runnerUp['user_name'],
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
                  runnerUp['user_name'] ?? 'Participante',
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

  Widget _buildRanking(AppThemeColors theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ranking semanal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.3,
            ),
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
                    width: 28,
                    height: 28,
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
                    name: player['user_name'],
                    avatarUrl: player['avatar_url'],
                    radius: 18,
                    forceCircular: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player['user_name'] ?? 'Jugador',
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
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(AppThemeColors theme, {required String label}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sage.withValues(alpha: 0.16),
          foregroundColor: theme.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
            color: AppColors.sage.withValues(alpha: 0.22),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    String formatDate(DateTime d) => '${d.day}/${d.month}';
    return '${formatDate(monday)} - ${formatDate(sunday)}';
  }
}
