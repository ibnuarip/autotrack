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
    IconData iconData;

    switch (type) {
      case ToastType.success:
        mainColor = const Color(0xFF4CAF50);
        iconData = Icons.check_circle;
        break;
      case ToastType.error:
        mainColor = const Color(0xFFF44336);
        iconData = Icons.cancel;
        break;
      case ToastType.info:
        mainColor = const Color(0xFF2196F3);
        iconData = Icons.info;
        break;
      case ToastType.warning:
        mainColor = const Color(0xFFFFB300);
        iconData = Icons.warning;
        break;
    }

    final safeAreaTop = MediaQuery.of(context).padding.top;
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: mainColor.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left Border Color Indicator
                  Container(
                    width: 6,
                    color: mainColor,
                  ),
                  const SizedBox(width: 16),
                  // Icon Section
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: mainColor, size: 22),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Text Content Section
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1E1E1E),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.6),
                              fontSize: 14,
                              height: 1.4,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Icon(Icons.close, color: Colors.black.withOpacity(0.3), size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - (safeAreaTop + 220),
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}
