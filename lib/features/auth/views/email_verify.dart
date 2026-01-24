import 'package:brahmakosh/core/custom_widgets/auth_logo.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/email_verify_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailOtpView extends StatelessWidget {
  final String email;

  EmailOtpView({super.key, required this.email});

  // Use Get.put to create controller for this page
  final EmailOtpController controller = Get.put(EmailOtpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFDFD),
      resizeToAvoidBottomInset: false, // Prevent bottom text from moving with keyboard
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// CONTENT
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const AuthLogoAvatar(),
                  const SizedBox(height: 20),

                  Text(
                    "Brahmakosh",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Verify OTP sent to your email",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// OTP FIELD
                  TextField(
                    controller: controller.otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter OTP",
                      hintStyle: GoogleFonts.inter(fontSize: 13),
                      prefixIcon: const Icon(Icons.lock_outline),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.black12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: AppTheme.primaryGold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  /// VERIFY BUTTON
                  Obx(
                    () => InkWell(
                      borderRadius: BorderRadius.circular(30),
                      onTap: controller.isLoading.value
                          ? null
                          : () => controller.verifyOtp(email: email),
                      child: Container(
                        height: 54,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                )
                              : Text(
                                  "Verify OTP",
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SizedBox(height: 90),
                ],
              ),
            ),

            /// PRIVACY - Fixed at bottom, doesn't move with keyboard
            Positioned(
              bottom: 20,
              left: 24,
              right: 24,
              child: Text(
                "By continuing, you agree to our Terms & Privacy Policy",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
