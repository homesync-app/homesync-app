import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/services/install_referrer_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _inviteReferrer = 'utm_source=invite&utm_medium=share&utm_content=AB12CD';

void main() {
  group('InstallReferrerService.parseInviteCode', () {
    test('lee el código de un referrer de invitación', () {
      expect(
        InstallReferrerService.parseInviteCode(
          'utm_source=invite&utm_medium=share&utm_content=ab12cd',
        ),
        'AB12CD',
      );
    });

    test('acepta un referrer que todavía viene codificado', () {
      expect(
        InstallReferrerService.parseInviteCode(
          'utm_source%3Dinvite%26utm_medium%3Dshare%26utm_content%3DAB12CD',
        ),
        'AB12CD',
      );
    });

    test('ignora instalaciones orgánicas y códigos mal formados', () {
      expect(
        InstallReferrerService.parseInviteCode(
          'utm_source=google-play&utm_medium=organic',
        ),
        isNull,
      );
      expect(
        InstallReferrerService.parseInviteCode(
          'utm_source=invite&utm_content=ABC',
        ),
        isNull,
      );
      expect(
        InstallReferrerService.parseInviteCode(
          'utm_source=invite&utm_content=AB-12C',
        ),
        isNull,
      );
      expect(InstallReferrerService.parseInviteCode(''), isNull);
      expect(InstallReferrerService.parseInviteCode(null), isNull);
    });
  });

  group('InstallReferrerService.takeInviteCode', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('devuelve el código una sola vez por instalación', () async {
      final prefs = await SharedPreferences.getInstance();
      var reads = 0;
      final service = InstallReferrerService(
        prefs,
        isAndroid: true,
        readReferrer: () async {
          reads++;
          return _inviteReferrer;
        },
      );

      expect(await service.takeInviteCode(), 'AB12CD');
      expect(await service.takeInviteCode(), isNull);
      expect(reads, 1);
    });

    test('un error de Play no es fatal', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = InstallReferrerService(
        prefs,
        isAndroid: true,
        readReferrer: () async => throw Exception('no play services'),
      );

      expect(await service.takeInviteCode(), isNull);
    });

    test('fuera de Android no consulta nada', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = InstallReferrerService(
        prefs,
        isAndroid: false,
        readReferrer: () async => fail('no debería leer el referrer'),
      );

      expect(await service.takeInviteCode(), isNull);
      expect(prefs.getBool(InstallReferrerService.checkedPrefsKey), isNull);
    });
  });
}
