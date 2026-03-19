import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/mobile_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneOtpView extends StatelessWidget {
  PhoneOtpView({super.key});

  final controller = Get.find<MobileOtpController>();

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    Center(
                      child: Text(
                        controller.isOtpSent.value ? "Verify OTP" : "Phone Verification",
                        style: GoogleFonts.lora(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        controller.isOtpSent.value
                            ? "Enter the 6-digit code sent to your number"
                            : "We'll send you a one-time password to verify your account",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.authTextSecondary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    if (controller.isOtpSent.value) ...[
                      // OTP INPUT STATE
                      _label("Enter OTP"),
                      const SizedBox(height: 16),

                      // Custom OTP Input
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          GetBuilder<MobileOtpController>(
                            builder: (_) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  final text = controller.otpController.text;
                                  final char = index < text.length ? text[index] : "";
                                  final isFocused = index == text.length;

                                  return Container(
                                    width: 48,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: AppTheme.authInputFill,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isFocused
                                            ? AppTheme.authPrimaryGold
                                            : Colors.white.withOpacity(0.1),
                                        width: isFocused ? 1.5 : 1,
                                      ),
                                      boxShadow: [
                                        if (isFocused)
                                          BoxShadow(
                                            color: AppTheme.authPrimaryGold.withOpacity(0.1),
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        char,
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),

                          TextField(
                            controller: controller.otpController,
                            keyboardType: TextInputType.number,
                            maxLength: 6,
                            textAlign: TextAlign.center,
                            showCursor: false,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                            onChanged: (val) {
                              // controller.otpController.text = val; // Removed: redundant
                              controller.update();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      _buildButton(
                        text: "Verify OTP",
                        onTap: controller.isLoading.value ? null : controller.verifyOtp,
                        isLoading: controller.isLoading.value,
                      ),

                      const SizedBox(height: 24),

                      Center(
                        child: TextButton(
                          onPressed: controller.isLoading.value ? null : () => controller.isOtpSent.value = false,
                          child: Text(
                            "Edit Phone Number",
                            style: GoogleFonts.poppins(
                              color: AppTheme.authPrimaryGold,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // MOBILE NUMBER INPUT STATE
                      _label("Mobile Number"),
                      const SizedBox(height: 12),

                      Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.authInputFill,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: IntlPhoneField(
                          controller: controller.phoneController,
                          initialCountryCode: 'IN',
                          disableLengthCheck: true,
                          dropdownIconPosition: IconPosition.trailing,
                          dropdownTextStyle: const TextStyle(color: Colors.white),
                          dropdownIcon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                          flagsButtonPadding: const EdgeInsets.only(left: 12),
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            hintText: "98765 43210",
                            fillColor: Colors.transparent,
                            hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.3)),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            counterText: "",
                          ),
                          onChanged: (phone) {
                            controller.countryCode.value = phone.countryCode.replaceAll("+", "");
                          },
                          onCountryChanged: (country) {
                            controller.countryCode.value = country.dialCode;
                          },
                        ),
                      ),

                      const SizedBox(height: 32),

                      _label("Get OTP Via"),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: _methodCard(
                              title: "WhatsApp",
                              icon: FontAwesomeIcons.whatsapp,
                              isSelected: controller.selectedChannel.value == "whatsapp",
                              onTap: () => controller.selectedChannel.value = "whatsapp",
                              accentColor: const Color(0xff25D366),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _methodCard(
                              title: "SMS",
                              icon: Icons.sms_outlined,
                              isSelected: controller.selectedChannel.value == "phone",
                              onTap: () => controller.selectedChannel.value = "phone",
                              accentColor: AppTheme.authPrimaryGold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      _buildButton(
                        text: "Send OTP",
                        onTap: controller.isLoading.value ? null : controller.sendOtp,
                        isLoading: controller.isLoading.value,
                      ),
                    ],

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: AppTheme.authTextSecondary.withOpacity(0.7),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _methodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.08) : AppTheme.authInputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? accentColor : Colors.white54,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.authPrimaryGold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (onTap != null)
              BoxShadow(
                color: AppTheme.authPrimaryGold.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
          ],
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
              : Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
