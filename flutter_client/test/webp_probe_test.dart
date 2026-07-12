import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

// Sonda temporal: decodifica los WebP animados igual que
// PremiumAnimatedAvatar (ui.instantiateImageCodec) y reporta frameCount y
// duraciones reales para diagnosticar animaciones que quedan "trabadas".
void main() {
  test('probe animated webp frame counts', () async {
    const dir = 'assets/images/premium_3d_avatars/animated';
    final files = Directory(dir)
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.webp'))
        .toList();
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      var totalMs = 0;
      for (var i = 0; i < codec.frameCount; i++) {
        final info = await codec.getNextFrame();
        totalMs += info.duration.inMilliseconds;
        info.image.dispose();
      }
      // ignore: avoid_print
      print(
        '${file.path.split(Platform.pathSeparator).last}: '
        'frames=${codec.frameCount} total=${totalMs}ms '
        'repeat=${codec.repetitionCount}',
      );
      codec.dispose();
    }
  });
}
