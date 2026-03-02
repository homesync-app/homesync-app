import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/services/supabase_rpc_service.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class WeeklyWinnerScreen extends ConsumerStatefulWidget {
  final SupabaseRpcService rpc;
  final VoidCallback onClose;

  const WeeklyWinnerScreen({
    super.key,
    required this.rpc,
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
      final ranking = await widget.rpc.getWeeklyRanking();

      if (ranking.isNotEmpty) {
        _winner = ranking.first;
        await widget.rpc.awardWeeklyWinner();
        
        if (ranking.length >= 2) {
          final householdInfo = await widget.rpc.getHouseholdInfo();
          final householdId = householdInfo['household_id'] as String?;
          
          if (householdId != null) {
            final winner = ranking.first;
            final loser = ranking[1];
            final weekStart = DateTime.now();
            final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day)
                .subtract(Duration(days: weekStart.weekday - 1));
            
            await widget.rpc.saveWeeklyDuelResult(
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

      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading winner: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProfileProvider, (previous, next) {
      _loadData();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF1E1B4B).withValues(alpha: 0.95),
              Colors.black.withValues(alpha: 0.9),
            ],
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_winner == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined,
                size: 80, color: Colors.white54),
            const SizedBox(height: 24),
            const Text(
              'Sin actividades esta semana',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '¡Completen tareas la próxima semana!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            TextButton(
              onPressed: widget.onClose,
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildHeader(),
          const SizedBox(height: 30),
          _buildWinnerCard(),
          const SizedBox(height: 24),
          _buildRanking(),
          const Spacer(),
          _buildCloseButton(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Text('🏆', style: TextStyle(fontSize: 48)),
        ),
        const SizedBox(height: 16),
        const Text(
          '¡GANADOR DE LA SEMANA!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _getWeekRange(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildWinnerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.3),
            AppColors.success.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          CustomUserAvatar(
            name: _winner!['user_name'],
            avatarUrl: _winner!['avatar_url'],
            radius: 60,
            showBorder: true,
            isPriority: true,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: AppColors.accent, size: 28),
              const SizedBox(width: 8),
              Text(
                _winner!['user_name'] ?? 'Ganador',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.star, color: AppColors.accent, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.accent, size: 24),
                const SizedBox(width: 8),
                Text(
                  '${_winner!['xp_earned'] ?? 0} XP',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on_rounded, color: AppColors.success, size: 20),
                SizedBox(width: 6),
                Text(
                  '+20 coins ganados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRanking() {
    if (_ranking.length <= 1) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ranking de la semana',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        ..._ranking.skip(1).map((player) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  CustomUserAvatar(
                    name: player['user_name'],
                    avatarUrl: player['avatar_url'],
                    radius: 18,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      player['user_name'] ?? 'Jugador',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: AppColors.accent, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${player['xp_earned'] ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildCloseButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.onClose,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text(
          '¡Genial!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
