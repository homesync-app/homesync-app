import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No mojibake or BOM in Dart source files', () {
    final forbiddenMarkers = <String>[
      '\u00C3',
      '\u00C2',
      '\u00F0\u0178',
      '\u00E2\u20AC\u2014',
      '\u00E2\u20AC\u2013',
      '\u00E2\u20AC\u0153',
      '\u00E2\u20AC\u009D',
      '\u00E2\u20AC\u2122',
      '\u00E2\u20AC\u00A2',
      '\u00E2\u0153',
      '\u00E2\u201D',
    ];

    final failures = <String>[];
    final baselinePath = File('test/text_encoding_guard_baseline.txt');
    final baseline = baselinePath.existsSync()
        ? baselinePath
            .readAsLinesSync()
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty && !line.startsWith('#'))
            .toSet()
        : <String>{};
    final baselinePaths = baseline
        .map((line) => line.split(':').first.trim().replaceAll('\\', '/'))
        .toSet();

    final roots = <String>['lib', 'test'];

    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;

      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('text_encoding_guard_test.dart')) continue;

        final bytes = entity.readAsBytesSync();
        final text = String.fromCharCodes(bytes);

        final hasBom = bytes.length >= 3 &&
            bytes[0] == 0xEF &&
            bytes[1] == 0xBB &&
            bytes[2] == 0xBF;
        if (hasBom) {
          failures.add('${entity.path}: UTF-8 BOM detected');
        }

        for (final marker in forbiddenMarkers) {
          if (text.contains(marker)) {
            failures.add('${entity.path}: contains mojibake marker "$marker"');
            break;
          }
        }
      }
    }

    final normalizedFailures = failures
        .map((line) => line.replaceAll('\\', '/'))
        .toList(growable: false);
    final newFailures = normalizedFailures
        .where((line) {
          final path = line.split(':').first.trim().replaceAll('\\', '/');
          return !baseline.contains(line) && !baselinePaths.contains(path);
        })
        .toList(growable: false);

    expect(
      newFailures,
      isEmpty,
      reason: newFailures.isEmpty
          ? null
          : '\n${newFailures.join('\n')}\n\n'
              'If this is legacy debt, add it to test/text_encoding_guard_baseline.txt.',
    );
  });
}
