import 'package:homesync_client/core/utils/receipt_matcher.dart';

/// Resultado del escaneo OCR de un ticket.
///
/// En este punto la imagen solo existe localmente (localImagePath).
/// NO se sube a Supabase Storage hasta que el usuario confirma el gasto.
/// Solo entonces se obtiene un receipt_path para persistir en DB.
class ReceiptScanResult {
  /// Comercio detectado → pre-rellena el título del gasto. Si el hogar ya le
  /// puso nombre a este comercio (por CUIT), viene ese nombre
  /// ([merchantFromHistory]).
  final String? merchant;

  /// Monto total del ticket → pre-rellena el campo amount.
  final double? amount;

  /// Fecha del ticket → pre-rellena paidAt.
  final DateTime? date;

  /// Categoría sugerida → pre-selecciona en el form, siempre editable.
  final String? category;

  /// Items detectados para mostrar (nombre canónico del catálogo o primer
  /// token de [itemNames]).
  final List<String> detectedItems;

  /// Nombres limpios de producto tal como los devolvió la IA (campo `items`
  /// del servidor: abreviaturas expandidas, sin marca). Entrada del matcher
  /// contra la lista de compras.
  final List<String> itemNames;

  /// Path local de la imagen comprimida (WebP).
  /// Se sube a Storage solo si el usuario confirma el gasto.
  final String localImagePath;

  /// Confianza 0.0–1.0 autodeclarada por la IA. Casi siempre 0.9–1.0: como
  /// señal de "monto dudoso" sirve más [amountCheck].
  final double confidence;

  /// Chequeo aritmético del servidor: 'ok' | 'mismatch' | 'missing' |
  /// 'unknown' (null en respuestas de servidores viejos).
  final String? amountCheck;

  /// CUIT del comercio (11 dígitos) si se leyó y valida.
  final String? merchantTaxId;

  /// El título/categoría salen de cómo el hogar nombró antes a este comercio.
  final bool merchantFromHistory;

  /// Id de la fila de ocr_scan_logs que el servidor insertó para este scan.
  /// El cliente NO inserta su propia fila: actualiza esta con el resultado
  /// del matcher y la acción final del usuario (confirmed/cancelled).
  final String? logId;

  /// El servidor detectó (por hash de imagen) que este mismo ticket ya se
  /// escaneó con éxito hace poco en el household. Solo aviso, no bloqueo.
  final bool isDuplicate;

  /// Ya hay un gasto del hogar con el mismo monto y fecha. Solo aviso.
  final PossibleDuplicateExpense? possibleDuplicate;

  const ReceiptScanResult({
    this.merchant,
    this.amount,
    this.date,
    this.category,
    required this.detectedItems,
    required this.itemNames,
    required this.localImagePath,
    required this.confidence,
    this.amountCheck,
    this.merchantTaxId,
    this.merchantFromHistory = false,
    this.logId,
    this.isDuplicate = false,
    this.possibleDuplicate,
  });

  factory ReceiptScanResult.fromJson(
    Map<String, dynamic> json,
    String localImagePath, {
    String? logId,
    bool isDuplicate = false,
    PossibleDuplicateExpense? possibleDuplicate,
  }) {
    final names = (json['items'] as List<dynamic>?)
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
      itemNames: names,
      detectedItems: names
          .map(ReceiptMatcher.cleanName)
          .where((e) => e.isNotEmpty)
          .toList(),
      localImagePath: localImagePath,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      amountCheck: json['amountCheck'] as String?,
      merchantTaxId: json['merchantTaxId'] as String?,
      merchantFromHistory: json['merchantFromHistory'] as bool? ?? false,
      logId: logId,
      isDuplicate: isDuplicate,
      possibleDuplicate: possibleDuplicate,
    );
  }

  /// True si el ticket era difícil de leer.
  bool get hasLowConfidence => confidence < 0.6;

  /// True si el monto pre-llenado merece revisión: no cierra con las líneas
  /// del ticket (aun después de escalar al modelo de respaldo) o la IA se
  /// autocalificó baja.
  bool get amountUncertain =>
      amount != null && (amountCheck == 'mismatch' || hasLowConfidence);
}

/// Gasto existente del hogar con el mismo monto y fecha que el ticket.
class PossibleDuplicateExpense {
  final String title;
  final DateTime? paidAt;

  const PossibleDuplicateExpense({required this.title, this.paidAt});

  factory PossibleDuplicateExpense.fromJson(Map<String, dynamic> json) =>
      PossibleDuplicateExpense(
        title: json['title'] as String? ?? '',
        paidAt: DateTime.tryParse(json['paidAt'] as String? ?? '')?.toLocal(),
      );
}
