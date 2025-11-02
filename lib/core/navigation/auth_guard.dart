import 'package:flutter/material.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';

class AuthGuard {
  bool checkAuth(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();
    final currentState = authBloc.state;

    if (currentState.status != AuthStatus.authenticated) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      return false;
    }

    return true;
  }
}
