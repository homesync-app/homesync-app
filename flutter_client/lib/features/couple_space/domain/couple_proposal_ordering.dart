import 'package:homesync_client/features/couple_space/domain/models/couple_proposal.dart';

/// En qué punto está una propuesta desde el lado de quien mira.
enum CoupleProposalStage {
  /// La propuso mi pareja y espera mi respuesta.
  toAnswer,

  /// La propuse yo y espera la respuesta de mi pareja.
  waiting,

  /// Quedó para después: cualquiera de los dos la puede retomar.
  later,

  /// Quedó acordada.
  agreed,
}

CoupleProposalStage coupleProposalStage(
  CoupleProposal proposal,
  String? currentUserId,
) {
  if (proposal.isAccepted) return CoupleProposalStage.agreed;
  if (proposal.isDeferred) return CoupleProposalStage.later;
  return proposal.isMine(currentUserId)
      ? CoupleProposalStage.waiting
      : CoupleProposalStage.toAnswer;
}

/// Ordena la bandeja "Entre ustedes": primero lo que me toca responder, después
/// lo que espera a mi pareja, lo que quedó para después y lo acordado. Dentro
/// de cada grupo, lo más nuevo arriba.
List<CoupleProposal> orderCoupleProposals(
  Iterable<CoupleProposal> proposals,
  String? currentUserId,
) {
  final ordered = proposals.toList(growable: false);
  ordered.sort((a, b) {
    final byStage = coupleProposalStage(a, currentUserId)
        .index
        .compareTo(coupleProposalStage(b, currentUserId).index);
    if (byStage != 0) return byStage;
    return b.createdAt.compareTo(a.createdAt);
  });
  return ordered;
}

/// Cuántas propuestas esperan una respuesta mía.
int coupleProposalsToAnswer(
  Iterable<CoupleProposal> proposals,
  String? currentUserId,
) {
  return proposals
      .where(
        (proposal) =>
            coupleProposalStage(proposal, currentUserId) ==
            CoupleProposalStage.toAnswer,
      )
      .length;
}
