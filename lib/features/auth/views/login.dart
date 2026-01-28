import 'package:brahmakosh/core/custom_widgets/auth_logo.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/auth/controllers/auth_controller.dart';
import 'package:brahmakosh/features/auth/views/email_register_view.dart';
import 'package:brahmakosh/features/auth/views/forgot_password.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPhoneView extends StatelessWidget {
  LoginPhoneView({super.key});

  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 15),

              const AuthLogoAvatar(),
              const SizedBox(height: 8),

              Text(
                "Brahmakosh",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                "Login to your account",
                style: GoogleFonts.inter(fontSize: 13, color: Colors.black45),
              ),

              const SizedBox(height: 20),

              /// 🧾 EMAIL + PASSWORD CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Email Address",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),

                    AuthInputField(
                      controller: authController.emailController,
                      hint: "Enter your email",
                      icon: Icons.email_outlined,
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Password",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),

                    AuthInputField(
                      controller: authController.passwordController,
                      hint: "Enter your password",
                      icon: Icons.lock_outline,
                      obscure: true,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Get.to(() => ForgotPasswordView()),
                      child: Text(
                        "Forget Password",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.primaryGold,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              AppTheme.primaryGold, // 👈 underline color
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// 🔐 LOGIN BUTTON (inside card)
                    Obx(
                      () => GestureDetector(
                        onTap: authController.isEmailLoading.value
                            ? null
                            : authController.loginWithEmail,
                        child: Container(
                          height: 48,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGold,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: authController.isEmailLoading.value
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Login",
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

              const SizedBox(height: 22),

              /// OR
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.black12)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "OR",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.black12)),
                ],
              ),

              const SizedBox(height: 22),

              /// 🔐 GOOGLE LOGIN
              Obx(
                () => GestureDetector(
                  onTap: authController.isLoading.value
                      ? null
                      : authController.signInWithGoogle,
                  child: Container(
                    height: 48,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        authController.isLoading.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Image.asset(
                                "assets/images/google.png",
                                height: 18,
                              ),
                        const SizedBox(width: 10),
                        Text(
                          "Continue with Google",
                          style: GoogleFonts.inter(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              /// 📝 SIGN UP
              GestureDetector(
                onTap: () => Get.to(() => EmailRegisterView()),
                child: Text(
                  "Don’t have an account? Sign Up",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),

              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Checkbox(
                      value: authController.isPrivacyPolicyAccepted.value,
                      onChanged: (value) {
                        authController.isPrivacyPolicyAccepted.value =
                            value ?? false;
                      },
                      activeColor: AppTheme.primaryGold,
                    ),
                  ),
                  Expanded(
                    child: RichText(
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
                  ),
                ],
              ),

              const SizedBox(height: 16),
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

  const AuthInputField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: GoogleFonts.inter(fontSize: 13.5),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xffFAFAFA),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppTheme.primaryGold),
        ),
      ),
    );
  }
}
