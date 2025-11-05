part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, error, valid, invalid }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.initial,
    this.email = '',
    this.password = '',
    this.emailError,
    this.passwordError,
    this.globalError,
    this.isLoginMode = true,
    this.token,
  });

  final LoginStatus status;
  final String email;
  final String password;
  final String? emailError;
  final String? passwordError;
  final String? globalError;
  final bool isLoginMode;
  final String? token;

  bool get isFormValid =>
      email.isNotEmpty &&
      password.isNotEmpty &&
      emailError == null &&
      passwordError == null;

  @override
  List<Object?> get props => [
    status,
    email,
    password,
    emailError,
    passwordError,
    globalError,
    isLoginMode,
    token,
  ];

  LoginState copyWith({
    LoginStatus? status,
    String? email,
    String? password,
    String? emailError,
    String? passwordError,
    String? globalError,
    bool? isLoginMode,
    String? token,
  }) {
    return LoginState(
      status: status ?? this.status,
      email: email ?? this.email,
      password: password ?? this.password,
      emailError: emailError,
      passwordError: passwordError,
      globalError: globalError ?? this.globalError,
      isLoginMode: isLoginMode ?? this.isLoginMode,
      token: token ?? this.token,
    );
  }
}
