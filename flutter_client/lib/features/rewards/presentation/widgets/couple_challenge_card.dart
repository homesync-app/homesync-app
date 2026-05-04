import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../domain/models/couple_challenge.dart';

class CoupleChallengeCard extends StatefulWidget {
  final CoupleChallenge challenge;
  final int challengeNumber;
  final int totalChallenges;
  final VoidCallback onComplete;

  const CoupleChallengeCard({
    super.key,
    required this.challenge,
    required this.challengeNumber,
    required this.totalChallenges,
    required this.onComplete,
  });

  @override
  State<CoupleChallengeCard> createState() => _CoupleChallengeCardState();
}

class _CoupleChallengeCardState extends State<CoupleChallengeCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    const highlight = Color(0xFF6B8E85);
    final theme = context.theme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: theme.border.withValues(alpha: 0.75),
        ),
        boxShadow: theme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _softPill(
                      icon: Icons.auto_awesome_rounded,
                      label:
                          'Especial semanal ${widget.challengeNumber} de ${widget.totalChallenges}',
                      textColor: highlight,
                      background: highlight.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Expandir',
                onPressed: _toggleExpanded,
                style: IconButton.styleFrom(
                  backgroundColor: theme.surface,
                  foregroundColor: theme.textMuted,
                ),
                icon: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _isExpanded ? 0.5 : 0,
                  child: const Icon(Icons.expand_more_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isExpanded)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 74,
                      height: 74,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: highlight.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Text(
                        widget.challenge.icon,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        widget.challenge.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 23,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  widget.challenge.description,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: highlight.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    widget.challenge.icon,
                    style: const TextStyle(fontSize: 30),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.challenge.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _collapsedSummary(widget.challenge.description),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _toggleExpanded,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: highlight,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              _isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18,
            ),
            label: Text(
              _isExpanded ? 'Ver menos' : 'Ver detalle completo',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: highlight.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _softPill(
                        icon: Icons.place_rounded,
                        label: widget.challenge.location,
                        textColor: highlight,
                        background: highlight.withValues(alpha: 0.08),
                      ),
                      _softPill(
                        icon: Icons.favorite_outline_rounded,
                        label: widget.challenge.category,
                        textColor: highlight,
                        background: highlight.withValues(alpha: 0.08),
                      ),
                      _softPill(
                        icon: Icons.schedule_rounded,
                        label: widget.challenge.timing,
                        textColor: theme.textSecondary,
                        background: theme.surface,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.challenge.motivation,
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: theme.surfaceVariant.withValues(
                alpha: theme.isDarkMode ? 0.52 : 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.border.withValues(alpha: 0.6),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recompensa compartida',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Si lo completan, ambos reciben ${widget.challenge.coinReward} coins.',
                        style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: widget.onComplete,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.94),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Lo hicimos',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleExpanded() {
    setState(() => _isExpanded = !_isExpanded);
  }

  String _collapsedSummary(String description) {
    final paragraphs = description
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (paragraphs.isEmpty) {
      return '';
    }
    return paragraphs.first;
  }

  Widget _softPill({
    required IconData icon,
    required String label,
    required Color textColor,
    required Color background,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
