import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
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

  /// Acento del modo de hogar; null usa el primary global (settings).
  final Color? accent;

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
    this.accent,
  });

  bool get _isShared => financeMode == 'shared';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final tone = accent ?? theme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (supportsFinanceModeChoice) ...[
          _buildInfoCard(
            theme,
            t.coupleSplitModeHowTitle(modeKey),
            t.coupleSplitModeHowBody(modeKey),
          ),
          const SizedBox(height: 20),
          _buildStrategyItem(
            theme,
            tone,
            t.coupleSplitModeSharedTitle,
            t.coupleSplitModeSharedBody(modeKey),
            Icons.all_inclusive_rounded,
            isActive: _isShared,
            onTap: () => onFinanceModeChanged('shared'),
          ),
          _buildStrategyItem(
            theme,
            tone,
            t.coupleSplitModeDividedTitle,
            t.coupleSplitModeDividedBody(modeKey),
            Icons.balance_rounded,
            isActive: !_isShared,
            onTap: () => onFinanceModeChanged('divided'),
          ),
        ],
        if (!supportsFinanceModeChoice || !_isShared) ...[
          SizedBox(height: supportsFinanceModeChoice ? 28 : 0),
          if (!supportsFinanceModeChoice) ...[
            _buildInfoCard(
              theme,
              t.coupleSplitInfoTitle,
              t.coupleSplitInfoBody,
            ),
            const SizedBox(height: 32),
          ],
          Text(
            t.coupleSplitStrategiesTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildStrategyItem(
            theme,
            tone,
            t.coupleSplitStrategy5050Title,
            t.coupleSplitStrategy5050Body,
            Icons.people_alt_rounded,
            isActive: splitRatio == 0.5,
            onTap: () => onSplitRatioChanged(0.5),
          ),
          _buildStrategyItem(
            theme,
            tone,
            t.coupleSplitStrategy6040Title,
            t.coupleSplitStrategy6040Body,
            Icons.trending_up_rounded,
            isActive: splitRatio != 0.5,
            onTap: () {}, // Adjusted via the slider below.
          ),
          const SizedBox(height: 32),
          Text(
            t.coupleSplitCustomTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: theme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.coupleSplitCustomBody,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          _buildSplitVisualizer(context, t, tone),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: tone,
              inactiveTrackColor: tone.withValues(alpha: 0.1),
              thumbColor: tone,
              overlayColor: tone.withValues(alpha: 0.2),
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

  Widget _buildInfoCard(AppThemeColors theme, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.accentTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.xl),
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
            style: TextStyle(height: 1.5, color: theme.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategyItem(
    AppThemeColors theme,
    Color tone,
    String title,
    String desc,
    IconData icon, {
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: AppMotion.slow,
        margin: const EdgeInsets.only(bottom: AppInsets.itemGap),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isActive
              ? theme.surface
              : theme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: isActive ? tone : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: tone.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.normal,
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: tone.withValues(alpha: isActive ? 0.14 : 0.08),
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(
                icon,
                color: isActive
                    ? tone
                    : theme.textMuted.withValues(alpha: 0.8),
                size: AppControlSizes.iconLg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                  Text(
                    desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive) Icon(Icons.check_circle_rounded, color: tone),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitVisualizer(
    BuildContext context,
    AppLocalizations t,
    Color tone,
  ) {
    final theme = context.theme;
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
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: tone,
                  ),
                ),
                Text(
                  '$youPercent%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: theme.textPrimary,
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
            borderRadius: BorderRadius.circular(AppRadii.lg),
            color: tone.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.slow,
                width: MediaQuery.of(context).size.width * 0.8 * splitRatio,
                color: tone,
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
