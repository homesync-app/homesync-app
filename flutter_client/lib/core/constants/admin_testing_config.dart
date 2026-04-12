import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';

class QaTestUser {
  final String userId;
  final String label;
  final String email;
  final String password;
  final String? displayRole;

  const QaTestUser({
    required this.userId,
    required this.label,
    required this.email,
    required this.password,
    this.displayRole,
  });
}

class AdminTestingScenario {
  final String id;
  final String householdId;
  final String defaultViewerUserId;
  final String title;
  final String description;
  final HouseholdType householdType;
  final List<QaTestUser> qaUsers;

  const AdminTestingScenario({
    required this.id,
    required this.householdId,
    required this.defaultViewerUserId,
    required this.title,
    required this.description,
    required this.householdType,
    this.qaUsers = const [],
  });
}

class AdminTestingConfig {
  static const String qaTestingPassword =
      String.fromEnvironment('QA_TESTING_PASSWORD', defaultValue: 'qapass123');

  static const String adminTestingUserId =
      '5ac9da1b-11ba-4427-a994-691577ad596f';
  static const String adminDisplayName = 'Admin QA';
  static const String adminEmail = 'admin@homesync.qa';
  static const String adminAvatar = '\u{1F6E0}\u{FE0F}';

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
      qaUsers: [
        QaTestUser(
          userId: '11110000-0000-0000-0000-000000000001',
          label: 'Entrar como Solo QA',
          email: 'qa.solo.luna@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Usuario Solo',
        ),
      ],
    ),
    AdminTestingScenario(
      id: 'couple',
      householdId: '22222222-2222-2222-2222-222222222222',
      defaultViewerUserId: '22220000-0000-0000-0000-000000000001',
      title: 'Modo Pareja',
      description: '2 usuarios. Tareas y finanzas compartidas.',
      householdType: HouseholdType.couple,
      qaUsers: [
        QaTestUser(
          userId: '22220000-0000-0000-0000-000000000001',
          label: 'Entrar como Pareja A',
          email: 'qa.couple.alex@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Pareja A',
        ),
        QaTestUser(
          userId: '22220000-0000-0000-0000-000000000002',
          label: 'Entrar como Pareja B',
          email: 'qa.couple.mora@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Pareja B',
        ),
      ],
    ),
    AdminTestingScenario(
      id: 'friends',
      householdId: '33333333-3333-3333-3333-333333333333',
      defaultViewerUserId: '33330000-0000-0000-0000-000000000001',
      title: 'Modo Amigos',
      description: '3 usuarios. Convivencia y gastos grupales.',
      householdType: HouseholdType.friends,
      qaUsers: [
        QaTestUser(
          userId: '33330000-0000-0000-0000-000000000001',
          label: 'Entrar como Roomie 1',
          email: 'qa.friends.nico@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Amigo 1',
        ),
        QaTestUser(
          userId: '33330000-0000-0000-0000-000000000002',
          label: 'Entrar como Roomie 2',
          email: 'qa.friends.cami@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Amigo 2',
        ),
        QaTestUser(
          userId: '33330000-0000-0000-0000-000000000003',
          label: 'Entrar como Roomie 3',
          email: 'qa.friends.juli@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Amigo 3',
        ),
      ],
    ),
    AdminTestingScenario(
      id: 'family',
      householdId: '44444444-4444-4444-4444-444444444444',
      defaultViewerUserId: '44440000-0000-0000-0000-000000000001',
      title: 'Modo Familia',
      description: '4 usuarios. Vista familiar completa.',
      householdType: HouseholdType.family,
      qaUsers: [
        QaTestUser(
          userId: '44440000-0000-0000-0000-000000000001',
          label: 'Entrar como Padre QA',
          email: 'qa.family.blas@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Blas',
        ),
        QaTestUser(
          userId: '44440000-0000-0000-0000-000000000002',
          label: 'Entrar como Madre QA',
          email: 'qa.family.ana@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Mamá',
        ),
        QaTestUser(
          userId: '44440000-0000-0000-0000-000000000003',
          label: 'Entrar como Hijo QA',
          email: 'qa.family.tomi@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Hijo 1',
        ),
        QaTestUser(
          userId: '44440000-0000-0000-0000-000000000004',
          label: 'Entrar como Hija QA',
          email: 'qa.family.mili@homesync.local',
          password: qaTestingPassword,
          displayRole: 'Hija 1',
        ),
      ],
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

  static AdminTestingScenario? scenarioById(String? scenarioId) {
    if (scenarioId == null || scenarioId.isEmpty) return null;
    for (final scenario in scenarios) {
      if (scenario.id == scenarioId) {
        return scenario;
      }
    }
    return null;
  }

  static QaTestUser? qaUserById(String? userId) {
    if (userId == null || userId.isEmpty) return null;
    for (final scenario in scenarios) {
      for (final user in scenario.qaUsers) {
        if (user.userId == userId) {
          return user;
        }
      }
    }
    return null;
  }
}
