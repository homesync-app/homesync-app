import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

/// Una de las dos personas de la pareja, ya resuelta para mostrar.
class CouplePerson {
  final String userId;
  final String label;
  final String? avatarName;
  final String? avatarUrl;

  const CouplePerson({
    required this.userId,
    required this.label,
    required this.avatarName,
    required this.avatarUrl,
  });
}

/// Avatar chico y circular de una persona de la pareja, para chips y notas.
class CouplePersonAvatar extends StatelessWidget {
  final CouplePerson person;
  final double radius;

  const CouplePersonAvatar({
    super.key,
    required this.person,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomUserAvatar(
        name: person.avatarName,
        userId: person.userId,
        avatarUrl: person.avatarUrl,
        radius: radius,
        forceCircular: true,
      ),
    );
  }
}

/// Quiet stationery surfaces for the couple tab. Deliberately flat so the
/// pastel fills and personal avatars carry the hierarchy, without stacked ledges.
class CoupleSurface extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double radius;
  final VoidCallback? onTap;

  const CoupleSurface({
    super.key,
    required this.child,
    this.color,
    this.borderColor,
    this.padding = AppInsets.card,
    this.radius = AppRadii.xl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? theme.surface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? theme.border),
      ),
      child: child,
    );
    return onTap == null
        ? content
        : AnimatedPress(onTap: onTap, child: content);
  }
}
