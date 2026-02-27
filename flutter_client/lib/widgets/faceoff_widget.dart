import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'user_avatar.dart';

class AIFaceoffWidget extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyRanking;

  const AIFaceoffWidget({super.key, required this.weeklyRanking});

  @override
  Widget build(BuildContext context) {
    if (weeklyRanking.length < 2) {
      return const SizedBox.shrink();
    }

    final p1 = weeklyRanking[0];
    final p2 = weeklyRanking[1];

    final p1Xp = (p1['xp_earned'] as num?)?.toInt() ?? 0;
    final p2Xp = (p2['xp_earned'] as num?)?.toInt() ?? 0;
    
    final totalXp = p1Xp + p2Xp;
    final p1Pct = totalXp == 0 ? 0.5 : p1Xp / totalXp;
    final p2Pct = totalXp == 0 ? 0.5 : p2Xp / totalXp;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'DUELO DE LA SEMANA',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accentGold.withOpacity(0.8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Player 1
              _buildCompetitor(p1, isLeft: true),
              
              // VS Heart
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 60),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withValues(alpha: 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(color: Colors.pink.shade50),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.pink,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),

              // Player 2
              _buildCompetitor(p2, isLeft: false),
            ],
          ),
          const SizedBox(height: 32),
          // Progress Bar
          _buildDuelProgress(p1Xp, p2Xp, p1Pct, p2Pct),
        ],
      ),
    );
  }

  Widget _buildCompetitor(Map<String, dynamic> player, {required bool isLeft}) {
    final name = (player['user_name'] as String? ?? 'Jugador').split(' ').first;
    final avatarUrl = player['avatar_url'] as String?;

    return Expanded(
      child: Column(
        children: [
          CustomUserAvatar(
            name: name,
            avatarUrl: avatarUrl,
            radius: 48,
            isAnimated: false,
            isPriority: false,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 17,
              color: Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuelProgress(int p1Xp, int p2Xp, double p1Pct, double p2Pct) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _XpIndicator(xp: p1Xp, color: AppColors.primary),
            _XpIndicator(xp: p2Xp, color: AppColors.accentTeal),
          ],
        ),
        const SizedBox(height: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 14,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  width: (p1Pct * 200).clamp(10, 190),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    ),
                  ),
                ),
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: AppColors.accentTeal,
                      gradient: LinearGradient(
                        colors: [AppColors.accentTeal.withOpacity(0.8), AppColors.accentTeal],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _XpIndicator extends StatelessWidget {
  final int xp;
  final Color color;
  const _XpIndicator({required this.xp, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${xp} XP',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color,
          fontSize: 15,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
