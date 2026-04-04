import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/services/qa_session_service.dart';

final qaSessionServiceProvider = Provider<QaSessionService>((ref) {
  return QaSessionService(ref);
});
