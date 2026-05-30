import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Remote image with a soft cross-fade once it lands, backed by disk + memory
/// caching via [cached_network_image].
///
/// Inspired by "Load images smoothly" (flutterpro.design): images should never
/// pop in hard. They fade. Crucially we keep the on-disk cache so a second cold
/// start shows avatars/tickets instantly instead of re-downloading them.
///
/// The public API mirrors a plain [Image.network] so existing call sites
/// (avatars, receipt previews, premium characters) don't need to change.
class AppSmoothNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final int? cacheWidth;
  final int? cacheHeight;
  final FilterQuality filterQuality;
  final Duration fadeDuration;
  final WidgetBuilder? placeholderBuilder;
  final ImageErrorWidgetBuilder? errorBuilder;

  const AppSmoothNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit,
    this.alignment = Alignment.center,
    this.cacheWidth,
    this.cacheHeight,
    this.filterQuality = FilterQuality.medium,
    this.fadeDuration = const Duration(milliseconds: 180),
    this.placeholderBuilder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment is Alignment
          ? alignment as Alignment
          : Alignment.center,
      filterQuality: filterQuality,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      fadeInDuration: fadeDuration,
      fadeOutDuration: fadeDuration,
      fadeInCurve: Curves.easeOutCubic,
      fadeOutCurve: Curves.easeInCubic,
      placeholder: placeholderBuilder == null
          ? null
          : (context, _) => placeholderBuilder!(context),
      errorWidget: (context, _, error) {
        return errorBuilder?.call(context, error, null) ??
            placeholderBuilder?.call(context) ??
            const SizedBox.shrink();
      },
    );
  }
}
