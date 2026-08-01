enum CoupleProposalCategory {
  talk,
  plan,
  affection,
  support;

  factory CoupleProposalCategory.fromString(String? value) {
    return CoupleProposalCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => CoupleProposalCategory.talk,
    );
  }
}

enum CoupleProposalStatus {
  pending,
  accepted,
  deferred,
  declined,
  withdrawn,
  archived;

  factory CoupleProposalStatus.fromString(String? value) {
    return CoupleProposalStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => CoupleProposalStatus.pending,
    );
  }
}

class CoupleProposal {
  final String id;
  final String householdId;
  final String createdBy;
  final String title;
  final String? description;
  final CoupleProposalCategory category;
  final CoupleProposalStatus status;
  final String? respondedBy;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// `fund_goal` cuando la propuesta nació de desbloquear una meta del fondo,
  /// `member` cuando la escribió una persona.
  final String origin;

  const CoupleProposal({
    required this.id,
    required this.householdId,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.respondedBy,
    required this.respondedAt,
    required this.createdAt,
    required this.updatedAt,
    this.origin = 'member',
  });

  bool get isFromFund => origin == 'fund_goal';
  bool isMine(String? currentUserId) => createdBy == currentUserId;
  bool get isPending => status == CoupleProposalStatus.pending;
  bool get isAccepted => status == CoupleProposalStatus.accepted;
  bool get isDeferred => status == CoupleProposalStatus.deferred;
  bool get canRespond => isPending || isDeferred;

  factory CoupleProposal.fromMap(Map<String, dynamic> map) {
    return CoupleProposal(
      id: map['id']?.toString() ?? '',
      householdId: map['household_id']?.toString() ?? '',
      createdBy: map['created_by']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      category: CoupleProposalCategory.fromString(
        map['category']?.toString(),
      ),
      status: CoupleProposalStatus.fromString(map['status']?.toString()),
      respondedBy: map['responded_by']?.toString(),
      respondedAt: DateTime.tryParse(map['responded_at']?.toString() ?? ''),
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updated_at']?.toString() ?? '')?.toLocal() ??
              DateTime.now(),
      origin: map['origin']?.toString() ?? 'member',
    );
  }
}
