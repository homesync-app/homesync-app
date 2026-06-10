import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';

void main() {
  final webp = File(
    '../tools/avatar_animation/dist/premium_orange_cat.webp',
  ).absolute;

  testWidgets('reproduce frames desde archivo local descargado',
      (tester) async {
    expect(webp.existsSync(), isTrue, reason: 'falta el webp de prueba');

    // Montar y dejar cargar DENTRO de runAsync: la carga del codec es IO
    // real y no completa dentro de la zona fake-async del tester.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          home: PremiumAnimatedAvatar(
            motionAssets: {AvatarMotion.idle: webp.path},
            fallbackAsset: 'assets/images/premium_3d_avatars/no_existe.png',
            size: 120,
          ),
        ),
      );
    });

    // Nota: Image.asset (fallback) tambien crea un RawImage interno,
    // asi que contamos solo los RawImage con frame decodificado real.
    Iterable<RawImage> framesOnScreen() => tester
        .widgetList<RawImage>(find.byType(RawImage))
        .where((w) => w.image != null);

    // Al inicio no hay frame decodificado: se ve el fallback.
    expect(framesOnScreen(), isEmpty);

    // Dejar correr la carga real del codec (IO + decode async).
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 800)),
    );
    await tester.pump();

    expect(
      framesOnScreen().length,
      1,
      reason: 'el primer frame del webp deberia estar en pantalla',
    );

    // Avanzar y verificar que el frame CAMBIA (la animacion corre).
    final firstImage = framesOnScreen().single.image;
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await tester.pump(const Duration(milliseconds: 400));
    final laterImage = framesOnScreen().single.image;
    expect(
      identical(firstImage, laterImage),
      isFalse,
      reason: 'la animacion deberia avanzar de frame',
    );

    // Desmontar para cancelar timers pendientes (respiro de 10s).
    await tester.pumpWidget(const SizedBox());
  });
}
