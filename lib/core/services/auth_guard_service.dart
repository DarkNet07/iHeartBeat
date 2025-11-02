import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';

class AuthGuardService {
  static bool canAccess(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();
    final state = authBloc.state;
    return state.status == AuthStatus.authenticated;
  }

  static Future<void> checkAndRedirect(
    BuildContext context, {
    required String redirectRoute,
  }) async {
    final authBloc = di.sl<AuthBloc>();
    final state = authBloc.state;

    if (state.status != AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        redirectRoute,
        (route) => false,
      );
      return;
    }
  }

  static Widget guardRoute({required Widget child, bool requireAuth = false}) {
    return Builder(
      builder: (context) {
        return BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (requireAuth && state.status != AuthStatus.authenticated) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            }
          },
          child: child,
        );
      },
    );
  }
}
