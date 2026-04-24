import 'package:upgrader/upgrader.dart';

class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._internal();
  AppUpdateService._internal();

  late Upgrader upgrader;

  void initialize() {
    upgrader = Upgrader(
      // Can be set to true for testing to always show the dialog
      debugDisplayAlways: false, 
      // How often to check for updates
      durationUntilAlertAgain: const Duration(hours: 2),
      // Minimum time between checks
      minAppVersion: '1.0.0',
    );
  }
}
