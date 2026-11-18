import 'package:flutter/material.dart';
import 'package:homesync_client/shared/widgets/user_avatar.dart';

export 'package:homesync_client/core/utils/premium_avatar_assets.dart';

/// A portrait drawn for this circle, never an enlarged crop of a full sticker.
class MemberPortrait extends StatelessWidget {
  final String? name;
  final String? avatarUrl;
  final double size;

  const MemberPortrait({
    super.key,
    this.name,
    this.avatarUrl,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return CustomUserAvatar(
      name: name,
      avatarUrl: avatarUrl,
      radius: size / 2,
      forceCircular: true,
      allowMotion: false,
    );
  }
}
