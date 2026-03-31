import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/common_imports.dart';
import '../viewmodels/splash_viewmodel.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SplashViewModel(),
      child: Consumer<SplashViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                children: [
                  // Main Splash Content
                  _buildSplashContent(context),

                  // No Internet Overlay/Gatekeeper
                  if (!viewModel.hasInternet)
                    _buildNoInternetUI(context, viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSplashContent(BuildContext context) {
    return Padding(
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
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/icons/splash_logo.png',
              width: MediaQuery.of(context).size.width * 0.80,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 20),
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
          const Spacer(),
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNoInternetUI(BuildContext context, SplashViewModel viewModel) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Premium Icon/Illustration
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'No Internet Connection',
            textAlign: TextAlign.center,
            style: GoogleFonts.merriweather(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD4AF),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'We couldn\'t connect to our servers. Please check your internet settings and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: viewModel.isCheckingConnection 
                  ? null 
                  : () => viewModel.retryConnection(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: viewModel.isCheckingConnection
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Try Again',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Retrying automatically when you connect...',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}
