import 'package:flutter/services.dart';

/// Semantic haptic vocabulary for HomeSync.
///
/// Always call these instead of [HapticFeedback] directly so the same kind of
/// moment feels the same everywhere in the app:
///
/// - [selection] — moving between options: tabs, segmented controls, pickers.
/// - [tap] — a lightly acknowledged touch: checkboxes, chips, minor toggles.
/// - [success] — a confirmed action: form saved, task completed, payment sent.
/// - [warning] — destructive or attention-demanding actions.
/// - [error] — something went wrong and the user should notice.
/// - [celebrate] — the over-produced moments: settling all debts, weekly
///   winner, claiming a reward. Use sparingly so it keeps its meaning.
class AppHaptics {
  AppHaptics._();

  static void selection() => HapticFeedback.selectionClick();

  static void tap() => HapticFeedback.lightImpact();

  static void success() => HapticFeedback.mediumImpact();

  static void warning() => HapticFeedback.heavyImpact();

  static void error() => HapticFeedback.vibrate();

  /// Three-beat rising pattern reserved for reward/goal moments.
  static Future<void> celebrate() async {
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 110));
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.lightImpact();
  }
}
