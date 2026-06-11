import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/animated_press.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

class HomeHeaderAvatar extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final PremiumAvatarMotionController? motionController;
  final AvatarMotion ambientMotion;
  final String? heroTag;
  final double premiumRadius;
  final double regularRadius;
  final Offset premiumOffset;
  final Offset regularOffset;

  const HomeHeaderAvatar({
    super.key,
    this.name,
    this.avatarUrl,
    this.onTap,
    this.motionController,
    this.ambientMotion = AvatarMotion.idle,
    this.heroTag = 'user_avatar_main',
    this.premiumRadius = 38,
    this.regularRadius = 29,
    this.premiumOffset = const Offset(6, -6),
    this.regularOffset = const Offset(0, -18),
  });

  @override
  Widget build(BuildContext context) {
    final isPremiumCharacter =
        UserAvatar.isPremiumCharacterAvatarValue(avatarUrl);
    final child = isPremiumCharacter
        ? _buildPremiumAvatar()
        : _buildRegularAvatar(context);

    return AnimatedPress(
      onTap: onTap,
      child: child,
    );
  }

  Widget _buildPremiumAvatar() {
    return Transform.translate(
      offset: premiumOffset,
      child: SizedBox(
        width: 110,
        height: 102,
        child: OverflowBox(
          alignment: Alignment.centerRight,
          maxWidth: 150,
          maxHeight: 150,
          child: CustomUserAvatar(
            name: name,
            avatarUrl: avatarUrl,
            radius: premiumRadius,
            isAnimated: true,
            ambientMotion: ambientMotion,
            motionController: motionController,
          ),
        ),
      ),
    );
  }

  Widget _buildRegularAvatar(BuildContext context) {
    Widget avatar = CustomUserAvatar(
      name: name,
      avatarUrl: avatarUrl,
      radius: regularRadius,
      showBorder: true,
      forceCircular: true,
      allowMotion: false,
    );

    if (heroTag != null) {
      avatar = Hero(
        tag: heroTag!,
        child: avatar,
      );
    }

    return Transform.translate(
      offset: regularOffset,
      child: avatar,
    );
  }
}
