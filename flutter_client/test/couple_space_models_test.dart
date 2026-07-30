import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_connection_summary.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';

void main() {
  group('CoupleConnectionSummary', () {
    test('parses shared progress and keeps the remaining count bounded', () {
      final summary = CoupleConnectionSummary.fromMap({
        'household_id': 'household',
        'week_start': '2026-07-20T00:00:00Z',
        'week_end': '2026-07-27T00:00:00Z',
        'tasks_done': 8,
        'tasks_planned': 11,
        'needs_attention': 1,
        'special_moments': 12,
        'member_distribution': [
          {
            'user_id': 'a',
            'name': 'Alex',
            'avatar_url': null,
            'tasks_done': 5,
          },
          {
            'user_id': 'b',
            'name': 'Sam',
            'avatar_url': null,
            'tasks_done': 3,
          },
        ],
      });

      expect(summary.tasksRemaining, 3);
      expect(summary.completionRate, closeTo(8 / 11, 0.001));
      expect(summary.specialMoments, 12);
      expect(summary.memberDistribution.map((member) => member.tasksDone), [
        5,
        3,
      ]);
    });

    test('does not report negative remaining tasks', () {
      final summary = CoupleConnectionSummary.fromMap({
        'household_id': 'household',
        'week_start': '2026-07-20T00:00:00Z',
        'week_end': '2026-07-27T00:00:00Z',
        'tasks_done': 4,
        'tasks_planned': 3,
      });

      expect(summary.tasksRemaining, 0);
      expect(summary.completionRate, 1);
    });
  });

  test('CoupleProposal maps a free pending proposal', () {
    final proposal = CoupleProposal.fromMap({
      'id': 'proposal',
      'household_id': 'household',
      'created_by': 'user',
      'title': 'Cocinar algo nuevo',
      'description': 'El viernes',
      'category': 'plan',
      'status': 'pending',
      'created_at': '2026-07-26T12:00:00Z',
      'updated_at': '2026-07-26T12:00:00Z',
    });

    expect(proposal.category, CoupleProposalCategory.plan);
    expect(proposal.isPending, isTrue);
    expect(proposal.isMine('user'), isTrue);
    expect(proposal.isAccepted, isFalse);
  });

  test('CoupleProposal keeps deferred proposals open for a later response', () {
    final proposal = CoupleProposal.fromMap({
      'id': 'proposal',
      'household_id': 'household',
      'created_by': 'user',
      'title': 'Salir a caminar',
      'category': 'plan',
      'status': 'deferred',
      'created_at': '2026-07-26T12:00:00Z',
      'updated_at': '2026-07-26T12:00:00Z',
    });

    expect(proposal.isDeferred, isTrue);
    expect(proposal.canRespond, isTrue);
    expect(proposal.isAccepted, isFalse);
  });
}
