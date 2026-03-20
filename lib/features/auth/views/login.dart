import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/auth/controllers/auth_controller.dart';
import 'package:brahmakosh/features/auth/views/forgot_password.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:brahmakosh/core/common_imports.dart';

class LoginView extends StatelessWidget {
  LoginView({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
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
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),

                  // Premium Gold Logo
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.authPrimaryGold.withOpacity(0.15),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        image: const DecorationImage(
                          image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  // const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "BRAHMAKOSH",
                      style: GoogleFonts.lora(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.authPrimaryGold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                   const SizedBox(height: 8),

                  Center(
                    child: Text(
                      "Your Spiritual Operating System",
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        color: AppTheme.authTextSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),


                  const SizedBox(height: 36),

                  // Text(
                  //   "Welcome Back",
                  //   style: GoogleFonts.lora(
                  //     fontSize: 28,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                  // const SizedBox(height: 8),
                  // Text(
                  //   "Login to continue your spiritual journey",
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 14,
                  //     color: AppTheme.authTextSecondary,
                  //   ),
                  // ),

                  // const SizedBox(height: 32),

                  // Email Field
                  AuthInputField(
                    controller: authController.emailController,
                    hint: "Email Address",
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
                          color: AppTheme.authTextSecondary.withOpacity(0.5),
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
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.authPrimaryGold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Login Button
                  Obx(() => _buildPrimaryButton(
                    text: "Log In",
                    onTap: authController.isEmailLoading.value ? null : () => authController.loginWithEmail(),
                    isLoading: authController.isEmailLoading.value,
                    backgroundColor: AppTheme.authPrimaryGold,
                    textColor: Colors.black,
                  )),

                  const SizedBox(height: 32),

                  // OR Divider
                  _buildDivider(),

                  const SizedBox(height: 32),

                  // Continue with Google
                  Obx(() => _buildSocialButton(
                    text: "Continue with Google",
                    imagePath: "assets/images/google.png",
                    onTap: authController.isLoading ? null : () => authController.signInWithGoogle(),
                    isLoading: authController.isGoogleLoading.value,
                    backgroundColor: AppTheme.authPrimaryGold.withOpacity(0.1),
                    textColor: Colors.white,
                  )),

                  const SizedBox(height: 48),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.authTextSecondary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed(AppConstants.routeRegister),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.authPrimaryGold,
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
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback? onTap,
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
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            if (onTap != null)
              BoxShadow(
                color: backgroundColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : Text(
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
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.authPrimaryGold.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
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

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or login with",
            style: GoogleFonts.poppins(
              color: Color(0xffD9D9D9),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.white)),
      ],
    );
  }
}

class AuthInputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final TextInputType? keyboardType;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.authInputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppTheme.authInputFill,
          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.35)),
          prefixIcon: Icon(icon, color: AppTheme.authPrimaryGold.withOpacity(0.7), size: 22),
          suffixIcon: suffix,
           border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  ),

  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  ),

        focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
         color: AppTheme.authPrimaryGold,
         width: 1.5,
          ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

extension on AuthController {
  bool get isLoading => isGoogleLoading.value || isAppleLoading.value || isEmailLoading.value;
}
