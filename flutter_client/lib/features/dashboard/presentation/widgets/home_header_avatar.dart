import 'package:flutter/material.dart';
import 'package:homesync_client/l10n/generated/app_localizations.dart';
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
  final double premiumWidth;
  final double premiumHeight;
  final double premiumMaxWidth;
  final double premiumMaxHeight;

  /// Read by screen readers. Defaults to the Settings title because in every
  /// home the header avatar opens Settings.
  final String? semanticLabel;

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
    this.premiumWidth = 110,
    this.premiumHeight = 102,
    this.premiumMaxWidth = 150,
    this.premiumMaxHeight = 150,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    // Sticker = premium:// o avatar IA generado: mismo render grande.
    final isPremiumCharacter = UserAvatar.isPremiumAvatarValue(avatarUrl);
    final child = isPremiumCharacter
        ? _buildPremiumAvatar()
        : _buildRegularAvatar(context);

    return AnimatedPress(
      onTap: onTap,
      // The avatar's own initials or image add nothing to the label.
      semanticLabel:
          semanticLabel ?? AppLocalizations.of(context).settingsAppBarTitle,
      excludeChildSemantics: true,
      child: child,
    );
  }

  Widget _buildPremiumAvatar() {
    return Transform.translate(
      offset: premiumOffset,
      child: SizedBox(
        width: premiumWidth,
        height: premiumHeight,
        child: OverflowBox(
          alignment: Alignment.centerRight,
          maxWidth: premiumMaxWidth,
          maxHeight: premiumMaxHeight,
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
