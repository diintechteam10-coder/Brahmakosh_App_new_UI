import '../../../../core/common_imports.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/services/connectivity_service.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool _hasInternet = true;
  bool _isCheckingConnection = false;

  bool get isLoading => _isLoading;
  bool get hasInternet => _hasInternet;
  bool get isCheckingConnection => _isCheckingConnection;

  late final ConnectivityService _connectivityService;

  SplashViewModel() {
    _connectivityService = Get.find<ConnectivityService>();
    
    // Listen to internet status for auto-retry/navigation
    _connectivityService.hasInternetAccess.listen((hasAccess) {
      if (hasAccess && !_hasInternet) {
        // Automatically try to proceed if internet restored
        _hasInternet = true;
        notifyListeners();
        _checkFirstLaunch();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    _isCheckingConnection = true;
    notifyListeners();

    // Layer 2: Real internet check
    final hasRealAccess = await _connectivityService.checkRealInternetAccess();
    
    _isCheckingConnection = false;
    _hasInternet = hasRealAccess;
    notifyListeners();

    if (_hasInternet) {
      await Future.delayed(const Duration(seconds: AppConstants.splashDuration));
      await _checkFirstLaunch();
    }
  }

  Future<void> retryConnection() async {
    if (_isCheckingConnection) return;
    
    _isCheckingConnection = true;
    notifyListeners();

    final hasRealAccess = await _connectivityService.checkRealInternetAccess();
    
    _isCheckingConnection = false;
    _hasInternet = hasRealAccess;
    notifyListeners();

    if (_hasInternet) {
      await _checkFirstLaunch();
    }
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final isFirstLaunch = StorageService.getBool(AppConstants.keyIsFirstLaunch) ?? true;
      final token = StorageService.getString(AppConstants.keyAuthToken);
      final hasToken = token != null && token.isNotEmpty;

      // Add a small delay to ensure navigation happens smoothly
      await Future.delayed(const Duration(milliseconds: 100));

      if (isFirstLaunch) {
        Get.offAllNamed(AppConstants.routeIntro);
      } else if (hasToken) {
        try {
          await PushNotificationService.instance.initialize();
        } catch (e) {
          debugPrint("Push Notification error: $e");
        }
        Get.offAllNamed(AppConstants.routeDashboard);
      } else {
        Get.offAllNamed(AppConstants.routeLogin);
      }
    } catch (e) {
      Get.offAllNamed(AppConstants.routeIntro);
    }
    
    _isLoading = false;
    notifyListeners();
  }
}
