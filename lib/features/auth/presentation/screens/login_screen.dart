import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/core/widgets/back_button_interceptor.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';
import 'package:iheartbeat/features/auth/blocs/login/login_bloc.dart';
import 'package:iheartbeat/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => di.sl<LoginBloc>(),
      child: Builder(
        builder: (context) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, authState) {
              if (authState.status == AuthStatus.authenticated) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (authState.status == AuthStatus.unauthenticated) {
              }
            },
            child: Scaffold(
              body: BlocListener<LoginBloc, LoginState>(
                listener: (context, loginState) {
                  if (loginState.status == LoginStatus.success &&
                      loginState.token != null) {
                    final authBloc = context.read<AuthBloc>();
                    authBloc.add(LoggedIn(token: loginState.token!));
                  } else if (loginState.status == LoginStatus.error &&
                      loginState.globalError != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(loginState.globalError!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: BackButtonInterceptor(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: const [
                        _Header(),
                        SizedBox(height: 32),
                        LoginForm(),
                        SizedBox(height: 32),
                        _Footer(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite_rounded, size: 80, color: primaryColor),
        const SizedBox(height: 16),
        const Text(
          'iHeartBeat',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Мониторинг здоровья и фитнеса',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© 2025 iHeartBeat',
        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
      ),
    );
  }
}
