import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';

void main() {
  group('weekDayInitials', () {
    for (final locale in AppLocalizations.supportedLocales) {
      test('produce 7 iniciales de un carácter en $locale', () {
        final t = lookupAppLocalizations(locale);
        final initials = t.weekDayInitials.split(',');
        expect(initials, hasLength(7));
        for (final initial in initials) {
          expect(initial.trim(), hasLength(1));
        }
      });
    }

    test('lunes primero: español usa X para miércoles', () {
      final t = lookupAppLocalizations(const Locale('es'));
      expect(t.weekDayInitials.split(','), ['L', 'M', 'X', 'J', 'V', 'S', 'D']);
    });

    test('inglés usa M T W T F S S', () {
      final t = lookupAppLocalizations(const Locale('en'));
      expect(t.weekDayInitials.split(','), ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
    });
  });
}
