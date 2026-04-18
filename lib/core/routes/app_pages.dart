import 'package:brahmakosh/features/auth/controllers/mobile_controller.dart';
import 'package:brahmakosh/features/auth/views/landing.dart';
import 'package:brahmakosh/features/auth/views/login.dart';
import 'package:brahmakosh/features/auth/views/mobile_number_page.dart';
import 'package:brahmakosh/features/brahm_bazar/brahm_bazar_view.dart';
import 'package:brahmakosh/features/check_in/views/check_in_view.dart';
import 'package:brahmakosh/features/check_in/views/meditation_selection_view_v2.dart';
import 'package:brahmakosh/features/check_in/views/meditation_start.dart';
import 'package:brahmakosh/features/check_in/views/spiritual_configuration_view.dart';
import 'package:brahmakosh/features/home/mantra/mantra_chanting.dart';
import 'package:brahmakosh/features/avatar/views/create_avatar_view.dart';
import 'package:brahmakosh/features/home/views/panchang_details_view.dart';
import 'package:brahmakosh/features/panchang/views/panchang_view.dart';
import 'package:brahmakosh/features/focus/views/focus_view.dart';
import 'package:brahmakosh/features/focus/views/health_focus_view.dart';
import 'package:brahmakosh/features/focus/views/relations_focus_view.dart';
import 'package:brahmakosh/features/focus/views/career_focus_view.dart';
import 'package:brahmakosh/features/panchang/views/tithi_view.dart';
import 'package:brahmakosh/features/panchang/views/nakshatra_view.dart';
import 'package:brahmakosh/features/panchang/views/yoga_view.dart';
import 'package:brahmakosh/features/panchang/views/karan_view.dart';
import 'package:brahmakosh/features/avatar_reels/views/avatar_reels_view.dart';
import '../../features/avatar_reels/controllers/avatar_reels_controller.dart';
import 'package:get/get.dart';
import '../../features/auth/views/email_register_view.dart';
import '../../features/auth/controllers/login_controller.dart';
import '../../features/auth/controllers/email_register_controller.dart';
import '../../features/dashboard/views/dashboard_view.dart';
import '../../features/intro/views/intro_view.dart';
import '../../features/auth/views/registration_success_view.dart';
import '../../features/splash/views/splash_view.dart';
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../../features/walkthrough/views/walkthrough_view.dart';
import 'package:brahmakosh/features/redeem/views/redeem_list_view.dart';
import 'package:brahmakosh/features/sankalp/views/sankalp_screen.dart';
import 'package:brahmakosh/features/notifications/views/notification_screen.dart';
import 'package:brahmakosh/features/home/views/astrology_details_screen.dart';
import 'package:brahmakosh/features/pooja/views/pooja_list_screen.dart';
import 'package:brahmakosh/features/swapna_decoder/views/swapna_decoder_screen.dart';
import 'package:brahmakosh/features/gita/views/gita_chapter_screen.dart';
import 'package:brahmakosh/features/wallet/views/recharge_plans_view.dart';
import 'package:brahmakosh/features/wallet/views/subscription_plans_view.dart'; // Added



class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppConstants.routeSplash, page: () => const SplashView()),
    GetPage(name: AppConstants.routeIntro, page: () => const IntroView()),
    GetPage(
      name: AppConstants.routeRegistrationSuccess,
      page: () => const RegistrationSuccessView(),
    ),
    GetPage(name: AppConstants.routeLogin, page: () => LandingView()),
    GetPage(
      name: AppConstants.routeEmailLogin,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<LoginController>()) {
          Get.put(LoginController());
        }
      }),
    ),
    GetPage(
      name: AppConstants.routeRegister,
      page: () => EmailRegisterView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<RegisterController>()) {
          Get.put(RegisterController());
        }
      }),
    ),
    GetPage(
      name: AppConstants.routeDashboard,
      page: () => const DashboardView(),
    ),
    GetPage(
      name: AppConstants.mobileOtp,
      page: () => PhoneOtpView(),
      binding: BindingsBuilder(() {
        // Get email from route arguments or storage
        final arguments = Get.arguments;
        String? email;

        if (arguments != null) {
          if (arguments is String) {
            email = arguments;
          } else if (arguments is Map && arguments.containsKey('email')) {
            email = arguments['email'] as String?;
          }
        }

        // If not in arguments, try to get from storage
        email ??= StorageService.getString(AppConstants.keyUserEmail);

        // If still no email, use empty string (will need to be handled by the controller)
        email ??= '';

        if (!Get.isRegistered<MobileOtpController>()) {
          Get.put(MobileOtpController(email: email));
        }
      }),
    ),
    GetPage(name: AppConstants.brahmBazar, page: () => const BrahmBazarView()),
    GetPage(
      name: AppConstants.routeCreateAvatar,
      page: () => const CreateAvatarView(),
    ),
    GetPage(name: AppConstants.routePanchang, page: () => const PanchangDetailsView()),
    GetPage(name: AppConstants.routePanchangToday, page: () => const PanchangView()),
    GetPage(name: AppConstants.routeFocus, page: () => const FocusView()),
    GetPage(
      name: AppConstants.routeFocusHealth,
      page: () => const HealthFocusView(),
    ),
    GetPage(
      name: AppConstants.routeFocusRelations,
      page: () => const RelationsFocusView(),
    ),
    GetPage(
      name: AppConstants.routeFocusCareer,
      page: () => const CareerFocusView(),
    ),

    GetPage(name: AppConstants.routeTithi, page: () => const TithiView()),
    GetPage(
      name: AppConstants.routeNakshatra,
      page: () => const NakshatraView(),
    ),
    GetPage(name: AppConstants.routeYoga, page: () => const YogaView()),
    GetPage(name: AppConstants.routeKaran, page: () => const KaranView()),
    GetPage(
      name: AppConstants.routeAvatarReels,
      page: () => const AvatarReelsView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<AvatarReelsController>()) {
          Get.put(AvatarReelsController());
        }
      }),
    ),
    GetPage(name: AppConstants.routeCheckIn, page: () => CheckInView()),
    GetPage(
      name: AppConstants.routeMeditate,
      page: () => const MeditationSelectionViewV2(meditationCategoryId: "69787dfbbeaf7e42675a221d"),
    ),
    GetPage(
      name: AppConstants.routeMantraChanting,
      page: () => const MantraChantingView(),
    ),
    GetPage(
      name: AppConstants.routeMeditationStart,
      page: () => const MeditationStart(),
    ),
    // GetPage(
    //   name: AppConstants.routeSpiritualConfiguration,
    //   page: () => const SpiritualConfigurationView(),
    // ),
    // GetPage(
    //   name: AppConstants.routeChantingConfiguration,
    //   page: () => ChantingConfigurationView(),
    // ),
    GetPage(
      name: AppConstants.routeWalkthrough,
      page: () => const WalkthroughView(),
    ),
    GetPage(name: AppConstants.routeRedeem, page: () => const RedeemListView()),
    GetPage(name: AppConstants.routeSankalp, page: () => const SankalpScreen()),
    GetPage(
      name: AppConstants.routeNotifications,
      page: () => const NotificationScreen(),
    ),
    GetPage(
      name: AppConstants.routeAstrologyDetails,
      page: () => const AstrologyDetailsScreen(),
    ),
    GetPage(
      name: AppConstants.routePoojaList,
      page: () => const PoojaListScreen(),
    ),
    GetPage(
      name: AppConstants.routeSwapnaDecoder,
      page: () => const SwapnaDecoderScreen(),
    ),
    GetPage(
      name: AppConstants.routeGita,
      page: () => const GitaChapterScreen(),
    ),
    GetPage(
      name: AppConstants.routeRechargePlans,
      page: () => const RechargePlansView(),
    ),
    GetPage(
      name: AppConstants.routesSubscription,
      page: () => const SubscriptionPlansView(),
    ),
  ];
}
