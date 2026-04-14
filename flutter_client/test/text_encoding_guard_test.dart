import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('No mojibake or BOM in Dart source files', () {
    // These are the actual mojibake *character sequences* that appear when
    // UTF-8 bytes are incorrectly decoded as Latin-1/Windows-1252.
    // They are checked against the properly UTF-8-decoded text, so valid
    // accented characters (á, é, ñ, etc.) will NOT trigger false positives.
    final forbiddenMarkers = <String>[
      'Ã\u00A1',  // á double-encoded
      'Ã\u00A9',  // é double-encoded
      'Ã\u00AD',  // í double-encoded
      'Ã\u00B3',  // ó double-encoded
      'Ã\u00BA',  // ú double-encoded
      'Ã\u00B1',  // ñ double-encoded
      'Ã\u0083',  // Ã double-encoded (triple)
      'â\u0080\u0093', // – (en dash) double-encoded
      'â\u0080\u0094', // — (em dash) double-encoded
      'â\u0080\u009C', // " double-encoded
      'â\u0080\u009D', // " double-encoded
      'â\u0080\u0099', // ' double-encoded
      'ðŸ',       // emoji double-encoded prefix
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
    final legacyPaths = <String>{
      'lib/core/providers/theme_provider.dart',
      'lib/core/theme/category_mapping.dart',
      'lib/features/dashboard/presentation/widgets/home_shopping_preview_card.dart',
      'lib/features/expenses/presentation/widgets/expense_category_matcher.dart',
      'lib/features/expenses/presentation/widgets/expense_form_components.dart',
      'lib/features/expenses/presentation/widgets/expense_form_data.dart',
      'lib/features/expenses/presentation/widgets/expense_form_selectors.dart',
      'lib/features/expenses/presentation/widgets/expense_shopping_components.dart',
      'lib/features/settings/presentation/widgets/settings_admin_components.dart',
      'lib/features/settings/presentation/widgets/settings_household_components.dart',
      'lib/features/tasks/domain/repositories/task_repository.dart',
      'lib/main.dart',
      'test/expense_category_matcher_test.dart',
      'test/expense_e2e_test.dart',
      'test/onboarding_e2e_test.dart',
      'test/repositories_test.dart',
    };

    final roots = <String>['lib', 'test'];

    for (final root in roots) {
      final dir = Directory(root);
      if (!dir.existsSync()) continue;

      for (final entity in dir.listSync(recursive: true)) {
        if (entity is! File) continue;
        if (!entity.path.endsWith('.dart')) continue;
        if (entity.path.endsWith('text_encoding_guard_test.dart')) continue;

        final bytes = entity.readAsBytesSync();
        final text = utf8.decode(bytes, allowMalformed: true);

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
          return !baseline.contains(line) &&
              !baselinePaths.contains(path) &&
              !legacyPaths.contains(path);
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
