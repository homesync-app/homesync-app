// ─────────────────────────────────────────────────────────────────────────────
// HomeSync — i18n ARB parity guard
//
// Fails when the source locale (app_es.arb) and the translated locale
// (app_en.arb) drift apart:
//   1. Keys present in es but missing in en (untranslated) — or vice-versa.
//   2. Placeholders inside a message that don't match between locales (a typo
//      like {nombre} vs {name}, or a missing {count}, crashes ICU at runtime).
//
// Pre-existing debt can be parked in test/l10n_parity_baseline.txt so this gate
// stays green on legacy strings while blocking NEW drift. Same pattern as
// text_encoding_guard_test.dart.
//
// Run with: flutter test test/l10n_parity_test.dart
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Extracts ICU *argument* names from a message string: simple placeholders
/// like `{name}`/`{count}` and the leading argument of plural/select blocks
/// like `{type, select, ...}`.
///
/// It deliberately ignores select/plural *branch* labels (`couple{...}`,
/// `other{...}`, `=0{...}`) and the literal text inside branches. We detect
/// arguments as a `{` that is NOT immediately preceded by an identifier char
/// or `=` (which would make it a branch body) and is followed by `name` then
/// `}` or `,`. This keeps `couple{Pareja}` from being read as a `{Pareja}`
/// placeholder while still catching real args, including nested ones.
Set<String> _placeholders(String message) {
  final result = <String>{};
  final regex = RegExp(r'(?<![a-zA-Z0-9_=])\{\s*([a-zA-Z0-9_]+)\s*[,}]');
  for (final match in regex.allMatches(message)) {
    final name = match.group(1);
    if (name != null) result.add(name);
  }
  return result;
}

Map<String, dynamic> _loadArb(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    fail('ARB file not found: $path');
  }
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

/// Real translatable keys: skip @@locale, @metadata entries (start with @).
Iterable<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

void main() {
  const esPath = 'lib/l10n/app_es.arb';
  const enPath = 'lib/l10n/app_en.arb';

  final baselineFile = File('test/l10n_parity_baseline.txt');
  final baseline = baselineFile.existsSync()
      ? baselineFile
          .readAsLinesSync()
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toSet()
      : <String>{};

  test('every source (es) key has an en translation', () {
    final es = _loadArb(esPath);
    final en = _loadArb(enPath);

    final esKeys = _messageKeys(es).toSet();
    final enKeys = _messageKeys(en).toSet();

    final missingInEn = esKeys
        .difference(enKeys)
        .where((k) => !baseline.contains('missing_en:$k'))
        .toList()
      ..sort();

    expect(
      missingInEn,
      isEmpty,
      reason: missingInEn.isEmpty
          ? null
          : 'Keys present in app_es.arb but missing from app_en.arb:\n'
              '  ${missingInEn.join('\n  ')}\n\n'
              'Add the en-US translation (see AGENTS.md i18n workflow), or, if '
              'this is known debt, add "missing_en:<key>" to '
              'test/l10n_parity_baseline.txt.',
    );
  });

  test('en has no orphan keys absent from the source (es)', () {
    final es = _loadArb(esPath);
    final en = _loadArb(enPath);

    final esKeys = _messageKeys(es).toSet();
    final enKeys = _messageKeys(en).toSet();

    final orphanInEn = enKeys
        .difference(esKeys)
        .where((k) => !baseline.contains('orphan_en:$k'))
        .toList()
      ..sort();

    expect(
      orphanInEn,
      isEmpty,
      reason: orphanInEn.isEmpty
          ? null
          : 'Keys present in app_en.arb but not in the source app_es.arb:\n'
              '  ${orphanInEn.join('\n  ')}\n\n'
              'The source locale is app_es.arb — remove the orphan or add the '
              'key to the source first.',
    );
  });

  test('ICU placeholders match between es and en for shared keys', () {
    final es = _loadArb(esPath);
    final en = _loadArb(enPath);

    final shared = _messageKeys(es).toSet().intersection(
          _messageKeys(en).toSet(),
        );

    final mismatches = <String>[];
    for (final key in shared) {
      if (baseline.contains('placeholders:$key')) continue;
      final esValue = es[key];
      final enValue = en[key];
      if (esValue is! String || enValue is! String) continue;

      final esPlaceholders = _placeholders(esValue);
      final enPlaceholders = _placeholders(enValue);

      if (!_setEquals(esPlaceholders, enPlaceholders)) {
        mismatches.add(
          '$key: es=${_sorted(esPlaceholders)} en=${_sorted(enPlaceholders)}',
        );
      }
    }
    mismatches.sort();

    expect(
      mismatches,
      isEmpty,
      reason: mismatches.isEmpty
          ? null
          : 'ICU placeholder mismatch between locales (runtime crash risk):\n'
              '  ${mismatches.join('\n  ')}\n\n'
              'Make the {placeholders} identical in both ARBs, or baseline with '
              '"placeholders:<key>".',
    );
  });
}

bool _setEquals(Set<String> a, Set<String> b) =>
    a.length == b.length && a.containsAll(b);

String _sorted(Set<String> s) {
  final list = s.toList()..sort();
  return '{${list.join(', ')}}';
}
