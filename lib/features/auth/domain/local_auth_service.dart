import 'dart:convert';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const _keyEmail = 'user_email';
  static const _keyPassword = 'user_password';
  static const _keyToken = 'auth_token';
  static const _keyPin = 'user_pin';
  static const _keyBiometricEnabled = 'biometric_enabled';

  Future<bool> signup(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final existingEmail = prefs.getString(_keyEmail);
    if (existingEmail != null && existingEmail == email) return false;

    await prefs.setString(_keyEmail, email);
    await _secureStorage.write(key: _keyPassword, value: password);

    final token = _generateMockJwt(email);
    await _secureStorage.write(key: _keyToken, value: token);
    return true;
  }

  Future<String?> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final storedEmail = prefs.getString(_keyEmail);
    final storedPassword = await _secureStorage.read(key: _keyPassword);

    if (storedEmail == email && storedPassword == password) {
      final storedToken = await _secureStorage.read(key: _keyToken);
      return storedToken ?? _generateMockJwt(email);
    }
    return null;
  }

  Future<String?> getToken() async => await _secureStorage.read(key: _keyToken);
  Future<void> saveToken(String token) async =>
      await _secureStorage.write(key: _keyToken, value: token);
  Future<void> logout() async => await _secureStorage.delete(key: _keyToken);

  Future<void> setPin(String pin) async =>
      await _secureStorage.write(key: _keyPin, value: pin);

  Future<bool> validatePin(String pin) async {
    final storedPin = await _secureStorage.read(key: _keyPin);
    return storedPin == pin;
  }

  Future<bool> hasPin() async {
    final pin = await _secureStorage.read(key: _keyPin);
    return pin != null && pin.isNotEmpty;
  }

  Future<void> enableBiometric(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _keyToken);
    return token != null;
  }

  String _generateMockJwt(String email) {
    final header = base64Url.encode(
      utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})),
    );
    final payload = base64Url.encode(
      utf8.encode(
        json.encode({
          'email': email,
          'exp': DateTime.now()
              .add(const Duration(days: 3))
              .millisecondsSinceEpoch,
        }),
      ),
    );
    return '$header.$payload.mock_signature';
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }
}
