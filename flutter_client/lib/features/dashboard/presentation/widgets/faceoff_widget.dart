import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class AIFaceoffWidget extends ConsumerWidget {
  final List<Map<String, dynamic>> weeklyRanking;

  const AIFaceoffWidget({super.key, required this.weeklyRanking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (weeklyRanking.length < 2) {
      return const SizedBox.shrink();
    }

    final theme = context.theme;
    final currentUserId = ref.watch(currentUserIdProvider);
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
        borderRadius: BorderRadius.circular(32),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.sage.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.iconSage,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'DUELO SEMANAL',
                      style: TextStyle(
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
                _daysRemainingLabel(),
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
            'Tu pareja juega con marcador oculto',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 23,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Vos ves tu propio avance. El resultado real se descubre al cierre de la semana.',
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _competitorCard(
                  context: context,
                  player: currentUserData,
                  xp: currentUserXp,
                  isLeader: true,
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
                  isLeader: false,
                  isCurrentUser: false,
                  showExactXp: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildDuelBar(
            context: context,
            currentUserXp: currentUserXp,
          ),
          const SizedBox(height: 16),
          _buildWeekRow(context),
        ],
      ),
    );
  }

  Widget _competitorCard({
    required BuildContext context,
    required Map<String, dynamic> player,
    required int xp,
    required bool showExactXp,
    required bool isLeader,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accent.withValues(alpha: isLeader ? 0.18 : 0.12),
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
            isCurrentUser ? 'Vos' : 'Pareja',
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
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              showExactXp ? '$xp XP' : 'XP oculta',
              style: TextStyle(
                color: accent,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuelBar({
    required BuildContext context,
    required int currentUserXp,
  }) {
    final theme = context.theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Ventaja semanal',
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              'Marcador oculto',
              style: TextStyle(
                color: theme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.18),
                  AppColors.accentPeach.withValues(alpha: 0.18),
                  AppColors.sage.withValues(alpha: 0.18),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tus $currentUserXp XP ya cuentan. La XP de tu pareja queda oculta hasta el domingo.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow(BuildContext context) {
    final theme = context.theme;
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now().weekday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ritmo semanal',
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
            final isPast = dayNumber < today;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
                height: 34,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : isPast
                          ? theme.surface
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? AppColors.primary.withValues(alpha: 0.35)
                        : theme.border.withValues(alpha: 0.55),
                    width: isToday ? 1.6 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday
                          ? AppColors.primary
                          : isPast
                              ? theme.textSecondary
                              : theme.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  String _daysRemainingLabel() {
    final today = DateTime.now().weekday;
    final remaining = 7 - today;
    if (remaining <= 0) return 'Cierra hoy';
    if (remaining == 1) return '1 día restante';
    return '$remaining días restantes';
  }

  String _firstName(dynamic rawName) {
    final name = (rawName as String? ?? 'Jugador').trim();
    if (name.isEmpty) return 'Jugador';
    return name.split(' ').first;
  }
}
