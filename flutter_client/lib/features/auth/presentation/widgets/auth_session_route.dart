import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/providers/auth_session_providers.dart';

/// A named login route must also react to session readiness. On the web it
/// can be restored above the home route after the sign-in event has occurred.
class AuthSessionRoute extends ConsumerWidget {
  const AuthSessionRoute({
    super.key,
    required this.authenticatedBuilder,
    required this.signedOutBuilder,
    required this.loadingBuilder,
  });

  final WidgetBuilder authenticatedBuilder;
  final WidgetBuilder signedOutBuilder;
  final WidgetBuilder loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(authStateProvider).when(
          data: (session) => session.isAuthenticated
              ? authenticatedBuilder(context)
              : signedOutBuilder(context),
          loading: () => loadingBuilder(context),
          error: (_, __) => signedOutBuilder(context),
        );
  }
}
