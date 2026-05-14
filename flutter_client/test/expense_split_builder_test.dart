import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/expenses/domain/repositories/expense_repository.dart';
import 'package:homesync_client/features/expenses/presentation/widgets/expense_split_builder.dart';
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

void main() {
  group('ExpenseSplitBuilder.build', () {
    final memberA = _member('user-a', name: 'Ana');
    final memberB = _member('user-b', name: 'Beto');
    final memberC = _member('user-c', name: 'Carla');

    test('returns payer-only split when split UI is hidden', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: false,
        splitMode: SplitType.equal,
        amount: 120,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB],
        selectedMembers: {memberA.userId, memberB.userId},
        fixedAmounts: {},
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, [
        {'user_id': memberA.userId, 'amount': 120.0},
      ]);
    });

    test('returns payer-only split for personal expenses', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.personal,
        amount: 85,
        paidByUserId: memberB.userId,
        financeMembers: [memberA, memberB],
        selectedMembers: {memberA.userId, memberB.userId},
        fixedAmounts: {},
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, [
        {'user_id': memberB.userId, 'amount': 85.0},
      ]);
    });

    test('returns empty splits for gift expenses', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.gift,
        amount: 50,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB],
        selectedMembers: {memberA.userId},
        fixedAmounts: {},
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, isEmpty);
    });

    test('uses household default ratio for two-member equal split', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.equal,
        amount: 100,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB],
        selectedMembers: {},
        fixedAmounts: {},
        defaultRatio: 0.7,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, [
        {'user_id': memberA.userId, 'amount': 70.0},
        {'user_id': memberB.userId, 'amount': 30.000000000000004},
      ]);
    });

    test('requires selected members for equal split when not using ratio mode',
        () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.equal,
        amount: 90,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB, memberC],
        selectedMembers: {},
        fixedAmounts: {},
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isTrue);
      expect(
        result.validationMessage,
        'Debes seleccionar al menos un miembro para dividir.',
      );
      expect(result.splits, isEmpty);
    });

    test('splits amount evenly across selected members', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.equal,
        amount: 90,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB, memberC],
        selectedMembers: {memberA.userId, memberC.userId},
        fixedAmounts: {},
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, hasLength(2));
      expect(
        result.splits,
        everyElement(
          allOf(
            containsPair('amount', 45.0),
            contains('user_id'),
          ),
        ),
      );
    });

    test('validates fixed split total against expense amount', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.fixed,
        amount: 100,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB],
        selectedMembers: {},
        fixedAmounts: {
          memberA.userId: 40,
          memberB.userId: 50,
        },
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isTrue);
      expect(
        result.validationMessage,
        'El reparto debe sumar el total (\$100.00)',
      );
      expect(result.splits, [
        {'user_id': memberA.userId, 'amount': 40.0},
        {'user_id': memberB.userId, 'amount': 50.0},
      ]);
    });

    test('returns fixed split amounts when total matches expense amount', () {
      final result = ExpenseSplitBuilder.build(
        showSplit: true,
        splitMode: SplitType.fixed,
        amount: 100,
        paidByUserId: memberA.userId,
        financeMembers: [memberA, memberB, memberC],
        selectedMembers: {},
        fixedAmounts: {
          memberA.userId: 40,
          memberB.userId: 60,
          memberC.userId: 0,
        },
        defaultRatio: 0.5,
        currentUserId: memberA.userId,
      );

      expect(result.hasValidationError, isFalse);
      expect(result.splits, [
        {'user_id': memberA.userId, 'amount': 40.0},
        {'user_id': memberB.userId, 'amount': 60.0},
      ]);
    });
  });
}
