import 'dart:convert';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/features/auth/controllers/mobile_controller.dart';
import 'package:brahmakosh/features/auth/views/mobile_number_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class EmailOtpController extends GetxController {
  final otpController = TextEditingController();

  final isLoading = false.obs;

  /// 🔐 VERIFY EMAIL OTP
  Future<void> verifyOtp({
    required String email,
  }) async {
    print("📩 Verify OTP called");

    if (otpController.text.isEmpty) {
      print("❌ OTP empty");
      Get.snackbar("Error", "OTP required");
      return;
    }

    final payload = {
      "email": email,
      "otp": otpController.text.trim(),
      "clientId": "CLI-KBHUMT"
    };

    print("➡️ OTP API URL: ${ApiUrls.emailRegister}");
    print("➡️ OTP Payload: $payload");

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("${ApiUrls.emailRegister}/verify"), // 🔴 change if backend differs
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("⬅️ Status Code: ${response.statusCode}");
      print("⬅️ Response: ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Email OTP verified successfully");

        Get.snackbar("Success", "Email verified");

        /// 👉 Navigate to mobile OTP verification with verified email
        print("➡️ Navigating to Mobile OTP with verified email: $email");
        Get.offAll(
          () => PhoneOtpView(),
          binding: BindingsBuilder(() {
            Get.put(MobileOtpController(email: email));
          }),
        );
      } else {
        print("❌ OTP verify failed");

        Get.snackbar("Error", data['message'] ?? "Invalid OTP");
      }
    } catch (e, s) {
      print("🔥 Exception in OTP verify");
      print(e);
      print(s);

      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
