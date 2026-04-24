import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/services/payment_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/chat_notification_service.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/widgets/global_connectivity_overlay.dart';
import 'core/widgets/in_app_notification_banner.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/profile/viewmodels/profile_viewmodel.dart';
import 'features/notifications/blocs/notification_bloc.dart';
import 'features/notifications/repositories/notification_repository.dart';
import 'core/localization/app_translations.dart';
import 'core/services/app_update_service.dart';
import 'package:upgrader/upgrader.dart';



@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
  await PushNotificationService.showLocalNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);

  await PushNotificationService.instance.initialize();
  await PaymentService.initialize();
  await StorageService.init();
  AppUpdateService.instance.initialize();


  // ✅ FORCE WHITE STATUS BAR ICONS (GLOBAL)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,

      // Android → WHITE icons
      statusBarIconBrightness: Brightness.light,

      // iOS → WHITE icons
      statusBarBrightness: Brightness.dark,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(ChatNotificationService(), permanent: true);
    Get.put(ConnectivityService(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final vm = ProfileViewModel();
            vm.fetchProfile();
            return vm;
          },
        ),
        BlocProvider(
          create: (_) =>
              NotificationBloc(repository: NotificationRepository())
                ..add(RefreshUnreadCount()),
        ),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return GetMaterialApp(
            title: 'Brahmakosh',
            debugShowCheckedModeBanner: false,
            translations: AppTranslations(),
            locale: _getSavedLocale(),
            fallbackLocale: const Locale('en', 'US'),
            theme: AppTheme.lightTheme,
            initialRoute: AppConstants.routeSplash,
            initialBinding: GlobalBindings(),
            getPages: AppPages.pages,
            defaultTransition: Transition.fadeIn,

            // ✅ IMPORTANT (GLOBAL WRAPPER)
            builder: (context, child) {
              return AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
                child: GlobalConnectivityOverlay(
                  child: InAppNotificationBanner(
                    child: UpgradeAlert(
                      upgrader: AppUpdateService.instance.upgrader,
                      barrierDismissible: false,
                      showIgnore: false,
                      showLater: false,
                      dialogStyle: UpgradeDialogStyle.material,
                      child: child ?? const SizedBox(),
                    ),
                  ),
                ),

              );
            },
          );
        },
      ),
    );
  }

  Locale _getSavedLocale() {
    final langCode = StorageService.getString(AppConstants.keySelectedLanguage);
    if (langCode == null) return const Locale('en', 'US');

    if (langCode == 'hi') return const Locale('hi', 'IN');
    return const Locale('en', 'US');
  }
}