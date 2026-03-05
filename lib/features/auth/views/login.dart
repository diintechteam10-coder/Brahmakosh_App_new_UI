import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/auth/controllers/auth_controller.dart';
import 'package:brahmakosh/features/auth/views/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.landingBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Logo
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                      fit: BoxFit.contain, // Matches landing
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Center(
                child: Text(
                  "BRAHMAKOSH",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5D4037),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: Text(
                  "Your Spiritual operating System",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xff5D4037),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Email Field
              AuthInputField(
                controller: authController.emailController,
                hint: "Email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              // Password Field
              Obx(
                () => AuthInputField(
                  controller: authController.passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: authController.isLoginPasswordHidden.value,
                  suffix: GestureDetector(
                    onTap: () {
                      authController.isLoginPasswordHidden.value =
                          !authController.isLoginPasswordHidden.value;
                    },
                    child: Icon(
                      authController.isLoginPasswordHidden.value
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Colors.black45,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => ForgotPasswordView()),
                  child: Text(
                    "Forgot Password?",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Login Button
              Obx(() {
                return GestureDetector(
                  onTap: authController.isEmailLoading.value
                      ? null
                      : () {
                          authController.loginWithEmail();
                        },
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.landingButton,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: authController.isEmailLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Log In",
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // OR Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: const Color(0xff5D4037).withOpacity(0.2),
                    ),
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
                    child: Divider(
                      color: const Color(0xff5D4037).withOpacity(0.2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Continue with Google
              Obx(() {
                return GestureDetector(
                  onTap:
                      authController.isGoogleLoading.value ||
                          authController.isAppleLoading.value ||
                          authController.isEmailLoading.value
                      ? null
                      : () {
                          authController.signInWithGoogle();
                        },
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffFDFDFD),
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
                        Image.asset(
                          "assets/images/google.png",
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        authController.isGoogleLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xff755C3B),
                                ),
                              )
                            : Text(
                                "Continue with Google",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff755C3B),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Continue with Apple
              Obx(() {
                return GestureDetector(
                  onTap:
                      authController.isGoogleLoading.value ||
                          authController.isAppleLoading.value ||
                          authController.isEmailLoading.value
                      ? null
                      : () {
                          authController.signInWithApple();
                        },
                  child: Container(
                    height: 54,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
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
                        const Icon(Icons.apple, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        authController.isAppleLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Continue with Apple",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

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

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account? ",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppConstants.routeRegister),
                    child: Text(
                      "Sign Up",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff5D4037),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xffFDFDFD), // Slightly off-white
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12), // Subtle border
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.inter(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(color: Colors.black45),
          prefixIcon: Icon(icon, color: const Color(0xff8D6E63), size: 22),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
