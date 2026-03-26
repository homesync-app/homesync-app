import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

class AdminTestingScenario {
  final String id;
  final String householdId;
  final String defaultViewerUserId;
  final String title;
  final String description;
  final HouseholdType householdType;

  const AdminTestingScenario({
    required this.id,
    required this.householdId,
    required this.defaultViewerUserId,
    required this.title,
    required this.description,
    required this.householdType,
  });
}

class AdminTestingConfig {
  static const String adminTestingUserId =
      '5ac9da1b-11ba-4427-a994-691577ad596f';
  static const String adminDisplayName = 'Admin QA';
  static const String adminEmail = 'admin@homesync.qa';
  static const String adminAvatar = '🛠️';

  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'superadmin';

  static const List<AdminTestingScenario> scenarios = [
    AdminTestingScenario(
      id: 'solo',
      householdId: '11111111-1111-1111-1111-111111111111',
      defaultViewerUserId: '11110000-0000-0000-0000-000000000001',
      title: 'Modo Solo',
      description: '1 usuario. Flujo individual y progreso personal.',
      householdType: HouseholdType.solo,
    ),
    AdminTestingScenario(
      id: 'couple',
      householdId: '22222222-2222-2222-2222-222222222222',
      defaultViewerUserId: '22220000-0000-0000-0000-000000000001',
      title: 'Modo Pareja',
      description: '2 usuarios. Tareas y finanzas compartidas.',
      householdType: HouseholdType.couple,
    ),
    AdminTestingScenario(
      id: 'friends',
      householdId: '33333333-3333-3333-3333-333333333333',
      defaultViewerUserId: '33330000-0000-0000-0000-000000000001',
      title: 'Modo Amigos',
      description: '3 usuarios. Convivencia y gastos grupales.',
      householdType: HouseholdType.friends,
    ),
    AdminTestingScenario(
      id: 'family',
      householdId: '44444444-4444-4444-4444-444444444444',
      defaultViewerUserId: '44440000-0000-0000-0000-000000000001',
      title: 'Modo Familia',
      description: '4 usuarios. Vista familiar completa.',
      householdType: HouseholdType.family,
    ),
  ];

  static AdminTestingScenario? scenarioByHouseholdId(String? householdId) {
    if (householdId == null) return null;
    for (final scenario in scenarios) {
      if (scenario.householdId == householdId) {
        return scenario;
      }
    }
    return null;
  }
}
