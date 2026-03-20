import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/auth/controllers/forgot_password_controller.dart';
import 'package:brahmakosh/features/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordView extends StatelessWidget {
  final String email;
  final String resetToken;

  ResetPasswordView({super.key, required this.email, required this.resetToken});

  final ForgotPasswordController controller = Get.find<ForgotPasswordController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.authBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),

                  // Circular Gold Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.authPrimaryGold, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: Text(
                      "Reset Password",
                      style: GoogleFonts.lora(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Text(
                      "Choose a strong password to secure your spiritual journey",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppTheme.authTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  _label("New Password"),
                  AuthInputField(
                    controller: controller.newPasswordController,
                    hint: "Enter new password",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 24),

                  _label("Confirm Password"),
                  AuthInputField(
                    controller: controller.confirmPasswordController,
                    hint: "Confirm new password",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),

                  const SizedBox(height: 48),

                  /// RESET PASSWORD BUTTON
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isResetLoading.value
                          ? null
                          : () => controller.resetPassword(
                                email: email,
                                resetToken: resetToken,
                              ),
                      child: Container(
                        height: 56,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.authPrimaryGold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!controller.isResetLoading.value)
                              BoxShadow(
                                color: AppTheme.authPrimaryGold.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                          ],
                        ),
                        child: Center(
                          child: controller.isResetLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "Confirm New Password",
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                        ),
                      ),
                    ),
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.authTextSecondary.withOpacity(0.7),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
