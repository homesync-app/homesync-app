import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_art.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_person.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_plans_section.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/couple_week_widgets.dart';
import 'package:homesync_client/features/couple_space/presentation/widgets/love_note_sheet.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_form_sheet.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/tasks/presentation/widgets/add_task_options_sheet.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
import 'package:homesync_client/shared/widgets/app_sheet.dart';
import 'package:homesync_client/shared/widgets/design/app_sheet_shell.dart';

Future<void> showCouplePlansSheet(
  BuildContext context, {
  required String householdId,
  required MemberModel partner,
  required String senderName,
}) async {
  final hostContext = context;
  final partnerFirst = partner.displayName.trim().split(RegExp(r'\s+')).first;
  await AppSheet.show<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (sheetContext) {
      final t = AppLocalizations.of(sheetContext);
      return AppSheetShell(
        title: t.couplePlansTitle,
        child: SingleChildScrollView(
          child: CouplePlansSection(
            householdId: householdId,
            note: CoupleNoteRow(
              partnerLabel: partnerFirst.isEmpty
                  ? t.homeCouplePartnerFallback
                  : partnerFirst,
              onTap: () {
                Navigator.of(sheetContext).pop();
                if (!hostContext.mounted) return;
                showLoveNoteSheet(
                  hostContext,
                  partner: partner,
                  householdId: householdId,
                  senderName: senderName,
                );
              },
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showCoupleActionsSheet(BuildContext context) async {
  final hostContext = context;
  await AppSheet.show<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final t = AppLocalizations.of(context);
        final members = ref.watch(householdMembersProvider).value ?? [];
        final currentUserId = ref.watch(currentUserIdProvider);
        final householdId = ref.watch(householdIdProvider).value;
        final me = members.where((m) => m.userId == currentUserId).firstOrNull;
        final partner =
            members.where((m) => m.userId != currentUserId).firstOrNull;
        final senderFirst =
            me?.displayName.trim().split(RegExp(r'\s+')).first ?? '';
        final senderName =
            senderFirst.isEmpty ? t.commonUserFallback : senderFirst;
        final actions = <(String, CoupleArtKind, VoidCallback)>[
          (
            t.coupleHomeAddExpense,
            CoupleArtKind.wallet,
            () => ExpenseFormSheet.show(hostContext),
          ),
          (
            t.tasksFabNew,
            CoupleArtKind.home,
            () => AddTaskOptionsSheet.show(hostContext, members),
          ),
          if (partner != null && householdId != null && householdId.isNotEmpty) ...[
            (
              t.coupleHomeLeaveNote,
              CoupleArtKind.letter,
              () => showLoveNoteSheet(
                    hostContext,
                    partner: partner,
                    householdId: householdId,
                    senderName: senderName,
                  ),
            ),
            (
              t.couplePlansTitle,
              CoupleArtKind.movies,
              () => showCouplePlansSheet(
                    hostContext,
                    householdId: householdId,
                    partner: partner,
                    senderName: senderName,
                  ),
            ),
          ],
        ];
        return AppSheetShell(
          title: t.homeFabActions,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: actions.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final (label, art, action) = actions[index];
              return CoupleSurface(
                padding: const EdgeInsets.all(AppSpacing.sm),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  action();
                },
                child: Row(
                  children: [
                    CoupleArt(kind: art, size: 44),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        label,
                        style: AppTypography.cardTitle
                            .copyWith(color: context.theme.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
