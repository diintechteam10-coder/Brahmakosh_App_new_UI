import 'package:brahmakosh/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/payment_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/chat_notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/widgets/global_connectivity_overlay.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/in_app_notification_banner.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PaymentService.initialize();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize storage
  await StorageService.init();

  // Always start with splash screen - let splash decide navigation
  // This ensures consistent behavior on app restart
  String initialRoute = AppConstants.routeSplash;

  // Run app
  runApp(MyApp(initialRoute: initialRoute));
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatNotificationService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProfileViewModel();
        // Fetch profile immediately on app start
        viewModel.fetchProfile();
        return viewModel;
      },
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            title: 'Brahmakosh',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            initialRoute: initialRoute,
            initialBinding: GlobalBindings(),
            getPages: AppPages.pages,
            defaultTransition: Transition.fadeIn,
            builder: (context, child) {
              return GlobalConnectivityOverlay(
                child: InAppNotificationBanner(
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
