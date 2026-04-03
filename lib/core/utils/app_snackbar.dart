import 'package:brahmakosh/core/common_imports.dart';

class AppSnackBar {
  // Common styling for all snackbars
  static void _show({
    required String title,
    required String message,
    required Color indicatorColor,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.4),
      barBlur: 15,
      colorText: Colors.white,
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: indicatorColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: indicatorColor,
          size: 20,
        ),
      ),
      margin: const EdgeInsets.all(15),
      borderRadius: 20,
      borderWidth: 0.5,
      borderColor: Colors.white.withOpacity(0.1),
      duration: duration,
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      // leftBarIndicatorColor: indicatorColor,
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppTheme.primaryGold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.9),
          fontSize: 12,
        ),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: 1,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static void showSuccess(String title, String message) {
    _show(
      title: title,
      message: message,
      indicatorColor: Colors.greenAccent,
      icon: Icons.check_circle_outline,
    );
  }

  static void showError(String title, String message) {
    _show(
      title: title,
      message: message,
      indicatorColor: Colors.redAccent,
      icon: Icons.error_outline,
    );
  }

  static void showInfo(String title, String message) {
    _show(
      title: title,
      message: message,
      indicatorColor: AppTheme.primaryGold,
      icon: Icons.info_outline,
    );
  }
}
