import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_design_tokens.dart';

class AppSnappyPagePhysics extends PageScrollPhysics {
  const AppSnappyPagePhysics({super.parent});

  @override
  SpringDescription get spring => AppMotion.snappyPageSpring;

  @override
  AppSnappyPagePhysics applyTo(ScrollPhysics? ancestor) {
    return AppSnappyPagePhysics(parent: buildParent(ancestor));
  }
}
