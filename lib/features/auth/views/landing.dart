import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class LandingView extends StatelessWidget {
  LandingView({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackground,
      body: Stack(
        children: [
          // Wavy Background Pattern
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_wavy_bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Premium Gold Logo
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.authPrimaryGold.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/brahmkosh_logo.jpeg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "BRAHMAKOSH",
                    style: GoogleFonts.lora(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryGold,
                      letterSpacing: 2.0,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your Spiritual Operating System",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.authTextSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Buttons
                  Obx(
                    () => _buildSocialButton(

                      text: "Continuer with Google",
                      imagePath: "assets/images/google.png",
                      onTap: authController.isLoading
                          ? null
                          : () => authController.signInWithGoogle(),
                      isLoading: authController.isGoogleLoading.value,
                      backgroundColor: AppTheme.authPrimaryGold.withOpacity(0.1),
                      textColor: Colors.white,
                    
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildDivider(),

                  const SizedBox(height: 24),

                  _buildPrimaryButton(
                    text: "Log In",
                    onTap: () => Get.toNamed(AppConstants.routeEmailLogin),
                    backgroundColor: AppTheme.authPrimaryGold,
                    textColor: Colors.black,
                  ),

                  const SizedBox(height: 16),

                  _buildOutlinedButton(
                    text: "Sign Up",
                    onTap: () => Get.toNamed(AppConstants.routeRegister),
                    borderColor: AppTheme.authPrimaryGold,
                    textColor: AppTheme.authPrimaryGold,
                  ),

                  const SizedBox(height: 48),

                  // Terms and Policy
                  _buildTermsAndPolicy(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required String imagePath,
    VoidCallback? onTap,
    bool isLoading = false,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.authPrimaryGold.withOpacity(0.3),width:1),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.black,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(imagePath, height: 20),
                    const SizedBox(width: 12),
                    Text(
                      text,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onTap,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required String text,
    required VoidCallback onTap,
    required Color borderColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or",
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white.withOpacity(0.5))),
      ],
    );
  }

  Widget _buildTermsAndPolicy() {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            final url = Uri.parse("https://www.brahmakosh.com/privacy-policy");
            if (await canLaunchUrl(url)) await launchUrl(url);
          },
          child: Text(
            "Privacy and Policy",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppTheme.authTextSecondary.withOpacity(0.7),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}

extension on AuthController {
  bool get isLoading =>
      isGoogleLoading.value || isAppleLoading.value || isEmailLoading.value;
}
