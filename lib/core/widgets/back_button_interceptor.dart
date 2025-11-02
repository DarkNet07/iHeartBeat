import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class BackButtonInterceptor extends StatelessWidget {
  final Widget child;

  const BackButtonInterceptor({required this.child, super.key});

  Future<bool> _showExitDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text('Подтверждение выхода'),
            content: const Text('Вы действительно хотите выйти из приложения?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                child: const Text('Выйти'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text('Подтверждение выхода'),
            content: const Text('Вы действительно хотите выйти из приложения?'),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Выйти'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        }
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          final shouldExit = await _showExitDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }
}
