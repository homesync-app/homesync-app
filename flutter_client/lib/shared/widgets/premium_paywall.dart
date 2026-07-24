import 'package:flutter/material.dart';
import 'package:homesync_client/features/premium/presentation/screens/premium_paywall_screen.dart';

class PremiumPaywall {
  /// Abre el paywall y completa cuando el usuario lo cierra (haya comprado o
  /// no). Los llamadores que gatean una accion premium deben re-chequear
  /// `premiumProvider` al volver para retomar la accion pendiente.
  ///
  /// [source] identifica QUE gate abrio el paywall. Es obligatorio a proposito:
  /// sin el, los ~15 puntos de entrada colapsan en un solo valor y no se puede
  /// saber cual gate vale la pena empujar. `PremiumPaywallScreen` es el unico
  /// que emite `paywall_opened`/`paywall_dismissed`, asi que el par de eventos
  /// siempre cierra aunque se cierre con el back del sistema.
  static Future<void> show(
    BuildContext context, {
    required String source,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PremiumPaywallScreen(source: source),
      ),
    );
  }
}
