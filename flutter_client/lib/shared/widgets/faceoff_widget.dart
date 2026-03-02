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

class _AIFaceoffWidgetState extends State<AIFaceoffWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.weeklyRanking.length < 2) {
      return const SizedBox.shrink();
    }

    final p1 = widget.weeklyRanking[0];
    final p2 = widget.weeklyRanking[1];

    final p1Xp = (p1['xp_earned'] as num?)?.toInt() ?? 0;
    final p2Xp = (p2['xp_earned'] as num?)?.toInt() ?? 0;
    final totalXp = p1Xp + p2Xp;
    final p1Pct = totalXp == 0 ? 0.5 : p1Xp / totalXp;
    final p2Pct = totalXp == 0 ? 0.5 : p2Xp / totalXp;

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.05),
            AppColors.accent.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink.withValues(alpha: 0.15),
                      Colors.purple.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.pink.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Colors.pink.shade600, Colors.purple.shade600],
                      ).createShader(bounds),
                      child: const Text(
                        'DUELO DE LA SEMANA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCompetitor(p1, isLeft: true, showXp: _currentUserId == p1['user_id']),
              _buildVSIndicator(),
              _buildCompetitor(p2, isLeft: false, showXp: _currentUserId == p2['user_id']),
            ],
          ),
          const SizedBox(height: 28),
          _buildMysteryProgressBar(p1Xp, p2Xp, p1Pct, p2Pct),
        ],
      ),
    );
  }

  Widget _buildCompetitor(Map<String, dynamic> player, {required bool isLeft, required bool showXp}) {
    final name = (player['user_name'] as String? ?? 'Jugador').split(' ').first;
    final avatarUrl = player['avatar_url'] as String?;
    final xp = (player['xp_earned'] as num?)?.toInt() ?? 0;
    final isCurrentUser = _currentUserId == player['user_id'];

    return Expanded(
      child: Column(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomUserAvatar(
                  name: name,
                  avatarUrl: avatarUrl,
                  radius: 52,
                  isAnimated: false,
                  isPriority: isCurrentUser,
                  showBorder: true,
                ),
                if (isCurrentUser)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isCurrentUser ? AppColors.primary : const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentGold,
                    AppColors.accentGold.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGold.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '$xp XP',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVSIndicator() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 60),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.shade400,
                Colors.purple.shade500,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Text(
            'VS',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMysteryProgressBar(int p1Xp, int p2Xp, double p1Pct, double p2Pct) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.textMuted.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 6),
              Text(
                'Los puntos se revelan el domingo',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 18,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeOutCubic,
                  width: (p1Pct * MediaQuery.of(context).size.width * 0.75).clamp(20, MediaQuery.of(context).size.width * 0.75 - 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.help_outline,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      Icon(
                        Icons.help_outline,
                        size: 12,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '¿Quién ganará?',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ),
            Text(
              '¡Descubrilo el domingo!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.accentTeal.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
