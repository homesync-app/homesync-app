// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — hardcoded Spanish copy guard
//
// The app ships in es + en via ARB files; any user-facing Spanish literal in
// lib/ leaks Spanish into the English UI. This guard scans Dart string
// literals (not comments) for Spanish-marker characters (á é í ó ú ñ ¿ ¡)
// and for a conservative list of high-confidence Spanish UI words, then fails
// when NEW ones appear outside l10n/.
//
// It's a heuristic: not every unaccented Spanish phrase can be identified
// without false positives. The extra patterns intentionally target common UI
// leaks seen in this app: "Reintentar", a standalone "Mes", interpolated
// pending/overdue counters, "a aprobar" and minimum-selection guidance.
// Accented literals and pre-existing/legitimate data (normalization maps,
// legacy avatar aliases, timeago config) live in the baseline file.
//
// To accept a new legit literal, add its `path|literal` line to the baseline.
// To fix a real leak, move the copy to app_es.arb/app_en.arb.
//
// Run with: flutter test test/hardcoded_spanish_guard_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _accentedSpanishMarker = RegExp('[áéíóúñÁÉÍÓÚÑ¿¡]');
final _unaccentedSpanishMarker = RegExp(
  r'''\breintentar\b|^(?:'Mes'|"Mes")$|'''
  r'''(?:\d+|\})\s+(?:pendientes?|atrasad(?:a|as|o|os))\b|'''
  r'''\ba aprobar\b|\bnecesitas al menos\b''',
  caseSensitive: false,
);
final _stringLiteral = RegExp(
  r"'(?:[^'\\\n]|\\.)*'" '|"(?:[^"\\\\\n]|\\\\.)*"',
);

const _excludedPathFragments = [
  'lib/l10n/',
  'lib/shared/widgets/portal_labs/',
  '.g.dart',
  '.freezed.dart',
  '.mocks.dart',
];

/// Strips `//` line comments unless the `//` sits inside a string literal
/// (approximated by counting unescaped quotes before it).
String _stripLineComment(String line) {
  final index = line.indexOf('//');
  if (index < 0) return line;
  final before = line.substring(0, index);
  final singleQuotes = RegExp(r"(?<!\\)'").allMatches(before).length;
  final doubleQuotes = RegExp(r'(?<!\\)"').allMatches(before).length;
  if (singleQuotes.isOdd || doubleQuotes.isOdd) return line;
  return before;
}

void main() {
  test('no NEW hardcoded Spanish string literals outside l10n', () {
    final libDir = Directory('lib');
    expect(libDir.existsSync(), isTrue, reason: 'run from flutter_client/');

    final baselineFile = File('test/hardcoded_spanish_baseline.txt');
    final baseline = baselineFile.existsSync()
        ? baselineFile
            .readAsLinesSync()
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty && !l.startsWith('#'))
            .toSet()
        : <String>{};

    final findings = <String>[];
    final files = libDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));

    for (final file in files) {
      final normalized = file.path.replaceAll('\\', '/');
      if (_excludedPathFragments.any(normalized.contains)) continue;

      var inBlockComment = false;
      for (final rawLine in file.readAsLinesSync()) {
        var line = rawLine;
        if (inBlockComment) {
          final end = line.indexOf('*/');
          if (end < 0) continue;
          line = line.substring(end + 2);
          inBlockComment = false;
        }
        final blockStart = line.indexOf('/*');
        if (blockStart >= 0) {
          final end = line.indexOf('*/', blockStart + 2);
          if (end < 0) {
            line = line.substring(0, blockStart);
            inBlockComment = true;
          } else {
            line = line.substring(0, blockStart) + line.substring(end + 2);
          }
        }
        line = _stripLineComment(line);

        for (final match in _stringLiteral.allMatches(line)) {
          final literal = match.group(0)!;
          final hasSpanishMarker = _accentedSpanishMarker.hasMatch(literal) ||
              _unaccentedSpanishMarker.hasMatch(literal);
          if (!hasSpanishMarker) continue;
          findings.add('$normalized|$literal');
        }
      }
    }

    final newFindings = findings.where((f) => !baseline.contains(f)).toList()
      ..sort();
    expect(
      newFindings,
      isEmpty,
      reason: 'Nuevas literales en español fuera de l10n/. '
          'Movelas a app_es.arb/app_en.arb (y traducilas en en), o si son '
          'datos legítimos agregá la línea exacta a '
          'test/hardcoded_spanish_baseline.txt:\n${newFindings.join('\n')}',
    );
  });
}
