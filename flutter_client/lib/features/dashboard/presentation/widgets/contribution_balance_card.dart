import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/contribution_balance_provider.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_loader.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Equilibrio de aporte para modo convivencia (friends).
///
/// Muestra, por integrante, cuántas tareas hizo y cuánta plata puso en gastos
/// compartidos este mes. Framing deliberadamente NEUTRO: sin ranking, sin
/// posiciones, sin corona. El objetivo es transparencia entre pares, no
/// competencia. Reemplaza al `FamilyRankingSection` competitivo en convivencia.
class ContributionBalanceCard extends ConsumerWidget {
  const ContributionBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final async = ref.watch(contributionBalanceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.contributionBalanceTitle,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: theme.textPrimary,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            t.contributionBalanceSubtitle,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: theme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          async.when(
            data: (balance) => balance.isEmpty
                ? _buildEmpty(theme, t)
                : _buildContent(theme, t, balance),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: AppLoader()),
            ),
            error: (_, __) => _buildEmpty(theme, t),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppThemeColors theme, AppLocalizations t) {
    return Column(
      children: [
        Icon(
          Icons.balance_rounded,
          size: 40,
          color: AppColors.accentTeal.withValues(alpha: 0.45),
        ),
        const SizedBox(height: 12),
        Text(
          t.contributionBalanceEmptyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: theme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          t.contributionBalanceEmptyBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: theme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    AppThemeColors theme,
    AppLocalizations t,
    ContributionBalance balance,
  ) {
    // Orden estable por nombre (NO por aporte) para evitar lectura competitiva.
    final members = [...balance.members]
      ..sort((a, b) => a.displayName.toLowerCase().compareTo(
            b.displayName.toLowerCase(),
          ),);

    return Column(
      children: [
        for (final m in members) ...[
          _MemberRow(
            member: m,
            totalTasks: balance.totalTasks,
            totalPaid: balance.totalPaid,
            t: t,
          ),
          if (m != members.last) const SizedBox(height: 14),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 15,
              color: theme.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t.contributionBalanceFootnote,
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.textMuted,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.totalTasks,
    required this.totalPaid,
    required this.t,
  });

  final MemberContribution member;
  final int totalTasks;
  final double totalPaid;
  final AppLocalizations t;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final taskShare = totalTasks > 0 ? member.tasksDone / totalTasks : 0.0;
    final paidShare = totalPaid > 0 ? member.amountPaid / totalPaid : 0.0;

    return Row(
      children: [
        CustomUserAvatar(
          avatarUrl: member.avatarUrl,
          radius: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              // Dos barras de proporción lado a lado: tareas y plata. Iguales en
              // peso visual para no jerarquizar una sobre la otra.
              _ShareBar(
                label: t.contributionBalanceTasksLabel(member.tasksDone),
                fraction: taskShare,
                color: AppColors.accentBlue,
                theme: theme,
              ),
              const SizedBox(height: 6),
              _ShareBar(
                label: '\$${member.amountPaid.toStringAsFixed(0)}',
                fraction: paidShare,
                color: AppColors.accentTeal,
                theme: theme,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ShareBar extends StatelessWidget {
  const _ShareBar({
    required this.label,
    required this.fraction,
    required this.color,
    required this.theme,
  });

  final String label;
  final double fraction;
  final Color color;
  final AppThemeColors theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: theme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                color.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 64,
          child: Text(
            label,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: theme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
