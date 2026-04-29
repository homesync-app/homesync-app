import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_split_state.dart';
import 'package:homesync_client/features/household/domain/models/member.dart';

MemberModel _member(
  String userId, {
  String? name,
}) {
  return MemberModel(
    id: 'member-$userId',
    userId: userId,
    householdId: 'house-1',
    role: 'member',
    joinedAt: DateTime(2024, 1, 1),
    fullName: name,
    type: MemberType.parent,
  );
}

ExpenseFixedSplitManager _buildManager({
  required String Function() readTotalInput,
  VoidCallback? onStateChanged,
}) {
  return ExpenseFixedSplitManager(
    formatAmount: (value) => value.toStringAsFixed(0),
    parseAmount: (value) => double.tryParse(value) ?? 0.0,
    readTotalInput: readTotalInput,
    onStateChanged: onStateChanged ?? () {},
    isMounted: () => true,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ExpenseFixedSplitManager', () {
    final memberA = _member('user-a', name: 'Ana');
    final memberB = _member('user-b', name: 'Beto');
    final memberC = _member('user-c', name: 'Carla');

    test('seeded amounts are reflected in lazily created controllers', () {
      final manager = _buildManager(readTotalInput: () => '100');
      addTearDown(manager.dispose);

      manager.seedAmounts({
        memberA.userId: 35,
        memberB.userId: 65,
      });

      expect(manager.amountFor(memberA.userId), 35);
      expect(manager.controllerForMember(memberA.userId).text, '35');
      expect(manager.controllerForMember(memberB.userId).text, '65');
    });

    test('onChanged updates entered member and auto-fills remainder for two members', () {
      var stateChangeCount = 0;
      final manager = _buildManager(
        readTotalInput: () => '100',
        onStateChanged: () => stateChangeCount++,
      );
      addTearDown(manager.dispose);

      manager.onChanged(memberA.userId, '40', [memberA, memberB]);

      expect(manager.amountFor(memberA.userId), 40);
      expect(manager.amountFor(memberB.userId), 60);
      expect(manager.controllerForMember(memberA.userId).text, '40');
      expect(manager.controllerForMember(memberB.userId).text, '60');
      expect(stateChangeCount, 1);
    });

    test('entered amount is clamped to total before syncing remainder', () {
      final manager = _buildManager(readTotalInput: () => '100');
      addTearDown(manager.dispose);

      manager.onChanged(memberA.userId, '150', [memberA, memberB]);

      expect(manager.amountFor(memberA.userId), 100);
      expect(manager.amountFor(memberB.userId), 0);
      expect(manager.controllerForMember(memberA.userId).text, '100');
      expect(manager.controllerForMember(memberB.userId).text, '0');
    });

    test('empty input resets current member to zero and rebalances pair', () {
      final manager = _buildManager(readTotalInput: () => '100');
      addTearDown(manager.dispose);

      manager.seedAmounts({
        memberA.userId: 45,
        memberB.userId: 55,
      });

      manager.onChanged(memberA.userId, '', [memberA, memberB]);

      expect(manager.amountFor(memberA.userId), 0);
      expect(manager.amountFor(memberB.userId), 100);
      expect(manager.controllerForMember(memberA.userId).text, '0');
      expect(manager.controllerForMember(memberB.userId).text, '100');
    });

    test('three-member split does not auto-distribute remainder', () {
      final manager = _buildManager(readTotalInput: () => '120');
      addTearDown(manager.dispose);

      manager.seedAmounts({
        memberA.userId: 30,
        memberB.userId: 30,
        memberC.userId: 60,
      });

      manager.onChanged(memberA.userId, '50', [memberA, memberB, memberC]);

      expect(manager.amountFor(memberA.userId), 50);
      expect(manager.amountFor(memberB.userId), 30);
      expect(manager.amountFor(memberC.userId), 60);
      expect(manager.controllerForMember(memberB.userId).text, '30');
      expect(manager.controllerForMember(memberC.userId).text, '60');
    });
  });
}
