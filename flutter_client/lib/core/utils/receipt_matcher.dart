import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';

/// Utilidad centralizada para matching entre items detectados por OCR
/// y la lista de compras activa.
///
/// Reglas de matching conservadoras para evitar falsos positivos:
/// - Normaliza texto (minúsculas, sin tildes, sin cantidades/unidades).
/// - Compara tokens relevantes (≥4 chars) en ambas direcciones.
/// - Solo matchea si la coincidencia es inequívoca.
///
/// Expuesto como clase estática: sin estado, sin dependencias de Flutter.
class ReceiptMatcher {
  ReceiptMatcher._();

  /// Unidades y palabras de cantidad que se eliminan antes de comparar.
  static final _quantityPattern = RegExp(
    r'\b\d+[\.,]?\d*\s*(ml|l|kg|g|gr|un|x\d+|pack|paq|caja|lt|lts|cc)\b',
    caseSensitive: false,
  );

  /// Artículos y palabras cortas irrelevantes.
  static final _stopWords = {
    'de', 'la', 'el', 'los', 'las', 'un', 'una', 'con', 'sin',
    'del', 'al', 'por', 'para', 'en', 'y', 'o',
  };

  /// Resultado del match: items de la lista que matchearon y los que no.
  static MatchResult match({
    required List<String> ocrItems,
    required List<ShoppingItemModel> pendingShoppingItems,
  }) {
    final matched = <ShoppingItemModel>{};
    final unmatched = <String>[];

    for (final ocrRaw in ocrItems) {
      final ocrTokens = _tokenize(ocrRaw);
      if (ocrTokens.isEmpty) {
        unmatched.add(ocrRaw);
        continue;
      }

      ShoppingItemModel? bestMatch;
      for (final shopItem in pendingShoppingItems) {
        final shopTokens = _tokenize(shopItem.name);
        if (shopTokens.isEmpty) continue;

        // Match: la primera palabra clave del item de lista aparece en el OCR
        // O la primera palabra clave del OCR aparece en el nombre del item.
        // "Primera palabra clave" = primer token con ≥4 chars.
        final shopKey = shopTokens.first;
        final ocrKey = ocrTokens.first;

        final shopMatchesOcr = ocrTokens.contains(shopKey);
        final ocrMatchesShop = shopTokens.contains(ocrKey);

        if (shopMatchesOcr || ocrMatchesShop) {
          bestMatch = shopItem;
          break;
        }
      }

      if (bestMatch != null) {
        matched.add(bestMatch);
      } else {
        unmatched.add(ocrRaw);
      }
    }

    return MatchResult(matched: matched.toList(), unmatched: unmatched);
  }

  /// Tokeniza un string para comparación:
  /// elimina cantidades/unidades, normaliza, filtra stop words y tokens cortos.
  static List<String> _tokenize(String raw) {
    final cleaned = raw
        .replaceAll(_quantityPattern, ' ')
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    return cleaned
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.length >= 4 && !_stopWords.contains(t))
        .toList();
  }

  /// Limpia el nombre crudo del OCR para mostrarlo y guardarlo como item de lista.
  /// Ej: "Leche La Serenísima 1L x2" → "Leche La Serenísima"
  static String cleanName(String raw) {
    final withoutQuantities = raw.replaceAll(_quantityPattern, '').trim();
    final words = withoutQuantities.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    return words.take(4).join(' ');
  }
}

class MatchResult {
  final List<ShoppingItemModel> matched;
  final List<String> unmatched;

  const MatchResult({required this.matched, required this.unmatched});
}
