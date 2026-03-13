import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class XPToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const XPToggleButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
            border: Border.all(
              color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : AppColors.textPrimary.withValues(alpha: 0.4),
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PrivacyBadge extends StatelessWidget {
  final String text;
  const PrivacyBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.shield_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String label;
  final String icon;
  const SectionLabel({super.key, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 14),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary.withValues(alpha: 0.6),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class MiniStatCard extends StatelessWidget {
  final String icon;
  final String value;
  final String label;
  final Color color;

  const MiniStatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Text(icon, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

class DuelHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> duelHistory;

  const DuelHistoryWidget({super.key, required this.duelHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: duelHistory.asMap().entries.map((entry) {
          final index = entry.key;
          final duel = entry.value;
          final isLast = index == duelHistory.length - 1;
          
          final winnerName = (duel['winner_name'] as String? ?? 'Ganador').split(' ').first;
          final loserName = (duel['loser_name'] as String? ?? 'Perdedor').split(' ').first;
          final winnerXp = (duel['winner_xp'] as num?)?.toInt() ?? 0;
          final loserXp = (duel['loser_xp'] as num?)?.toInt() ?? 0;
          final userResult = duel['user_result'] as String? ?? 'neutral';
          final weekDate = duel['week_start_date'];
          
          String weekLabel = 'Semana pasada';
          if (weekDate != null) {
            try {
              final date = DateTime.parse(weekDate.toString());
              weekLabel = '${date.day}/${date.month}';
            } catch (_) {}
          }

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast ? null : Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: userResult == 'win'
                          ? [AppColors.success, AppColors.success.withValues(alpha: 0.8)]
                          : userResult == 'loss'
                              ? [Colors.red.shade400, Colors.red.shade300]
                              : [AppColors.textMuted.withValues(alpha: 0.3), AppColors.textMuted.withValues(alpha: 0.2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      userResult == 'win' ? '🏆' : userResult == 'loss' ? '😢' : '⚔️',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            winnerName,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: userResult == 'win' ? AppColors.success : AppColors.textPrimary,
                            ),
                          ),
                          const Text(' vs ', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          Text(
                            loserName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        weekLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: userResult == 'win'
                        ? AppColors.success.withValues(alpha: 0.1)
                        : userResult == 'loss'
                            ? Colors.red.withValues(alpha: 0.1)
                            : AppColors.accentGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        userResult == 'win' ? '✓' : userResult == 'loss' ? '✗' : '=',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: userResult == 'win'
                              ? AppColors.success
                              : userResult == 'loss'
                                  ? Colors.red
                                  : AppColors.accentGold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$winnerXp - $loserXp',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: userResult == 'win'
                              ? AppColors.success
                              : userResult == 'loss'
                                  ? Colors.red.shade600
                                  : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
