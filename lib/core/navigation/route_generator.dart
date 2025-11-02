import 'package:flutter/material.dart';
import 'package:iheartbeat/features/auth/presentation/screens/login_screen.dart';
import 'package:iheartbeat/features/home/presentation/screens/home_screen.dart';
import 'package:iheartbeat/features/settings/presentation/screens/permissions_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/login':
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case '/home':
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(title: "Главная страница"),
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
