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
    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(_controller);
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
        final shimmer = Container(
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surfaceVariant.withValues(alpha: 0.1),
                AppColors.surfaceVariant.withValues(alpha: 0.3),
                AppColors.surfaceVariant.withValues(alpha: 0.1),
              ],
              stops: [
                0.0,
                (_animation.value + 1) / 2,
                1.0,
              ],
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
