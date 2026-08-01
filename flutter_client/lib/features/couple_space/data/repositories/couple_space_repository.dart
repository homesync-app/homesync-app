import 'package:homesync_client/features/couple_space/domain/models/couple_connection_summary.dart';
import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoupleSpaceRepository {
  final SupabaseClient _client;

  const CoupleSpaceRepository(this._client);

  Future<CoupleConnectionSummary> getSummary(String householdId) async {
    final response = await _client.rpc(
      'get_couple_connection_summary_v1',
      params: {'p_household_id': householdId},
    );
    return CoupleConnectionSummary.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<List<CoupleProposal>> getProposals(String householdId) async {
    final response = await _client
        .from('couple_proposals')
        .select()
        .eq('household_id', householdId)
        .inFilter('status', ['pending', 'accepted', 'deferred']).order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(response)
        .map(CoupleProposal.fromMap)
        .toList(growable: false);
  }

  Stream<List<CoupleProposal>> watchProposals(String householdId) {
    return _client
        .from('couple_proposals')
        .stream(primaryKey: ['id'])
        .eq('household_id', householdId)
        .map((rows) {
          final proposals = rows
              .map(CoupleProposal.fromMap)
              .where(
                (proposal) =>
                    proposal.status == CoupleProposalStatus.pending ||
                    proposal.status == CoupleProposalStatus.accepted ||
                    proposal.status == CoupleProposalStatus.deferred,
              )
              .toList(growable: false);
          proposals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return proposals;
        });
  }

  Future<CoupleProposal> createProposal({
    required String householdId,
    required String title,
    String? description,
    required CoupleProposalCategory category,
  }) async {
    final response = await _client.rpc(
      'create_couple_proposal_v1',
      params: {
        'p_household_id': householdId,
        'p_title': title,
        'p_description': description,
        'p_category': category.name,
      },
    );
    return CoupleProposal.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<CoupleProposal> respondToProposal({
    required String proposalId,
    required CoupleProposalStatus response,
  }) async {
    if (response != CoupleProposalStatus.accepted &&
        response != CoupleProposalStatus.deferred &&
        response != CoupleProposalStatus.declined) {
      throw ArgumentError.value(response, 'response');
    }
    final rpcResponse = await _client.rpc(
      'respond_couple_proposal_v1',
      params: {
        'p_proposal_id': proposalId,
        'p_response': response.name,
      },
    );
    return CoupleProposal.fromMap(
      Map<String, dynamic>.from(rpcResponse as Map),
    );
  }

  Future<CoupleProposal> withdrawProposal(String proposalId) async {
    final response = await _client.rpc(
      'withdraw_couple_proposal_v1',
      params: {'p_proposal_id': proposalId},
    );
    return CoupleProposal.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<CoupleProposal> archiveProposal(String proposalId) async {
    final response = await _client.rpc(
      'archive_couple_proposal_v1',
      params: {'p_proposal_id': proposalId},
    );
    return CoupleProposal.fromMap(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
