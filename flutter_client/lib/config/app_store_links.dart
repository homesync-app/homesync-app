/// Links públicos de la app en las tiendas.
///
/// La invitación por WhatsApp los necesita: sin link, quien la recibe no sabe
/// de dónde bajar la app y el loop de invitación se corta ahí.
class AppStoreLinks {
  AppStoreLinks._();

  static const String androidPackage = 'com.blas.homesync';

  static const String _playStoreBase =
      'https://play.google.com/store/apps/details?id=$androidPackage';

  /// Ficha de Play Store. Con [inviteCode], el código viaja en el parámetro
  /// `referrer`: Play lo atribuye como tráfico de invitación en la consola, y
  /// deja la puerta abierta para leerlo con Install Referrer y precargarlo.
  static String playStore({String? inviteCode}) {
    if (inviteCode == null || inviteCode.isEmpty) return _playStoreBase;
    final referrer = Uri.encodeComponent(
      'utm_source=invite&utm_medium=share&utm_content=$inviteCode',
    );
    return '$_playStoreBase&referrer=$referrer';
  }
}
