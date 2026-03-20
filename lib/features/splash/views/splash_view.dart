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
      // If token exists, go directly to dashboard (walkthrough disabled)
      Get.offAllNamed(AppConstants.routeDashboard);
    } else {
      Get.offAllNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Text(
                'BRAHMAKOSH',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37), // Gold color
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your Spiritual Operating System',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: const Color(0xFFD4AF37).withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            SizedBox(height: 20),
              // Center Logo Image
              Center(
                child: Image.asset(
                  'assets/icons/splash_logo.png',
                  width: MediaQuery.of(context).size.width * 0.80,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Daily insights and astrology that bring\nclarity, discipline, and balance\nto your life.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
