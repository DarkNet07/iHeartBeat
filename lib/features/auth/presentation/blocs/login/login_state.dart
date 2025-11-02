part of 'login_bloc.dart';

enum AuthStatus { initial, loading, success, error, valid, invalid }

class LoginState extends Equatable {
  const LoginState({
    this.status = AuthStatus.initial,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.globalError,
    this.isLoginMode = true,
  });

  final AuthStatus status;
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? globalError;
  final bool isLoginMode;

  bool get isFormValid => emailError == null && passwordError == null;

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    emailError,
    passwordError,
    globalError,
    isLoginMode,
    isFormValid,
  ];

  LoginState copyWith({
    AuthStatus? status,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
    bool? isLoginMode,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      globalError: globalError ?? this.globalError,
      isLoginMode: isLoginMode ?? this.isLoginMode,
    );
  }
}
