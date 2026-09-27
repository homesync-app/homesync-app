import 'package:flutter/widgets.dart';

/// A tap target that screen readers announce with its role and state.
///
/// Drop-in for a `GestureDetector` that only handles [onTap]: same [onTap],
/// [behavior] and [child], plus the state a plain GestureDetector cannot
/// express. Chips, segmented tabs and option cards used to read as a bare
/// "double-tap to activate" with no way to tell which option was active.
class SemanticTap extends StatelessWidget {
  const SemanticTap({
    super.key,
    required this.onTap,
    required this.child,
    this.behavior,
    this.selected,
    this.checked,
    this.inMutuallyExclusiveGroup = false,
    this.label,
    this.excludeChildSemantics = false,
  });

  final VoidCallback? onTap;
  final Widget child;
  final HitTestBehavior? behavior;

  /// Selected state for chips, tabs and single-choice options.
  final bool? selected;

  /// Checked state for items that toggle on and off. When set, the target is
  /// announced as a checkbox instead of a button.
  final bool? checked;

  /// True for radio-like groups where exactly one option is selected.
  final bool inMutuallyExclusiveGroup;

  /// Label for targets without readable text (avatars, icons).
  final String? label;

  /// Reads only [label] and skips the children's text, for example a
  /// currency symbol that the reader would spell out before the name.
  final bool excludeChildSemantics;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: checked == null,
      enabled: onTap != null,
      selected: selected,
      checked: checked,
      inMutuallyExclusiveGroup: inMutuallyExclusiveGroup ? true : null,
      label: label,
      excludeSemantics: excludeChildSemantics,
      // With the children excluded, the GestureDetector's own tap action is
      // excluded too, so the node needs its own.
      onTap: excludeChildSemantics ? onTap : null,
      child: GestureDetector(
        behavior: behavior,
        onTap: onTap,
        child: child,
      ),
    );
  }
}
