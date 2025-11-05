import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/injection_container.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';
import 'package:iheartbeat/features/auth/domain/biometric_service.dart';
import 'package:iheartbeat/features/auth/domain/local_auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = authService;
  final _biometricService = BiometricService();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  void _initializeApp() {
    if (_initialized) return;
    _initialized = true;
  }

  void _handleAuthState(BuildContext context, AuthState state) {
    if (state.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (state.status == AuthStatus.tokenAvailable) {
      _checkAdditionalAuth(context, state.token!);
      return;
    }

    if (state.status == AuthStatus.authenticated) {
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    if (state.status == AuthStatus.error) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
  }

  Future<void> _checkAdditionalAuth(BuildContext context, String token) async {
    final isBiometricEnabled = await _authService.isBiometricEnabled();
    final hasPin = await _authService.hasPin();
    if (isBiometricEnabled) {
      await _handleBiometricAuth(context, hasPin);
      return;
    }
    if (hasPin) {
      Navigator.pushReplacementNamed(context, '/pin_auth');
      return;
    }
    context.read<AuthBloc>().add(AdditionalAuthRequired());
  }

  Future<void> _handleBiometricAuth(BuildContext context, bool hasPin) async {
    try {
      final success = await _biometricService.authenticate();
      if (success) {
        context.read<AuthBloc>().add(AdditionalAuthRequired());
      } else {
        _handleBiometricFailure(context, hasPin);
      }
    } catch (e) {
      _handleBiometricFailure(context, hasPin);
    }
  }

  void _handleBiometricFailure(BuildContext context, bool hasPin) {
    if (hasPin) {
      Navigator.pushReplacementNamed(context, '/pin_auth');
    } else {
      context.read<AuthBloc>().add(LoggedOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: _handleAuthState,
      child: const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: Colors.red, size: 80),
              SizedBox(height: 16),
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Загрузка...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
