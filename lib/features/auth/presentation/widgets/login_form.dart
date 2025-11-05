import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/blocs/login/login_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) {
        return previous.email != current.email ||
            previous.password != current.password ||
            previous.emailError != current.emailError ||
            previous.passwordError != current.passwordError ||
            previous.status != current.status ||
            previous.isLoginMode != current.isLoginMode;
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: state.email,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    helperText: state.emailError == null ? ' ' : null,
                    errorText: state.emailError,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (email) {
                    context.read<LoginBloc>().add(EmailChanged(email: email));
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue:
                      state.password,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
                    prefixIcon: const Icon(Icons.lock),
                    helperText: state.passwordError == null ? ' ' : null,
                    errorText: state.passwordError,
                  ),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                  onChanged: (password) {
                    context.read<LoginBloc>().add(
                      PasswordChanged(password: password),
                    );
                  },
                ),
                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed:
                      state.status == LoginStatus.loading || !state.isFormValid
                      ? null
                      : () {
                          if (state.isLoginMode) {
                            context.read<LoginBloc>().add(
                              LoginSubmitted(
                                email: state.email,
                                password: state.password,
                              ),
                            );
                          } else {
                            context.read<LoginBloc>().add(
                              SignupSubmitted(
                                email: state.email,
                                password: state.password,
                              ),
                            );
                          }
                        },
                  child: state.status == LoginStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(state.isLoginMode ? 'Войти' : 'Регистрация'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    context.read<LoginBloc>().add(const ToggleAuthMode());
                  },
                  child: Text(
                    state.isLoginMode
                        ? 'Нет аккаунта? Зарегистрироваться'
                        : 'Уже есть аккаунт? Войти',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
