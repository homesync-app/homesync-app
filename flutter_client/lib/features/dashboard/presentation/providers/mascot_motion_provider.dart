import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';

/// Controller compartido de la mascota del home: cualquier widget puede
/// dispararle un movimiento de evento (ej. festejar al saldar una deuda).
final homeMascotMotionProvider =
    Provider<PremiumAvatarMotionController>((ref) {
  return PremiumAvatarMotionController();
});
