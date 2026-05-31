import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/concept_icons.dart';

/// Muestra el icono ilustrado de un concepto (premio, duelo, logro, meta) a
/// partir del emoji que ya tiene guardado el modelo. Si existe PNG remoto para
/// ese emoji, lo muestra (cacheado); si no, cae al emoji del sistema.
///
/// No necesita rectángulo de fondo: el PNG es transparente y se dibuja directo.
class ConceptIcon extends ConsumerWidget {
  const ConceptIcon({
    super.key,
    required this.emoji,
    this.size = 40,
  });

  /// El emoji crudo guardado en el modelo (ej. reward.icon, goal.icon).
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = ConceptIcons.keyForEmoji(emoji);
    final fallback = _EmojiFallback(emoji: emoji, size: size);

    if (key == null) return fallback;

    final manifest = ref.watch(conceptIconManifestProvider);
    final version = manifest[key];
    if (version == null) return fallback;

    return CachedNetworkImage(
      imageUrl: ConceptIcons.urlFor(key, version),
      width: size,
      height: size,
      fit: BoxFit.contain,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => fallback,
      errorWidget: (_, __, ___) => fallback,
    );
  }
}

class _EmojiFallback extends StatelessWidget {
  const _EmojiFallback({required this.emoji, required this.size});

  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.82),
        ),
      ),
    );
  }
}
