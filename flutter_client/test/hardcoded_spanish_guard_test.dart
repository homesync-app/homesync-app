// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — hardcoded Spanish copy guard
//
// The app ships in es + en via ARB files; any user-facing Spanish literal in
// lib/ leaks Spanish into the English UI. This guard scans Dart string
// literals (not comments) for Spanish-marker characters (á é í ó ú ñ ¿ ¡) and
// fails when NEW ones appear outside l10n/.
//
// It's a heuristic: unaccented Spanish ("Hogar no encontrado") slips through,
// and some accented literals are legitimate data (accent-normalization maps,
// legacy avatar aliases, timeago config). Pre-existing/legit entries live in
// test/hardcoded_spanish_baseline.txt — same pattern as l10n_parity_test.
//
// To accept a new legit literal, add its `path|literal` line to the baseline.
// To fix a real leak, move the copy to app_es.arb/app_en.arb.
//
// Run with: flutter test test/hardcoded_spanish_guard_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _spanishMarker = RegExp('[áéíóúñÁÉÍÓÚÑ¿¡]');
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
          if (!_spanishMarker.hasMatch(literal)) continue;
          findings.add('$normalized|$literal');
        }
      }
    }

    final newFindings =
        findings.where((f) => !baseline.contains(f)).toList()..sort();
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
