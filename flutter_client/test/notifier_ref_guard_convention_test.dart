import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Heuristic guardrail for the Riverpod `Ref`-after-dispose bug class at the
/// *notifier* layer (the repository layer is covered by
/// `ref_lifecycle_convention_test.dart`).
///
/// This is intentionally a convention TEST, not a custom_lint rule: this project
/// runs riverpod_lint via the native analyzer plugin and deliberately avoids
/// `custom_lint`. The check is coarse on purpose (file-level, no AST) to stay
/// robust and low-maintenance — it catches the egregious regression of adding a
/// brand-new auto-dispose notifier that invalidates other providers after an
/// async gap without ever guarding `ref.mounted`. Finer cases are covered by the
/// documented pattern in docs/FINANCE_HARDENING_PLAN_2026-06.md + code review.
void main() {
  test(
      'auto-dispose notifiers that invalidate providers also guard with '
      'ref.mounted', () {
    // `@riverpod` (lowercase = auto-dispose) on a Notifier class. KeepAlive
    // notifiers (`@Riverpod(keepAlive: true)`) are immune — their Ref is
    // session-lived — so they never match this pattern.
    final autoDisposeNotifier =
        RegExp(r'@riverpod\s+class\s+\w+\s+extends\s+_\$');

    // Files where an auto-dispose notifier invalidates/refreshes another
    // provider after an await, but the invalidation provably runs before any
    // async gap (or is otherwise safe). Add with a justification.
    final allowlist = <String>{};

    final offenders = <String>[];
    for (final entity in Directory('lib').listSync(recursive: true)) {
      if (entity is! File ||
          !entity.path.endsWith('.dart') ||
          entity.path.endsWith('.g.dart')) {
        continue;
      }
      final text = entity.readAsStringSync();
      if (!autoDisposeNotifier.hasMatch(text)) continue;

      final rel = entity.path.replaceAll('\\', '/');
      if (allowlist.any(rel.endsWith)) continue;

      final touchesOtherProviders =
          text.contains('ref.invalidate(') || text.contains('ref.refresh(');
      if (touchesOtherProviders && !text.contains('ref.mounted')) {
        offenders.add(rel);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: offenders.isEmpty
          ? null
          : '\nAuto-dispose notifiers invalidate other providers without any '
              'ref.mounted guard:\n${offenders.join('\n')}\n\n'
              'After an await the notifier may be disposed; guard post-await '
              'ref/state use with `if (!ref.mounted) return;` (see TaskController '
              'or ExpenseController for the canonical pattern).',
    );
  });
}
