import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LocalAuthService _authService;
  StreamSubscription<String?>? _emailSubscription;
  StreamSubscription<String?>? _passwordSubscription;

  LoginBloc() : _authService = di.authService, super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<ToggleAuthMode>(_onToggleMode);
    on<ResetError>(_onResetError);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    final emailError = _validateEmail(event.email);
    final newState = state.copyWith(
      email: event.email,
      emailError: emailError,
    );
    emit(newState);
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final passwordError = _validatePassword(event.password);
    final newState = state.copyWith(
      password: event.password,
      passwordError: passwordError,
    );
    emit(newState);
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Email обязателен';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Введите корректный email';
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Пароль обязателен';
    }
    if (password.length < 6) {
      return 'Пароль должен содержать минимум 6 символов';
    }
    return null;
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, globalError: null));

    try {
      final token = await _authService.login(event.email, event.password);
      if (token != null) {
        emit(state.copyWith(status: LoginStatus.success, token: token));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.error,
            globalError: 'Неверный email или пароль',
            email: state.email,
            password: state.password,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          globalError: 'Ошибка входа: ${e.toString()}',
          email: state.email,
          password: state.password,
        ),
      );
    }
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading, globalError: null));

    try {
      final success = await _authService.signup(event.email, event.password);
      if (success) {
        emit(state.copyWith(status: LoginStatus.success, globalError: null));
        add(LoginSubmitted(email: event.email, password: event.password));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.error,
            globalError: 'Пользователь уже существует',
            email: state.email,
            password: state.password,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          globalError: 'Ошибка регистрации: ${e.toString()}',
          email: state.email,
          password: state.password,
        ),
      );
    }
  }

  void _onToggleMode(ToggleAuthMode event, Emitter<LoginState> emit) {
    emit(
      state.copyWith(
        isLoginMode: !state.isLoginMode,
        globalError: null,
        status: LoginStatus.initial,
      ),
    );
  }

  void _onResetError(ResetError event, Emitter<LoginState> emit) {
    emit(state.copyWith(globalError: null, status: LoginStatus.initial));
  }

  @override
  Future<void> close() {
    _emailSubscription?.cancel();
    _passwordSubscription?.cancel();
    return super.close();
  }
}
