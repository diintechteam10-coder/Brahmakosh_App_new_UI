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
      backgroundColor: AppTheme.landingBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo
              Container(
                width: 160,
                height: 160,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                    fit: BoxFit
                        .contain, // Changed to contain to avoid cropping if it has no background
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "BRAHMAKOSH",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Your Spiritual operating System",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xff5D4037),
                ),
              ),

              const Spacer(),

              // Continue with Google
              Obx(
                () => _buildButton(
                  text: "Continue with Google",
                  imagePath: "assets/images/google.png",
                  onTap:
                      authController.isGoogleLoading.value ||
                          authController.isAppleLoading.value ||
                          authController.isEmailLoading.value
                      ? null
                      : () {
                          authController.signInWithGoogle();
                        },
                  isLoading: authController.isGoogleLoading.value,
                  backgroundColor: const Color(0xffFDFDFD),
                  textColor: const Color(0xff755C3B),
                ),
              ),

              const SizedBox(height: 16),

              // Continue with Apple
              Obx(
                () => _buildButton(
                  text: "Continue with Apple",
                  icon: Icons.apple,
                  onTap:
                      authController.isGoogleLoading.value ||
                          authController.isAppleLoading.value ||
                          authController.isEmailLoading.value
                      ? null
                      : () {
                          authController.signInWithApple();
                        },
                  isLoading: authController.isAppleLoading.value,
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              OrDivider(),

              const SizedBox(height: 16),

              // Log In
              _buildButton(
                text: "Log In",
                onTap: () {
                  Get.toNamed(AppConstants.routeEmailLogin);
                },
                backgroundColor: AppTheme.landingButton,
                textColor: Colors.white,
              ),

              const SizedBox(height: 16),

              // Sign Up
              _buildButton(
                text: "Sign Up",
                onTap: () {
                  Get.toNamed(AppConstants.routeRegister);
                },
                backgroundColor: AppTheme.landingButton,
                textColor: Colors.white,
              ),

              const SizedBox(height: 48),

              // Terms and Conditions text (Replaced Checkbox)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "By continuing, you agree to our ",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                    children: [
                      TextSpan(
                        text: "Terms and Conditions",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff5D4037),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.parse(
                              "https://www.brahmakosh.com/privacy-policy",
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    VoidCallback? onTap,
    String? imagePath,
    IconData? icon,
    bool isLoading = false,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              Image.asset(imagePath, height: 24, width: 24),
              const SizedBox(width: 12),
            ] else if (icon != null) ...[
              Icon(icon, color: textColor, size: 28),
              const SizedBox(width: 12),
            ],

            isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  )
                : Text(
                    text,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: const Color(0xff5D4037).withOpacity(0.2)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xff5D4037).withOpacity(0.6),
            ),
          ),
        ),
        Expanded(
          child: Divider(color: const Color(0xff5D4037).withOpacity(0.2)),
        ),
      ],
    );
  }
}
