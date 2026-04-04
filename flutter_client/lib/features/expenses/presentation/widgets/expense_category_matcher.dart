class ExpenseCategoryMatchResult {
  final bool isIncome;
  final Map<String, dynamic>? selectedCategory;

  const ExpenseCategoryMatchResult({
    required this.isIncome,
    required this.selectedCategory,
  });
}

ExpenseCategoryMatchResult resolveExpenseCategoryMatch({
  required String title,
  String? description,
  required bool isIncome,
  required List<Map<String, dynamic>> expenseCategories,
  required List<Map<String, dynamic>> incomeCategories,
  required Map<String, dynamic>? selectedCategory,
}) {
  final normalizedTitle = title.toLowerCase().trim();
  final normalizedDescription = description?.toLowerCase().trim() ?? '';
  final content = '$normalizedTitle $normalizedDescription'.trim();

  final matchedId = _matchCategoryId(content);
  if (matchedId == null) {
    return ExpenseCategoryMatchResult(
      isIncome: isIncome,
      selectedCategory: selectedCategory,
    );
  }

  final isIncomeMatch =
      incomeCategories.any((category) => category['id'] == matchedId);
  final isExpenseMatch =
      expenseCategories.any((category) => category['id'] == matchedId);

  if (isIncomeMatch && !isIncome) {
    return ExpenseCategoryMatchResult(
      isIncome: true,
      selectedCategory: incomeCategories.firstWhere(
        (category) => category['id'] == matchedId,
      ),
    );
  }

  if (isExpenseMatch && isIncome) {
    return ExpenseCategoryMatchResult(
      isIncome: false,
      selectedCategory: expenseCategories.firstWhere(
        (category) => category['id'] == matchedId,
      ),
    );
  }

  if (selectedCategory?['id'] == matchedId) {
    return ExpenseCategoryMatchResult(
      isIncome: isIncome,
      selectedCategory: selectedCategory,
    );
  }

  final currentCategories = isIncome ? incomeCategories : expenseCategories;
  return ExpenseCategoryMatchResult(
    isIncome: isIncome,
    selectedCategory: currentCategories.firstWhere(
      (category) => category['id'] == matchedId,
      orElse: () => currentCategories.first,
    ),
  );
}

String? inferExpenseCategoryIdFromText(String text) {
  return _matchCategoryId(text.toLowerCase().trim());
}

String? _matchCategoryId(String content) {
  if (content.isEmpty) return null;

  if (_containsAny(content, const [
    'sueldo',
    'nomina',
    'nómina',
    'salario',
    'cobro',
    'haberes',
  ])) {
    return 'salary';
  }

  if (_containsAny(content, const [
    'freelance',
    'honorarios',
    'cliente',
    'servicio prestado',
    'transferencia cobrada',
  ])) {
    return 'freelance';
  }

  if (_containsAny(content, const [
    'venta',
    'vendi',
    'mercadopago',
    'mercado pago',
    'cobro qr',
  ])) {
    return 'ventas';
  }

  if (_containsAny(content, const [
    'regalo',
    'premio',
    'sorpresa',
    'obsequio',
  ])) {
    return 'gift';
  }

  if (_containsAny(content, const [
    'bono',
    'bonus',
    'comision',
    'comisión',
    'aguinaldo',
  ])) {
    return 'bonus';
  }

  if (_containsAny(content, const [
    'reembolso',
    'devolucion',
    'devolución',
    'refund',
  ])) {
    return 'reembolso';
  }

  if (_containsAny(content, const [
    'inversion',
    'inversión',
    'plazo fijo',
    'bitcoin',
    'crypto',
    'cripto',
    'usdt',
    'eth',
    'broker',
  ])) {
    return 'investment';
  }

  if (_containsAny(content, const [
    'liquidacion',
    'liquidación',
    'saldar',
    'deuda',
    'balance hogar',
    'ajuste hogar',
  ])) {
    return 'settlement';
  }

  if (_containsAny(content, const [
    'ahorro',
    'banco',
    'finanzas',
    'fci',
    'fondo comun',
    'fondo común',
  ])) {
    return 'finanzas';
  }

  if (_containsAny(content, const [
    'mercadolibre',
    'mercado libre',
    'amazon',
    'compra online',
    'pedido online',
    'tienda online',
  ])) {
    return 'mercadolibre';
  }

  if (_containsAny(content, const [
    'supermercado',
    'super',
    'coto',
    'carrefour',
    'jumbo',
    'disco',
    'vea',
    'dia',
    'despensa',
    'almacen',
    'almacén',
    'verduleria',
    'verdulería',
    'carniceria',
    'carnicería',
  ])) {
    return 'supermarket';
  }

  if (_containsAny(content, const [
    'luz',
    'agua',
    'gas',
    'internet',
    'wifi',
    'wi-fi',
    'servicio',
    'metrogas',
    'aysa',
    'edenor',
    'edesur',
    'telecentro',
    'fibra',
    'personal flow',
    'expensa de servicio',
  ])) {
    return 'utilities';
  }

  if (_containsAny(content, const [
    'alquiler',
    'expensas',
    'renta',
    'consorcio',
    'inmobiliaria',
    'cochera',
    'garage',
    'garaje',
  ])) {
    return 'rent';
  }

  if (_containsAny(content, const [
    'restaurante',
    'restaurant',
    'cena',
    'almuerzo',
    'desayuno',
    'brunch',
    'merienda',
    'salida',
    'bar',
    'cerveceria',
    'cervecería',
    'cafeteria',
    'cafetería',
    'pizza',
    'hamburguesa',
    'burger',
    'empanada',
    'sushi',
    'ramen',
    'helado',
    'postre',
    'cafe',
    'café',
    'pedidosya',
    'rappi',
    'delivery',
    'take away',
    'takeaway',
    'mcdonald',
    'burger king',
    'mostaza',
  ])) {
    return 'restaurants';
  }

  if (_containsAny(content, const [
    'transporte',
    'uber',
    'cabify',
    'nafta',
    'gasolina',
    'sube',
    'taxi',
    'colectivo',
    'subte',
    'tren',
    'peaje',
    'estacionamiento',
    'parking',
    'shell',
    'ypf',
    'axion',
  ])) {
    return 'transport';
  }

  if (_containsAny(content, const [
    'farmacia',
    'farmacity',
    'medico',
    'médico',
    'salud',
    'pastillas',
    'remedio',
    'medicamento',
    'consulta',
    'osde',
    'swiss medical',
    'prepaga',
    'obra social',
    'dentista',
  ])) {
    return 'health';
  }

  if (_containsAny(content, const [
    'cine',
    'teatro',
    'juego',
    'fiesta',
    'concierto',
    'show',
    'entrada',
    'steam',
    'playstation',
    'xbox',
    'nintendo',
    'spotify',
    'netflix',
    'disney',
    'hbo',
    'streaming',
  ])) {
    return 'entertainment';
  }

  return null;
}

bool _containsAny(String content, List<String> terms) {
  for (final term in terms) {
    if (_containsTerm(content, term)) {
      return true;
    }
  }
  return false;
}

bool _containsTerm(String content, String term) {
  final escapedTerm = RegExp.escape(term);
  final pattern = RegExp(
    '(^|[^a-z0-9áéíóúüñ])$escapedTerm([^a-z0-9áéíóúüñ]|\$)',
    caseSensitive: false,
  );
  return pattern.hasMatch(content);
}
