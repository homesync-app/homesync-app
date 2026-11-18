import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homesync_client/core/utils/premium_avatar_assets.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

const _names = {
  'key_bird': 'Pajarito',
  'keys_girl': 'Llaves',
  'market_dog': 'Perrito',
  'mate_boy': 'Matecito',
  'orange_cat': 'Gatito',
  'paper_plane_kid': 'Aventurero',
  'star_girl': 'Estrella',
  'tool_adult_man': 'Manos a casa',
};

void main() {
  setUpAll(() async {
    final loader = FontLoader('Outfit');
    loader.addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/outfit/Outfit-Regular.ttf').readAsBytesSync(),
        ),
      ),
    );
    await loader.load();
  });
  test('art covers the premium avatar catalog', () {
    expect(
      PremiumAvatarArt.ids.map((id) => 'premium_$id').toSet(),
      UserAvatar.premiumAvatars.map((avatar) => avatar['id']).toSet(),
    );
    expect(
      PremiumAvatarArt.portraitFor(' premium://premium_orange_cat '),
      PremiumAvatarArt.portraitFor(
        'assets/images/premium_3d_avatars/premium_orange_cat.webp',
      ),
    );
  });

  for (final dark in [false, true]) {
    testWidgets('all avatar artwork renders ${dark ? 'dark' : 'light'}',
        (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1260, 1200);
      addTearDown(tester.view.reset);
      final pairs = [
        for (var a = 0; a < PremiumAvatarArt.ids.length; a++)
          for (var b = a; b < PremiumAvatarArt.ids.length; b++)
            (PremiumAvatarArt.ids[a], PremiumAvatarArt.ids[b]),
      ];
      final shot = GlobalKey();
      final textColor =
          dark ? const Color(0xFFF6ECE5) : const Color(0xFF4A4443);
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(fontFamily: 'Outfit'),
          home: RepaintBoundary(
            key: shot,
            child: Scaffold(
              backgroundColor:
                  dark ? const Color(0xFF26211F) : const Color(0xFFFFFCF9),
              body: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (final id in PremiumAvatarArt.ids)
                          Expanded(
                            child: Column(
                              children: [
                                Image.asset(
                                  PremiumAvatarArt.portraitFor(
                                    'premium://premium_$id',
                                  )!,
                                  width: 64,
                                  height: 64,
                                  cacheWidth: 192,
                                ),
                                Text(
                                  _names[id]!,
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 6,
                        childAspectRatio: 1.18,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          for (final pair in pairs)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  PremiumAvatarArt.duoFor(
                                    'premium://premium_${pair.$1}',
                                    'premium://premium_${pair.$2}',
                                  )!,
                                  width: 160,
                                  height: 115,
                                  cacheWidth: 480,
                                ),
                                Text(
                                  '${_names[pair.$1]} + ${_names[pair.$2]}',
                                  textAlign: TextAlign.center,
                                  style:
                                      TextStyle(fontSize: 12, color: textColor),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.runAsync(() async {
        for (final element in find.byType(Image).evaluate()) {
          await precacheImage((element.widget as Image).image, element);
        }
      });
      await tester.pump();
      expect(find.byType(Image), findsNWidgets(44));
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('CAPTURE_HOME')) {
        await tester.runAsync(() async {
          final boundary =
              shot.currentContext!.findRenderObject()! as RenderRepaintBoundary;
          final image = await boundary.toImage();
          final data = await image.toByteData(format: ui.ImageByteFormat.png);
          File(
            'build/couple_home/avatar_catalog_${dark ? 'dark' : 'light'}.png',
          )
            ..createSync(recursive: true)
            ..writeAsBytesSync(data!.buffer.asUint8List());
          image.dispose();
        });
      }
      await tester.pumpWidget(const SizedBox());
    });
  }
}
