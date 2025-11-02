part of 'auth_bloc.dart';

enum AuthStatus { unauthenticated, loading, authenticated, error }

class AuthState extends Equatable {
  const AuthState({required this.status, this.token, this.errorMessage});

  final AuthStatus status;
  final String? token;
  final String? errorMessage;

  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);

  factory AuthState.loading() => AuthState(status: AuthStatus.loading);

  factory AuthState.authenticated({required String token}) =>
      AuthState(status: AuthStatus.authenticated, token: token);

  factory AuthState.error({required String message}) =>
      AuthState(status: AuthStatus.error, errorMessage: message);

  @override
  List<Object?> get props => [status, token, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
