import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/rewards/presentation/providers/couple_duel_stats_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/expressive/expressive.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Card del duelo semanal. El marcador de la pareja es oculto a propósito
/// (se revela el domingo), así que todo lo que muestra la card es información
/// propia y real: tu XP, tu progreso contra tu récord personal y tu ritmo
/// diario de la semana. Nada de barras decorativas sin datos.
class AIFaceoffWidget extends ConsumerWidget {
  final List<Map<String, dynamic>> weeklyRanking;

  /// Historial de duelos cerrados (`get_weekly_duel_history`): se usa para
  /// calcular el récord personal de XP semanal del usuario.
  final List<Map<String, dynamic>> duelHistory;

  /// Meta inicial cuando todavía no hay semanas cerradas en el historial.
  static const int _starterGoalXp = 50;

  const AIFaceoffWidget({
    super.key,
    required this.weeklyRanking,
    this.duelHistory = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (weeklyRanking.length < 2) {
      return const SizedBox.shrink();
    }

    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final currentUserId = ref.watch(currentUserIdProvider);
    final xpByDay =
        ref.watch(weeklyXpByDayProvider).value ?? const [0, 0, 0, 0, 0, 0, 0];
    final leader = weeklyRanking[0];
    final challenger = weeklyRanking[1];

    final leaderXp = (leader['xp_earned'] as num?)?.toInt() ?? 0;
    final challengerXp = (challenger['xp_earned'] as num?)?.toInt() ?? 0;
    final currentUserData =
        leader['user_id'] == currentUserId ? leader : challenger;
    final partnerData =
        leader['user_id'] == currentUserId ? challenger : leader;
    final currentUserXp =
        leader['user_id'] == currentUserId ? leaderXp : challengerXp;
    final personalRecord = _personalRecordXp();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.isDarkMode
              ? [
                  theme.elevatedSurface,
                  theme.surface,
                ]
              : const [
                  Color(0xFFFFFBF7),
                  Color(0xFFFFF4EB),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadii.modal),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.55),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.iconSage,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      t.faceoffWeeklyDuelLabel,
                      style: const TextStyle(
                        color: AppColors.iconSage,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _daysRemainingLabel(t),
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            t.faceoffHiddenScoreTitle,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _competitorCard(
                      context: context,
                      player: currentUserData,
                      xp: currentUserXp,
                      t: t,
                      isCurrentUser: true,
                      showExactXp: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _competitorCard(
                      context: context,
                      player: partnerData,
                      xp: leader['user_id'] == currentUserId
                          ? challengerXp
                          : leaderXp,
                      t: t,
                      isCurrentUser: false,
                      showExactXp: false,
                    ),
                  ),
                ],
              ),
              _vsBadge(context),
            ],
          ),
          const SizedBox(height: 18),
          _buildMyWeekProgress(
            context: context,
            t: t,
            currentUserXp: currentUserXp,
            personalRecord: personalRecord,
          ),
          const SizedBox(height: 16),
          _buildWeekRow(context, t, xpByDay),
        ],
      ),
    );
  }

  /// Mejor semana propia según el historial de duelos cerrados (gané →
  /// winner_xp, perdí → loser_xp). 0 cuando no hay historial.
  int _personalRecordXp() {
    var record = 0;
    for (final week in duelHistory) {
      final result = week['user_result']?.toString();
      final xp = switch (result) {
        'win' => (week['winner_xp'] as num?)?.toInt() ?? 0,
        'loss' => (week['loser_xp'] as num?)?.toInt() ?? 0,
        _ => 0,
      };
      if (xp > record) record = xp;
    }
    return record;
  }

  Widget _vsBadge(BuildContext context) {
    final theme = context.theme;
    // Silueta gem M3E en vez de círculo: le da carácter de "enfrentamiento"
    // al pivote de la card sin tocar la paleta.
    return Container(
      width: 34,
      height: 34,
      decoration: ShapeDecoration(
        color: theme.surface,
        shape: MaterialShapeBorder(
          shape: AppShapes.gem,
          side: BorderSide(color: theme.border.withValues(alpha: 0.7)),
        ),
        shadows: [
          BoxShadow(
            color: theme.shadowBase.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'VS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            color: theme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _competitorCard({
    required BuildContext context,
    required Map<String, dynamic> player,
    required int xp,
    required AppLocalizations t,
    required bool showExactXp,
    required bool isCurrentUser,
  }) {
    final theme = context.theme;
    final name = _firstName(player['user_name']);
    final avatarUrl = player['avatar_url'] as String?;
    final accent = isCurrentUser ? AppColors.primary : AppColors.sage;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(
          color: accent.withValues(alpha: isCurrentUser ? 0.18 : 0.12),
        ),
      ),
      child: Column(
        children: [
          CustomUserAvatar(
            name: name,
            avatarUrl: avatarUrl,
            radius: 38,
            isAnimated: true,
            showBorder: true,
            ambientMotion: AvatarMotion.versus,
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isCurrentUser ? t.faceoffYouLabel : t.faceoffPartnerLabel,
            style: TextStyle(
              color: isCurrentUser ? accent : theme.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!showExactXp) ...[
                  Icon(
                    Icons.visibility_off_rounded,
                    size: 12,
                    color: accent.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 5),
                ],
                Text(
                  showExactXp ? t.faceoffXpValue(xp) : t.faceoffHiddenXp,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Progreso propio de la semana contra el récord personal (o la meta
  /// inicial si todavía no hay historial). Reemplaza a la vieja barra de
  /// "ventaja" que era un gradiente estático sin datos.
  Widget _buildMyWeekProgress({
    required BuildContext context,
    required AppLocalizations t,
    required int currentUserXp,
    required int personalRecord,
  }) {
    final theme = context.theme;
    final goal = personalRecord > 0 ? personalRecord : _starterGoalXp;
    final beatRecord = personalRecord > 0 && currentUserXp > personalRecord;
    final progress = goal == 0 ? 0.0 : (currentUserXp / goal).clamp(0.0, 1.0);
    final barColor = beatRecord ? AppColors.accentGold : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              t.faceoffMyWeekLabel,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              personalRecord > 0
                  ? t.faceoffPersonalRecordChip(personalRecord)
                  : t.faceoffStarterGoalChip(_starterGoalXp),
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          // M3 Expressive: el ritmo semanal ondula mientras el duelo está
          // vivo; la onda se aplana sola al acercarse al récord.
          builder: (context, value, _) => AppWavyProgress(
            value: value,
            color: barColor,
            trackColor: barColor.withValues(alpha: 0.12),
            strokeWidth: 7,
            amplitude: 2.6,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            // Al romper el récord en vivo, el badge brota de círculo a burst
            // de celebración sobre spring expresivo (M3E).
            if (beatRecord) ...[
              AppShapeMorph(
                active: beatRecord,
                from: AppShapes.circle,
                to: AppShapes.celebration,
                fromValue: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  color: AppColors.accentGold,
                  child: const Icon(
                    Icons.star_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Text(
                beatRecord
                    ? t.faceoffNewRecord
                    : t.faceoffCurrentXpCounts(currentUserXp),
                style: TextStyle(
                  color:
                      beatRecord ? const Color(0xFFB07E1F) : theme.textSecondary,
                  fontSize: 12,
                  fontWeight: beatRecord ? FontWeight.w800 : FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Ritmo semanal con datos reales: cada día se pinta según el XP propio
  /// ganado ese día (intensidad relativa al mejor día de la semana).
  Widget _buildWeekRow(
    BuildContext context,
    AppLocalizations t,
    List<int> xpByDay,
  ) {
    final theme = context.theme;
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now().weekday;
    final maxDayXp = xpByDay.fold(0, (max, xp) => xp > max ? xp : max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t.faceoffWeeklyRhythm,
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNumber = index + 1;
            final isToday = dayNumber == today;
            final isFuture = dayNumber > today;
            final dayXp = index < xpByDay.length ? xpByDay[index] : 0;
            final hasActivity = dayXp > 0;
            final intensity = maxDayXp == 0 ? 0.0 : dayXp / maxDayXp;

            final background = hasActivity
                ? AppColors.primary.withValues(alpha: 0.10 + 0.16 * intensity)
                : isToday
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : Colors.transparent;
            final borderColor = isToday
                ? AppColors.primary.withValues(alpha: 0.45)
                : hasActivity
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : theme.border.withValues(alpha: isFuture ? 0.35 : 0.55);
            final letterColor = hasActivity || isToday
                ? AppColors.primary
                : isFuture
                    ? theme.textMuted.withValues(alpha: 0.6)
                    : theme.textMuted;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
                height: 42,
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  border: Border.all(
                    color: borderColor,
                    width: isToday ? 1.6 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: hasActivity || isToday
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: letterColor,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: hasActivity
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _daysRemainingLabel(AppLocalizations t) {
    final today = DateTime.now().weekday;
    final remaining = 7 - today;
    if (remaining <= 0) return t.faceoffClosesToday;
    return t.faceoffDaysRemaining(remaining);
  }

  String _firstName(dynamic rawName) {
    final name = (rawName as String? ?? '').trim();
    if (name.isEmpty) return 'Player';
    return name.split(' ').first;
  }
}
