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

  /// Threshold para matching OCR↔lista pendiente del usuario (flujo legado `match`).
  static const double _minScore = 0.4;

  /// Threshold para matching contra el catálogo predefinido.
  /// 1.0 exige que TODOS los tokens del nombre de catálogo aparezcan en OCR.
  /// Evita falsos positivos como "CARNE VACUNA" → "Carne picada" (score 0.5).
  static const double _catalogMinScore = 1.0;

  static final _quantityPattern = RegExp(
    r'\b\d+[\.,]?\d*\s*(ml|l|kg|g|gr|un|x\d+|pack|paq|caja|lt|lts|cc|cm3|cmc)\b',
    caseSensitive: false,
  );

  /// Precios habituales en tickets AR: "$1.250,00", "250,00", trailing "1250".
  static final _pricePattern = RegExp(
    r'\$\s*[\d\.,]+|\b\d+[\.,]\d{2}\b|\s+\d{3,}\s*$',
  );

  static final _stopWords = {
    'de', 'la', 'el', 'los', 'las', 'un', 'una', 'con', 'sin',
    'del', 'al', 'por', 'para', 'en', 'y', 'o', 'the',
  };

  /// Palabras que indican que la línea es metadata del ticket, no un producto.
  /// Si alguna aparece en la línea, se descarta por completo.
  static const _blacklistWords = {
    'total', 'subtotal', 'iva', 'efectivo', 'vuelto', 'cambio',
    'tarjeta', 'credito', 'debito', 'cuotas', 'descuento', 'descuentos',
    'promo', 'promocion', 'bonif', 'bonificacion', 'ticket', 'factura',
    'cuit', 'cuil', 'dni', 'gracias', 'operacion', 'caja', 'cajero',
    'vendedor', 'atencion', 'cliente', 'fecha', 'hora', 'neto',
    'importe', 'precio',
  };

  static final _blacklistPattern = RegExp(
    r'\b(?:' + _blacklistWords.join('|') + r')\b',
    caseSensitive: false,
  );

  /// Marcas argentinas comunes. Como tokens sueltos son ruido; se filtran al
  /// tokenizar. Si una línea es SOLO marca (ej: "MOLINOS SA"), queda vacía y
  /// se descarta.
  static const _brandWords = {
    'sancor', 'serenisima', 'ilolay', 'milkaut', 'tregar', 'nestle',
    'molinos', 'arcor', 'bagley', 'terrabusi', 'marolio', 'cocacola',
    // 'coca' y 'cola' NO van aquí: son tokens del catálogo "Coca Cola"
    'pepsi', 'sprite', 'quilmes', 'brahma', 'imperial', 'stella', 'heineken',
    'corona', 'patagonia', 'manaos', 'cunnington', 'bimbo', 'fargo',
    'knorr', 'maggi', 'hellmanns', 'natura', 'cocinero', 'canuelas',
    'matarazzo', 'luchetti', 'ledesma', 'chango', 'celusal',
    'dove', 'nivea', 'colgate', 'gillette', 'milka',
  };

  /// Genéricos ambiguos: si el OCR no matcheó ningún item del catálogo y el
  /// primer token (ya stemmeado) es uno de estos, NO ofrecemos el producto
  /// como "nuevo detectado". Son palabras que requieren un calificador para
  /// tener sentido en una lista de compras.
  ///
  /// Ejemplo: "JABON LIQUIDO REP KARITE" no matchea "Jabón ropa" ni
  /// "Jabón tocador" del catálogo; sin esta regla se ofrecería solo "Jabón",
  /// que sería un duplicado ambiguo si el ticket también trae Jabón ropa/tocador.
  /// Tokens ya pasados por `_stem`.
  static const _ambiguousGenerics = {
    'jabon', // requiere 'ropa' o 'tocador'
    'queso', // requiere 'fresco', 'rallado' o 'crema'
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
    int bestCatLen = 0;    // tie-breaker 1: más tokens = más específico
    int bestCatChars = 0;  // tie-breaker 2: token más largo = más específico
    // "ANTITRAN DOVE M PEPINO": tanto Antitranspirante como Pepino tienen
    // 1 token con score 1.0. Gana Antitranspirante porque 'antitranspirante'
    // (16 chars) > 'pepino' (6 chars).

    for (final entry in _flatCatalog) {
      final catTokens = _tokenize(entry.name);
      if (catTokens.isEmpty) continue;
      final s = _scoreByCatalog(ocrTokens, catTokens);
      final catChars = catTokens.fold(0, (sum, t) => sum + t.length);
      if (s > bestScore ||
          (s == bestScore && s >= _catalogMinScore &&
              (catTokens.length > bestCatLen ||
               (catTokens.length == bestCatLen && catChars > bestCatChars)))) {
        bestScore = s;
        bestCatLen = catTokens.length;
        bestCatChars = catChars;
        best = entry;
      }
    }

    return (best != null && bestScore >= _catalogMinScore) ? best : null;
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
        .replaceAll(_pricePattern, ' ')
        .replaceAll(_quantityPattern, ' ')
        // "sin azucar", "sin tacc", "sin sodio", etc. son descriptores del
        // producto, no el producto en sí. Se eliminan ambas palabras para
        // evitar que "COCA COLA SIN AZUCAR" matchee "Azúcar".
        .replaceAll(RegExp(r'\bsin\s+\w+', caseSensitive: false), ' ')
        .toLowerCase()
        .replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i')
        .replaceAll('ó', 'o').replaceAll('ú', 'u').replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');

    return cleaned
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) =>
            t.length >= 3 &&
            !_stopWords.contains(t) &&
            !_brandWords.contains(t),)
        .map(_stem)
        .toList();
  }

  /// Stemming suave para español: normaliza plurales (-s, -es) y diminutivos
  /// (-ito/-ita/-itos/-itas/-cito/-cita/-citos/-citas) para que "Galletitas"
  /// matchee "Galletas" y "Tomates" matchee "Tomate".
  ///
  /// Conservador: solo toca tokens de 5+ chars y deja margen ≥3 chars tras stem.
  static String _stem(String token) {
    if (token.length < 5) return token;
    const diminutives = [
      'citos', 'citas', 'cito', 'cita', 'itos', 'itas', 'ito', 'ita',
    ];
    for (final suf in diminutives) {
      if (token.endsWith(suf) && token.length > suf.length + 2) {
        return token.substring(0, token.length - suf.length);
      }
    }
    if (token.endsWith('es') && token.length > 4) {
      return token.substring(0, token.length - 2);
    }
    if (token.endsWith('s') && token.length > 3) {
      return token.substring(0, token.length - 1);
    }
    return token;
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

  /// Valida si una línea OCR parece un nombre de producto real (no ruido del
  /// ticket como totales, descuentos, códigos internos, etc.).
  ///
  /// Descarta automáticamente:
  /// - Líneas con `%` (promos: "2do50%-MOLINOS")
  /// - Strings que empiezan con guión, símbolo o dígito ("-arcor-golos1")
  /// - Líneas que contienen palabras de metadata del ticket (total, iva, etc.)
  /// - Strings con menos de 3 letras reales
  /// - Strings donde las letras son menos del 40% del total (muy ruidosos)
  static bool looksLikeValidProduct(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return false;

    // Descarta líneas de descuento/promo con porcentaje
    if (t.contains('%')) return false;

    // Descarta si empieza con símbolo, guión o dígito
    if (RegExp(r'^[-_*/\\@#!+=\d]').hasMatch(t)) return false;

    // Descarta si contiene guión en cualquier posición: es código interno del
    // ticket (ARCOR-GOLOS1, SERR-C1, 2do50%-MOLINOS). Los productos reales en
    // tickets argentinos no usan guión.
    if (t.contains('-')) return false;

    // Descarta si contiene una palabra de blacklist (total, descuento, etc.)
    if (_blacklistPattern.hasMatch(t)) return false;

    // Cuenta letras reales (con acentos)
    final letters =
        RegExp(r'[a-zA-ZáéíóúüñÁÉÍÓÚÜÑ]').allMatches(t).length;
    if (letters < 3) return false;

    // Al menos 40% del string deben ser letras (filtra "golos1", "SERR-C1")
    if (letters / t.length < 0.4) return false;

    // Requiere al menos un token puramente alfabético tras limpiar marcas,
    // stopwords, precios y cantidades. Descarta códigos internos del ticket
    // donde solo sobrevive basura con dígitos embebidos.
    //
    // Ej: "ARCOR-GOLOS1" → se filtra "arcor" (marca), queda solo "golos1"
    // (mezcla letras+dígitos) → rechazado.
    // Ej: "MOLINOS 2do50%" → ya cae antes por el '%'.
    // Ej: "SODA COOPERATIVA SIFON 1750Cm" → quedan "soda", "cooperativa",
    // "sifon" (puro alfabéticos) → aceptado.
    final cleanTokens = _tokenize(t);
    final hasPureLetterToken = cleanTokens.any(
      (tok) => RegExp(r'^[a-z]+$').hasMatch(tok),
    );
    if (!hasPureLetterToken) return false;

    return true;
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
/// - [dropped]: descartados por quality gate (telemetría para mejorar reglas)
class ScanMatchResult {
  final List<ShoppingItemModel> toMarkPurchased;
  final List<ShoppingItemModel> toAddAndMark;
  final List<String> unrecognized;
  final List<String> dropped;

  const ScanMatchResult({
    required this.toMarkPurchased,
    required this.toAddAndMark,
    required this.unrecognized,
    this.dropped = const [],
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
  final dropped = <String>[];

  // Claves de deduplicación. Si dos líneas OCR resuelven al mismo item
  // (ej: "POROTOS NEGROS..." y "POROTO SECO..." → ambos al catálogo "Porotos"),
  // queremos ofrecerlo una sola vez. Para unrecognized comparamos por la
  // firma de tokens stemmeados, que colapsa singular/plural.
  final seenMarked = <String>{};
  final seenAdded = <String>{};
  final seenUnrecognized = <String>{};

  for (final ocrRaw in ocrItems) {
    // ── Paso 0: quality gate ─────────────────────────────────────────────────
    // Descartar ruido del ticket (totales, descuentos, códigos, marcas sueltas).
    // Previene que "DESCUENTO LECHE 10%" matchee "Leche" por error.
    if (!ReceiptMatcher.looksLikeValidProduct(ocrRaw)) {
      dropped.add(ocrRaw);
      continue;
    }

    final rawTokens = ReceiptMatcher.tokenize(ocrRaw);

    // Si después de limpiar (precios, marcas, cantidades) no queda nada con
    // sentido, la línea es solo ruido (ej: "MOLINOS SA $1.250,00").
    if (rawTokens.isEmpty) {
      dropped.add(ocrRaw);
      continue;
    }

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
      if (seenMarked.add(directMatch.id)) {
        toMarkPurchased.add(directMatch);
      }
      continue;
    }

    // ── Paso 2: resolver con el catálogo predefinido ──────────────────────────
    final catalog = ReceiptMatcher.findPredefined(ocrRaw);

    if (catalog == null) {
      // Genéricos ambiguos (ej: "jabon" sin qualifier ropa/tocador) no se
      // ofrecen como producto nuevo — evita agregar "Jabón" cuando el ticket
      // también tiene Jabón ropa y Jabón tocador bien detectados.
      if (ReceiptMatcher._ambiguousGenerics.contains(rawTokens.first)) {
        dropped.add(ocrRaw);
        continue;
      }
      // La línea ya pasó el quality gate del Paso 0 → es un candidato genuino
      // a producto nuevo (ej: "Chicle"), lo ofrecemos al usuario.
      // Dedupe por nombre de display (cleanName), que es lo que el usuario
      // ve en el banner. Así "JUGO DURAZNO TROPA" y "JUGO MULTIFRUTA NATURAL"
      // — ambos se mostrarían como "Jugo" — colapsan en una sola sugerencia.
      final displayKey = ReceiptMatcher.cleanName(ocrRaw).toLowerCase();
      if (displayKey.isNotEmpty && seenUnrecognized.add(displayKey)) {
        unrecognized.add(ocrRaw);
      }
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
      if (seenMarked.add(pendingMatch.id)) {
        toMarkPurchased.add(pendingMatch);
      }
    } else {
      // Dedupe por nombre canónico: "POROTOS NEGROS..." y "POROTO SECO..."
      // ambos resuelven al catálogo "Porotos" → se ofrece una sola vez.
      final key = catalog.name.toLowerCase();
      if (seenAdded.add(key)) {
        toAddAndMark.add(ShoppingItemModel(
          id: 'temp_${key.replaceAll(' ', '_')}',
          name: catalog.name,
          emoji: catalog.emoji,
          category: catalog.category,
          householdId: householdId,
          createdAt: DateTime.now(),
        ),);
      }
    }
  }

  return ScanMatchResult(
    toMarkPurchased: toMarkPurchased,
    toAddAndMark: toAddAndMark,
    unrecognized: unrecognized,
    dropped: dropped,
  );
}
