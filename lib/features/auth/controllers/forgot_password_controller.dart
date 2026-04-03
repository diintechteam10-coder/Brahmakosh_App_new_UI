import 'dart:convert';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/auth/views/reset_password.dart';
import 'package:brahmakosh/features/auth/views/verify_reset_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/core/utils/app_snackbar.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isOtpLoading = false.obs;
  final isResetLoading = false.obs;

  String? resetToken;
  String? userEmail;

  /// 1️⃣ Request forgot password OTP
  Future<void> requestForgotPassword() async {
    if (emailController.text.isEmpty) {
      AppSnackBar.showError("Error", "Please enter your email");
      return;
    }

    final email = emailController.text.trim();

    // Basic email validation
    if (!GetUtils.isEmail(email)) {
      AppSnackBar.showError("Error", "Please enter a valid email");
      return;
    }

    isLoading.value = true;

    try {
      final requestBody = {"email": email, "clientId": "CLI-KBHUMT"};

      print("📤 Requesting forgot password for: $email");
      print("➡️ API URL: ${ApiUrls.forgotPassword}");

      await callWebApi(
        null,
        ApiUrls.forgotPassword,
        requestBody,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) async {
          isLoading.value = false;
          try {
            final responseBody = json.decode(response.body);
            print("✅ Forgot password response: $responseBody");

            if (responseBody['otp'] != null) {
              print("YOUR OTP IS: ${responseBody['otp']}");
            } else if (responseBody['data'] != null &&
                responseBody['data']['otp'] != null) {
              print("YOUR OTP IS: ${responseBody['data']['otp']}");
            }

            if (response.statusCode == 200 || response.statusCode == 201) {
              userEmail = email;
              AppSnackBar.showSuccess(
                "Success",
                responseBody['message'] ?? "OTP sent to your email",
              );
              // Navigate to OTP verification page
              Get.to(() => VerifyResetOtpView(email: email));
            } else {
              final message = responseBody['message'] ?? "Failed to send OTP";
              AppSnackBar.showError("Error", message);
            }
          } catch (e) {
            print("❌ Error parsing response: $e");
            AppSnackBar.showError("Error", "Failed to send OTP");
          }
        },
        onError: (error) {
          isLoading.value = false;
          print("❌ Forgot password error: $error");
          AppSnackBar.showError("Error", "Failed to send OTP. Please try again.");
        },
      );
    } catch (e) {
      isLoading.value = false;
      print("❌ Error: $e");
      AppSnackBar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  /// 2️⃣ Verify reset OTP
  Future<void> verifyResetOtp({required String email}) async {
    if (otpController.text.isEmpty) {
      AppSnackBar.showError("Error", "Please enter OTP");
      return;
    }

    isOtpLoading.value = true;

    try {
      final requestBody = {
        "email": email,
        "otp": otpController.text.trim(),
        "clientId": "CLI-KBHUMT",
      };

      print("📤 Verifying reset OTP for: $email");
      print("➡️ API URL: ${ApiUrls.verifyResetOtp}");

      await callWebApi(
        null,
        ApiUrls.verifyResetOtp,
        requestBody,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) async {
          isOtpLoading.value = false;
          try {
            final responseBody = json.decode(response.body);
            print("✅ Verify OTP response: $responseBody");

            if (response.statusCode == 200 || response.statusCode == 201) {
              // Extract reset token from response
              resetToken =
                  responseBody['data']?['resetToken'] ??
                  responseBody['resetToken'] ??
                  responseBody['data']?['token'];
              userEmail = email;

              AppSnackBar.showSuccess(
                "Success",
                responseBody['message'] ?? "OTP verified successfully",
              );

              // Navigate to reset password page
              Get.to(
                () => ResetPasswordView(
                  email: email,
                  resetToken: resetToken ?? '',
                ),
              );
            } else {
              final message = responseBody['message'] ?? "Invalid OTP";
              AppSnackBar.showError("Error", message);
            }
          } catch (e) {
            print("❌ Error parsing response: $e");
            AppSnackBar.showError("Error", "Failed to verify OTP");
          }
        },
        onError: (error) {
          isOtpLoading.value = false;
          print("❌ Verify OTP error: $error");
          AppSnackBar.showError("Error", "Failed to verify OTP. Please try again.");
        },
      );
    } catch (e) {
      isOtpLoading.value = false;
      print("❌ Error: $e");
      AppSnackBar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  /// 3️⃣ Reset password
  Future<void> resetPassword({
    required String email,
    required String resetToken,
  }) async {
    if (newPasswordController.text.isEmpty) {
      AppSnackBar.showError("Error", "Please enter new password");
      return;
    }

    if (newPasswordController.text.length < 6) {
      AppSnackBar.showError("Error", "Password must be at least 6 characters");
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      AppSnackBar.showError("Error", "Passwords do not match");
      return;
    }

    isResetLoading.value = true;

    try {
      final requestBody = {
        "email": email,
        "resetToken": resetToken,
        "newPassword": newPasswordController.text.trim(),
        "clientId": "CLI-KBHUMT",
      };

      print("📤 Resetting password for: $email");
      print("➡️ API URL: ${ApiUrls.resetPassword}");

      await callWebApi(
        null,
        ApiUrls.resetPassword,
        requestBody,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) async {
          isResetLoading.value = false;
          try {
            final responseBody = json.decode(response.body);
            print("✅ Reset password response: $responseBody");

            if (response.statusCode == 200 || response.statusCode == 201) {
              AppSnackBar.showSuccess(
                "Success",
                responseBody['message'] ?? "Password reset successfully",
              );

              // Navigate back to login screen
              Future.delayed(const Duration(seconds: 1), () {
                Get.offAllNamed(AppConstants.routeLogin);
              });
            } else {
              final message =
                  responseBody['message'] ?? "Failed to reset password";
              AppSnackBar.showError("Error", message);
            }
          } catch (e) {
            print("❌ Error parsing response: $e");
            AppSnackBar.showError("Error", "Failed to reset password");
          }
        },
        onError: (error) {
          isResetLoading.value = false;
          print("❌ Reset password error: $error");
          AppSnackBar.showError("Error", "Failed to reset password. Please try again.");
        },
      );
    } catch (e) {
      isResetLoading.value = false;
      print("❌ Error: $e");
      AppSnackBar.showError("Error", "Something went wrong. Please try again.");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
