import 'package:flutter/material.dart';
import 'package:iheartbeat/core/ui/theme/app_theme.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/features/auth/presentation/screens/login_screen.dart';
import 'package:iheartbeat/features/home/presentation/screens/home_screen.dart';
import 'package:iheartbeat/features/settings/presentation/screens/permissions_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const IHeartBeatApp());
}

class IHeartBeatApp extends StatelessWidget {
  const IHeartBeatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iHeartBeat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(title: "Главная страница"),
        '/settings/permissions': (context) => const PermissionsScreen(),
      },
    );
  }
}
