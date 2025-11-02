import 'package:get_it/get_it.dart';
import 'package:iheartbeat/core/services/auth_guard_service.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';
import 'package:iheartbeat/features/auth/blocs/login/login_bloc.dart';
import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';
import 'package:iheartbeat/features/auth/repositories/auth_repository.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _initCore();
  _initAuth();
}

void _initCore() {}

void _initAuth() {
  sl.registerLazySingleton<LocalAuthService>(() => LocalAuthService());

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(sl<LocalAuthService>()),
  );

  sl.registerLazySingleton<AuthGuardService>(() => AuthGuardService());

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerFactory<LoginBloc>(() => LoginBloc());
}

LocalAuthService get authService => sl<LocalAuthService>();
AuthGuardService get authGuard => sl<AuthGuardService>();
