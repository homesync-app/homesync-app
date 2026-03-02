import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MercadoPagoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Mercado Pago Public Key for FE initialization
  static const String publicKey = 'APP_USR-c6c4925e-2e11-4fb3-980f-ac459a542677';

  /// Creates a payment preference by calling our Supabase Edge Function.
  /// This returns the [initPoint] URL to redirect the user to.
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
    } catch (e) {
      print('Error creating MP preference: $e');
      return null;
    }
  }

  /// Launches the Mercado Pago checkout URL.
  Future<void> launchCheckout(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Important for opening MP app or mobile browser
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Starts the OAuth flow to connect the user's Mercado Pago account.
  /// This will redirect to a URL provided by our backend.
  Future<void> startOAuthFlow() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw 'Usuario no autenticado';

    try {
      final response = await _supabase.functions.invoke(
        'mercadopago-api',
        body: {
          'action': 'get_auth_url',
          'userId': user.id,
        },
      );

      // Check if the response itself indicates an error code or status
      // Some versions of Supabase SDK return a FunctionResponse where status is the HTTP status code
      if (response.status >= 400) {
        throw 'Error de servidor: ${response.status}';
      }

      final data = response.data;
      if (data is Map && data.containsKey('url')) {
        final url = data['url'] as String;
        await launchCheckout(url);
      } else {
         throw 'No se pudo obtener la URL de conexión.';
      }
    } catch (e) {
      print('Error starting OAuth: $e');
      throw 'Error al conectar con Mercado Pago: $e';
    }
  }

  /// Fetches recent approved payments from the user's connected MP account.
  Future<List<Map<String, dynamic>>> getRecentMovements() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw 'No autenticado';

    try {
      final response = await _supabase.functions.invoke(
        'mercadopago-api',
        body: {
          'action': 'get_recent_movements',
          'userId': user.id,
        },
      );

      if (response.status == 200 && response.data != null) {
        final List<dynamic> movements = response.data['movements'] ?? [];
        return movements.map((m) => m as Map<String, dynamic>).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching MP movements: $e');
      return [];
    }
  }
}
