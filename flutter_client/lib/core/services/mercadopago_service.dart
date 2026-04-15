import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logger_service.dart';
import 'rpc/admin_rpc_service.dart';

class MercadoPagoService {
  MercadoPagoService({required SupabaseClient supabaseClient})
      : _supabase = supabaseClient;

  final SupabaseClient _supabase;

  static const String publicKey =
      'APP_USR-c6c4925e-2e11-4fb3-980f-ac459a542677';

  Future<String> _requireCurrentUserId() async {
    final appUserId = await AppIdentityService.instance.refresh();
    if (appUserId != null && appUserId.isNotEmpty) {
      return appUserId;
    }
    throw 'Usuario no autenticado';
  }

  Future<String?> createPaymentPreference({
    required String title,
    required double amount,
    required String externalReference,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'mercadopago-api',
        body: {
          'action': 'create_preference',
          'title': title,
          'amount': amount,
          'external_reference': externalReference,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        return data['init_point'] as String?;
      }
      return null;
    } catch (e, stack) {
      log.e('Error creating MP preference: $e');
      await AdminRpcService(clientOverride: _supabase).logApplicationError(
        message: 'Error creating MP preference: $e',
        stackTrace: stack.toString(),
        context: {
          'title': title,
          'amount': amount,
          'external_reference': externalReference,
        },
      );
      return null;
    }
  }

  Future<void> launchCheckout(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> startOAuthFlow() async {
    final userId = await _requireCurrentUserId();

    try {
      final response = await _supabase.functions.invoke(
        'mercadopago-api',
        body: {
          'action': 'get_auth_url',
          'userId': userId,
        },
      );

      if (response.status >= 400) {
        throw 'Error de servidor: ${response.status}';
      }

      final data = response.data;
      if (data is Map && data.containsKey('url')) {
        final url = data['url'] as String;
        await launchCheckout(url);
      } else {
        throw 'No se pudo obtener la URL de conexion.';
      }
    } catch (e, stack) {
      log.e('Error starting OAuth: $e');
      await AdminRpcService(clientOverride: _supabase).logApplicationError(
        message: 'Error starting OAuth: $e',
        stackTrace: stack.toString(),
        context: {'userId': userId},
      );
      throw 'Error al conectar con Mercado Pago: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getRecentMovements() async {
    final userId = await _requireCurrentUserId();

    try {
      final response = await _supabase.functions.invoke(
        'mercadopago-api',
        body: {
          'action': 'get_recent_movements',
          'userId': userId,
        },
      );

      if (response.status == 200 && response.data != null) {
        final List<dynamic> movements = response.data['movements'] ?? [];
        return movements.map((m) => m as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e, stack) {
      log.e('Error fetching MP movements: $e');
      await AdminRpcService(clientOverride: _supabase).logApplicationError(
        message: 'Error fetching MP movements: $e',
        stackTrace: stack.toString(),
        context: {'userId': userId},
      );
      return [];
    }
  }
}
