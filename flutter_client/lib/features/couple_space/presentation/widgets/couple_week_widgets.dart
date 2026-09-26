import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/theme/category_mapping.dart';
import 'package:homesync_client/features/couple_space/domain/couple_proposal_ordering.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_proposal_sheets.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/animated_amount.dart';
import 'package:homesync_client/shared/widgets/design/app_button.dart';
import 'package:homesync_client/shared/widgets/design/app_card.dart';
import 'package:homesync_client/shared/widgets/design/app_pill.dart';
import 'package:homesync_client/shared/widgets/shimmer_loading.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Una persona del reparto, ya resuelta para mostrar.
class CoupleSplitPerson {
  final String userId;
  final String label;
  final String? avatarName;
  final String? avatarUrl;
  final int tasksDone;
  final int demandingDone;

  const CoupleSplitPerson({
    required this.userId,
    required this.label,
    required this.avatarName,
    required this.avatarUrl,
    required this.tasksDone,
    required this.demandingDone,
  });
}

/// El bloque principal de la pestaña: cómo se repartió la semana entre los
/// dos, una sola lectura accionable y el ritmo del hogar.
///
/// Nunca hay ganador: las dos personas se muestran con el mismo peso visual y
/// la barra es una proporción, no un marcador.
class CoupleSplitCard extends StatelessWidget {
  final HouseholdContribution contribution;
  final CoupleSplitPerson me;
  final CoupleSplitPerson partner;
  final CoupleWeekReading reading;

  /// Nombre de la categoría ya localizado (solo para lecturas por categoría).
  final String? categoryLabel;

  /// Null mientras el resumen de la semana no llegó: mejor no mostrar nada
  /// que un "no queda nada" falso.
  final int? tasksRemaining;
  final int overdue;
  final bool actionBusy;
  final VoidCallback onPropose;
  final VoidCallback onSeeTasks;

  const CoupleSplitCard({
    super.key,
    required this.contribution,
    required this.me,
    required this.partner,
    required this.reading,
    required this.categoryLabel,
    required this.tasksRemaining,
    required this.overdue,
    required this.actionBusy,
    required this.onPropose,
    required this.onSeeTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final total = me.tasksDone + partner.tasksDone;
    final showDemanding = me.demandingDone > 0 || partner.demandingDone > 0;

    return AppCard(
      variant: AppCardVariant.hero,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.contributionTitle,
            style: AppTypography.cardTitle.copyWith(color: theme.textPrimary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _PersonSide(
                  person: me,
                  alignEnd: false,
                  showDemanding: showDemanding,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PersonSide(
                  person: partner,
                  alignEnd: true,
                  showDemanding: showDemanding,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SplitBar(
            mine: me.tasksDone,
            theirs: partner.tasksDone,
            semanticsLabel: total == 0
                ? t.contributionEmpty
                : t.coupleWeekSplitSemantics(
                    me.tasksDone,
                    partner.label,
                    partner.tasksDone,
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReadingBox(
            reading: reading,
            totalTasks: total,
            partnerLabel: partner.label,
            categoryLabel: categoryLabel,
            actionBusy: actionBusy,
            onPropose: onPropose,
            onSeeTasks: onSeeTasks,
          ),
          const SizedBox(height: AppSpacing.md),
          Divider(
            height: 1,
            thickness: 1,
            color: theme.border.withValues(alpha: 0.7),
          ),
          const SizedBox(height: AppSpacing.sm),
          _RhythmRow(
            weeks: contribution.rhythmWeeks,
            window: contribution.rhythmWindow,
          ),
          if (tasksRemaining != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Text(
              overdue > 0
                  ? '${t.coupleWeekRemaining(tasksRemaining!)} · '
                      '${t.coupleWeekOverdue(overdue)}'
                  : t.coupleWeekRemaining(tasksRemaining!),
              style: AppTypography.caption.copyWith(color: theme.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonSide extends StatelessWidget {
  final CoupleSplitPerson person;
  final bool alignEnd;
  final bool showDemanding;

  const _PersonSide({
    required this.person,
    required this.alignEnd,
    required this.showDemanding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final avatar = CustomUserAvatar(
      name: person.avatarName,
      userId: person.userId,
      avatarUrl: person.avatarUrl,
      radius: 18,
      forceCircular: true,
    );

    final texts = Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          person.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.caption.copyWith(color: theme.textSecondary),
        ),
        Text(
          t.contributionTasksLabel(person.tasksDone),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.cardTitle.copyWith(
            color: theme.textPrimary,
            fontFeatures: kTabularFigures,
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: alignEnd
              ? [
                  Flexible(child: texts),
                  const SizedBox(width: AppSpacing.xs),
                  avatar,
                ]
              : [
                  avatar,
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(child: texts),
                ],
        ),
        if (showDemanding) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(
            t.contributionDemandingLabel(person.demandingDone),
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            style: AppTypography.caption.copyWith(color: theme.textSecondary),
          ),
        ],
      ],
    );
  }
}

/// Una proporción, no un marcador: dos tramos con el mismo tratamiento y una
/// separación fina. Con cero tareas queda neutra, nunca en alarma.
class _SplitBar extends StatelessWidget {
  final int mine;
  final int theirs;
  final String semanticsLabel;

  const _SplitBar({
    required this.mine,
    required this.theirs,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final total = mine + theirs;

    return Semantics(
      label: semanticsLabel,
      child: ExcludeSemantics(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          // Ancho y alto explícitos: los ColoredBox sin hijo toman el tamaño
          // mínimo de sus constraints, y dentro de una Column alineada al
          // inicio eso era 0 (la barra no se veía).
          child: SizedBox(
            height: 10,
            width: double.infinity,
            child: total == 0
                ? ColoredBox(color: theme.surfaceContainer)
                : TweenAnimationBuilder<double>(
                    tween: Tween(end: mine / total),
                    duration: AppMotion.slow,
                    curve: AppMotion.standard,
                    builder: (context, share, _) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          const gap = 3.0;
                          final width = constraints.maxWidth;
                          final showGap = mine > 0 && theirs > 0;
                          final usable = showGap ? width - gap : width;
                          final mineWidth = usable * share;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: mineWidth,
                                child: ColoredBox(color: theme.primary),
                              ),
                              if (showGap) const SizedBox(width: gap),
                              const Expanded(
                                child: ColoredBox(color: AppColors.sage),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _ReadingBox extends StatelessWidget {
  final CoupleWeekReading reading;
  final int totalTasks;
  final String partnerLabel;
  final String? categoryLabel;
  final bool actionBusy;
  final VoidCallback onPropose;
  final VoidCallback onSeeTasks;

  const _ReadingBox({
    required this.reading,
    required this.totalTasks,
    required this.partnerLabel,
    required this.categoryLabel,
    required this.actionBusy,
    required this.onPropose,
    required this.onSeeTasks,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final category = categoryLabel ?? '';
    final contributionTotal = totalTasks;

    final (String text, IconData icon, Color tint) = switch (reading.kind) {
      CoupleWeekReadingKind.empty => (
          t.contributionEmpty,
          Icons.wb_twilight_rounded,
          AppColors.sage,
        ),
      CoupleWeekReadingKind.early => (
          t.coupleWeekReadingEarly(contributionTotal),
          Icons.hourglass_top_rounded,
          AppColors.sage,
        ),
      CoupleWeekReadingKind.balanced => (
          t.coupleWeekReadingBalanced,
          Icons.check_circle_rounded,
          AppColors.sage,
        ),
      CoupleWeekReadingKind.categorySkew => (
          reading.leaderIsMe
              ? t.coupleWeekReadingCategoryMe(category)
              : t.coupleWeekReadingCategoryPartner(category, partnerLabel),
          CategoryMapping.getCategoryMaterialIcon(reading.category),
          theme.primary,
        ),
      CoupleWeekReadingKind.overallSkew => (
          reading.leaderIsMe
              ? t.coupleWeekReadingOverallMe
              : t.coupleWeekReadingOverallPartner(partnerLabel),
          Icons.balance_rounded,
          theme.primary,
        ),
    };

    final readableTint = Color.alphaBlend(
      Colors.black.withValues(alpha: theme.isDarkMode ? 0 : 0.18),
      tint,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: theme.isDarkMode ? 0.16 : 0.09),
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 20, color: readableTint),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  text,
                  style: AppTypography.body.copyWith(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (reading.isSkewed) ...[
            const SizedBox(height: AppSpacing.sm),
            // AppButton siempre ocupa el ancho disponible, así que las dos
            // acciones van apiladas: la propuesta primero y "Ver tareas"
            // centrado debajo, como acción secundaria.
            AppButton(
              label: reading.leaderIsMe
                  ? t.coupleWeekProposeTurns
                  : t.coupleWeekOfferHand,
              icon: reading.leaderIsMe
                  ? Icons.sync_alt_rounded
                  : Icons.volunteer_activism_rounded,
              size: AppButtonSize.small,
              variant: AppButtonVariant.secondary,
              isLoading: actionBusy,
              onTap: onPropose,
            ),
            Center(
              child: TextButton(
                onPressed: onSeeTasks,
                child: Text(t.coupleWeekSeeTasks),
              ),
            ),
          ] else if (reading.kind == CoupleWeekReadingKind.empty) ...[
            const SizedBox(height: AppSpacing.xs),
            TextButton(
              onPressed: onSeeTasks,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              ),
              child: Text(t.coupleWeekSeeTasks),
            ),
          ],
        ],
      ),
    );
  }
}

/// Semanas activas dentro de la ventana. Nunca una racha: una semana floja se
/// ve en neutro y se recupera sola.
class _RhythmRow extends StatelessWidget {
  final int weeks;
  final int window;

  const _RhythmRow({required this.weeks, required this.window});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final safeWindow = window <= 0 ? 4 : window;

    return Semantics(
      label: '${t.contributionRhythmLabel}: '
          '${t.contributionRhythmValue(weeks, safeWindow)}',
      child: ExcludeSemantics(
        child: Row(
          children: [
            for (var week = 0; week < safeWindow; week++) ...[
              if (week > 0) const SizedBox(width: 4),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: week < weeks ? AppColors.iconSage : theme.border,
                ),
              ),
            ],
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                '${t.contributionRhythmLabel} · '
                '${t.contributionRhythmValue(weeks, safeWindow)}',
                style: AppTypography.caption.copyWith(
                  color: theme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Esqueleto del bloque principal mientras llega el reparto.
class CoupleSplitCardSkeleton extends StatelessWidget {
  const CoupleSplitCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      variant: AppCardVariant.hero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerLoading(width: 140, height: 16, borderRadius: AppRadii.xs),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              ShimmerLoading(width: 36, height: 36, borderRadius: 18),
              SizedBox(width: AppSpacing.xs),
              ShimmerLoading(width: 80, height: 28, borderRadius: AppRadii.xs),
              Spacer(),
              ShimmerLoading(width: 80, height: 28, borderRadius: AppRadii.xs),
              SizedBox(width: AppSpacing.xs),
              ShimmerLoading(width: 36, height: 36, borderRadius: 18),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          ShimmerLoading(height: 10, borderRadius: AppRadii.pill),
          SizedBox(height: AppSpacing.md),
          ShimmerLoading(height: 56, borderRadius: AppRadii.md),
        ],
      ),
    );
  }
}

/// Una propuesta en la bandeja "Entre ustedes".
class CoupleAskTile extends StatelessWidget {
  final CoupleProposal proposal;
  final CoupleProposalStage stage;
  final bool isMine;
  final String partnerLabel;
  final String whenLabel;
  final VoidCallback? onTap;

  const CoupleAskTile({
    super.key,
    required this.proposal,
    required this.stage,
    required this.isMine,
    required this.partnerLabel,
    required this.whenLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final (String statusLabel, Color statusColor, bool emphasized) =
        switch (stage) {
      CoupleProposalStage.toAnswer => (
          t.coupleWeekAskToAnswer,
          theme.primary,
          true,
        ),
      CoupleProposalStage.waiting => (
          t.coupleWeekAskWaiting(partnerLabel),
          theme.textSecondary,
          false,
        ),
      CoupleProposalStage.later => (
          t.coupleSpaceProposalDeferred,
          AppColors.iconSage,
          false,
        ),
      CoupleProposalStage.agreed => (
          t.coupleSpaceProposalAccepted,
          AppColors.iconSage,
          true,
        ),
    };

    final meta = isMine
        ? t.coupleWeekAskFromYou(whenLabel)
        : t.coupleWeekAskFrom(partnerLabel, whenLabel);

    // El estado va debajo del título y no a la derecha: al costado le robaba
    // la mitad del ancho y las propuestas se cortaban a las pocas palabras.
    return AppCard(
      padding: AppInsets.compactCard,
      accentColor: stage == CoupleProposalStage.toAnswer ? theme.primary : null,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              coupleProposalCategoryIcon(proposal.category),
              size: AppControlSizes.iconMd,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.cardTitle.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xxs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    AppPill(
                      label: statusLabel,
                      color: statusColor,
                      selected: emphasized,
                      dense: true,
                    ),
                    Text(
                      meta,
                      style: AppTypography.caption.copyWith(
                        color: theme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vacío de la bandeja: invita sin empujar. El botón para proponer ya
/// está en la acción principal de la pantalla.
class CoupleAsksEmpty extends StatelessWidget {
  final String actionLabel;

  const CoupleAsksEmpty({super.key, required this.actionLabel});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: AppInsets.compactCard,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.forum_outlined,
            color: AppColors.iconSage,
            size: AppControlSizes.iconLg,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.coupleWeekAsksEmpty,
                  style: AppTypography.bodyStrong.copyWith(
                    color: theme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t.coupleWeekAsksEmptyHint(actionLabel),
                  style: AppTypography.caption.copyWith(
                    color: theme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fila para escribirle una nota a la pareja.
class CoupleNoteRow extends StatelessWidget {
  final String partnerLabel;
  final VoidCallback onTap;

  const CoupleNoteRow({
    super.key,
    required this.partnerLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    return AppCard(
      padding: AppInsets.compactCard,
      onTap: onTap,
      child: Semantics(
        button: true,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.accentPeach.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline_rounded,
                color: AppColors.primaryDark,
                size: AppControlSizes.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.coupleWeekNoteTitle(partnerLabel),
                    style: AppTypography.cardTitle.copyWith(
                      color: theme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.coupleWeekNoteBody,
                    style: AppTypography.caption.copyWith(
                      color: theme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: theme.textSecondary),
          ],
        ),
      ),
    );
  }
}
