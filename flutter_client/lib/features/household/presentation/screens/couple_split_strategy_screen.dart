import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/identity_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/household/presentation/providers/household_usecase_providers.dart';
import 'package:homesync_client/features/household/presentation/widgets/couple_finance_config_body.dart';
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
    final household = ref.read(currentHouseholdProvider).value;
    if (household != null) {
      // The slider always represents the CURRENT user's share. The stored ratio
      // belongs to the anchor member, so flip it when the anchor is the partner.
      final currentUserId = ref.read(currentUserIdProvider);
      final anchor = household.splitRatioAnchorId;
      final myShare = (anchor == null || anchor == currentUserId)
          ? household.defaultSplitRatio
          : (1.0 - household.defaultSplitRatio);
      setState(() {
        _splitRatio = myShare;
        _financeMode = household.financeMode;
      });
    }
  }

  Future<void> _saveRatio() async {
    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      final household = ref.read(currentHouseholdProvider).value;

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
    final household = ref.watch(currentHouseholdProvider).value;
    final isShared = _financeMode == 'shared';
    final t = AppLocalizations.of(context);
    final modeKey = household?.householdType ?? 'couple';
    // Couples and families can choose between an integrated/shared economy
    // (no debt between adults) and a divided economy (percentages + balances).
    final supportsFinanceModeChoice = modeKey == 'family' || modeKey == 'couple';

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
                          child: const Text(
                            '💰',
                            style: TextStyle(fontSize: 48),
                          ),
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
                    CoupleFinanceConfigBody(
                      modeKey: modeKey,
                      financeMode: _financeMode,
                      splitRatio: _splitRatio,
                      supportsFinanceModeChoice: supportsFinanceModeChoice,
                      onFinanceModeChanged: (mode) =>
                          setState(() => _financeMode = mode),
                      onSplitRatioChanged: (ratio) =>
                          setState(() => _splitRatio = ratio),
                    ),
                    SizedBox(height: isShared ? 28 : 48),
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
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
