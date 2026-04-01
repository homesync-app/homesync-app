import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/constants/admin_testing_config.dart';
import 'package:homesync_client/core/providers/supabase_provider.dart';

class QaAdminEvent {
  const QaAdminEvent({
    required this.title,
    required this.subtitle,
    required this.occurredAt,
    required this.householdId,
  });

  final String title;
  final String subtitle;
  final DateTime occurredAt;
  final String householdId;
}

final qaAdminRecentEventsProvider =
    FutureProvider<List<QaAdminEvent>>((ref) async {
  final response = await ref
      .read(supabaseClientProvider)
      .from('system_events')
      .select('created_at, event_type, household_id, metadata')
      .eq('source', 'qa_admin')
      .order('created_at', ascending: false)
      .limit(12);

  return (response as List).map((raw) {
    final event = Map<String, dynamic>.from(raw as Map);
    final metadata = event['metadata'] is Map
        ? Map<String, dynamic>.from(event['metadata'] as Map)
        : <String, dynamic>{};
    final householdId = event['household_id'] as String? ?? '';
    final scenario = AdminTestingConfig.scenarioByHouseholdId(householdId);
    final householdLabel = scenario?.title ?? 'Escenario QA';
    final eventType = event['event_type'] as String? ?? '';

    final (title, subtitle) = switch (eventType) {
      'qa_scenario_reset' => (
          'Reset de seed',
          '$householdLabel volvió a su estado base',
        ),
      'qa_dummy_member_added' => (
          'Miembro dummy agregado',
          '${metadata['full_name'] ?? 'Miembro'} entró en $householdLabel',
        ),
      'qa_dummy_member_deleted' => (
          'Dummy eliminado',
          '${metadata['email'] ?? 'Miembro QA'} fue eliminado en $householdLabel',
        ),
      _ => (
          'Acción QA',
          '$householdLabel · $eventType',
        ),
    };

    return QaAdminEvent(
      title: title,
      subtitle: subtitle,
      occurredAt:
          DateTime.tryParse(event['created_at'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      householdId: householdId,
    );
  }).toList(growable: false);
});
