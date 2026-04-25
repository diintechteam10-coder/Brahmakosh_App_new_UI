import 'package:upgrader/upgrader.dart';

class AppUpdateService {
  static final AppUpdateService instance = AppUpdateService._internal();
  AppUpdateService._internal();

  late Upgrader upgrader;

  void initialize() {
    upgrader = Upgrader(
      // Can be set to true for testing to always show the dialog
      debugDisplayAlways: false, 
      // Set to 0 to check for update on every app launch
      durationUntilAlertAgain: Duration.zero,
    );
  }
}
