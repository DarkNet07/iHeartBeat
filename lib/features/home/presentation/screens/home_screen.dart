import 'package:flutter/material.dart';
import 'package:iheartbeat/core/services/auth_guard_service.dart';
import 'package:iheartbeat/core/widgets/back_button_interceptor.dart';
import 'package:iheartbeat/features/home/presentation/screens/tabbed_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AuthGuardService.guardRoute(
      child: BackButtonInterceptor(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Text(title),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          body: const TabbedHomeScreen(),
        ),
      ),
      requireAuth: true,
    );
  }
}
