import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/currency_provider.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/utils/app_haptics.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_pool_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/pool_provider.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/pool_detail_sheet.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/app_snack_bar.dart';

/// Carrusel de fondos de gasto en Movimientos (solo convivencia): un fondo
/// agrupa los gastos de un evento ("Asado", "Viaje") sin sacarlos del
/// balance global. Sin fondos activos, la sección desaparece y el alta vive
/// en el mismo header.
class PoolSection extends ConsumerWidget {
  const PoolSection({super.key});

  static const double _cardHeight = 96;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caps = ref.watch(householdCapabilitiesProvider);
    if (caps.type != HouseholdType.friends) return const SizedBox.shrink();

    final pools = ref.watch(activePoolsProvider).value;
    if (pools == null) return const SizedBox.shrink();

    final t = AppLocalizations.of(context);
    final theme = context.theme;

    // Sin fondos todavía: CTA compacto para crear el primero.
    if (pools.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppInsets.screenHorizontal,
          AppSpacing.md,
          AppInsets.screenHorizontal,
          0,
        ),
        child: AnimatedPress(
          onTap: () => PoolCreateSheet.show(context),
          scale: 0.98,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border:
                  Border.all(color: theme.primary.withValues(alpha: 0.18)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle_outline_rounded,
                  size: 20,
                  color: theme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    t.poolsEmptyCta,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: theme.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: theme.primary.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppInsets.screenHorizontal,
            AppSpacing.lg,
            AppInsets.screenHorizontal,
            AppSpacing.xs,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                child: Icon(
                  Icons.savings_outlined,
                  size: 12,
                  color: theme.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t.poolsSectionTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: theme.textSecondary.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => PoolCreateSheet.show(context),
                style: TextButton.styleFrom(
                  foregroundColor: theme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  t.poolsNewAction,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppInsets.screenHorizontal,
            ),
            itemCount: pools.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _PoolCard(pool: pools[index]),
          ),
        ),
      ],
    );
  }
}

class _PoolCard extends ConsumerWidget {
  final ExpensePoolModel pool;

  const _PoolCard({required this.pool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;
    final currency = ref.watch(currencyProvider);
    final summary = ref.watch(poolSummaryProvider(pool.id)).value;

    return AnimatedPress(
      onTap: () => PoolDetailSheet.show(context, pool.id),
      scale: 0.97,
      child: Container(
        width: 168,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(AppRadii.xl),
          border: Border.all(color: theme.border.withValues(alpha: 0.55)),
          boxShadow: theme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(pool.emoji, style: const TextStyle(fontSize: 17)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pool.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: theme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              summary == null
                  ? '—'
                  : currency.format(summary.total.round()),
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              summary == null
                  ? ''
                  : (summary.isSettled
                      ? t.poolsCardSettled
                      : t.poolsCardExpenseCount(summary.expenses.length)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Alta de un fondo: nombre + emoji rápido.
class PoolCreateSheet extends ConsumerStatefulWidget {
  const PoolCreateSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppSheet.show<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PoolCreateSheet(),
    );
  }

  @override
  ConsumerState<PoolCreateSheet> createState() => _PoolCreateSheetState();
}

class _PoolCreateSheetState extends ConsumerState<PoolCreateSheet> {
  final _nameController = TextEditingController();
  String _emoji = '🎉';
  bool _isSaving = false;

  static const _emojiOptions = ['🎉', '🍖', '✈️', '🏖️', '🎂', '🏠', '⚽', '🛒'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await ref.read(poolMutationsProvider).create(name: name, emoji: _emoji);
      if (!mounted) return;
      AppHaptics.success();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: t.commonErrorWithDetails('$e'),
        type: AppSnackBarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.theme;

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadii.modal)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.poolsCreateTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t.poolsCreateSubtitle,
              style: TextStyle(
                color: theme.textSecondary,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              autofocus: true,
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 40,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: theme.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: t.poolsCreateNameHint,
                counterText: '',
                filled: true,
                fillColor: theme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide: BorderSide(color: theme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide:
                      BorderSide(color: theme.border.withValues(alpha: 0.5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  borderSide:
                      BorderSide(color: theme.primary.withValues(alpha: 0.7)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojiOptions.map((emoji) {
                final isSelected = _emoji == emoji;
                return GestureDetector(
                  onTap: () => setState(() => _emoji = emoji),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.primary.withValues(alpha: 0.14)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      border: Border.all(
                        color: isSelected
                            ? theme.primary
                            : theme.border.withValues(alpha: 0.5),
                        width: isSelected ? 1.6 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 20)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        t.poolsCreateCta,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
