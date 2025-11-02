import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';


class AuthRepository {
  final LocalAuthService _authService;

  AuthRepository(this._authService);

  Future<bool> isAuthenticated() async {
    return await _authService.isLoggedIn();
  }

  Future<String?> getToken() async {
    return await _authService.getToken();
  }

  Future<void> login(String token) async {
    await _authService.saveToken(token);
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<String?> getUserEmail() async {
    return await _authService.getEmail();
  }

  Future<bool> isTokenValid(String token) async {
    return true;
  }
}
