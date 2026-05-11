import 'package:flutter/foundation.dart';
import 'package:homesync_client/core/services/app_identity_service.dart';
import 'package:homesync_client/core/services/breadcrumb_service.dart';
import 'package:homesync_client/core/services/logger_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'base_rpc_service.dart';

class AdminRpcService extends BaseRpcService {
  AdminRpcService({required super.clientOverride});

  Future<void> logApplicationError({
    required String message,
    String? stackTrace,
    String level = 'error',
    Map<String, dynamic>? context,
  }) async {
    try {
      final userId = await AppIdentityService.instance.refresh();
      if (userId == null || userId.isEmpty) {
        log.d('Skipping Supabase error log: app user is not resolved yet');
        return;
      }

      final breadcrumbContext = breadcrumb.buildErrorContext();
      final logData = {
        'user_id': userId,
        'level': level,
        'message': message,
        'stack_trace': stackTrace,
        'context': {
          ...breadcrumbContext,
          if (context != null) ...context,
          'email': currentAuthEmail(),
        },
        'device_info': {
          'platform': kIsWeb ? 'web' : 'native',
          'is_web': kIsWeb,
          'timestamp': DateTime.now().toIso8601String(),
          'operating_system':
              kIsWeb ? 'Browser' : defaultTargetPlatform.toString(),
        },
      };

      await client.from('application_logs').insert(logData);
    } on PostgrestException catch (e, stack) {
      if (e.code == '42501') {
        log.w(
          'Skipping Supabase error log: application_logs RLS denied insert',
          error: e,
        );
        return;
      }
      log.e('Failed to log error to Supabase', error: e, stackTrace: stack);
    } catch (e, stack) {
      log.e('Failed to log error to Supabase', error: e, stackTrace: stack);
    }
  }

  Future<Map<String, dynamic>> resetUserAccount() async {
    final response = await client.rpc('reset_user_account');
    return Map<String, dynamic>.from(response);
  }
}
