import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/utils/receipt_matcher.dart';
import 'package:homesync_client/features/shopping/domain/models/shopping_model.dart';

/// Tests del matcher OCR ↔ catálogo/lista de compras.
///
/// Los casos vienen de tickets argentinos reales que motivaron cada regla
/// (estaban documentados como comentarios en receipt_matcher.dart; ahora
/// cualquier ajuste de thresholds o stemming los valida automáticamente).
void main() {
  ShoppingItemModel pendingItem(String id, String name) => ShoppingItemModel(
        id: id,
        householdId: 'h1',
        name: name,
        createdAt: DateTime(2026),
      );

  group('findPredefined', () {
    test('línea con tokens extra de marca/tamaño matchea el catálogo', () {
      // "¿cuánto del nombre del catálogo aparece en el OCR?" → Terma 1/1
      expect(
        ReceiptMatcher.findPredefined('TERMA SERR C 1350Cm3')?.name,
        'Terma',
      );
    });

    test('empate de score entre dos entradas: gana el token más largo', () {
      // "Aperitivo" y "Terma" están ambos en el catálogo con score 1.0;
      // gana 'aperitivo' (9 chars) sobre 'terma' (5).
      expect(
        ReceiptMatcher.findPredefined('APERITIVO TERMA SERR C 1350Cm3')?.name,
        'Aperitivo',
      );
    });

    test('tie-break por largo de token: gana el más específico', () {
      // Antitranspirante y Pepino empatan con score 1.0; gana el token
      // más largo ('antitranspirante' > 'pepino').
      expect(
        ReceiptMatcher.findPredefined('ANTITRAN DOVE M PEPINO')?.name,
        'Antitranspirante',
      );
    });

    test('"sin azucar" no matchea Azúcar (descriptor eliminado)', () {
      final match = ReceiptMatcher.findPredefined('COCA COLA SIN AZUCAR');
      expect(match?.name, 'Coca Cola');
    });

    test('match parcial no alcanza el threshold de catálogo (1.0)', () {
      // "CARNE VACUNA" comparte 1 de 2 tokens con "Carne picada" (0.5) → null
      // o bien resuelve a otra entrada de un solo token "carne" si existiera.
      final match = ReceiptMatcher.findPredefined('CARNE VACUNA');
      expect(match?.name, isNot('Carne picada'));
    });

    test('plural y diminutivo matchean por stemming', () {
      expect(
        ReceiptMatcher.findPredefined('GALLETITAS DULCES SURTIDAS')?.name,
        'Galletitas dulces',
      );
    });

    test('línea sin tokens útiles devuelve null', () {
      expect(ReceiptMatcher.findPredefined(r'$1.250,00'), isNull);
      expect(ReceiptMatcher.findPredefined(''), isNull);
    });

    // ── Regresiones de falsos positivos vistos en ocr_scan_logs (jul 2026) ──
    // El Levenshtein laxo (2 ediciones desde 7 chars, sin exigir inicial)
    // convertía productos bien leídos en sugerencias absurdas.

    test('BANANA matchea Banana, no Manzana (exacto gana a fuzzy)', () {
      expect(ReceiptMatcher.findPredefined('BANANA')?.name, 'Banana');
    });

    test('MARGARINA no matchea Mandarina (2 ediciones en 9 chars)', () {
      expect(
        ReceiptMatcher.findPredefined('MARGARINA DANICA EQUIL')?.name,
        isNot('Mandarina'),
      );
    });

    test('REPOLLO BLANCO no matchea Pollo (inicial distinta)', () {
      expect(
        ReceiptMatcher.findPredefined('REPOLLO BLANCO')?.name,
        isNot('Pollo'),
      );
    });

    test('NUEZ MOSCADA no matchea Tostadas (inicial distinta)', () {
      expect(
        ReceiptMatcher.findPredefined('Nuez moscada Alicante molida')?.name,
        isNot('Tostadas'),
      );
    });

    test('yogur MANZ/FR no matchea Manzana (prefijo acotado a diff ≤2)', () {
      expect(
        ReceiptMatcher.findPredefined('ACTIVIA SACHET MANZ/FR')?.name,
        isNot('Manzana'),
      );
    });

    test('UVA singular matchea Uvas del catálogo (stem plural de 4 letras)',
        () {
      expect(
        ReceiptMatcher.findPredefined('UVA RED GLOBE X KG (T)')?.name,
        'Uvas',
      );
    });

    test('abreviaturas de ticket se expanden (QSO, GALL, CERV, ANTITRANS)',
        () {
      expect(
        ReceiptMatcher.findPredefined('CERV MICHELOB ULTRA 473')?.name,
        'Cerveza',
      );
      expect(
        ReceiptMatcher.findPredefined('ANTITRANS DOVE M POMEL 150Cm3')?.name,
        'Antitranspirante',
      );
      expect(
        ReceiptMatcher.findPredefined('GALL ECOOP DE ARROZ C/ 100Grs')?.name,
        contains('Galle'),
      );
    });

    test('SUAV VIVERE matchea Suavizante vía abreviatura', () {
      expect(
        ReceiptMatcher.findPredefined('SUAV VIVERE CLAS MAS I 900Cm3')?.name,
        'Suavizante',
      );
    });

    test('el primer token de la línea manda: premezcla no es Pan lactal', () {
      // "PREMEZCLA S TACC S LACT PAN REP SANTA MA" contiene "pan"+"lact"
      // pero es una premezcla; el tie-break por primer token evita ofrecer
      // "Pan lactal".
      expect(
        ReceiptMatcher.findPredefined(
          'PREMEZCLA S TACC S LACT PAN REP SANTA MA',
        )?.name,
        isNot('Pan lactal'),
      );
    });

    test('garble de OCR con 1 edición y misma inicial sigue matcheando', () {
      // "SOPAPO COCINA PLASTICO" (garble real de "SOPAPA", visto en logs):
      // misma inicial, 1 edición → el Levenshtein conservador lo acepta.
      expect(
        ReceiptMatcher.findPredefined('SOPAPO COCINA PLASTICO 1Uni')?.name,
        'Sopapa',
      );
    });
  });

  group('cleanName', () {
    test('usa el nombre canónico cuando hay match de catálogo', () {
      expect(ReceiptMatcher.cleanName('LIMON 2KG'), 'Limón');
    });

    test('sin match: primer token significativo en title case', () {
      expect(
        ReceiptMatcher.cleanName('SODA COOPERATIVA SIFON 1750Cm'),
        'Soda',
      );
    });
  });

  group('looksLikeValidProduct (quality gate)', () {
    test('descarta promos con porcentaje', () {
      expect(ReceiptMatcher.looksLikeValidProduct('2do50%-MOLINOS'), isFalse);
    });

    test('descarta códigos internos con guión', () {
      expect(ReceiptMatcher.looksLikeValidProduct('ARCOR-GOLOS1'), isFalse);
    });

    test('descarta metadata del ticket (total, iva, descuento)', () {
      expect(ReceiptMatcher.looksLikeValidProduct('TOTAL 12.500,00'), isFalse);
      expect(ReceiptMatcher.looksLikeValidProduct('DESCUENTO LECHE'), isFalse);
      expect(ReceiptMatcher.looksLikeValidProduct('IVA 21%'), isFalse);
    });

    test('descarta líneas que empiezan con símbolo o dígito', () {
      expect(ReceiptMatcher.looksLikeValidProduct('-arcor-golos1'), isFalse);
      expect(ReceiptMatcher.looksLikeValidProduct('123 ABC'), isFalse);
    });

    test('acepta productos reales con ruido de tamaño', () {
      expect(
        ReceiptMatcher.looksLikeValidProduct('SODA COOPERATIVA SIFON 1750Cm'),
        isTrue,
      );
      expect(ReceiptMatcher.looksLikeValidProduct('PAN LACTAL'), isTrue);
    });

    // Casos extraídos del panel de OCR insights: productos reales que el gate
    // descartaba (dropped) por reglas demasiado amplias.
    test('acepta productos con "0%" nutricional (no es descuento)', () {
      expect(
        ReceiptMatcher.looksLikeValidProduct('LECHE LV TREGAR 0% LAC 1Lts'),
        isTrue,
      );
    });

    test('acepta productos en "caja" (formato, no metadata)', () {
      expect(
        ReceiptMatcher.looksLikeValidProduct(
          'CAPSULAS CAFE BRASIL MORENITA CAJA X 10',
        ),
        isTrue,
      );
    });

    test('sigue descartando promos "2do al 50%" (empiezan con dígito)', () {
      expect(
        ReceiptMatcher.looksLikeValidProduct('2DO AL 50% BIBA HY'),
        isFalse,
      );
    });

    test('sigue descartando líneas de descuento con %', () {
      expect(
        ReceiptMatcher.looksLikeValidProduct('DESCUENTO % LIMPIEZA 1Uni'),
        isFalse,
      );
    });
  });

  group('match (OCR ↔ lista pendiente, flujo legado)', () {
    test('matchea variantes por prefijo (yogurt ↔ yogur)', () {
      final result = ReceiptMatcher.match(
        ocrItems: ['YOGURT DESCREMADO 190G'],
        pendingShoppingItems: [pendingItem('1', 'Yogur')],
      );
      expect(result.matched, hasLength(1));
      expect(result.matched.first.id, '1');
    });

    test('sin coincidencia queda en unmatched', () {
      final result = ReceiptMatcher.match(
        ocrItems: ['LAVANDINA AYUDIN 1L'],
        pendingShoppingItems: [pendingItem('1', 'Tomate')],
      );
      expect(result.matched, isEmpty);
      expect(result.unmatched, ['LAVANDINA AYUDIN 1L']);
    });
  });

  group('resolveScanItems', () {
    test('item pendiente detectado en el ticket → toMarkPurchased', () {
      final terma = pendingItem('1', 'Terma');
      final result = resolveScanItems(
        ocrItems: ['APERITIVO TERMA SERR C 1350Cm3'],
        pendingShoppingItems: [terma],
        householdId: 'h1',
      );
      expect(result.toMarkPurchased.map((i) => i.id), ['1']);
      expect(result.toAddAndMark, isEmpty);
    });

    test('item de catálogo no pendiente → toAddAndMark con nombre canónico',
        () {
      final result = resolveScanItems(
        ocrItems: ['LIMON 2KG'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.toAddAndMark.map((i) => i.name), ['Limón']);
    });

    test('dedupe por nombre canónico: dos líneas → una sola sugerencia', () {
      // "POROTOS NEGROS..." y "POROTO SECO..." resuelven ambos a "Porotos".
      final result = resolveScanItems(
        ocrItems: ['POROTOS NEGROS 500G', 'POROTO SECO ALUBIA 500G'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(
        result.toAddAndMark.where((i) => i.name == 'Porotos'),
        hasLength(1),
      );
    });

    test('queso específico resuelve al genérico Queso del catálogo', () {
      // Historia: "queso" fue genérico ambiguo (caía en dropped), después
      // pasó a unrecognized, y ahora "Queso" está en el catálogo → los
      // quesos específicos del ticket se ofrecen como "Queso" directamente.
      final result = resolveScanItems(
        ocrItems: ['QUESO PORT SALUT LA SERENISIMA SIN LACTO'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.dropped, isEmpty);
      expect(result.unrecognized, isEmpty);
      expect(result.toAddAndMark.map((i) => i.name), ['Queso']);
    });

    test('abreviatura QSO BARRA resuelve a Queso (14x en logs reales)', () {
      final result = resolveScanItems(
        ocrItems: ['QSO BARRA L3N FET FFL 200Grs'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.toAddAndMark.map((i) => i.name), ['Queso']);
    });

    test('leche 0% lactosa se detecta como Leche (no se dropea)', () {
      final result = resolveScanItems(
        ocrItems: ['LECHE LV TREGAR 0% LAC 1Lts'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.dropped, isEmpty);
      expect(result.toAddAndMark.map((i) => i.name), contains('Leche'));
    });

    test('genérico ambiguo sin qualifier se descarta (jabón)', () {
      // "JABON LIQUIDO REP KARITE" no matchea Jabón ropa/tocador; ofrecer
      // "Jabón" a secas sería un duplicado ambiguo.
      final result = resolveScanItems(
        ocrItems: ['JABON LIQUIDO REP KARITE'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.toMarkPurchased, isEmpty);
      expect(result.toAddAndMark, isEmpty);
      expect(result.unrecognized, isEmpty);
      expect(result.dropped, ['JABON LIQUIDO REP KARITE']);
    });

    test('ruido del ticket cae en dropped, no en unrecognized', () {
      final result = resolveScanItems(
        ocrItems: ['TOTAL 12.500,00', '2do50%-MOLINOS'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.dropped, hasLength(2));
      expect(result.unrecognized, isEmpty);
      expect(result.allLinked, isEmpty);
    });

    test('producto genuino fuera de catálogo → unrecognized', () {
      final result = resolveScanItems(
        ocrItems: ['CHICLE BELDENT MENTA'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.unrecognized, ['CHICLE BELDENT MENTA']);
    });

    test('dedupe de unrecognized por nombre de display', () {
      // Ambos se mostrarían como "Chicle" en el banner → una sola sugerencia.
      final result = resolveScanItems(
        ocrItems: ['CHICLE BELDENT MENTA', 'CHICLE TOP LINE MENTA'],
        pendingShoppingItems: const [],
        householdId: 'h1',
      );
      expect(result.unrecognized, hasLength(1));
    });
  });
}
