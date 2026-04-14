import 'package:flutter/material.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

class ExpenseFixedSplitManager {
  ExpenseFixedSplitManager({
    required String Function(double value) formatAmount,
    required double Function(String value) parseAmount,
    required String Function() readTotalInput,
    required VoidCallback onStateChanged,
    required bool Function() isMounted,
  })  : _formatAmount = formatAmount,
        _parseAmount = parseAmount,
        _readTotalInput = readTotalInput,
        _onStateChanged = onStateChanged,
        _isMounted = isMounted;

  final String Function(double value) _formatAmount;
  final double Function(String value) _parseAmount;
  final String Function() _readTotalInput;
  final VoidCallback _onStateChanged;
  final bool Function() _isMounted;

  final Map<String, double> _amounts = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _isProgrammaticUpdate = false;

  Map<String, double> get amounts => _amounts;

  double amountFor(String userId) => _amounts[userId] ?? 0.0;

  void seedAmounts(Map<String, double> amounts) {
    _amounts
      ..clear()
      ..addAll(amounts);
  }

  TextEditingController controllerForMember(String userId) {
    return _controllers.putIfAbsent(userId, () {
      final initial = _formatAmount(_amounts[userId] ?? 0.0);
      return TextEditingController(text: initial);
    });
  }

  FocusNode focusNodeForMember(String userId, List<MemberModel> members) {
    return _focusNodes.putIfAbsent(userId, () {
      final node = FocusNode();
      node.addListener(() {
        if (!_isMounted()) return;
        _onStateChanged();
        if (node.hasFocus) {
          _applyIntelligentRemainder(userId, members);
        }
      });
      return node;
    });
  }

  void syncControllerTextIfNeeded(String userId, double amount) {
    final controller = controllerForMember(userId);
    final formatted = _formatAmount(amount);
    if (controller.text == formatted) return;

    _isProgrammaticUpdate = true;
    controller.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    _isProgrammaticUpdate = false;
  }

  void onChanged(String userId, String value, List<MemberModel> members) {
    if (_isProgrammaticUpdate) return;

    final clean = value.replaceAll('.', '').replaceAll(',', '');
    if (clean.isEmpty) {
      _amounts[userId] = 0.0;
      syncControllerTextIfNeeded(userId, 0.0);
      _applyIntelligentRemainder(userId, members);
      _onStateChanged();
      return;
    }

    final parsed = int.tryParse(clean);
    if (parsed == null) return;

    final total = _parseAmount(_readTotalInput());
    final entered =
        parsed.toDouble().clamp(0.0, total > 0 ? total : parsed.toDouble());
    _amounts[userId] = entered;
    syncControllerTextIfNeeded(userId, entered);
    _applyIntelligentRemainder(userId, members);
    _onStateChanged();
  }

  void dismissKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    for (final node in _focusNodes.values) {
      node.unfocus();
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }
  }

  void _applyIntelligentRemainder(String userId, List<MemberModel> members) {
    if (members.length != 2) return;

    final total = _parseAmount(_readTotalInput());
    final entered = (_amounts[userId] ?? 0.0).clamp(0.0, total);
    final otherId = members.firstWhere((m) => m.userId != userId).userId;
    final remaining = (total - entered).clamp(0.0, total);

    _amounts[userId] = entered;
    _amounts[otherId] = remaining;
    syncControllerTextIfNeeded(otherId, remaining);
  }
}
