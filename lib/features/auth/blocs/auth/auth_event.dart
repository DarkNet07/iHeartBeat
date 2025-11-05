part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedIn extends AuthEvent {
  const LoggedIn({required this.token});
  final String token;
  @override
  List<Object> get props => [token];
}

class LoggedOut extends AuthEvent {}

class AdditionalAuthRequired extends AuthEvent {}

class AuthErrorOccurred extends AuthEvent {
  const AuthErrorOccurred({required this.message});
  final String message;
  @override
  List<Object> get props => [message];
}
