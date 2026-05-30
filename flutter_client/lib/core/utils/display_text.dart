extension DisplayTextX on String? {
  String? toDisplayTextOrNull() {
    final value = this?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.toLowerCase() == 'null') return null;
    return value;
  }

  String displayTextOr([String placeholder = '-']) {
    return toDisplayTextOrNull() ?? placeholder;
  }

  bool get hasDisplayText => toDisplayTextOrNull() != null;
}
