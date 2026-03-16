import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumNotifier extends Notifier<bool> {
  static const _premiumKey = 'is_premium_simulated';

  @override
  bool build() {
    // Inicialmente cargamos falso, pero luego disparamos la carga persistente
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> togglePremium() async {
    final prefs = await SharedPreferences.getInstance();
    final newState = !state;
    await prefs.setBool(_premiumKey, newState);
    state = newState;
  }

  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    state = value;
  }
}

final premiumProvider = NotifierProvider<PremiumNotifier, bool>(() {
  return PremiumNotifier();
});
