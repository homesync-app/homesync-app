import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

class FAQSheet extends StatelessWidget {
  const FAQSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FAQSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  t.faqSheetTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              t.faqSheetSubtitle,
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildFAQItem(
                  context,
                  icon: Icons.favorite_rounded,
                  color: AppColors.accentRed,
                  question: t.faqHowSharedHome,
                  answer: t.faqHowSharedHomeAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.monetization_on_rounded,
                  color: AppColors.accentGold,
                  question: t.faqWhatCoins,
                  answer: t.faqWhatCoinsAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentTeal,
                  question: t.faqWhatWeeklyDuels,
                  answer: t.faqWhatWeeklyDuelsAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.bolt_rounded,
                  color: AppColors.accentBlue,
                  question: t.faqHowEarnXp,
                  answer: t.faqHowEarnXpAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accentGreen,
                  question: t.faqHowFinancesWork,
                  answer: t.faqHowFinancesWorkAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.event_repeat_rounded,
                  color: AppColors.primary,
                  question: t.faqHowRecurringCount,
                  answer: t.faqHowRecurringCountAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.auto_awesome_rounded,
                  color: const Color(0xFF8B5CF6),
                  question: t.faqWhatSpecialEvents,
                  answer: t.faqWhatSpecialEventsAnswer,
                ),
                _buildFAQItem(
                  context,
                  icon: Icons.trending_up_rounded,
                  color: AppColors.primary,
                  question: t.faqLevelsAndAchievements,
                  answer: t.faqLevelsAndAchievementsAnswer,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            answer,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
