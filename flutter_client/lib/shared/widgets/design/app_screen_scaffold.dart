import 'package:flutter/material.dart';
import 'package:homesync_client/core/theme/app_theme_extension.dart';
import 'package:homesync_client/core/widgets/app_background.dart';

class AppScreenScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool showBackground;
  final bool resizeToAvoidBottomInset;

  const AppScreenScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showBackground = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: appBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: showBackground
          ? Stack(
              children: [
                Positioned.fill(
                  child: AppBackground(isDarkMode: theme.isDarkMode),
                ),
                body,
              ],
            )
          : body,
    );
  }
}
