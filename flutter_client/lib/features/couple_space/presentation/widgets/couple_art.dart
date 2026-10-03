import 'package:flutter/material.dart';

enum CoupleArtKind {
  movies,
  cooking,
  picnic,
  coffee,
  walk,
  letter,
  wallet,
  home,
  medal
}

/// One original transparent atlas keeps the entire icon family consistent.
/// Each illustration occupies a cell in a 3 × 3 grid. No platform emoji.
class CoupleArt extends StatelessWidget {
  final CoupleArtKind kind;
  final double size;

  const CoupleArt({super.key, required this.kind, this.size = 72});

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: ClipRect(
            clipper:
                kind == CoupleArtKind.walk ? const _MapGutterClipper() : null,
            child: OverflowBox(
              minWidth: size * 3,
              maxWidth: size * 3,
              minHeight: size * 3,
              maxHeight: size * 3,
              alignment:
                  Alignment((kind.index % 3) - 1.0, (kind.index ~/ 3) - 1.0),
              child: Image.asset(
                'assets/images/couple_plan_icons.png',
                width: size * 3,
                height: size * 3,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
      );
}

// The map's left gutter shares a few pixels with the mug handle in the atlas.
// Clip only that transparent gutter, preserving the complete map illustration.
class _MapGutterClipper extends CustomClipper<Rect> {
  const _MapGutterClipper();

  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(size.width * 0.07, 0, size.width, size.height);

  @override
  bool shouldReclip(covariant _MapGutterClipper oldClipper) => false;
}
