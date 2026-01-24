import 'package:brahmakosh/core/custom_widgets/splash_welcome.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/common_imports.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: AppConstants.splashDuration));

    if (!mounted) return;

    final isFirstLaunch =
        StorageService.getBool(AppConstants.keyIsFirstLaunch) ?? true;
    final token = StorageService.getString(AppConstants.keyAuthToken);
    final hasToken = token != null && token.isNotEmpty;

    if (isFirstLaunch) {
      Get.offAllNamed(AppConstants.routeIntro);
    } else if (hasToken) {
      // If token exists, go directly to dashboard
      Get.offAllNamed(AppConstants.routeDashboard);
    } else {
      Get.offAllNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: WelcomeVideo(
          videoAsset: 'assets/images/app_launcher.mp4',
          fit: BoxFit.cover, // 🔥 full screen cover
          loop: false,
        ),
      ),
    );
  }
}
