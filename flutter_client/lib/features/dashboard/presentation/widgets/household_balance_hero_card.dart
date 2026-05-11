import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/theme/app_spacing.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/features/expenses/domain/models/expense_model.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';
import 'package:intl/intl.dart';

class HouseholdBalanceHeroCard extends ConsumerWidget {
  const HouseholdBalanceHeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final householdAsync = ref.watch(currentHouseholdProvider);
    final membersAsync = ref.watch(householdMembersProvider);
    final expenseBalancesAsync = ref.watch(expenseBalancesProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final householdName = householdAsync.whenOrNull(data: (h) => h?.name);
    final members =
        membersAsync.whenOrNull(data: (m) => m) ?? const <MemberModel>[];
    final sortedMembers = [...members]..sort((a, b) {
        if (a.userId == currentUserId) return -1;
        if (b.userId == currentUserId) return 1;
        return a.displayName.compareTo(b.displayName);
      });
    final visibleMembers = sortedMembers.take(2).toList();
    final balance = _resolveBalance(
      expenseBalancesAsync: expenseBalancesAsync,
      currentUserId: currentUserId,
    );

    final accent = balance < -0.01
        ? AppColors.accentOrange
        : balance > 0.01
            ? AppColors.sage
            : AppColors.primary;
    final hasCustomHouseholdName =
        householdName != null && !_isGenericName(householdName);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.white,
            Color(0xFFFFFCFA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.70),
        ),
        boxShadow: [
          ...theme.cardShadow,
          BoxShadow(
            color: AppColors.accentPeach.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _greeting(),
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _welcomeTitle(householdName: householdName),
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: hasCustomHouseholdName ? 27 : 25,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                height: 1.02,
              ),
            ),
            const SizedBox(height: 8),
            _MembersHeader(
              members: visibleMembers,
              hasCustomHouseholdName: hasCustomHouseholdName,
            ),
            const SizedBox(height: 14),
            Text(
              _sectionLine(balance: balance),
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.38,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAF7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.40),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currency(balance.abs()),
                          style: TextStyle(
                            color: theme.textPrimary,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          balance.abs() <= 0.01
                              ? Icons.favorite_rounded
                              : balance < 0
                                  ? Icons.balance_rounded
                                  : Icons.volunteer_activism_rounded,
                          color: accent,
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          balance.abs() <= 0.01
                              ? 'En calma'
                              : balance < 0
                                  ? 'Equilibrar'
                                  : 'A favor',
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _resolveBalance({
    required AsyncValue<List<HouseholdBalanceModel>> expenseBalancesAsync,
    required String? currentUserId,
  }) {
    double balance = 0;
    expenseBalancesAsync.whenData((balances) {
      final mine = balances.where((b) => b.userId == currentUserId).firstOrNull;
      if (mine != null) {
        balance = mine.balance;
      }
    });
    return balance;
  }

  String _greeting() {
    final now = DateTime.now();
    if (now.hour < 12) return 'Buen dia';
    if (now.hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  String _welcomeTitle({
    required String? householdName,
  }) {
    if (householdName != null && !_isGenericName(householdName)) {
      return 'Bienvenidos a $householdName';
    }
    return 'Bienvenidos al hogar de';
  }

  bool _isGenericName(String name) {
    final normalized = name.trim().toLowerCase();
    return normalized.isEmpty ||
        normalized == 'mi hogar' ||
        normalized == 'hogar' ||
        normalized == 'casa';
  }

  String _sectionLine({
    required double balance,
  }) {
    if (balance.abs() <= 0.01) {
      return 'Aca van a encontrar de un vistazo como viene su balance compartido.';
    }
    if (balance < 0) {
      return 'Aca van a ver lo que conviene acomodar para volver a estar en equilibrio.';
    }
    return 'Aca van a ver cuando alguno puso un poco de mas y toca compensar con carino.';
  }

  String _currency(double amount) {
    final formatted =
        NumberFormat.decimalPattern('es_AR').format(amount.round());
    return '\$ $formatted';
  }
}

class _MembersHeader extends StatelessWidget {
  final List<MemberModel> members;
  final bool hasCustomHouseholdName;

  const _MembersHeader({
    required this.members,
    required this.hasCustomHouseholdName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final label = members.isEmpty
        ? 'ustedes'
        : members.length == 1
            ? members.first.displayName
            : '${members[0].displayName} y ${members[1].displayName}';

    final prefix = hasCustomHouseholdName ? 'con' : null;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: [
        if (prefix != null)
          Text(
            prefix,
            style: TextStyle(
              color: theme.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7F3),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.50),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: members.length > 1 ? 48 : 28,
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(members.length, (index) {
                    final member = members[index];
                    return Positioned(
                      left: index * 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CustomUserAvatar(
                          name: member.displayName,
                          avatarUrl: member.avatarUrl,
                          radius: 14,
                          forceCircular: true,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
