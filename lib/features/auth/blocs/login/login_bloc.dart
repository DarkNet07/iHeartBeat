import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LocalAuthService _authService;

  LoginBloc() : _authService = di.authService, super(const LoginState()) {
    on<EmailChanged>(_onEmailChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<SignupSubmitted>(_onSignupSubmitted);
    on<ToggleAuthMode>(_onToggleMode);
  }

  void _onEmailChanged(EmailChanged event, Emitter<LoginState> emit) {
    final newState = state.copyWith(
      email: event.email,
      emailError: _validateEmail(event.email),
    );
    emit(newState);
  }

  void _onPasswordChanged(PasswordChanged event, Emitter<LoginState> emit) {
    final newState = state.copyWith(
      password: event.password,
      passwordError: _validatePassword(event.password),
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
    if (!state.isFormValid) {
      emit(state.copyWith(status: LoginStatus.invalid));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    try {
      final token = await _authService.login(event.email, event.password);
      if (token != null) {
        emit(
          state.copyWith(
            status: LoginStatus.success,
            globalError: null,
            token: token,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.error,
            globalError: 'Неверный email или пароль',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          globalError: 'Ошибка входа: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSignupSubmitted(
    SignupSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormValid) {
      emit(state.copyWith(status: LoginStatus.invalid));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

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
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          globalError: 'Ошибка регистрации: ${e.toString()}',
        ),
      );
    }
  }

  void _onToggleMode(ToggleAuthMode event, Emitter<LoginState> emit) {
    emit(state.copyWith(isLoginMode: !state.isLoginMode, globalError: null));
  }
}
