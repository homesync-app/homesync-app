import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

/// Shared body for the couple/family finance configuration.
///
/// Renders the integrated-vs-divided economy selector and, when "divided" is
/// chosen, the percentage strategies + custom slider. It does NOT include a
/// Scaffold, app bar, or save button so it can be embedded both in the settings
/// screen (CoupleSplitStrategyScreen) and in the onboarding wizard step, which
/// keeps the two flows visually identical and in sync.
class CoupleFinanceConfigBody extends StatelessWidget {
  /// Household type key for localization (`couple`, `family`, ...).
  final String modeKey;

  /// Current finance mode: `'shared'` (integrated) or `'divided'`.
  final String financeMode;

  /// Current split ratio (0..1) for the divided economy.
  final double splitRatio;

  /// Whether this household can choose between shared and divided economy.
  /// Friends/solo cannot — they only see the divided percentage config.
  final bool supportsFinanceModeChoice;

  final ValueChanged<String> onFinanceModeChanged;
  final ValueChanged<double> onSplitRatioChanged;

  const CoupleFinanceConfigBody({
    super.key,
    required this.modeKey,
    required this.financeMode,
    required this.splitRatio,
    required this.supportsFinanceModeChoice,
    required this.onFinanceModeChanged,
    required this.onSplitRatioChanged,
  });

  bool get _isShared => financeMode == 'shared';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (supportsFinanceModeChoice) ...[
          _buildInfoCard(
            t.coupleSplitModeHowTitle(modeKey),
            t.coupleSplitModeHowBody(modeKey),
          ),
          const SizedBox(height: 20),
          _buildStrategyItem(
            t.coupleSplitModeSharedTitle,
            t.coupleSplitModeSharedBody(modeKey),
            '🏠',
            isActive: _isShared,
            onTap: () => onFinanceModeChanged('shared'),
          ),
          _buildStrategyItem(
            t.coupleSplitModeDividedTitle,
            t.coupleSplitModeDividedBody(modeKey),
            '⚖️',
            isActive: !_isShared,
            onTap: () => onFinanceModeChanged('divided'),
          ),
        ],
        if (!supportsFinanceModeChoice || !_isShared) ...[
          SizedBox(height: supportsFinanceModeChoice ? 28 : 0),
          if (!supportsFinanceModeChoice) ...[
            _buildInfoCard(
              t.coupleSplitInfoTitle,
              t.coupleSplitInfoBody,
            ),
            const SizedBox(height: 32),
          ],
          Text(
            t.coupleSplitStrategiesTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          _buildStrategyItem(
            t.coupleSplitStrategy5050Title,
            t.coupleSplitStrategy5050Body,
            '👫',
            isActive: splitRatio == 0.5,
            onTap: () => onSplitRatioChanged(0.5),
          ),
          _buildStrategyItem(
            t.coupleSplitStrategy6040Title,
            t.coupleSplitStrategy6040Body,
            '📈',
            isActive: splitRatio != 0.5,
            onTap: () {}, // Adjusted via the slider below.
          ),
          const SizedBox(height: 32),
          Text(
            t.coupleSplitCustomTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.coupleSplitCustomBody,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          _buildSplitVisualizer(context, t),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.primary.withValues(alpha: 0.1),
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 15),
            ),
            child: Slider(
              value: splitRatio,
              min: 0,
              max: 1,
              divisions: 20, // 5% increments
              onChanged: (val) {
                HapticFeedback.lightImpact();
                onSplitRatioChanged(val);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInfoCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.accentTeal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.accentTeal,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.accentTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(height: 1.5, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyItem(
    String title,
    String desc,
    String emoji, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(Icons.check_circle_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitVisualizer(BuildContext context, AppLocalizations t) {
    final youPercent = (splitRatio * 100).toInt();
    final partnerPercent = 100 - youPercent;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.coupleSplitVisualizerYou,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '$youPercent%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t.coupleSplitVisualizerPartner,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: AppColors.error,
                  ),
                ),
                Text(
                  '$partnerPercent%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 40,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: MediaQuery.of(context).size.width * 0.8 * splitRatio,
                color: AppColors.primary,
                child: const Center(
                  child: Icon(Icons.person, color: Colors.white, size: 16),
                ),
              ),
              Expanded(
                child: Container(
                  color: AppColors.error.withValues(alpha: 0.7),
                  child: const Center(
                    child: Icon(Icons.favorite, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
