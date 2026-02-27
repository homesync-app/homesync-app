import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/supabase_rpc_service.dart';
import '../theme/app_colors.dart';
import '../widgets/user_avatar.dart';

class WeeklyWinnerScreen extends StatefulWidget {
  final SupabaseRpcService rpc;
  final VoidCallback onClose;

  const WeeklyWinnerScreen({
    super.key,
    required this.rpc,
    required this.onClose,
  });

  @override
  State<WeeklyWinnerScreen> createState() => _WeeklyWinnerScreenState();
}

class _WeeklyWinnerScreenState extends State<WeeklyWinnerScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _ranking = [];
  Map<String, dynamic>? _winner;
  bool _isLoading = true;
  bool _showContent = false;

  late AnimationController _confettiController;
  late AnimationController _winnerController;
  late Animation<double> _winnerAnimation;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _winnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _winnerAnimation = CurvedAnimation(
      parent: _winnerController,
      curve: Curves.elasticOut,
    );

    _loadData();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _winnerController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final ranking = await widget.rpc.getWeeklyRanking();

      if (ranking.isNotEmpty) {
        _winner = ranking.first;
        await widget.rpc.awardWeeklyWinner();
      }

      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() => _showContent = true);
          _confettiController.repeat();
          _winnerController.forward();
        }
      });
    } catch (e) {
      debugPrint('Error loading winner: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              const Color(0xFF1E1B4B).withOpacity(0.95),
              Colors.black.withOpacity(0.9),
            ],
            radius: 1.2,
          ),
        ),
        child: Stack(
          children: [
            if (_showContent) _buildConfetti(),
            SafeArea(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfetti() {
    return AnimatedBuilder(
      animation: _confettiController,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(_confettiController.value),
          size: Size.infinite,
        );
      },
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

    return AnimatedOpacity(
      opacity: _showContent ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 40),
            _buildWinnerCard(),
            const SizedBox(height: 32),
            _buildRanking(),
            const Spacer(),
            _buildCloseButton(),
          ],
        ),
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
            fontSize: 28,
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
    return ScaleTransition(
      scale: _winnerAnimation,
      child: Container(
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
            Center(
              child: CustomUserAvatar(
                name: _winner!['user_name'],
                avatarUrl: _winner!['avatar_url'],
                radius: 60,
                showBorder: true,
                isPriority: true,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: AppColors.accent, size: 32),
                const SizedBox(width: 8),
                Text(
                  _winner!['user_name'] ?? 'Ganador',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.star, color: AppColors.accent, size: 32),
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
                  const Icon(Icons.star_rounded,
                      color: AppColors.accent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '${_winner!['xp_earned'] ?? 0} XP',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.monetization_on_rounded,
                      color: AppColors.success, size: 20),
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
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                      color: AppColors.accent.withOpacity(0.1),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

class ConfettiPainter extends CustomPainter {
  final double progress;
  final List<ConfettiPiece> pieces;

  ConfettiPainter(this.progress) : pieces = [] {
    final random = Random(42);
    for (int i = 0; i < 60; i++) {
      pieces.add(ConfettiPiece(random));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var piece in pieces) {
      piece.update(progress);
      piece.draw(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ConfettiPiece {
  final Random random;
  double x;
  double y;
  double speed;
  double size;
  Color color;
  double rotation;

  ConfettiPiece(this.random)
      : x = random.nextDouble(),
        y = -0.1 - random.nextDouble() * 0.5,
        speed = 0.002 + random.nextDouble() * 0.004,
        size = 5 + random.nextDouble() * 8,
        rotation = random.nextDouble() * 360,
        color = [
          AppColors.accent,
          AppColors.success,
          AppColors.primary,
          Colors.pink,
          Colors.orange,
          Colors.cyan,
        ][random.nextInt(6)];

  void update(double progress) {
    y += speed;
    rotation += 3;

    if (y > 1.2) {
      y = -0.1;
      x = random.nextDouble();
    }
  }

  void draw(Canvas canvas, Size size) {
    final paint = Paint()..color = color;

    canvas.save();
    canvas.translate(x * size.width, y * size.height);
    canvas.rotate(rotation * 3.14159 / 180);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: this.size,
        height: this.size * 0.5,
      ),
      paint,
    );

    canvas.restore();
  }
}
