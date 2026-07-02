import 'package:flutter/material.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';

class PremiumPaywall {
  /// Abre el paywall y completa cuando el usuario lo cierra (haya comprado o
  /// no). Los llamadores que gatean una accion premium deben re-chequear
  /// `premiumProvider` al volver para retomar la accion pendiente.
  static Future<void> show(BuildContext context) {
    AnalyticsService().trackPaywallOpened(
      source: 'shared_paywall',
      variant: 'full_screen',
    );
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PremiumPaywallScreen(),
      ),
    );
  }
}
