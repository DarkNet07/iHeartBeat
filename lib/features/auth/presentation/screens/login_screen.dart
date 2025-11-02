import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:iheartbeat/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginBloc(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state.status == AuthStatus.success) {
                Navigator.pushReplacementNamed(context, '/home');
              } else if (state.status == AuthStatus.error &&
                  state.globalError != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.globalError!),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'iHeartBeat',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Мониторинг здоровья и фитнеса',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    LoginForm(),
                    const SizedBox(height: 32),
                    Center(
                      child: Text(
                        '© 2025 iHeartBeat',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
