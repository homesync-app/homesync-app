import 'package:flutter/material.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';

class PremiumPaywall {
  static void show(BuildContext context) {
    AnalyticsService().trackPaywallOpened(
      source: 'shared_paywall',
      variant: 'full_screen',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PremiumPaywallScreen(),
      ),
    );
  }
}
