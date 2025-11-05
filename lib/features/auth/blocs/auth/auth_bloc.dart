import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/features/auth/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
    : _authRepository = authRepository,
      super(AuthState.loading()) {
    on<AppStarted>(_onAppStarted);
    on<LoggedIn>(_onLoggedIn);
    on<LoggedOut>(_onLoggedOut);
    on<AdditionalAuthRequired>(_onAdditionalAuthRequired);
    on<AuthErrorOccurred>(_onAuthErrorOccurred);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    try {
      final isLoggedIn = await _authRepository.isAuthenticated();

      if (isLoggedIn) {
        final token = await _authRepository.getToken();
        if (token != null) {
          emit(AuthState.tokenAvailable(token: token));
        } else {
          await _authRepository.logout();
          emit(AuthState.unauthenticated());
        }
      } else {
        emit(AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(message: 'Ошибка проверки авторизации: $e'));
    }
  }

  Future<void> _onLoggedIn(LoggedIn event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.login(event.token);
      emit(AuthState.authenticated(token: event.token));
    } catch (e) {
      emit(AuthState.error(message: 'Ошибка сохранения токена: $e'));
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    try {
      await _authRepository.logout();
      emit(AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(message: 'Ошибка выхода: $e'));
    }
  }

  Future<void> _onAdditionalAuthRequired(
    AdditionalAuthRequired event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.tokenAvailable && state.token != null) {
      emit(AuthState.authenticated(token: state.token!));
    }
  }

  Future<void> _onAuthErrorOccurred(
    AuthErrorOccurred event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.error(message: event.message));
  }
}
