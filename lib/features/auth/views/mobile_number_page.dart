import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/core/custom_widgets/auth_logo.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/mobile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:lottie/lottie.dart';

class PhoneOtpView extends StatelessWidget {
  PhoneOtpView({super.key});

  final controller = Get.find<MobileOtpController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFDFDFD),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.cardBackground.withOpacity(0.5),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Extra spacing for AppBar
                /// 🧘 LOTTIE ANIMATION
                Center(
                  child: Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.1),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Lottie.asset(
                      "assets/lotties/Meditating.json",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  "Brahmakosh",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),

                const SizedBox(height: 10),

                /// 🔹 SUB TITLE & CONTENT
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Obx(
                    () => Column(
                      key: ValueKey(controller.isOtpSent.value),
                      children: [
                        Text(
                          controller.isOtpSent.value
                              ? "A 6-digit code has been sent to your ${controller.selectedChannel.value == "whatsapp" ? "WhatsApp" : "Phone"}"
                              : "Select your preferred way to receive the verification code",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.black45,
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 25),

                        if (!controller.isOtpSent.value) ...[
                          /// 🔘 OTP METHOD SELECTOR
                          Row(
                            children: [
                              Expanded(
                                child: _methodTile(
                                  title: "WhatsApp",
                                  icon: Icons.chat_bubble_outline,
                                  isSelected:
                                      controller.selectedChannel.value ==
                                      "whatsapp",
                                  onTap: () =>
                                      controller.selectedChannel.value =
                                          "whatsapp",
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _methodTile(
                                  title: "Text SMS",
                                  icon: Icons.phone_android,
                                  isSelected:
                                      controller.selectedChannel.value ==
                                      "phone",
                                  onTap: () =>
                                      controller.selectedChannel.value =
                                          "phone",
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          /// 📱 PHONE INPUT
                          _input(
                            textController: controller.phoneController,
                            hint:
                                "${controller.selectedChannel.value == "whatsapp" ? "WhatsApp" : "Mobile"} Number",
                            assetPath:
                                controller.selectedChannel.value == "whatsapp"
                                ? "assets/images/whatsapp.png"
                                : null,
                            icon: controller.selectedChannel.value == "phone"
                                ? Icons.phone_outlined
                                : null,
                            keyboard: TextInputType.phone,
                          ),
                        ] else ...[
                          /// 📲 OTP SENT STATE INFO
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppTheme.lightGoldGradient,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.primaryGold.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "+${controller.countryCode.value} ${controller.phoneController.text}",
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    InkWell(
                                      onTap: controller.editNumber,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          "Edit",
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppTheme.primaryGold,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          /// 🔐 OTP INPUT
                          _input(
                            textController: controller.otpController,
                            hint: "Enter Verification Code",
                            icon: Icons.security_outlined,
                            keyboard: TextInputType.number,
                          ),

                          const SizedBox(height: 15),

                          /// 🔁 RESEND
                          InkWell(
                            onTap: controller.isLoading.value
                                ? null
                                : controller.resendOtp,
                            child: Text(
                              "Didn’t receive the code? Resend",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppTheme.primaryGold,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 35),

                        /// 🔘 ACTION BUTTON
                        InkWell(
                          onTap: controller.isLoading.value
                              ? null
                              : controller.isOtpSent.value
                              ? controller.verifyOtp
                              : controller.sendOtp,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            height: 52,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.3),
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
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      controller.isOtpSent.value
                                          ? "VERIFY & CONTINUE"
                                          : "GET VERIFICATION CODE",
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                /// PRIVACY
                Text(
                  "By continuing, you agree to our Terms of Service and Privacy Policy",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.black38,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController textController,
    required String hint,
    required TextInputType keyboard,

    /// optional
    IconData? icon,
    String? assetPath,
  }) {
    if (keyboard == TextInputType.phone) {
      return IntlPhoneField(
        controller: textController,
        initialCountryCode: 'IN',
        disableLengthCheck: true,
        textAlignVertical: TextAlignVertical.center,
        style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 24,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryGold.withOpacity(0.1),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryGold.withOpacity(0.1),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppTheme.primaryGold,
              width: 1.5,
            ),
          ),
        ),
        languageCode: "en",
        onChanged: (phone) {
          controller.countryCode.value = phone.countryCode.replaceAll("+", "");
          print("Full number: ${phone.completeNumber}");
        },
        onCountryChanged: (country) {
          controller.countryCode.value = country.dialCode;
          print('Country changed to: ' + country.name);
        },
      );
    }
    return TextField(
      controller: textController,
      keyboardType: keyboard,
      textAlignVertical: TextAlignVertical.center,
      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (keyboard == TextInputType.number)
          LengthLimitingTextInputFormatter(6),
      ],
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: _buildPrefixIcon(icon, assetPath),
        hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primaryGold.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.primaryGold.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
        ),
      ),
    );
  }

  Widget? _buildPrefixIcon(IconData? icon, String? assetPath) {
    if (assetPath != null) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Image.asset(
          assetPath,
          width: 20,
          height: 20,
          fit: BoxFit.contain,
        ),
      );
    }

    if (icon != null) {
      return Icon(icon);
    }

    return null; // no icon
  }

  Widget _methodTile({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGold
                : AppTheme.primaryGold.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : Colors.black45,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
