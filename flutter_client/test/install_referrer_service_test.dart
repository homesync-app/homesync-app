import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/services/analytics_service.dart';
import 'package:homesync_client/core/services/install_attribution_reporter.dart';
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

  group('InstallAttribution.parse', () {
    test('lee los utm de una campaña', () {
      final attribution = InstallAttribution.parse(
        'utm_source=instagram&utm_medium=bio&utm_campaign=lanzamiento_sep',
      );

      expect(attribution?.source, 'instagram');
      expect(attribution?.medium, 'bio');
      expect(attribution?.campaign, 'lanzamiento_sep');
      expect(attribution?.content, isNull);
    });

    test('conserva el referrer crudo de Meta Ads para descifrarlo después', () {
      const meta = 'utm_source=apps.facebook.com&utm_campaign=fb4a'
          '&utm_content=%7B%22app%22%3A1%2C%22source%22%3A%7B%22data%22%3A'
          '%22abc%22%2C%22nonce%22%3A%22def%22%7D%7D';
      final attribution = InstallAttribution.parse(meta);

      expect(attribution?.source, 'apps.facebook.com');
      expect(attribution?.campaign, 'fb4a');
      expect(attribution?.content, contains('"nonce"'));
      expect(attribution?.rawReferrer, meta);
    });

    test('sin referrer no hay atribución', () {
      expect(InstallAttribution.parse(null), isNull);
      expect(InstallAttribution.parse('  '), isNull);
    });
  });

  group('InstallReferrerService.pendingAttribution', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('el código y la atribución comparten una sola consulta a Play',
        () async {
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

      final results = await Future.wait([
        service.takeInviteCode(),
        service.pendingAttribution().then((a) => a?.source),
      ]);

      expect(results, ['AB12CD', 'invite']);
      expect((await service.pendingAttribution())?.content, 'AB12CD');
      expect(reads, 1);
    });

    test('una vez guardada no se vuelve a ofrecer', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = InstallReferrerService(
        prefs,
        isAndroid: true,
        readReferrer: () async => 'utm_source=google-play&utm_medium=organic',
      );

      expect((await service.pendingAttribution())?.medium, 'organic');
      await service.markAttributionReported();
      expect(await service.pendingAttribution(), isNull);
    });

    test('si Play falla se reintenta en el próximo arranque', () async {
      final prefs = await SharedPreferences.getInstance();
      var fail = true;
      final service = InstallReferrerService(
        prefs,
        isAndroid: true,
        readReferrer: () async {
          if (fail) throw Exception('timeout');
          return 'utm_source=instagram';
        },
      );

      expect(await service.pendingAttribution(), isNull);
      fail = false;
      expect((await service.pendingAttribution())?.source, 'instagram');
    });
  });

  group('InstallAttributionReporter', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    Future<InstallReferrerService> serviceWith(String? referrer) async {
      final prefs = await SharedPreferences.getInstance();
      return InstallReferrerService(
        prefs,
        isAndroid: true,
        readReferrer: () async => referrer,
      );
    }

    test('guarda la atribución una sola vez y la manda a analytics', () async {
      final service = await serviceWith(
        'utm_source=instagram&utm_medium=reel&utm_campaign=parejas',
      );
      final analytics = _FakeAnalytics();
      final saved = <Map<String, dynamic>>[];
      final reporter = InstallAttributionReporter(
        referrer: service,
        analytics: analytics,
        appVersion: '1.5.0',
        saveAttribution: (params) async => saved.add(params),
      );

      await reporter.reportIfNeeded();
      await reporter.reportIfNeeded();

      expect(saved, hasLength(1));
      expect(saved.single['p_source'], 'instagram');
      expect(saved.single['p_campaign'], 'parejas');
      expect(saved.single['p_app_version'], '1.5.0');
      expect(analytics.attributed, [('instagram', 'reel', 'parejas')]);
    });

    test('si el backend falla no la marca como guardada', () async {
      final service = await serviceWith('utm_source=instagram');
      final analytics = _FakeAnalytics();
      final reporter = InstallAttributionReporter(
        referrer: service,
        analytics: analytics,
        saveAttribution: (_) async => throw Exception('offline'),
      );

      await reporter.reportIfNeeded();

      expect(await service.pendingAttribution(), isNotNull);
      expect(analytics.attributed, isEmpty);
    });

    test('sin referrer no llama al backend', () async {
      final service = await serviceWith(null);
      var calls = 0;
      final reporter = InstallAttributionReporter(
        referrer: service,
        analytics: _FakeAnalytics(),
        saveAttribution: (_) async => calls++,
      );

      await reporter.reportIfNeeded();

      expect(calls, 0);
    });
  });
}

class _FakeAnalytics extends AnalyticsService {
  final attributed = <(String?, String?, String?)>[];

  @override
  Future<void> trackInstallAttributed({
    String? source,
    String? medium,
    String? campaign,
  }) async {
    attributed.add((source, medium, campaign));
  }
}
