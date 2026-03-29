import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/features/household/presentation/providers/household_providers.dart';

class CustomBottomNav extends ConsumerWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.theme;
    final caps = ref.watch(householdCapabilitiesProvider);
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowBase.withValues(alpha: theme.isDarkMode ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            label: 'Inicio',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavItem(
            icon: Icons.format_list_bulleted_rounded,
            selectedIcon: Icons.format_list_bulleted_rounded,
            label: 'Tareas',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 48),
          _NavItem(
            icon: Icons.account_balance_wallet_outlined,
            selectedIcon: Icons.account_balance_wallet_rounded,
            label: 'Finanzas',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavItem(
            icon: caps.socialTabIcon,
            selectedIcon: caps.socialTabSelectedIcon,
            label: caps.socialTabLabel,
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? selectedIcon : icon,
            color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: isSelected ? AppColors.primary : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
