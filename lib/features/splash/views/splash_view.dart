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
      // If token exists, go directly to walkthrough
      Get.offAllNamed(AppConstants.routeWalkthrough);
    } else {
      Get.offAllNamed(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image.asset('assets/images/splashScreen.png', fit: BoxFit.cover),
      ),
      // body: SafeArea(
      //   child: Center(
      //     child: SingleChildScrollView(
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           Image.asset(
      //             'assets/images/brahmkosh_logo.jpeg',
      //             height: 200,
      //             width: 200,
      //           ),
      //           //const SizedBox(height: 5),
      //           Text(
      //             'BRAHMAKOSH',
      //             style: GoogleFonts.lora(
      //               fontSize: 32,
      //               fontWeight: FontWeight.bold,
      //               color: const Color(0xFFD4AF37), // Gold color
      //               letterSpacing: 1.5,
      //             ),
      //           ),
      //           const SizedBox(height: 10),
      //           Text(
      //             'Your Spiritual Operating System',
      //             style: GoogleFonts.lora(fontSize: 18, color: Colors.black87),
      //             textAlign: TextAlign.center,
      //           ),
      //           const SizedBox(height: 12),
      //           Text(
      //             'Spirituality • Astrology • Companion • Intelligence',
      //             style: GoogleFonts.lora(
      //               fontSize: 14,
      //               color: Colors.grey[600],
      //               fontWeight: FontWeight.w500,
      //             ),
      //             textAlign: TextAlign.center,
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
