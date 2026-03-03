import 'package:flutter/foundation.dart';
import 'base_rpc_service.dart';

class AdminRpcService extends BaseRpcService {
  AdminRpcService({super.clientOverride});

  Future<void> logApplicationError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) async {
    final user = client.auth.currentUser;
    try {
      final logData = {
        'user_id': user?.id,
        'level': level,
        'message': message,
        'stack_trace': stackTrace,
        'context': {
          if (context != null) ...context,
          'email': user?.email,
        },
        'device_info': {
          'platform': kIsWeb ? 'web' : 'native',
          'is_web': kIsWeb,
          'timestamp': DateTime.now().toIso8601String(),
          'operating_system': kIsWeb ? 'Browser' : defaultTargetPlatform.toString(),
        }
      };
      
      await client.from('application_logs').insert(logData);
    } catch (e) {
      // If logging fails, we just print so we don't cause an infinite error loop
      debugPrint('CRITICAL: Failed to log error to Supabase: $e');
    }
  }

  Future<Map<String, dynamic>> resetUserAccount() async {
    final response = await client.rpc('reset_user_account');
    return Map<String, dynamic>.from(response);
  }
}
