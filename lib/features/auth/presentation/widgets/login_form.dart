import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/presentation/blocs/login/login_bloc.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
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
                      state.status == AuthStatus.loading || !state.isFormValid
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
                  child: state.status == AuthStatus.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(state.isLoginMode ? 'Войти' : 'Регистрация',),
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
