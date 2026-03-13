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
    with TickerProviderStateMixin {
  String? _currentUserId;
  late AnimationController _vsPulseController;
  late AnimationController _scanningController;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;

    _vsPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanningController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _vsPulseController.dispose();
    _scanningController.dispose();
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.02)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('⚔️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Text(
                      'DUELO DE PODER',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary.withValues(alpha: 0.8),
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
            children: [
              _buildCompetitor(p1),
              _buildVSIndicator(),
              _buildCompetitor(p2),
            ],
          ),
          const SizedBox(height: 36),
          _buildMysteryBar(p1Pct),
          const SizedBox(height: 32),
          _buildWeeklyTrack(),
          const SizedBox(height: 28),
          _buildSimulationButton(context),
        ],
      ),
    );
  }

  Widget _buildSimulationButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _simulateFinal(context),
        icon: const Icon(Icons.science_outlined, size: 16, color: AppColors.primary),
        label: const Text(
          'SIMULAR FINAL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: AppColors.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _simulateFinal(BuildContext context) {
    final p1 = widget.weeklyRanking[0];
    final p2 = widget.weeklyRanking[1];
    
    final p1Xp = (p1['xp_earned'] as num?)?.toInt() ?? 0;
    final p2Xp = (p2['xp_earned'] as num?)?.toInt() ?? 0;
    
    final winner = p1Xp >= p2Xp ? p1 : p2;
    final loser = p1Xp >= p2Xp ? p2 : p1;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '¡${winner['user_name']} ganaría el duelo!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Con ${winner['xp_earned']} XP vs ${loser['xp_earned']} XP',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Premio estimado:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🪙', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    '20 COINS',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.accentGold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'ENTENDIDO',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
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
            isAnimated: true,
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
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _vsPulseController, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'VS',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
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
            Icon(Icons.lock_outline,
                size: 14, color: AppColors.textMuted.withValues(alpha: 0.6)),
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
            height: 14,
            width: double.infinity,
            color: const Color(0xFFF1F5F9),
            child: Stack(
              children: [
                AnimatedBuilder(
                  animation: _scanningController,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                AppColors.primary.withValues(alpha: 0.1),
                                AppColors.primary.withValues(alpha: 0.3),
                                AppColors.primary.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                              stops: [
                                (_scanningController.value - 0.3)
                                    .clamp(0.0, 1.0),
                                (_scanningController.value - 0.1)
                                    .clamp(0.0, 1.0),
                                _scanningController.value.clamp(0.0, 1.0),
                                (_scanningController.value + 0.1)
                                    .clamp(0.0, 1.0),
                                (_scanningController.value + 0.3)
                                    .clamp(0.0, 1.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Container(
                        width: 2,
                        height: double.infinity,
                        color: AppColors.primary.withValues(alpha: 0.3),
                      ),
                    );
                  },
                ),
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                        8,
                        (_) => Icon(
                              Icons.help_outline,
                              size: 8,
                              color: AppColors.textMuted.withValues(alpha: 0.3),
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
        Row(
          children: [
            const Text(
              'RITMO SEMANAL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: AppColors.textMuted,
                letterSpacing: 0.8,
              ),
            ),
            const Spacer(),
            Text(
              '${7 - today} días restantes',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
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
                height: 38,
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (isPast
                          ? Colors.black.withValues(alpha: 0.03)
                          : Colors.transparent),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isToday
                        ? AppColors.primary.withValues(alpha: 0.4)
                        : (isPast
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.05)),
                    width: isToday ? 2 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    days[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                      color: isToday
                          ? AppColors.primary
                          : (isPast
                              ? AppColors.textSecondary
                              : AppColors.textMuted),
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
