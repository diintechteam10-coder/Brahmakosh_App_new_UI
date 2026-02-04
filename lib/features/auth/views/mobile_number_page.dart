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
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    "Verify Mobile Number",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28, // Matches Login Title Size
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    "We need to verify your number for security.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xff5D4037), // Matches subtitle color
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                if (controller.isOtpSent.value) ...[
                  // OTP SENT STATE
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffFFFDE7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.primaryGold.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      "OTP sent to your mobile number",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xff5D4037),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  _label("Enter OTP"),
                  const SizedBox(height: 12),

                  // Custom OTP Input
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Visual Boxes
                      GetBuilder<MobileOtpController>(
                        builder: (_) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final text = controller.otpController.text;
                              final char = index < text.length
                                  ? text[index]
                                  : "";
                              final isFocused = index == text.length;

                              return Container(
                                width: 50,
                                height:
                                    56, // Slightly taller for the rounded look
                                decoration: BoxDecoration(
                                  color: const Color(0xffFDFDFD),
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ), // Softer corners
                                  border: Border.all(
                                    color: isFocused
                                        ? AppTheme.landingButton
                                        : Colors.black.withOpacity(0.1),
                                    width: isFocused ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    char,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xff5D4037),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          );
                        },
                      ),

                      // Invisible TextField
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
                          controller.otpController.text = val;
                          controller.update();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // Verify Button
                  _buildButton(
                    text: "Verify",
                    onTap: controller.isLoading.value
                        ? null
                        : controller.verifyOtp,
                    isLoading: controller.isLoading.value,
                  ),
                ] else ...[
                  // MOBILE NUMBER INPUT STATE
                  _label("Mobile Number"),
                  const SizedBox(height: 8),

                  // Mobile Input Field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xffFDFDFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: IntlPhoneField(
                      controller: controller.phoneController,
                      initialCountryCode: 'IN',
                      disableLengthCheck: true,
                      dropdownIconPosition: IconPosition.trailing,
                      flagsButtonPadding: const EdgeInsets.only(left: 10),
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "98765 43210",
                        hintStyle: GoogleFonts.inter(color: Colors.black38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        counterText: "", // Hide character counter
                      ),
                      onChanged: (phone) {
                        controller.countryCode.value = phone.countryCode
                            .replaceAll("+", "");
                      },
                      onCountryChanged: (country) {
                        controller.countryCode.value = country.dialCode;
                      },
                    ),
                  ),

                  const SizedBox(height: 32),

                  _label("Send OTP Via"),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Whatsapp Card
                      Expanded(
                        child: _methodCard(
                          title: "WhatsApp",
                          icon: FontAwesomeIcons.whatsapp,
                          isSelected:
                              controller.selectedChannel.value == "whatsapp",
                          onTap: () =>
                              controller.selectedChannel.value = "whatsapp",
                          iconColor: const Color(
                            0xff25D366,
                          ), // WhatsApp brand green
                          selectedBorderColor: const Color(0xff25D366),
                          bgColor: const Color(0xffEFFBF3), // Very light green
                        ),
                      ),
                      const SizedBox(width: 16),
                      // SMS Card
                      Expanded(
                        child: _methodCard(
                          title: "SMS",
                          icon: Icons.sms_outlined,
                          isSelected:
                              controller.selectedChannel.value == "phone",
                          onTap: () =>
                              controller.selectedChannel.value = "phone",
                          iconColor: const Color(0xff5D4037),
                          selectedBorderColor: const Color(
                            0xff5D4037,
                          ), // Brown border
                          bgColor: const Color(
                            0xffFFF8E1,
                          ), // Light brown/beige BG
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Send OTP Button
                  _buildButton(
                    text: "Send OTP",
                    onTap: controller.isLoading.value
                        ? null
                        : controller.sendOtp,
                    isLoading: controller.isLoading.value,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xff5D4037),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _methodCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? iconColor,
    Color? selectedBorderColor,
    Color? bgColor,
  }) {
    // If selected, use specific styling
    final Color backgroundColor = isSelected
        ? (bgColor ?? Colors.white)
        : const Color(0xffFDFDFD);
    final Color borderColor = isSelected
        ? (selectedBorderColor ?? AppTheme.landingButton)
        : Colors.transparent;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? borderColor : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (selectedBorderColor ?? const Color(0xff5D4037))
                  : Colors.black45,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? (selectedBorderColor ?? const Color(0xff5D4037))
                    : Colors.black45,
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
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.landingButton,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
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
                    color: Colors.white,
                  ),
                )
              : Text(
                  text,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
