import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/auth/controllers/email_verify_controller.dart';
import 'package:brahmakosh/features/auth/views/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailOtpView extends StatelessWidget {
  final String email;

  EmailOtpView({super.key, required this.email});

  final EmailOtpController controller = Get.put(EmailOtpController());

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
                children: [
                  const SizedBox(height: 60),

                  // Circular Gold Logo
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // border: Border.all(color: AppTheme.authPrimaryGold, width: 2),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    "Email Verification",
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "We've sent a 6-digit verification code to",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.authTextSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    email,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.authPrimaryGold,
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// OTP FIELD
                  AuthInputField(
                    controller: controller.otpController,
                    hint: "Enter 6-digit OTP",
                    icon: Icons.lock_outline,
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 48),

                  /// VERIFY BUTTON
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.verifyOtp(email: email),
                      child: Container(
                        height: 45,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.authPrimaryGold,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            if (!controller.isLoading.value)
                              BoxShadow(
                                color: AppTheme.authPrimaryGold.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                          ],
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  "Verify & Continue",
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

                  const SizedBox(height: 24),

                  Text(
                    "Didn't receive the code?",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppTheme.authTextSecondary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  GestureDetector(
                    onTap: () {
                      // Add resend logic if available in controller
                    },
                    child: Text(
                      "Resend Code",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.authPrimaryGold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
