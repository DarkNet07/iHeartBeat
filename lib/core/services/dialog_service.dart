import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iheartbeat/core/widgets/common/dialogs/confirmation_dialog.dart';

class DialogService {
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String cancelText = 'Отмена',
    String confirmText = 'Подтвердить',
  }) async {
    final dialogWidget = ConfirmationDialog(
      title: title,
      content: content,
      cancelText: cancelText,
      confirmText: confirmText,
    );

    if (Platform.isIOS) {
      return await showCupertinoDialog<bool>(
            context: context,
            builder: (context) => dialogWidget,
          ) ??
          false;
    } else {
      return await showDialog<bool>(
            context: context,
            builder: (context) => dialogWidget,
          ) ??
          false;
    }
  }

  static Future<bool> showExitConfirmation(BuildContext context) =>
      showConfirmationDialog(
        context,
        title: 'Вы действительно хотите выйти?',
        content: 'Это действие закроет приложение.',
        cancelText: 'Отмена',
        confirmText: 'Выйти',
      );

  static Future<bool> showLogoutConfirmation(BuildContext context) =>
      showConfirmationDialog(
        context,
        title: 'Выход из аккаунта',
        content: 'Вы действительно хотите выйти из аккаунта?',
        cancelText: 'Отмена',
        confirmText: 'Выйти',
      );

  static Future<bool> showDeleteConfirmation(BuildContext context) =>
      showConfirmationDialog(
        context,
        title: 'Удалить данные?',
        content: 'Это действие нельзя отменить.',
        cancelText: 'Отмена',
        confirmText: 'Удалить',
      );
}
