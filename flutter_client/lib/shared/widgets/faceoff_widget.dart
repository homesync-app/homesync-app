import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AIFaceoffWidget extends StatefulWidget {
  final List<Map<String, dynamic>> weeklyRanking;

  const AIFaceoffWidget({super.key, required this.weeklyRanking});

  @override
  State<AIFaceoffWidget> createState() => _AIFaceoffWidgetState();
}

class _AIFaceoffWidgetState extends State<AIFaceoffWidget> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeklyRanking.length < 2) {
      return const SizedBox.shrink();
    }

    // Sort to ensure current user is easily identifiable or standard order
    final p1 = widget.weeklyRanking[0];
    final p2 = widget.weeklyRanking[1];

    final p1Xp = (p1['xp_earned'] as num?)?.toInt() ?? 0;
    final p2Xp = (p2['xp_earned'] as num?)?.toInt() ?? 0;
    
    // We create a "mystery" percentage. 
    // If it's not Sunday, we might want to hide the real progress or show a generic one.
    // The user mentioned "no se sepa hasta el domingo quien gana".
    final totalXp = p1Xp + p2Xp;
    final p1Pct = totalXp == 0 ? 0.5 : p1Xp / totalXp;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '⚔️ DUELO SEMANAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Competitors
          Row(
            children: [
              _buildCompetitor(p1),
              _buildVSIndicator(),
              _buildCompetitor(p2),
            ],
          ),
          const SizedBox(height: 32),
          
          // Mystery Progress Bar
          _buildMysteryBar(p1Pct),
          
          const SizedBox(height: 24),
          
          // Weekly Activity Track
          _buildWeeklyTrack(),
        ],
      ),
    );
  }

  Widget _buildCompetitor(Map<String, dynamic> player) {
    final name = (player['user_name'] as String? ?? 'Jugador').split(' ').first;
    final avatarUrl = player['avatar_url'] as String?;
    final xp = (player['xp_earned'] as num?)?.toInt() ?? 0;
    final isCurrentUser = _currentUserId == player['user_id'];

    return Expanded(
      child: Column(
        children: [
          CustomUserAvatar(
            name: name,
            avatarUrl: avatarUrl,
            radius: 46,
            isAnimated: false,
            showBorder: true,
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: isCurrentUser ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(height: 4),
            Text(
              '$xp XP',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.accentGold,
                fontSize: 13,
              ),
            ),
          ] else ...[
             const SizedBox(height: 4),
             const Text(
              '??? XP',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVSIndicator() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: const Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildMysteryBar(double p1Pct) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 14, color: AppColors.textMuted.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(
              'EL RESULTADO SE REVELA EL DOMINGO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted.withValues(alpha: 0.8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 12,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            child: Stack(
              children: [
                // We show a "balanced" or "shifting" bar that doesn't reveal the winner clearly
                // unless it's Sunday. For now, let's keep it mystery.
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 800),
                      width: constraints.maxWidth * 0.5, // Always show 50% for mystery?
                      // Or slightly offset based on current user's lead but hidden?
                      // The user said "no se sepa hasta el domingo".
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.4),
                            AppColors.accent.withValues(alpha: 0.4),
                          ],
                        ),
                      ),
                    );
                  }
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(8, (_) => Icon(
                      Icons.help_outline,
                      size: 8,
                      color: Colors.white.withValues(alpha: 0.5),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrack() {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now().weekday; // 1-7

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'RITMO SEMANAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            Spacer(),
            Text(
              '7 días restantes', // This could be calculated
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final dayNum = index + 1;
            final isToday = dayNum == today;
            final isPast = dayNum < today;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index == 6 ? 0 : 6),
                height: 36,
                decoration: BoxDecoration(
                  color: isToday 
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : (isPast ? Colors.black.withValues(alpha: 0.03) : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday 
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : (isPast ? Colors.black.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday 
                        ? AppColors.primary 
                        : (isPast ? AppColors.textSecondary : AppColors.textMuted),
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
}
