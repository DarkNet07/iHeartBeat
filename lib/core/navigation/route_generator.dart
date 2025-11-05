import 'package:flutter/material.dart';
import 'package:iheartbeat/features/auth/presentation/screens/login_screen.dart';
import 'package:iheartbeat/features/auth/presentation/screens/pin_auth_screen.dart';
import 'package:iheartbeat/features/auth/presentation/screens/splash_screen.dart';
import 'package:iheartbeat/features/home/presentation/screens/home_screen.dart';
import 'package:iheartbeat/features/settings/presentation/screens/permissions_screen.dart';
import 'package:iheartbeat/features/settings/presentation/screens/setup_security.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/splash':
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case '/pin_auth':
        return MaterialPageRoute(builder: (_) => const PinAuthScreen());
      case '/setup_security':
        return MaterialPageRoute(builder: (_) => const SetupSecurityScreen());

      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      case '/settings/permissions':
        return MaterialPageRoute(builder: (_) => const PermissionsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Неизвестный маршрут: ${settings.name}')),
          ),
        );
    }
  }
}
