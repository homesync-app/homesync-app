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
    test('arranca en value prop con formulario por defecto', () {
      expect(state().step, SetupStep.valueProp);
      expect(state().selectedMode, isNull);
      expect(state().createNew, isTrue);
      expect(state().financeMode, 'divided');
      expect(state().splitRatio, 0.5);
      expect(state().familyRole, 'Padre');
      expect(state().creatorMemberType, 'parent');
    });

    test('confirmar modo solo saltea equipo y va directo a tareas', () {
      controller.selectMode('solo');
      controller.confirmMode();
      expect(state().step, SetupStep.taskSelection);
    });

    test('confirmar modo couple/family/friends pasa a crear o unirse', () {
      for (final mode in ['couple', 'family', 'friends']) {
        controller.selectMode(mode);
        controller.confirmMode();
        expect(state().step, SetupStep.teamOptions, reason: 'mode=$mode');
        controller.goTo(SetupStep.mode);
      }
    });

    test('continuar desde el código de invitación va a config del hogar', () {
      controller.selectMode('couple');
      controller.goTo(SetupStep.inviteCode);
      controller.continueFromInviteCode();
      expect(state().step, SetupStep.householdConfig);
    });

    test('continuar desde el código con modo solo va directo a tareas', () {
      controller.selectMode('solo');
      controller.goTo(SetupStep.inviteCode);
      controller.continueFromInviteCode();
      expect(state().step, SetupStep.taskSelection);
    });

    test('back del sistema retrocede un paso y en el primero deja pasar el pop',
        () {
      controller.goTo(SetupStep.identity);
      expect(controller.goBack(), isTrue);
      expect(state().step, SetupStep.welcome);
      expect(controller.goBack(), isTrue);
      expect(state().step, SetupStep.valueProp);
      expect(controller.goBack(), isFalse);
      expect(state().step, SetupStep.valueProp);
    });
  });

  group('SetupWizardController progreso honesto por modo', () {
    test('sin modo elegido la barra cubre los 7 pasos post-intro', () {
      expect(state().progressTotal, 7);
      expect(state().progressIndex, -1); // intro no cuenta
      controller.goTo(SetupStep.identity);
      expect(state().progressIndex, 1);
    });

    test('modo solo reduce la ruta a 4 segmentos y termina lleno en tareas',
        () {
      controller.selectMode('solo');
      expect(state().progressTotal, 4);
      controller.confirmMode();
      expect(state().step, SetupStep.taskSelection);
      expect(state().progressIndex, 3); // último segmento, sin saltos 3/7→7/7
    });

    test('modo couple recorre la ruta completa hasta tareas', () {
      controller.selectMode('couple');
      expect(state().progressTotal, 7);
      controller.goTo(SetupStep.taskSelection);
      expect(state().progressIndex, 6);
    });

    test('paso fuera de la ruta del modo no desborda la barra', () {
      controller.selectMode('solo');
      controller.goTo(SetupStep.householdConfig);
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

    test('el diseño de modo sigue al modo elegido y cae en couple sin modo',
        () {
      expect(state().modeDesign.type, HouseholdType.couple);
      controller.selectMode('solo');
      expect(state().modeDesign.type, HouseholdType.solo);
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
