import 'package:get_it/get_it.dart';
import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  _initCore();

  _initAuth();
}

void _initCore() {
}

void _initAuth() {
  sl.registerLazySingleton<LocalAuthService>(() => LocalAuthService());
}

LocalAuthService get authService => sl<LocalAuthService>();
