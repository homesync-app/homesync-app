import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/couple_space/domain/couple_money.dart';
import 'package:homesync_client/features/couple_space/domain/couple_proposal_ordering.dart';
import 'package:homesync_client/features/couple_space/domain/couple_week_reading.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:homesync_client/features/couple_space/domain/models/household_contribution.dart';
import 'package:homesync_client/features/expenses/domain/models/feed_item_model.dart';

const _me = 'user-me';
const _partner = 'user-partner';

HouseholdContribution _contribution({
  required int mine,
  required int theirs,
  List<Map<String, dynamic>> categories = const [],
}) {
  return HouseholdContribution.fromMap({
    'household_id': 'h1',
    'week_start': '2026-09-21T00:00:00Z',
    'week_end': '2026-09-28T00:00:00Z',
    'total_tasks': mine + theirs,
    'rhythm_weeks': 3,
    'rhythm_window': 4,
    'members': [
      {'user_id': _me, 'name': 'Blas', 'tasks_done': mine, 'demanding_done': 0},
      {
        'user_id': _partner,
        'name': 'Sofi',
        'tasks_done': theirs,
        'demanding_done': 1,
      },
    ],
    'categories': categories,
  });
}

FeedItemModel _expense({
  required String payer,
  required double amount,
  DateTime? date,
  String type = 'expense',
  String record = 'expense',
  String? split,
}) {
  return FeedItemModel(
    recordType: record,
    transactionType: type,
    id: '${payer}_$amount',
    title: 'x',
    amount: amount,
    splitType: split,
    payerId: payer,
    date: date ?? DateTime(2026, 9, 10),
    status: 'paid',
  );
}

CoupleProposal _proposal({
  required String id,
  required String createdBy,
  required String status,
  required DateTime createdAt,
}) {
  return CoupleProposal.fromMap({
    'id': id,
    'household_id': 'h1',
    'created_by': createdBy,
    'title': 'Plan $id',
    'category': 'plan',
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'updated_at': createdAt.toIso8601String(),
  });
}

void main() {
  group('CoupleWeekReading', () {
    test('sin tareas en la semana la lectura es vacía', () {
      final reading = CoupleWeekReading.from(
        _contribution(mine: 0, theirs: 0),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.empty);
      expect(reading.isSkewed, isFalse);
    });

    test('una categoría inclinada gana a la lectura general', () {
      final reading = CoupleWeekReading.from(
        _contribution(
          mine: 1,
          theirs: 5,
          categories: [
            {
              'category': 'cocina',
              'total': 4,
              'dominant_user_id': _partner,
              'dominant_name': 'Sofi',
              'dominant_count': 4,
              'skewed': true,
            },
          ],
        ),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.categorySkew);
      expect(reading.category, 'cocina');
      expect(reading.leaderIsMe, isFalse);
      expect(reading.leaderUserId, _partner);
    });

    test('si la categoría la hice yo, el tono es proponer turnarnos', () {
      final reading = CoupleWeekReading.from(
        _contribution(
          mine: 4,
          theirs: 1,
          categories: [
            {
              'category': 'limpieza',
              'total': 3,
              'dominant_user_id': _me,
              'dominant_name': 'Blas',
              'dominant_count': 3,
              'skewed': true,
            },
          ],
        ),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.categorySkew);
      expect(reading.leaderIsMe, isTrue);
    });

    test('sin categorías inclinadas, un total muy desparejo se nombra', () {
      final reading = CoupleWeekReading.from(
        _contribution(mine: 1, theirs: 7),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.overallSkew);
      expect(reading.leaderUserId, _partner);
      expect(reading.leaderIsMe, isFalse);
    });

    test('con pocas tareas no se lee ni desequilibrio ni parejo', () {
      final reading = CoupleWeekReading.from(
        _contribution(mine: 0, theirs: 3),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.early);
      expect(reading.isSkewed, isFalse);
    });

    test('un reparto parejo se lee como parejo', () {
      final reading = CoupleWeekReading.from(
        _contribution(mine: 4, theirs: 5),
        currentUserId: _me,
      );
      expect(reading.kind, CoupleWeekReadingKind.balanced);
    });
  });

  group('CoupleBalanceView', () {
    test('diferencias de redondeo se leen como estar a mano', () {
      final view = CoupleBalanceView.fromMyBalance(-8);
      expect(view.direction, CoupleBalanceDirection.even);
      expect(view.amount, 0);
    });

    test('balance negativo: le debo a mi pareja', () {
      final view = CoupleBalanceView.fromMyBalance(-12400);
      expect(view.direction, CoupleBalanceDirection.iOwe);
      expect(view.amount, 12400);
    });

    test('balance positivo: mi pareja me debe', () {
      final view = CoupleBalanceView.fromMyBalance(3500.5);
      expect(view.direction, CoupleBalanceDirection.theyOwe);
      expect(view.amount, 3500.5);
    });
  });

  group('computeCoupleMonthMoney', () {
    final now = DateTime(2026, 9, 25);

    test('suma por persona solo gastos compartidos del mes', () {
      final money = computeCoupleMonthMoney(
        feed: [
          _expense(payer: _me, amount: 1000),
          _expense(payer: _me, amount: 500, split: 'personal'),
          _expense(payer: _partner, amount: 2000),
          _expense(payer: _partner, amount: 700, type: 'settlement'),
          _expense(payer: _partner, amount: 900, type: 'income'),
          _expense(payer: _partner, amount: 300, record: 'planned'),
          _expense(payer: _me, amount: 400, date: DateTime(2026, 8, 30)),
        ],
        now: now,
        currentUserId: _me,
        partnerId: _partner,
      );
      expect(money.mePaid, 1000);
      expect(money.partnerPaid, 2000);
      expect(money.total, 3000);
      expect(money.myShare, closeTo(1 / 3, 0.0001));
    });

    test('con economía integrada también cuentan los personales', () {
      final money = computeCoupleMonthMoney(
        feed: [
          _expense(payer: _me, amount: 1000),
          _expense(payer: _me, amount: 500, split: 'personal'),
        ],
        now: now,
        currentUserId: _me,
        partnerId: _partner,
        includePersonal: true,
      );
      expect(money.mePaid, 1500);
      expect(money.partnerPaid, 0);
    });

    test('sin gastos el resumen queda vacío', () {
      final money = computeCoupleMonthMoney(
        feed: const [],
        now: now,
        currentUserId: _me,
        partnerId: _partner,
      );
      expect(money.isEmpty, isTrue);
      expect(money.myShare, 0);
    });
  });

  group('orderCoupleProposals', () {
    test('primero lo que me toca responder y después lo acordado', () {
      final base = DateTime(2026, 9, 20);
      final agreed = _proposal(
        id: 'agreed',
        createdBy: _partner,
        status: 'accepted',
        createdAt: base.add(const Duration(days: 4)),
      );
      final mineWaiting = _proposal(
        id: 'mine',
        createdBy: _me,
        status: 'pending',
        createdAt: base.add(const Duration(days: 3)),
      );
      final toAnswerOld = _proposal(
        id: 'answer-old',
        createdBy: _partner,
        status: 'pending',
        createdAt: base,
      );
      final toAnswerNew = _proposal(
        id: 'answer-new',
        createdBy: _partner,
        status: 'pending',
        createdAt: base.add(const Duration(days: 1)),
      );
      final later = _proposal(
        id: 'later',
        createdBy: _partner,
        status: 'deferred',
        createdAt: base.add(const Duration(days: 2)),
      );

      final ordered = orderCoupleProposals(
        [agreed, mineWaiting, toAnswerOld, later, toAnswerNew],
        _me,
      );

      expect(ordered.map((p) => p.id), [
        'answer-new',
        'answer-old',
        'mine',
        'later',
        'agreed',
      ]);
      expect(coupleProposalsToAnswer(ordered, _me), 2);
      expect(
        coupleProposalStage(mineWaiting, _me),
        CoupleProposalStage.waiting,
      );
    });
  });
}
