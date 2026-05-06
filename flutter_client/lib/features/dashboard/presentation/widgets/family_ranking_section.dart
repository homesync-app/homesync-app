import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

const _tabs = ['Todos', 'Adultos', 'Chicos'];

class FamilyRankingSection extends ConsumerStatefulWidget {
  const FamilyRankingSection({
    super.key,
    required this.currentMember,
  });

  final MemberModel? currentMember;

  @override
  ConsumerState<FamilyRankingSection> createState() =>
      _FamilyRankingSectionState();
}

class _FamilyRankingSectionState extends ConsumerState<FamilyRankingSection> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final statsAsync = ref.watch(statsControllerProvider);

    return statsAsync.when(
      data: (stats) {
        final ranking = stats.weeklyRanking;
        return _RankingContent(
          ranking: ranking,
          selectedTab: _selectedTab,
          onTabChanged: (i) => setState(() => _selectedTab = i),
          theme: theme,
          hideLiveScores: _shouldHideLiveScores(widget.currentMember),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: AppLoadingState(message: 'Cargando ranking...'),
      ),
      error: (error, _) => AppErrorState(
        message: 'No pudimos cargar el ranking.\n$error',
        onRetry: () => ref.invalidate(statsControllerProvider),
      ),
    );
  }

  bool _shouldHideLiveScores(MemberModel? member) {
    if (member == null || member.isAdult) return false;
    final today = DateTime.now().weekday;
    return member.isTeen || member.isChild ? today >= DateTime.thursday : false;
  }
}

class _RankingContent extends StatelessWidget {
  const _RankingContent({
    required this.ranking,
    required this.selectedTab,
    required this.onTabChanged,
    required this.theme,
    required this.hideLiveScores,
  });

  final List<Map<String, dynamic>> ranking;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final AppThemeColors theme;
  final bool hideLiveScores;

  List<Map<String, dynamic>> get _filtered {
    if (selectedTab == 0) return ranking;
    if (selectedTab == 1) {
      return ranking.where((item) {
        final type = item['member_type'] as String?;
        return type == 'parent' || type == 'guardian';
      }).toList();
    }
    return ranking.where((item) {
      final type = item['member_type'] as String?;
      return type == 'child' || type == 'teen';
    }).toList();
  }

  bool get _hasAdults => ranking.any((i) {
        final type = i['member_type'] as String?;
        return type == 'parent' || type == 'guardian';
      });

  bool get _hasChildren => ranking.any((i) {
        final type = i['member_type'] as String?;
        return type == 'child' || type == 'teen';
      });

  bool get _showTabs => _hasAdults && _hasChildren;

  String _displayName(Map<String, dynamic> item) {
    final name = item['user_name'] as String? ?? '';
    return name.isNotEmpty ? name.split(' ').first : 'Integrante';
  }

  String _roleLabel(Map<String, dynamic> item) {
    final type = item['member_type'] as String?;
    switch (type) {
      case 'parent':
        return 'Adulto';
      case 'guardian':
        return 'Adulto';
      case 'teen':
        return 'Adolescente';
      case 'child':
        return 'Peque';
      default:
        return 'Integrante';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = hideLiveScores
        ? (List<Map<String, dynamic>>.of(_filtered)
          ..sort(
            (a, b) => _displayName(a).compareTo(_displayName(b)),
          ))
        : _filtered;
    final leader = ranking.isNotEmpty ? ranking.first : null;
    final leaderName = leader == null ? null : _displayName(leader);
    final totalPoints = ranking.fold<int>(
      0,
      (sum, item) => sum + ((item['xp_earned'] as num?)?.toInt() ?? 0),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: AppColors.accentGold,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Ranking semanal',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (totalPoints > 0 && !hideLiveScores)
              _HeaderPill(
                label: '$totalPoints pts',
              ),
            if (hideLiveScores) const _HeaderPill(label: 'Sorpresa'),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          hideLiveScores
              ? 'Desde el jueves guardamos los puntos para revelar el ganador al cierre.'
              : leaderName == null || totalPoints == 0
                  ? 'Puntos por tareas completadas esta semana.'
                  : '$leaderName viene liderando la semana.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: theme.isDarkMode
                  ? [
                      theme.surface,
                      theme.surfaceContainer.withValues(alpha: 0.62),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFFFFAF6),
                    ],
            ),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: theme.border.withValues(alpha: 0.58)),
            boxShadow: [
              BoxShadow(
                color: theme.shadow
                    .withValues(alpha: theme.isDarkMode ? 0.18 : 0.055),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            children: [
              if (_showTabs) ...[
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainer.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: theme.border.withValues(alpha: 0.36),
                    ),
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (i) {
                      final selected = selectedTab == i;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => onTabChanged(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  selected ? theme.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                              boxShadow: selected
                                  ? [
                                      BoxShadow(
                                        color: theme.shadow.withValues(
                                          alpha: theme.isDarkMode ? 0.12 : 0.06,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 5),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              _tabs[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w900
                                    : FontWeight.w700,
                                color: selected
                                    ? AppColors.primary
                                    : theme.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: theme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        selectedTab == 0
                            ? 'Completen tareas para sumar puntos'
                            : 'Nadie sumó puntos en ${_tabs[selectedTab]} todavía',
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filtered.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final rank = index + 1;
                  final xp = (item['xp_earned'] as num?)?.toInt() ?? 0;
                  final tasks = (item['tasks_completed'] as num?)?.toInt() ?? 0;
                  final isFirst = !hideLiveScores && rank == 1 && xp > 0;
                  final isSecond = !hideLiveScores && rank == 2 && xp > 0;
                  final isThird = !hideLiveScores && rank == 3 && xp > 0;
                  final isLast = index == filtered.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: _RankingRow(
                      rank: rank,
                      name: _displayName(item),
                      role: _roleLabel(item),
                      avatarUrl: item['avatar_url'] as String?,
                      xp: xp,
                      tasks: tasks,
                      hideLiveScores: hideLiveScores,
                      isFirst: isFirst,
                      isSecond: isSecond,
                      isThird: isThird,
                      theme: theme,
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }
}

class _RankingRow extends ConsumerWidget {
  const _RankingRow({
    required this.rank,
    required this.name,
    required this.role,
    required this.avatarUrl,
    required this.xp,
    required this.tasks,
    required this.hideLiveScores,
    required this.isFirst,
    required this.isSecond,
    required this.isThird,
    required this.theme,
  });

  final int rank;
  final String name;
  final String role;
  final String? avatarUrl;
  final int xp;
  final int tasks;
  final bool hideLiveScores;
  final bool isFirst;
  final bool isSecond;
  final bool isThird;
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersNotifierProvider);
    final members = membersAsync.valueOrNull ?? [];

    String? resolvedAvatar = avatarUrl;
    if (resolvedAvatar == null || resolvedAvatar.isEmpty) {
      final member = members
          .where(
            (m) => m.displayName.toLowerCase() == name.toLowerCase(),
          )
          .firstOrNull;
      if (member != null) {
        resolvedAvatar = member.avatarUrl;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.accentGold.withValues(
                alpha: theme.isDarkMode ? 0.16 : 0.13,
              )
            : theme.surface.withValues(alpha: theme.isDarkMode ? 0.28 : 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFirst
              ? AppColors.accentGold.withValues(alpha: 0.34)
              : theme.border.withValues(alpha: 0.36),
        ),
      ),
      child: Row(
        children: [
          _RankBadge(
            rank: rank,
            hidden: hideLiveScores,
            isFirst: isFirst,
            isSecond: isSecond,
            isThird: isThird,
            theme: theme,
          ),
          const SizedBox(width: 11),
          CustomUserAvatar(
            avatarUrl: resolvedAvatar,
            name: name,
            radius: 19,
            forceCircular: true,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: isFirst ? FontWeight.w900 : FontWeight.w700,
                    color: theme.textPrimary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _roleColor(role).withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: _roleColor(role),
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: xp > 0
                      ? (hideLiveScores
                          ? AppColors.accentPurple.withValues(alpha: 0.10)
                          : AppColors.primary.withValues(alpha: 0.12))
                      : theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: xp > 0
                        ? (hideLiveScores
                            ? AppColors.accentPurple.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.10))
                        : theme.border.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  hideLiveScores ? 'Oculto' : (xp > 0 ? '$xp pts' : '0 pts'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: hideLiveScores
                        ? AppColors.accentPurple
                        : xp > 0
                            ? AppColors.primary
                            : theme.textSecondary,
                  ),
                ),
              ),
              if (!hideLiveScores && tasks > 0) ...[
                const SizedBox(height: 3),
                Text(
                  '$tasks tarea${tasks == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: theme.textMuted,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _roleColor(String role) {
    return switch (role) {
      'Adulto' => AppColors.sage,
      'Adolescente' => AppColors.accentBlue,
      'Peque' => AppColors.accentGold,
      _ => AppColors.primary,
    };
  }
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.hidden,
    required this.isFirst,
    required this.isSecond,
    required this.isThird,
    required this.theme,
  });

  final int rank;
  final bool hidden;
  final bool isFirst;
  final bool isSecond;
  final bool isThird;
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
    if (hidden) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: AppColors.accentPurple.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.lock_rounded,
          size: 15,
          color: AppColors.accentPurple,
        ),
      );
    }

    if (isFirst) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.accentGold,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.emoji_events,
          size: 16,
          color: Colors.white,
        ),
      );
    }

    if (isSecond) {
      return Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.military_tech,
          size: 16,
          color: Colors.white,
        ),
      );
    }

    if (isThird) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: Color(0xFFCD7F32),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.military_tech,
          size: 16,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: theme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.14)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }
}
