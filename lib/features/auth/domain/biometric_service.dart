import 'dart:developer';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _isAuthenticating = false;

  Future<bool> authenticate() async {
    if (_isAuthenticating) {
      return false;
    }

    try {
      _isAuthenticating = true;

      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return false;
      }

      final success = await _localAuth.authenticate(
        localizedReason: 'Подтвердите вход с помощью биометрии',
        biometricOnly: true,
        sensitiveTransaction: false,
        persistAcrossBackgrounding: true,
      );

      return success;
    } catch (e) {

      if (e.toString().contains('authInProgress')) {
        await Future.delayed(const Duration(seconds: 1));
        return authenticate();
      }

      return false;
    } finally {
      _isAuthenticating = false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      log('ошибка при проверки доступности био: $e');
      return false;
    }
  }
}
