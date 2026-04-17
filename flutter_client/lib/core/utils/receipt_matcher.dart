import 'package:homesync_client/features/shopping/data/shopping_predefined.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';

/// Utilidad centralizada para matching entre items detectados por OCR
/// y la lista de compras activa.
///
/// Estrategia:
/// 1. Resuelve cada item OCR a su nombre canónico del catálogo predefinido.
///    Ej: "LIMON" → "Limón 🍋"
/// 2. Matchea contra la lista de compras pendientes usando score de overlap
///    de tokens normalizados (sin acentos, minúsculas).
/// 3. Score ≥ 0.4 o prefijo compartido de ≥4 chars acepta el match.
class ReceiptMatcher {
  ReceiptMatcher._();

  static const double _minScore = 0.4;

  static final _quantityPattern = RegExp(
    r'\b\d+[\.,]?\d*\s*(ml|l|kg|g|gr|un|x\d+|pack|paq|caja|lt|lts|cc)\b',
    caseSensitive: false,
  );

  static final _stopWords = {
    'de', 'la', 'el', 'los', 'las', 'un', 'una', 'con', 'sin',
    'del', 'al', 'por', 'para', 'en', 'y', 'o', 'the',
  };

  // ─── Catálogo predefinido aplanado (lazy) ──────────────────────────────────

  static List<CatalogEntry>? _catalog;

  static List<CatalogEntry> get _flatCatalog {
    return _catalog ??= ShoppingPredefined.itemsPerCategory.entries
        .expand((entry) => entry.value.map((item) => CatalogEntry(
              name: item['name'] ?? '',
              emoji: item['emoji'] ?? '🛒',
              category: entry.key,
            ),),)
        .toList();
  }

  /// Busca el item del catálogo predefinido que mejor coincide con [rawOcr].
  ///
  /// Scoring: shared / catTokens.length — pregunta "¿cuánto del nombre del
  /// catálogo aparece en el texto OCR?" en lugar del overlap simétrico.
  /// Esto permite que "APERITIVO TERMA SERR C 1350Cm3" matchee "Terma" (1/1=1.0)
  /// aunque el OCR tenga muchos tokens extra.
  static CatalogEntry? findPredefined(String rawOcr) {
    final ocrTokens = _tokenize(rawOcr);
    if (ocrTokens.isEmpty) return null;

    CatalogEntry? best;
    double bestScore = 0;

    for (final entry in _flatCatalog) {
      final catTokens = _tokenize(entry.name);
      if (catTokens.isEmpty) continue;
      final s = _scoreByCatalog(ocrTokens, catTokens);
      if (s > bestScore) {
        bestScore = s;
        best = entry;
      }
    }

    return (best != null && bestScore >= _minScore) ? best : null;
  }

  /// Resultado del match: items de la lista que matchearon y los que no.
  static MatchResult match({
    required List<String> ocrItems,
    required List<ShoppingItemModel> pendingShoppingItems,
  }) {
    final matched = <ShoppingItemModel>{};
    final unmatched = <String>[];

    for (final ocrRaw in ocrItems) {
      // Intenta resolver al nombre canónico primero para mejor matching
      final canonical = findPredefined(ocrRaw);
      final ocrTokens = _tokenize(canonical?.name ?? ocrRaw);

      if (ocrTokens.isEmpty) {
        unmatched.add(ocrRaw);
        continue;
      }

      ShoppingItemModel? bestMatch;
      double bestScore = 0;

      for (final shopItem in pendingShoppingItems) {
        final shopTokens = _tokenize(shopItem.name);
        if (shopTokens.isEmpty) continue;
        final s = _score(ocrTokens, shopTokens);
        if (s > bestScore) {
          bestScore = s;
          bestMatch = shopItem;
        }
      }

      if (bestMatch != null && bestScore >= _minScore) {
        matched.add(bestMatch);
      } else {
        unmatched.add(ocrRaw);
      }
    }

    return MatchResult(matched: matched.toList(), unmatched: unmatched);
  }

  // ─── Helpers de scoring ────────────────────────────────────────────────────

  /// Scoring simétrico (max): para matching OCR ↔ lista de compras.
  static double _score(List<String> a, List<String> b) {
    if (a.isEmpty || b.isEmpty) return 0;
    int shared = 0;
    for (final ta in a) {
      for (final tb in b) {
        if (_tokensMatch(ta, tb)) {
          shared++;
          break;
        }
      }
    }
    return shared / (a.length > b.length ? a.length : b.length);
  }

  /// Scoring orientado al catálogo: shared / catTokens.length.
  ///
  /// Pregunta "¿cuánto del nombre del catálogo aparece en el texto OCR?"
  /// Permite que "APERITIVO TERMA SERR C 1350Cm3" matchee "Terma" con 1.0
  /// aunque el OCR tenga muchos tokens adicionales de marca/tamaño.
  static double _scoreByCatalog(List<String> ocrTokens, List<String> catTokens) {
    if (ocrTokens.isEmpty || catTokens.isEmpty) return 0;
    int shared = 0;
    for (final tc in catTokens) {
      for (final to in ocrTokens) {
        if (_tokensMatch(tc, to)) {
          shared++;
          break;
        }
      }
    }
    return shared / catTokens.length;
  }

  static bool _tokensMatch(String a, String b) {
    if (a == b) return true;
    // Prefijo: "yogur" matchea "yogurt"
    if (a.length >= 4 && b.startsWith(a)) return true;
    if (b.length >= 4 && a.startsWith(b)) return true;
    // Levenshtein: permite 1 error cada 5 chars (ej: "bonito" ↔ "boniato")
    final maxLen = a.length > b.length ? a.length : b.length;
    if (maxLen >= 5) {
      final maxEdits = maxLen <= 6 ? 1 : 2;
      if (_levenshtein(a, b) <= maxEdits) return true;
    }
    return false;
  }

  /// Distancia de edición (Levenshtein) entre dos strings.
  static int _levenshtein(String a, String b) {
    final m = a.length, n = b.length;
    // Optimización: si la diferencia de largo ya supera el threshold, descartamos
    if ((m - n).abs() > 3) return 99;
    final dp = List.generate(m + 1, (i) => List.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1];
        } else {
          dp[i][j] = 1 +
              [dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1]]
                  .reduce((x, y) => x < y ? x : y);
        }
      }
    }
    return dp[m][n];
  }

  /// Público para uso en [resolveScanItems].
  static List<String> tokenize(String raw) => _tokenize(raw);

  /// Público para uso en [resolveScanItems].
  static double scoreTokens(List<String> a, List<String> b) => _score(a, b);

  /// "¿Cuánto del [target] aparece en [source]?" — igual que _scoreByCatalog.
  /// Útil para comparar tokens OCR crudos contra un item de la lista.
  static double scoreByTarget(List<String> sourceTokens, List<String> targetTokens) =>
      _scoreByCatalog(sourceTokens, targetTokens);

  static List<String> _tokenize(String raw) {
    final cleaned = raw
        .replaceAll(_quantityPattern, ' ')
        .toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
        .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    return cleaned
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.length >= 3 && !_stopWords.contains(t))
        .toList();
  }

  // ─── Limpieza de nombre para mostrar ──────────────────────────────────────

  /// Normaliza el nombre crudo del OCR para mostrar:
  /// - Si hay match en el catálogo, usa el nombre canónico (con tilde, capitalizado).
  /// - Si no, extrae el primer token significativo como nombre genérico.
  ///
  /// Ej: "LIMON 2KG" → "Limón" (canónico)
  /// Ej: "SODA COOPERATIVA SIFON 1750Cm" → "Soda" (primer token)
  /// Ej: "APERITIVO AMARO LUCANO 750ML" → "Aperitivo" (primer token)
  static String cleanName(String raw) {
    final canonical = findPredefined(raw);
    if (canonical != null) return canonical.name;

    // Sin match en catálogo: proponer solo el primer token como nombre genérico.
    // En tickets argentinos el tipo de producto generalmente va primero.
    final withoutQuantities = raw.replaceAll(_quantityPattern, '').trim();
    final firstToken = withoutQuantities
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .firstOrNull;

    return firstToken != null ? _toTitleCase(firstToken) : '';
  }

  static String _toTitleCase(String word) {
    if (word.isEmpty) return word;
    if (word == word.toUpperCase() || word == word.toLowerCase()) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }
    return word;
  }
}

// ─── Tipos públicos auxiliares ─────────────────────────────────────────────

class CatalogEntry {
  final String name;
  final String emoji;
  final String category;
  const CatalogEntry({required this.name, required this.emoji, required this.category});
}

// ─── Tipos públicos ────────────────────────────────────────────────────────

class MatchResult {
  final List<ShoppingItemModel> matched;
  final List<String> unmatched;
  const MatchResult({required this.matched, required this.unmatched});
}

/// Resultado del nuevo flujo de scan:
/// - [toMarkPurchased]: items ya en la lista pendiente → solo tachar
/// - [toAddAndMark]: items reconocidos por catálogo pero no en lista → agregar + tachar
/// - [unrecognized]: no matchean el catálogo → mostrar en banner
class ScanMatchResult {
  final List<ShoppingItemModel> toMarkPurchased;
  final List<ShoppingItemModel> toAddAndMark;
  final List<String> unrecognized;

  const ScanMatchResult({
    required this.toMarkPurchased,
    required this.toAddAndMark,
    required this.unrecognized,
  });

  /// Todos los items que van a quedar vinculados (para mostrar en el card)
  List<ShoppingItemModel> get allLinked => [...toMarkPurchased, ...toAddAndMark];
}

/// Resuelve cada item OCR al flujo correcto dados los items pendientes.
/// Usa el catálogo predefinido como fuente de verdad de reconocimiento.
ScanMatchResult resolveScanItems({
  required List<String> ocrItems,
  required List<ShoppingItemModel> pendingShoppingItems,
  required String householdId,
}) {
  final toMarkPurchased = <ShoppingItemModel>[];
  final toAddAndMark = <ShoppingItemModel>[];
  final unrecognized = <String>[];

  for (final ocrRaw in ocrItems) {
    final rawTokens = ReceiptMatcher.tokenize(ocrRaw);

    // ── Paso 1: buscar directamente en la lista pendiente ────────────────────
    // Pregunta: "¿aparece el nombre del item pendiente dentro del texto OCR?"
    // Ej: "APERITIVO TERMA SERR C 1350Cm3" contiene "terma" → score 1.0
    ShoppingItemModel? directMatch;
    double bestDirectScore = 0;

    for (final item in pendingShoppingItems) {
      final itemTokens = ReceiptMatcher.tokenize(item.name);
      if (itemTokens.isEmpty) continue;
      final s = ReceiptMatcher.scoreByTarget(rawTokens, itemTokens);
      if (s > bestDirectScore) {
        bestDirectScore = s;
        directMatch = item;
      }
    }

    if (directMatch != null && bestDirectScore >= 0.5) {
      toMarkPurchased.add(directMatch);
      continue;
    }

    // ── Paso 2: resolver con el catálogo predefinido ──────────────────────────
    final catalog = ReceiptMatcher.findPredefined(ocrRaw);

    if (catalog == null) {
      unrecognized.add(ocrRaw);
      continue;
    }

    // ── Paso 3: buscar el nombre canónico en la lista pendiente ───────────────
    final catalogTokens = ReceiptMatcher.tokenize(catalog.name);
    ShoppingItemModel? pendingMatch;
    double bestScore = 0;

    for (final item in pendingShoppingItems) {
      final s = ReceiptMatcher.scoreTokens(catalogTokens, ReceiptMatcher.tokenize(item.name));
      if (s > bestScore) {
        bestScore = s;
        pendingMatch = item;
      }
    }

    if (pendingMatch != null && bestScore >= 0.4) {
      toMarkPurchased.add(pendingMatch);
    } else {
      toAddAndMark.add(ShoppingItemModel(
        id: 'temp_${catalog.name.toLowerCase().replaceAll(' ', '_')}',
        name: catalog.name,
        emoji: catalog.emoji,
        category: catalog.category,
        householdId: householdId,
        createdAt: DateTime.now(),
      ),);
    }
  }

  return ScanMatchResult(
    toMarkPurchased: toMarkPurchased,
    toAddAndMark: toAddAndMark,
    unrecognized: unrecognized,
  );
}
