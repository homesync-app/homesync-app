import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_colors.dart';

class ShimmerLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Widget? child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.margin,
    this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading && widget.child != null) return widget.child!;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final sweep = (_animation.value * 2.4) - 1.2;
        final shimmer = Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1 + sweep, -0.7),
              end: Alignment(0.8 + sweep, 0.7),
              colors: [
                AppColors.surfaceVariant.withValues(alpha: 0.1),
                AppColors.surfaceVariant.withValues(alpha: 0.3),
                AppColors.surfaceVariant.withValues(alpha: 0.1),
              ],
              stops: const [0.18, 0.5, 0.82],
            ),
          ),
          child: widget.child != null
              ? Opacity(opacity: 0.2, child: widget.child)
              : null,
        );
        return shimmer;
      },
    );
  }
}
