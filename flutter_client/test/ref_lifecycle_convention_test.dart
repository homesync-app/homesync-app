import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Convention guard for the Riverpod `Ref`-after-dispose bug class.
///
/// Root cause (see docs/FINANCE_HARDENING_PLAN_2026-06.md): an auto-dispose
/// provider invoked via `ref.read(...)` keeps no listener, so it can be torn
/// down while an async method it triggered is still awaiting. Any `ref`/`_ref`
/// use after that throws "Cannot use the Ref ... after it has been disposed".
///
/// A repository is a stateless, session-lived singleton that holds its `Ref`
/// and reads it after async gaps — so it must NEVER be auto-dispose. This test
/// fails if a codegen repository provider is annotated `@riverpod` (auto-dispose)
/// instead of `@Riverpod(keepAlive: true)`. Plain `Provider<XRepository>`
/// declarations are keepAlive by default and are intentionally not matched.
void main() {
  test('codegen repository providers are keepAlive (never auto-dispose)', () {
    // Matches a riverpod_generator function provider that returns a repository,
    // e.g. `ExpenseRepository expenseRepository(Ref ref) {`.
    final repoProviderDecl = RegExp(
      r'^[A-Za-z0-9_]+Repository\s+[a-z][A-Za-z0-9_]*Repository\(\s*Ref\s+ref\s*\)',
    );

    final offenders = <String>[];
    final libDir = Directory('lib');

    for (final entity in libDir.listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      if (entity.path.endsWith('.g.dart')) continue;

      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (!repoProviderDecl.hasMatch(lines[i].trimLeft())) continue;

        // Walk upward to the nearest annotation, skipping blank/comment lines.
        var j = i - 1;
        while (j >= 0) {
          final prev = lines[j].trim();
          if (prev.isEmpty ||
              prev.startsWith('//') ||
              prev.startsWith('*') ||
              prev.startsWith('/*')) {
            j--;
            continue;
          }
          break;
        }
        final annotation = j >= 0 ? lines[j].trim() : '';
        final isKeepAlive = annotation.startsWith('@Riverpod(') &&
            annotation.contains('keepAlive: true');
        if (!isKeepAlive) {
          offenders.add(
            '${entity.path.replaceAll('\\', '/')}:${i + 1}  '
            '($annotation) — repositories must be @Riverpod(keepAlive: true)',
          );
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: offenders.isEmpty
          ? null
          : '\nAuto-dispose repository providers found:\n'
              '${offenders.join('\n')}\n\n'
              'A repository holds its Ref and reads it after async gaps; as '
              'auto-dispose it can be torn down mid-await and throw '
              '"Cannot use the Ref ... after it has been disposed". '
              'Annotate it with @Riverpod(keepAlive: true).',
    );
  });
}
