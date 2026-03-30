import '../../../../core/common_imports.dart';
import '../../../../core/services/push_notification_service.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  SplashViewModel() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));
    await _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final isFirstLaunch = StorageService.getBool(AppConstants.keyIsFirstLaunch) ?? true;
      final token = StorageService.getString(AppConstants.keyAuthToken);
      final hasToken = token != null && token.isNotEmpty;

      // Add a small delay to ensure navigation happens smoothly
      await Future.delayed(const Duration(milliseconds: 100));

      if (isFirstLaunch) {
        // Navigate to Intro screens
        Get.offAllNamed(AppConstants.routeIntro);
      } else if (hasToken) {
        // Initialize Push Notifications for existing session
        try {
          await PushNotificationService.instance.initialize();
        } catch (e) {
          debugPrint("Push Notification error: $e");
        }
        // If token exists, navigate to Dashboard
        Get.offAllNamed(AppConstants.routeDashboard);
      } else {
        // Navigate to Login
        Get.offAllNamed(AppConstants.routeLogin);
      }
    } catch (e) {
      // Fallback navigation if there's an error
      Get.offAllNamed(AppConstants.routeIntro);
    }
    
    _isLoading = false;
    notifyListeners();
  }
}

