import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_provider.dart';
import 'package:homesync_client/features/stats/presentation/providers/stats_provider.dart';
import 'package:homesync_client/shared/widgets/app_state_views.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

const _tabs = ['Todos', 'Adultos', 'Peques'];

class FamilyRankingSection extends ConsumerStatefulWidget {
  const FamilyRankingSection({super.key});

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
}

class _RankingContent extends StatelessWidget {
  const _RankingContent({
    required this.ranking,
    required this.selectedTab,
    required this.onTabChanged,
    required this.theme,
  });

  final List<Map<String, dynamic>> ranking;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final AppThemeColors theme;

  List<Map<String, dynamic>> get _filtered {
    if (selectedTab == 0) return ranking;
    if (selectedTab == 1) {
      return ranking.where((item) {
        final type = item['member_type'] as String?;
        return type == 'parent' || type == 'guardian';
      }).toList();
    }
    return ranking
        .where((item) => (item['member_type'] as String?) == 'child')
        .toList();
  }

  bool get _hasAdults => ranking.any((i) {
        final type = i['member_type'] as String?;
        return type == 'parent' || type == 'guardian';
      });

  bool get _hasChildren => ranking.any((i) => i['member_type'] == 'child');

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
    final filtered = _filtered;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.emoji_events_outlined,
              color: AppColors.accentGold,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Ranking semanal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Puntos por tareas completadas esta semana.',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 13,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: theme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.border.withValues(alpha: 0.72)),
          ),
          child: Column(
            children: [
              if (_showTabs) ...[
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: theme.surfaceContainer,
                    borderRadius: BorderRadius.circular(14),
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
                            padding: const EdgeInsets.symmetric(vertical: 7),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Text(
                              _tabs[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
                const SizedBox(height: 16),
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
                  final isFirst = rank == 1 && xp > 0;
                  final isSecond = rank == 2 && xp > 0;
                  final isThird = rank == 3 && xp > 0;
                  final isLast = index == filtered.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: _RankingRow(
                      rank: rank,
                      name: _displayName(item),
                      role: _roleLabel(item),
                      avatarUrl: item['avatar_url'] as String?,
                      xp: xp,
                      tasks: tasks,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isFirst
            ? AppColors.accentGold.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isFirst
            ? Border.all(
                color: AppColors.accentGold.withValues(alpha: 0.28),
              )
            : null,
      ),
      child: Row(
        children: [
          _RankBadge(
            rank: rank,
            isFirst: isFirst,
            isSecond: isSecond,
            isThird: isThird,
            theme: theme,
          ),
          const SizedBox(width: 10),
          CustomUserAvatar(
            avatarUrl: resolvedAvatar,
            name: name,
            radius: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isFirst ? FontWeight.w900 : FontWeight.w700,
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.textSecondary,
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
                      ? AppColors.primary.withValues(alpha: 0.10)
                      : theme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  xp > 0 ? '$xp pts' : '0 pts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: xp > 0 ? AppColors.primary : theme.textSecondary,
                  ),
                ),
              ),
              if (tasks > 0) ...[
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
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({
    required this.rank,
    required this.isFirst,
    required this.isSecond,
    required this.isThird,
    required this.theme,
  });

  final int rank;
  final bool isFirst;
  final bool isSecond;
  final bool isThird;
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
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
