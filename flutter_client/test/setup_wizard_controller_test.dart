import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/household/domain/models/household_capabilities.dart';
import 'package:homesync_client/features/household/presentation/providers/setup_wizard_controller.dart';

void main() {
  late ProviderContainer container;
  late SetupWizardController controller;

  SetupWizardState state() => container.read(setupWizardControllerProvider);

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
    controller = container.read(setupWizardControllerProvider.notifier);
  });

  group('SetupWizardController navegación', () {
    test('arranca en start, en modo pareja y creando un hogar', () {
      expect(state().step, SetupStep.start);
      expect(state().selectedMode, 'couple');
      expect(state().createNew, isTrue);
      expect(state().familyRole, 'Padre');
      expect(state().creatorMemberType, 'parent');
    });

    test('empezar un hogar va al paso del hogar y cierra el panel de código',
        () {
      controller.setCreateNew(false);
      controller.setJoinError('código inválido');
      controller.startCreate();
      expect(state().step, SetupStep.household);
      expect(state().createNew, isTrue);
      expect(state().joinError, isNull);
    });

    test('con el hogar creado sigue la elección de tareas', () {
      controller.startCreate();
      controller.householdReady();
      expect(state().step, SetupStep.tasks);
    });

    test('pareja, familia y amigos pasan a invitar después de las tareas', () {
      for (final mode in ['couple', 'family', 'friends']) {
        controller.selectMode(mode);
        controller.goTo(SetupStep.tasks);
        expect(controller.tasksSaved(), isTrue, reason: 'mode=$mode');
        expect(state().step, SetupStep.invite, reason: 'mode=$mode');
      }
    });

    test('solo termina el setup al guardar las tareas, sin invitar', () {
      controller.selectMode('solo');
      controller.goTo(SetupStep.tasks);
      expect(controller.tasksSaved(), isFalse);
      expect(state().step, SetupStep.tasks);
    });

    test('back del sistema retrocede y en start deja pasar el pop', () {
      controller.goTo(SetupStep.tasks);
      expect(controller.goBack(), isTrue);
      expect(state().step, SetupStep.household);
      expect(controller.goBack(), isTrue);
      expect(state().step, SetupStep.start);
      expect(controller.goBack(), isFalse);
      expect(state().step, SetupStep.start);
    });

    test('back en invitar no vuelve a tareas (evita clonarlas dos veces)', () {
      controller.goTo(SetupStep.invite);
      expect(controller.goBack(), isTrue);
      expect(state().step, SetupStep.invite);
    });
  });

  group('SetupWizardController progreso honesto por modo', () {
    test('pareja: 3 segmentos y la bienvenida no cuenta', () {
      expect(state().progressTotal, 3);
      expect(state().progressIndex, -1);
      controller.goTo(SetupStep.household);
      expect(state().progressIndex, 0);
      controller.goTo(SetupStep.tasks);
      expect(state().progressIndex, 1);
      controller.goTo(SetupStep.invite);
      expect(state().progressIndex, 2);
    });

    test('solo: 2 segmentos y las tareas llenan la barra', () {
      controller.selectMode('solo');
      expect(state().progressTotal, 2);
      controller.goTo(SetupStep.tasks);
      expect(state().progressIndex, 1);
    });

    test('un paso fuera de la ruta del modo no desborda la barra', () {
      controller.selectMode('solo');
      controller.goTo(SetupStep.invite);
      expect(state().progressIndex, lessThan(state().progressTotal));
    });
  });

  group('SetupWizardController formulario', () {
    test('cambiar a unirse con código limpia el error de join previo', () {
      controller.setJoinError('código inválido');
      controller.setCreateNew(false);
      expect(state().joinError, isNull);
      expect(state().createNew, isFalse);
    });

    test('elegir un emoji de avatar descarta la URL de Google', () {
      controller.setAvatarUrl('https://example.com/photo.jpg');
      expect(state().resolvedAvatarValue, 'https://example.com/photo.jpg');
      controller.setAvatarEmoji('🦊');
      expect(state().selectedAvatarUrl, isNull);
      expect(state().resolvedAvatarValue, '🦊');
    });

    test('rol Adolescente deriva member type teen; el resto parent', () {
      controller.setFamilyRole('Adolescente');
      expect(state().creatorMemberType, 'teen');
      controller.setFamilyRole('Madre');
      expect(state().creatorMemberType, 'parent');
    });

    test('el diseño de modo sigue al modo elegido (pareja por defecto)', () {
      expect(state().modeDesign.type, HouseholdType.couple);
      controller.selectMode('solo');
      expect(state().modeDesign.type, HouseholdType.solo);
      expect(state().isSolo, isTrue);
      controller.selectMode('friends');
      expect(state().modeDesign.type, HouseholdType.friends);
    });

    test('toggle de template agrega y quita sin duplicar', () {
      controller.seedSelectedTemplates(['a', 'b']);
      controller.toggleTemplate('c');
      expect(state().selectedTemplateIds, {'a', 'b', 'c'});
      controller.toggleTemplate('b');
      expect(state().selectedTemplateIds, {'a', 'c'});
      controller.seedSelectedTemplates(['a']);
      expect(state().selectedTemplateIds, {'a', 'c'});
    });
  });
}
