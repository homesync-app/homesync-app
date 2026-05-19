import 'package:homesync_client/core/theme/category_mapping.dart';

/// Categoria conceptual de un item del feed combinado (ver docs/feed_contract.md).
///
/// - [resource]: recurso financiero persistente (gasto/ingreso/settlement/planned).
///   Editable/borrable como recurso via su RPC.
/// - [activity]: actividad derivada (tarea completada, aprobacion, nota,
///   recompensa). NO se edita como recurso financiero.
/// - [system]: evento interno generado por reglas.
///
/// Hoy `get_combined_feed` solo devuelve recursos financieros, asi que todo
/// item es [resource]. El enum existe para que las cards decidan acciones por
/// `kind` (no por strings) y para estar listos cuando el RPC sume activities.
enum FeedItemKind {
  resource,
  activity,
  system;

  static FeedItemKind fromName(String? raw) {
    switch (raw) {
      case 'activity':
        return FeedItemKind.activity;
      case 'system':
        return FeedItemKind.system;
      case 'resource':
      default:
        return FeedItemKind.resource;
    }
  }
}

class FeedItemModel {
  /// Categoria conceptual. Las cards deben ramificar acciones por esto, no por
  /// strings de titulo/categoria. `transactionType` queda como subtipo
  /// financiero solo cuando `kind == FeedItemKind.resource`.
  final FeedItemKind kind;
  final String recordType; // 'expense' or 'planned'
  final String transactionType; // 'expense' | 'income' | 'settlement'
  final String id;
  final String title;
  final String? titleKey;
  final double amount;
  final String? category;
  final String? splitType;
  final String payerId;
  final String? payerEmail;
  final String? payerFullName;
  final String? payerAvatarUrl;
  final DateTime date;
  final String status; // 'paid', 'pending', 'skipped'

  const FeedItemModel({
    this.kind = FeedItemKind.resource,
    required this.recordType,
    required this.transactionType,
    required this.id,
    required this.title,
    this.titleKey,
    required this.amount,
    this.category,
    this.splitType,
    required this.payerId,
    this.payerEmail,
    this.payerFullName,
    this.payerAvatarUrl,
    required this.date,
    required this.status,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> map) {
    return FeedItemModel(
      // get_combined_feed hoy no manda 'kind'; default resource. Forward-
      // compatible: cuando el RPC lo mande, se respeta sin tocar el modelo.
      kind: FeedItemKind.fromName(map['kind'] as String?),
      recordType: map['record_type'] as String? ?? 'expense',
      transactionType: map['transaction_type'] as String? ?? 'expense',
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Movimiento',
      titleKey: map['title_key'] as String?,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String?,
      splitType: map['split_type'] as String?,
      payerId: map['payer_id'] as String? ?? '',
      payerEmail: map['payer_email'] as String?,
      payerFullName: map['payer_full_name'] as String?,
      payerAvatarUrl: map['payer_avatar_url'] as String?,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      status: map['status'] as String? ?? 'paid',
    );
  }

  /// true si el item es un recurso financiero editable/borrable como recurso.
  /// Las cards deben gatear acciones de recurso con esto antes de mirar
  /// `recordType`/`transactionType`.
  bool get isResource => kind == FeedItemKind.resource;

  bool get isPlanned => recordType == 'planned';
  bool get isRealExpense => recordType == 'expense';
  bool get isPending => status == 'pending';
  bool get isSettlement => transactionType == 'settlement';

  String get payerDisplayName {
    if (payerFullName != null && payerFullName!.isNotEmpty) {
      return payerFullName!.split(' ').first;
    }
    if (payerEmail != null && payerEmail!.isNotEmpty) {
      return payerEmail!.split('@').first;
    }
    return 'Alguien';
  }

  String get formattedAmount => '\$${amount.toStringAsFixed(2)}';

  String get categoryIcon {
    return CategoryMapping.categoryIcons[category] ?? '📦';
  }

  String get categoryLabel {
    return CategoryMapping.categoryNames[category] ?? 'Otros';
  }
}
