import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/shared/widgets/premium_animated_avatar.dart';

void main() {
  // El gato va empaquetado en el APK: este es el asset real de produccion.
  const webpAsset =
      'assets/images/premium_3d_avatars/animated/premium_orange_cat.webp';

  testWidgets('reproduce frames del webp empaquetado (asset)', (tester) async {
    // Montar y dejar cargar DENTRO de runAsync: la carga del codec es IO
    // real y no completa dentro de la zona fake-async del tester.
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PremiumAnimatedAvatar(
            motionAssets: {AvatarMotion.idle: webpAsset},
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

  testWidgets('clip con headroom desborda hacia arriba sin mover al avatar',
      (tester) async {
    // El tada trae aire arriba para el salto (frame > 480px): antes el
    // recorte cuadrado le cortaba las orejas.
    const tadaAsset =
        'assets/images/premium_3d_avatars/animated/premium_orange_cat_tada.webp';
    const avatarKey = Key('avatar');
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: PremiumAnimatedAvatar(
              key: avatarKey,
              motionAssets: {AvatarMotion.tada: tadaAsset},
              ambientMotion: AvatarMotion.tada,
              fallbackAsset: 'assets/images/premium_3d_avatars/no_existe.png',
              size: 120,
            ),
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 800));
    });
    await tester.pump();

    final frame = find.byWidgetPredicate(
      (w) => w is RawImage && w.image != null,
    );
    expect(frame, findsOneWidget);
    final image = tester.widget<RawImage>(frame).image!;
    expect(image.width, greaterThan(kAnimatedAvatarBaseFramePx));

    // La caja del avatar no cambia; el frame se pinta mas grande y anclado
    // abajo al centro, asi que el excedente queda arriba.
    final box = tester.getRect(find.byKey(avatarKey));
    final painted = tester.getRect(frame);
    expect(box.size, const Size(120, 120));
    final headroom = image.width / kAnimatedAvatarBaseFramePx;
    expect(painted.width, closeTo(120 * headroom, 0.01));
    expect(painted.bottom, closeTo(box.bottom, 0.01));
    expect(painted.center.dx, closeTo(box.center.dx, 0.01));
    expect(painted.top, lessThan(box.top));

    await tester.pumpWidget(const SizedBox());
  });
}
