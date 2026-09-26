/// Ahorro del plan anual contra pagar 12 meses del mensual, en puntos
/// porcentuales enteros y redondeado hacia abajo (nunca promete de más).
///
/// Devuelve null si los precios no permiten compararlos o si el ahorro es
/// menor al 5%, que no vale la pena anunciar.
int? annualSavingsPercent({
  required double annualPrice,
  required double monthlyPrice,
}) {
  if (annualPrice <= 0 || monthlyPrice <= 0) return null;
  // El epsilon evita que un 20% exacto se lea 19,999… por error de flotante
  // y termine anunciado como 19%.
  final percent =
      ((1 - annualPrice / (monthlyPrice * 12)) * 100 + 1e-9).floor();
  if (percent < 5 || percent >= 100) return null;
  return percent;
}
