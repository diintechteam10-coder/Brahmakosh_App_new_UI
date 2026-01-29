import 'package:brahmakosh/core/custom_widgets/auth_logo.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/email_register_controller.dart';
import 'package:brahmakosh/features/auth/views/login.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailRegisterView extends StatelessWidget {
  EmailRegisterView({super.key});

  final RegisterController controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              const AuthLogoAvatar(),
              const SizedBox(height: 18),

              Text(
                "Create Account",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                "Secure your account with email verification",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
              ),

              const SizedBox(height: 30),

              /// 🧾 FORM CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 22,
                      offset: Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label("Email Address"),
                    AuthInputField(
                      controller: controller.emailController,
                      hint: "example@gmail.com",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 16),

                    _label("Password"),
                    AuthInputField(
                      controller: controller.passwordController,
                      hint: "Create strong password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),

                    const SizedBox(height: 22),

                    /// 🔐 CTA
                    Obx(
                      () => GestureDetector(
                        onTap: controller.isLoading.value
                            ? null
                            : controller.registerStep1,
                        child: Container(
                          height: 50,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: controller.isLoading.value
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Send OTP to Email",
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
                  ],
                ),
              ),

              const SizedBox(height: 60),

              /// PRIVACY
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Checkbox(
                      value: controller.isPrivacyPolicyAccepted.value,
                      onChanged: (value) {
                        controller.isPrivacyPolicyAccepted.value =
                            value ?? false;
                      },
                      activeColor: AppTheme.primaryGold,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      text: "I accept the ",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                      children: [
                        TextSpan(
                          text: "Privacy Policy",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGold,
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
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.black54,
        ),
      ),
    );
  }
}
