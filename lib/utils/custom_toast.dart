import 'package:flutter/material.dart';

enum ToastType { success, error, info, warning }

class CustomToast {
  static bool showLoginSuccessToast = false;
  static String? successMessage;

  static void showSuccess(BuildContext context, {required String title, required String message}) {
    _showToast(context, title: title, message: message, type: ToastType.success);
  }

  static void showError(BuildContext context, {required String title, required String message}) {
    _showToast(context, title: title, message: message, type: ToastType.error);
  }

  static void showInfo(BuildContext context, {required String title, required String message}) {
    _showToast(context, title: title, message: message, type: ToastType.info);
  }

  static void showWarning(BuildContext context, {required String title, required String message}) {
    _showToast(context, title: title, message: message, type: ToastType.warning);
  }

  static void _showToast(
    BuildContext context, {
    required String title,
    required String message,
    required ToastType type,
  }) {
    Color mainColor;

    switch (type) {
      case ToastType.success:
        mainColor = Colors.green;
        break;
      case ToastType.error:
        mainColor = Colors.red;
        break;
      case ToastType.info:
        mainColor = Colors.blue;
        break;
      case ToastType.warning:
        mainColor = Colors.orange;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: mainColor,
      ),
    );
  }
}
