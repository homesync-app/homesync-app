import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class CoupleSplitStrategyScreen extends ConsumerStatefulWidget {
  const CoupleSplitStrategyScreen({super.key});

  @override
  ConsumerState<CoupleSplitStrategyScreen> createState() =>
      _CoupleSplitStrategyScreenState();
}

class _CoupleSplitStrategyScreenState
    extends ConsumerState<CoupleSplitStrategyScreen> {
  double _splitRatio = 0.5;
  String _financeMode = 'divided';
  bool _isSaving = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCurrentRatio();
  }

  void _loadCurrentRatio() {
    final household = ref.read(currentHouseholdProvider).valueOrNull;
    if (household != null) {
      setState(() {
        _splitRatio = household.defaultSplitRatio;
        _financeMode = household.financeMode;
      });
    }
  }

  Future<void> _saveRatio() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final household = ref.read(currentHouseholdProvider).valueOrNull;

      if (household != null) {
        final result =
            await ref.read(updateFinanceSettingsUseCaseProvider).call(
                  household.id,
                  financeMode: _financeMode,
                  defaultSplitRatio: _splitRatio,
                );
        result.fold((failure) => throw failure, (_) {});
        ref.invalidate(currentHouseholdProvider);

        if (mounted) {
          final t = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.coupleSplitSavedSnack),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        final t = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.coupleSplitSaveError(e.toString())),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final household = ref.watch(currentHouseholdProvider).valueOrNull;
    final isFamily = household?.householdType == 'family';
    final isShared = _financeMode == 'shared';
    final t = AppLocalizations.of(context);
    final modeKey = household?.householdType ?? 'couple';

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackground,
      body: Stack(
        children: [
          // Background Decor
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),

          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: context.theme.scaffoldBackground,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    t.coupleSplitTitle(modeKey),
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  background: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Text('âš–ï¸',
                              style: TextStyle(fontSize: 48),),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (isFamily) ...[
                      _buildInfoCard(
                        t.coupleSplitFamilyHowTitle,
                        t.coupleSplitFamilyHowBody,
                      ),
                      const SizedBox(height: 20),
                      _buildStrategyItem(
                        t.coupleSplitFamilySharedTitle,
                        t.coupleSplitFamilySharedBody,
                        '🏠',
                        isActive: isShared,
                        onTap: () => setState(() => _financeMode = 'shared'),
                      ),
                      _buildStrategyItem(
                        t.coupleSplitFamilyDividedTitle,
                        t.coupleSplitFamilyDividedBody,
                        '⚖️',
                        isActive: !isShared,
                        onTap: () => setState(() => _financeMode = 'divided'),
                      ),
                      const SizedBox(height: 28),
                    ],
                    if (!isFamily || !isShared) ...[
                      _buildInfoCard(
                        t.coupleSplitInfoTitle,
                        t.coupleSplitInfoBody,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        t.coupleSplitStrategiesTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800,),
                      ),
                      const SizedBox(height: 16),
                      _buildStrategyItem(
                        t.coupleSplitStrategy5050Title,
                        t.coupleSplitStrategy5050Body,
                        '👫',
                        isActive: _splitRatio == 0.5,
                        onTap: () => setState(() => _splitRatio = 0.5),
                      ),
                      _buildStrategyItem(
                        t.coupleSplitStrategy6040Title,
                        t.coupleSplitStrategy6040Body,
                        '📈',
                        isActive: _splitRatio != 0.5,
                        onTap: () {}, // Handled by slider
                      ),
                      const SizedBox(height: 48),
                      Text(
                        t.coupleSplitCustomTitle,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800,),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        t.coupleSplitCustomBody,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildSplitVisualizer(context),
                      const SizedBox(height: 24),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          thumbColor: AppColors.primary,
                          overlayColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          trackHeight: 8,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 15,),
                        ),
                        child: Slider(
                          value: _splitRatio,
                          min: 0,
                          max: 1,
                          divisions: 20, // 5% increments
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            setState(() => _splitRatio = val);
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 64),
                    ElevatedButton(
                      onPressed: _isSaving ? null : _saveRatio,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              t.coupleSplitSaveButton,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
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
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.accentTeal,
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
      onTap: onTap,
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

  Widget _buildSplitVisualizer(BuildContext context) {
    final youPercent = (_splitRatio * 100).toInt();
    final partnerPercent = 100 - youPercent;
    final t = AppLocalizations.of(context);

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
                width: MediaQuery.of(context).size.width * 0.8 * _splitRatio,
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
