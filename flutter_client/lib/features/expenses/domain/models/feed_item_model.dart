import 'package:homesync_client/core/theme/app_colors.dart';

class FeedItemModel {
  final String recordType; // 'expense' or 'planned'
  final String id;
  final String title;
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
    required this.recordType,
    required this.id,
    required this.title,
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
      recordType: map['record_type'] as String? ?? 'expense',
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Movimiento',
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

  bool get isPlanned => recordType == 'planned';
  bool get isRealExpense => recordType == 'expense';
  bool get isPending => status == 'pending';

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
    return AppColors.categoryIcons[category] ?? '📦';
  }

  String get categoryLabel {
    return AppColors.categoryNames[category] ?? 'Otros';
  }
}
