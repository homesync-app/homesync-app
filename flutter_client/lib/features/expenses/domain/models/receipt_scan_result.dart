import 'package:homesync_client/core/utils/receipt_matcher.dart';

/// Resultado del escaneo OCR de un ticket.
///
/// En este punto la imagen solo existe localmente (localImagePath).
/// NO se sube a Supabase Storage hasta que el usuario confirma el gasto.
/// Solo entonces se obtiene un receipt_path para persistir en DB.
class ReceiptScanResult {
  /// Comercio detectado → pre-rellena el título del gasto.
  final String? merchant;

  /// Monto total del ticket → pre-rellena el campo amount.
  final double? amount;

  /// Fecha del ticket → pre-rellena paidAt.
  final DateTime? date;

  /// Categoría sugerida → pre-selecciona en el form, siempre editable.
  final String? category;

  /// Items detectados en el ticket (nombres limpios).
  /// Se usan para matching conservador contra la lista de compras.
  final List<String> detectedItems;

  /// Path local de la imagen comprimida (WebP).
  /// Se sube a Storage solo si el usuario confirma el gasto.
  final String localImagePath;

  /// Confianza 0.0–1.0 según legibilidad del ticket.
  final double confidence;

  const ReceiptScanResult({
    this.merchant,
    this.amount,
    this.date,
    this.category,
    required this.detectedItems,
    required this.localImagePath,
    required this.confidence,
  });

  factory ReceiptScanResult.fromJson(
      Map<String, dynamic> json, String localImagePath) {
    return ReceiptScanResult(
      merchant: json['merchant'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      category: json['category'] as String?,
      detectedItems: (json['items'] as List<dynamic>?)
              ?.map((e) => ReceiptMatcher.cleanName(e.toString().trim()))
              .where((e) => e.isNotEmpty)
              .toList() ??
          [],
      localImagePath: localImagePath,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// True si el ticket era difícil de leer.
  /// Útil para mostrar un aviso de "revisá los datos" en UI.
  bool get hasLowConfidence => confidence < 0.6;
}
