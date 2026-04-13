import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/features/dashboard/domain/models/love_note_model.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/love_notes_provider.dart';

/// Sobre animado que aparece en el header del home cuando hay una nota de amor.
///
/// Flujo:
/// 1. Entra volando desde la esquina superior derecha (slide + scale + fade).
/// 2. Flota suavemente en loop mientras no se toca.
/// 3. Al tocar: se abre con animación y muestra el mensaje con corazones.
/// 4. Al cerrar: se va volando hacia arriba y se marca como leída.
class LoveNoteEnvelope extends ConsumerStatefulWidget {
  final LoveNoteModel note;
  final String senderName;

  const LoveNoteEnvelope({
    super.key,
    required this.note,
    required this.senderName,
  });

  @override
  ConsumerState<LoveNoteEnvelope> createState() => _LoveNoteEnvelopeState();
}

class _LoveNoteEnvelopeState extends ConsumerState<LoveNoteEnvelope>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _openController;
  late final ConfettiController _confettiController;

  bool _isOpen = false;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _openController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1800),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _openController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _onTap() {
    if (_isDismissing) return;
    HapticFeedback.lightImpact();
    setState(() => _isOpen = true);
    _floatController.stop();
    _openController.forward();
    _confettiController.play();
  }

  Future<void> _onClose() async {
    HapticFeedback.lightImpact();
    setState(() {
      _isOpen = false;
      _isDismissing = true;
    });
    await _openController.reverse();
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
      ref.read(loveNotesProvider.notifier).markAsRead(widget.note.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        // Confetti de corazones
        Positioned(
          top: 0,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.08,
            numberOfParticles: 12,
            gravity: 0.15,
            colors: const [
              Color(0xFFEF4444),
              Color(0xFFF87171),
              Color(0xFFFCA5A5),
              Color(0xFFFF8FAB),
              AppColors.accentOrange,
            ],
            createParticlePath: _heartPath,
          ),
        ),

        // El sobre / mensaje
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            final floatOffset = _isOpen || _isDismissing
                ? 0.0
                : sin(_floatController.value * pi) * 5.0;
            return Transform.translate(
              offset: Offset(0, floatOffset),
              child: child,
            );
          },
          child: GestureDetector(
            onTap: _isOpen ? null : _onTap,
            child: _isOpen ? _buildOpenNote() : _buildClosedEnvelope(),
          ),
        ),
      ],
    );
  }

  // ── Sobre cerrado ────────────────────────────────────────────────────────────

  Widget _buildClosedEnvelope() {
    return SizedBox(
      width: 100,
      height: 74,
      child: Stack(
        children: [
          // Imagen custom del sobre (la que vas a crear vos)
          Positioned.fill(
            child: Image.asset(
              'assets/images/love_note_envelope.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => _buildFallbackEnvelope(),
            ),
          ),
          // Badge de punto rojo arriba a la derecha
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 0.8, end: 1.2, duration: 900.ms),
          ),
        ],
      ),
    )
        // Entrada: vuela desde arriba-derecha
        .animate()
        .slideX(begin: 1.2, end: 0, duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms)
        .scaleXY(begin: 0.4, end: 1.0, duration: 600.ms, curve: Curves.elasticOut);
  }

  Widget _buildFallbackEnvelope() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF1F2), Color(0xFFFFE4E6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text('💌', style: TextStyle(fontSize: 36)),
      ),
    );
  }

  // ── Nota abierta ─────────────────────────────────────────────────────────────

  Widget _buildOpenNote() {
    return AnimatedBuilder(
      animation: _openController,
      builder: (context, child) => Opacity(
        opacity: _openController.value,
        child: Transform.scale(
          scale: 0.6 + (_openController.value * 0.4),
          child: child,
        ),
      ),
      child: Container(
        width: 220,
        constraints: const BoxConstraints(maxHeight: 260),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBFB),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFCA5A5).withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEF4444).withValues(alpha: 0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE4E6), Color(0xFFFFF1F2)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  const Text('💌', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${widget.senderName} te escribió',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9F1239),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: _onClose,
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: Color(0xFFBE123C),
                    ),
                  ),
                ],
              ),
            ),
            // Mensaje
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.note.content,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1917),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Footer
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text('❤️', style: TextStyle(fontSize: 11)),
                  SizedBox(width: 4),
                  Text(
                    'Guardado en tu corazón',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFBE123C),
                      fontWeight: FontWeight.w600,
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

  // ── Forma de corazón para confetti ───────────────────────────────────────────

  Path _heartPath(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w / 2, h * 0.35);
    path.cubicTo(w * 0.15, 0, -w * 0.25, h * 0.55, w / 2, h);
    path.cubicTo(w * 1.25, h * 0.55, w * 0.85, 0, w / 2, h * 0.35);
    path.close();
    return path;
  }
}
