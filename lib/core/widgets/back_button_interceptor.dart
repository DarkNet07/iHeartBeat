import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iheartbeat/core/services/dialog_service.dart';

class BackButtonInterceptor extends StatelessWidget {
  final Widget child;

  const BackButtonInterceptor({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          final shouldExit = await DialogService.showExitConfirmation(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: child,
    );
  }
}
