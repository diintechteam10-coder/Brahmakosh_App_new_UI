import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/common_imports.dart';
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
                  const SizedBox(height: 20),

                  // Logo (Gold Circular Logo)
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
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

                  const SizedBox(height: 8),

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

                  const SizedBox(height: 48),

                  _label("Email Address"),
                  AuthInputField(
                    controller: controller.emailController,
                    hint: "Enter your email",
                    icon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 24),

                  _label("Create Password"),
                  Obx(
                    () => AuthInputField(
                      controller: controller.passwordController,
                      hint: "Enter your password",
                      icon: Icons.lock_outline,
                      obscure: controller.isPasswordHidden.value,
                      suffix: GestureDetector(
                        onTap: () {
                          controller.isPasswordHidden.value =
                              !controller.isPasswordHidden.value;
                        },
                        child: Icon(
                          controller.isPasswordHidden.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppTheme.authPrimaryGold.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  /// CTA
                  Obx(
                    () => GestureDetector(
                      onTap: controller.isLoading.value
                          ? null
                          : controller.registerStep1,
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
                                  "Create Account",
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

                  const SizedBox(height: 32),

                  /// PRIVACY
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "By continuing, you agree to our ",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppTheme.authTextSecondary,
                          ),
                          children: [
                            TextSpan(
                              text: "\nTerms and Conditions",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.authPrimaryGold,
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
