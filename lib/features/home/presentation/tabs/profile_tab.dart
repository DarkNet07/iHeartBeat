import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iheartbeat/core/injection_container.dart' as di;
import 'package:iheartbeat/core/services/dialog_service.dart';
import 'package:iheartbeat/features/auth/blocs/auth/auth_bloc.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<String?>(
        future: di.authService.getEmail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final email = snapshot.data;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text('Профиль', style: TextStyle(fontSize: 24)),
                  if (email != null) ...[
                    const SizedBox(height: 8),
                    Text('Email: $email', style: const TextStyle(fontSize: 16)),
                  ],
                  const SizedBox(height: 24),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 16,
                    children: [
                      ElevatedButton(
                        onPressed: () => _navigateToPermissions(context),
                        child: const Text('Проверить настройки разрешений'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        icon: const Icon(Icons.logout, size: 20),
                        label: const Text('Выйти'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _navigateToPermissions(BuildContext context) {
    Navigator.pushNamed(context, 'home/profile/permissions');
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await DialogService.showLogoutConfirmation(context);
    if (confirmed) {
      final authBloc = context.read<AuthBloc>();
      authBloc.add(LoggedOut());
    }
  }
}
