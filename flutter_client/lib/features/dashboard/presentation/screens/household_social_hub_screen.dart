import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/contribution_balance_card.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/debt_settlement_section.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/family_ranking_section.dart';
import 'package:homesync_client/features/dashboard/presentation/widgets/household_bills_card.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/features/rewards/presentation/screens/family_rewards_screen.dart';
import 'package:homesync_client/features/settings/presentation/widgets/settings_parent_mode_card.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class HouseholdSocialHubScreen extends ConsumerStatefulWidget {
  const HouseholdSocialHubScreen({super.key});

  @override
  ConsumerState<HouseholdSocialHubScreen> createState() =>
      _HouseholdSocialHubScreenState();
}

class _HouseholdSocialHubScreenState
    extends ConsumerState<HouseholdSocialHubScreen> {
  Future<void> _refreshData() async {
    ref.invalidate(currentHouseholdProvider);
    await ref.read(householdMembersProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(householdMembersProvider);
    final caps = ref.watch(householdCapabilitiesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);
    final theme = context.theme;

    final members = membersAsync.value ?? const <MemberModel>[];
    final currentMember =
        members.where((member) => member.userId == currentUserId).firstOrNull;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _refreshData,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              8,
              AppSpacing.lg,
              132,
            ),
            children: [
              _HeaderCard(
                caps: caps,
                currentMember: currentMember,
                onRewards: caps.usesRewardsStore
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const FamilyRewardsScreen(),
                          ),
                        );
                      }
                    : null,
              ),
              const SizedBox(height: 18),
              // Familia: ranking competitivo (corona, puntos, adultos vs chicos).
              // Convivencia: equilibrio de aporte neutro (tareas + plata del mes,
              // sin ganador). Cada modo usa su propia experiencia.
              if (caps.usesCompetitiveRanking)
                FamilyRankingSection(currentMember: currentMember)
              else if (caps.usesContributionBalance) ...[
                const ContributionBalanceCard(),
                const SizedBox(height: 18),
                _SettleUpSection(),
                const SizedBox(height: 18),
                const HouseholdBillsCard(),
              ],
              // Configuracion del Modo Padres (toggle de aprobacion de tareas,
              // bandeja de pendientes). El widget se auto-oculta si el usuario
              // no es admin adulto de una familia, asi que es seguro siempre.
              const SizedBox(height: 18),
              const SettingsParentModeCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.caps,
    required this.currentMember,
    required this.onRewards,
  });

  final HouseholdCapabilities caps;
  final MemberModel? currentMember;
  final VoidCallback? onRewards;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);

    final title = caps.socialHubTitle(t);
    final subtitle = caps.socialHubSubtitle(t);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: theme.isDarkMode
              ? [
                  const Color(0xFF312A27),
                  const Color(0xFF251F1D),
                ]
              : [
                  Colors.white,
                  const Color(0xFFFFF7F0),
                ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: theme.border.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(
            color:
                theme.shadow.withValues(alpha: theme.isDarkMode ? 0.24 : 0.07),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.16),
                      AppColors.sage.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                child: Icon(caps.partnerIcon, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  currentMember == null
                      ? t.householdSocialHubRoleFallback
                      : t.householdSocialHubYourRole(
                          // Si el usuario es admin/owner del hogar, lo agregamos
                          // como sufijo para que sepa que tiene permisos
                          // adicionales (aprobar tareas, configurar, etc.).
                          () {
                            // Convivencia (friends) trata a todos como adultos
                            // pares: nunca mostramos rol familiar (Padre/Madre).
                            final roleLabel = caps.usesFamilyRoles
                                ? currentMember!.localizedRoleLabel(t)
                                : t.householdSocialHubRoleMember;
                            return currentMember!.isAdmin
                                ? '$roleLabel · Admin'
                                : roleLabel;
                          }(),
                        ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.textSecondary,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (onRewards != null)
                _QuickActionButton(
                  icon: Icons.storefront_rounded,
                  label: t.householdSocialHubStoreButton,
                  onPressed: onRewards!,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: theme.surfaceVariant,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sección "Saldar cuentas" para convivencia. Para roomies, saber quién le debe
/// a quién es EL feature, no un extra — por eso es protagonista en el hub.
/// Reusa `DebtSettlementSection`, que ya maneja la simplificación de deudas y el
/// estado "todo saldado".
class _SettleUpSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final t = AppLocalizations.of(context);
    final balancesAsync = ref.watch(expenseBalancesProvider);

    return balancesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (balances) {
        // Con un solo integrante o sin balances no hay nada que saldar.
        if (balances.length < 2) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.householdSettleUpTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: theme.textPrimary,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.householdSettleUpSubtitle,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            DebtSettlementSection(balances: balances),
          ],
        );
      },
    );
  }
}
