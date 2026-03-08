import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_links/app_links.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/features/expenses/presentation/providers/expense_provider.dart';
import 'package:homesync_client/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:homesync_client/features/savings/presentation/providers/savings_provider.dart';
import 'package:homesync_client/core/services/logger_service.dart';

class DeepLinkService {
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  void init(WidgetRef ref, Function(String message, Color color) showToast) {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      log.i('Deep Link received: $uri');

      if (uri.scheme != 'homesync') return;

      // 1. Mercado Pago Auth callback
      if (uri.host == 'auth-complete' || uri.path.contains('auth-complete')) {
        final status = uri.queryParameters['status'];
        final message = uri.queryParameters['message'];

        if (status == 'success') {
          showToast('✅ Mercado Pago conectado con éxito', AppColors.success);
        } else if (status == 'error') {
          showToast('❌ Error al conectar: ${message ?? "Desconocido"}',
              AppColors.error);
        }
      }

      // 2. Mercado Pago Payment callbacks
      if (uri.host == 'payment-success' ||
          uri.path.contains('payment-success')) {
        showToast('🎉 ¡Acreditado! Se verá reflejado en unos segundos.',
            AppColors.success);

        // Refresh all relevant data
        ref.invalidate(savingsGoalsProvider);
        ref.invalidate(expenseBalancesProvider);
        ref.invalidate(userBalanceProvider);
        ref.invalidate(recentActivityProvider);
      }

      if (uri.host == 'payment-failure' ||
          uri.path.contains('payment-failure')) {
        showToast('❌ El pago fue rechazado. Reintentá luego.', AppColors.error);
      }

      if (uri.host == 'payment-pending' ||
          uri.path.contains('payment-pending')) {
        showToast(
            '⏳ Pago en proceso. Te avisaremos al acreditarse.', Colors.orange);
      }
    });
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}

final deepLinkServiceProvider = Provider<DeepLinkService>((ref) {
  return DeepLinkService();
});
