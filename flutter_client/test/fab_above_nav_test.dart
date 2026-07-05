import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/theme/app_theme.dart';
import 'package:homesync_client/shared/widgets/app_floating_action_button.dart';
import 'package:homesync_client/shared/widgets/custom_bottom_nav.dart';

void main() {
  testWidgets(
      'AppFloatingActionButton clears the floating nav when the shell uses extendBody',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme(),
        home: Scaffold(
          extendBody: true,
          bottomNavigationBar: CustomBottomNav(
            currentIndex: 0,
            items: const [
              CustomBottomNavItem(
                index: 0,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Inicio',
              ),
              CustomBottomNavItem(
                index: 1,
                icon: Icons.attach_money,
                selectedIcon: Icons.attach_money,
                label: 'Finanzas',
              ),
            ],
            onTap: (_) {},
          ),
          // Inner screen exactly like home/expenses: its own Scaffold + FAB,
          // wrapped in NavClearance like the main shell does.
          body: NavClearance(
            child: Scaffold(
              floatingActionButton: AppFloatingActionButton(
                label: 'Acción',
                icon: Icons.add_rounded,
                onPressed: () {},
              ),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(FloatingActionButton), findsOneWidget);

    final fabRect = tester.getRect(find.byType(FloatingActionButton));
    final navRect = tester.getRect(find.byType(CustomBottomNav));

    // The visible button must sit fully above the nav pill, with some gap.
    expect(
      fabRect.bottom,
      lessThan(navRect.top),
      reason: 'FAB (bottom=${fabRect.bottom}) debe quedar por encima '
          'del nav (top=${navRect.top})',
    );
  });
}
