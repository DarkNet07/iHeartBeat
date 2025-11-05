import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/core/widgets/back_button_interceptor.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';
import 'package:iheartbeat/features/auth/blocs/login/login_bloc.dart';
import 'package:iheartbeat/features/auth/presentation/widgets/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Future<Map<String, bool>> _authSettingsFuture;

  @override
  void initState() {
    super.initState();
    _authSettingsFuture = _getAuthSettings();
  }

  Future<Map<String, bool>> _getAuthSettings() async {
    final authService = di.authService;
    final isBiometricEnabled = await authService.isBiometricEnabled();
    final hasPin = await authService.hasPin();

    final showSetupPrompt = !isBiometricEnabled && !hasPin;

    return {
      'isBiometricEnabled': isBiometricEnabled,
      'hasPin': hasPin,
      'showSetupPrompt': showSetupPrompt,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => di.sl<LoginBloc>(),
      child: Builder(
        builder: (context) {
          return FutureBuilder<Map<String, bool>>(
            future: _authSettingsFuture,
            builder: (context, snapshot) {
              return BlocListener<AuthBloc, AuthState>(
                listener: (context, authState) {
                  if (authState.status == AuthStatus.authenticated) {
                    final showSetupPrompt =
                        snapshot.data?['showSetupPrompt'] ?? true;
                    Navigator.pushReplacementNamed(
                      context,
                      '/home',
                      arguments: {'showSetupPrompt': showSetupPrompt},
                    );
                  }
                },
                child: Scaffold(
                  body: BlocConsumer<LoginBloc, LoginState>(
                    listener: (context, loginState) {
                      if (loginState.status == LoginStatus.success &&
                          loginState.token != null) {
                        final authBloc = context.read<AuthBloc>();
                        authBloc.add(LoggedIn(token: loginState.token!));
                      } else if (loginState.status == LoginStatus.error &&
                          loginState.globalError != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                                SnackBar(
                                  content: Text(loginState.globalError!),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 4),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      context.read<LoginBloc>().add(
                                        const ResetError(),
                                      );
                                    },
                                  ),
                                ),
                              )
                              .closed
                              .then((_) {
                                context.read<LoginBloc>().add(
                                  const ResetError(),
                                );
                              });
                        });
                      }
                    },
                    builder: (context, loginState) {
                      if (loginState.status == LoginStatus.loading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return BackButtonInterceptor(
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
                      );
                    },
                  ),
                ),
              );
            },
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
