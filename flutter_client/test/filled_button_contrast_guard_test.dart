// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — contraste de FilledButton
//
// En el tema claro los FilledButton son tonales: fondo durazno al 16% y texto
// `AppColors.primaryDark` (ver filledButtonTheme en app_theme.dart). Si un
// boton pisa solo `backgroundColor` con un color solido (primary, error,
// accentRed…), el texto sigue siendo primaryDark y queda naranja sobre
// naranja o sobre rojo, casi ilegible. Paso con "Crear recurrente", el
// "Eliminar" de presupuestos y el "Rechazar" de aprobaciones.
//
// Regla: todo `FilledButton.styleFrom(...)` que define `backgroundColor`
// tiene que definir tambien `foregroundColor`.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _excludedPathFragments = [
  'lib/l10n/',
  'lib/shared/widgets/portal_labs/',
  'lib/shared/widgets/vendor/',
  '.g.dart',
  '.freezed.dart',
];

final _styleFromCall = RegExp(r'FilledButton(?:\.icon)?\.styleFrom\(');

/// Devuelve el texto entre los parentesis balanceados que abren en [start].
String _argsFrom(String source, int start) {
  var depth = 1;
  var i = start;
  while (depth > 0 && i < source.length) {
    final char = source[i];
    if (char == '(') depth++;
    if (char == ')') depth--;
    i++;
  }
  return source.substring(start, i);
}

void main() {
  test('FilledButton con fondo propio define tambien el color del texto', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'run from flutter_client/');

    final findings = <String>[];
    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final path = file.path.replaceAll('\\', '/');
      if (_excludedPathFragments.any(path.contains)) continue;
      final source = file.readAsStringSync();
      for (final match in _styleFromCall.allMatches(source)) {
        final args = _argsFrom(source, match.end);
        if (args.contains('backgroundColor') &&
            !args.contains('foregroundColor')) {
          final line = '\n'.allMatches(source.substring(0, match.start)).length;
          findings.add('$path:${line + 1}');
        }
      }
    }

    expect(
      findings,
      isEmpty,
      reason: 'Estos FilledButton cambian el fondo pero no el texto, que '
          'queda en primaryDark (ilegible sobre un fondo solido). Agregar '
          'foregroundColor:\n${findings.join('\n')}',
    );
  });
}
