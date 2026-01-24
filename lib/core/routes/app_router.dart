import 'package:brahmakosh/features/auth/controllers/mobile_controller.dart';
import 'package:brahmakosh/features/auth/views/create_avtar.dart';
import 'package:brahmakosh/features/auth/views/login.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import '../../features/auth/controllers/avtar_controller.dart';
import '../../features/auth/views/email_register_view.dart';
import '../../features/auth/views/complete_profile.dart';
import '../../features/auth/controllers/login_controller.dart';
import '../../features/auth/controllers/email_register_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/intro/views/intro_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../constants/app_constants.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: Get.key,
    initialLocation: AppConstants.routeSplash,
    routes: [
      GoRoute(
        path: AppConstants.routeSplash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppConstants.routeIntro,
        builder: (context, state) => const IntroView(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) {
          Get.lazyPut<LoginController>(() => LoginController());
          return LoginPhoneView();
        },
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        builder: (context, state) {
          Get.lazyPut<RegisterController>(() => RegisterController());
          return EmailRegisterView();
        },
      ),
      GoRoute(
        path: AppConstants.routeDashboard,
        builder: (context, state) => const DashboardView(),
      ),
      GoRoute(
        path: AppConstants.avtarGenrate,
        builder: (context, state) {
          Get.lazyPut<GenerateAvatarController>(
            () => GenerateAvatarController(),
          );
          return GenerateAvatarView();
        },
      ),
    ],
  );
}
