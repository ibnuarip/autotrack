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
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 70, // Fixed height for consistency
              child: Row(
                children: [
                  // Left Border Color Indicator (Slimmer)
                  Container(
                    width: 6,
                    color: mainColor,
                  ),
                  const SizedBox(width: 12),
                  // Icon Section (Smaller)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: mainColor, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Text Content Section (Compact)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            message,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 13,
                              height: 1.3,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Close Button (Smaller)
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Icon(Icons.close, color: Colors.grey, size: 18),
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
          bottom: MediaQuery.of(context).size.height - (safeAreaTop + 180), // Lowered further for full visibility
          left: 16,
          right: 16,
        ),
      ),
    );
  }
}
