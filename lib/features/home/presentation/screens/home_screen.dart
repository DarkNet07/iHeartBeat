import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:iheartbeat/core/services/auth_guard_service.dart';
import 'package:iheartbeat/core/widgets/back_button_interceptor.dart';
import 'package:iheartbeat/core/widgets/common/dialogs/confirmation_dialog.dart';
import 'package:iheartbeat/features/home/presentation/screens/tabbed_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _dialogShown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkArguments();
  }

  void _checkArguments() {
    if (_dialogShown) return;

    final args = ModalRoute.of(context)?.settings.arguments;

    final showPrompt = args is Map ? args['showSetupPrompt'] == true : false;

    if (showPrompt) {
      _dialogShown = true;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _showSetupDialog();
        }
      });
    }
  }

  void _showSetupDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ConfirmationDialog(
        title: 'Хотите включить вход по биометрии или PIN-коду?',
        content: 'Настроить быстрый вход для удобства и безопасности.',
        cancelText: 'Позже',
        confirmText: 'Настроить',
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _navigateToSetupSecurity();
        },
        onCancel: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _navigateToSetupSecurity() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        Navigator.pushNamed(context, '/setup_security');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuardService.guardRoute(
      child: BackButtonInterceptor(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: const Text('Главная страница'),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: const TabbedHomeScreen(),
        ),
      ),
      requireAuth: true,
    );
  }
}
