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

  /// Items tal como vinieron de la IA, sin pasar por cleanName.
  /// Se usan para telemetría / análisis del OCR.
  final List<String> rawItems;

  /// Path local de la imagen comprimida (WebP).
  /// Se sube a Storage solo si el usuario confirma el gasto.
  final String localImagePath;

  /// Confianza 0.0–1.0 según legibilidad del ticket.
  final double confidence;

  /// Id de la fila de ocr_scan_logs que el servidor insertó para este scan.
  /// El cliente NO inserta su propia fila: actualiza esta con el resultado
  /// del matcher y la acción final del usuario (confirmed/cancelled).
  final String? logId;

  /// El servidor detectó (por hash de imagen) que este mismo ticket ya se
  /// escaneó con éxito hace poco en el household. Solo aviso, no bloqueo.
  final bool isDuplicate;

  const ReceiptScanResult({
    this.merchant,
    this.amount,
    this.date,
    this.category,
    required this.detectedItems,
    required this.rawItems,
    required this.localImagePath,
    required this.confidence,
    this.logId,
    this.isDuplicate = false,
  });

  factory ReceiptScanResult.fromJson(
    Map<String, dynamic> json,
    String localImagePath, {
    String? logId,
    bool isDuplicate = false,
  }) {
    final raw = (json['items'] as List<dynamic>?)
            ?.map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
    return ReceiptScanResult(
      merchant: json['merchant'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String)
          : null,
      category: json['category'] as String?,
      rawItems: raw,
      detectedItems:
          raw.map(ReceiptMatcher.cleanName).where((e) => e.isNotEmpty).toList(),
      localImagePath: localImagePath,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      logId: logId,
      isDuplicate: isDuplicate,
    );
  }

  /// True si el ticket era difícil de leer.
  /// Útil para mostrar un aviso de "revisá los datos" en UI.
  bool get hasLowConfidence => confidence < 0.6;
}
