import 'dart:convert';
import 'package:brahmakosh/common/api_urls.dart';

import 'package:brahmakosh/features/auth/views/email_verify.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  /// 🔐 REGISTER STEP 1 (EMAIL + PASSWORD)
  Future<void> registerStep1() async {
    print("📩 Register Step 1 called");

    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar("Error", "Email & Password required");
      return;
    }

    final payload = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "clientId": "CLI-KBHUMT",
    };

    print("➡️ API URL: ${ApiUrls.emailRegister}");
    print("➡️ Request Body: $payload");

    try {
      isLoading.value = true;
      print("⏳ Loading started");

      final response = await http.post(
        Uri.parse(ApiUrls.emailRegister),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("⬅️ Status Code: ${response.statusCode}");
      print("⬅️ Raw Response: ${response.body}");

      final data = jsonDecode(response.body);
      print("⬅️ Decoded Response: $data");

      if (data['otp'] != null) {
        print("YOUR OTP IS: ${data['otp']}");
      } else if (data['data'] != null && data['data']['otp'] != null) {
        print("YOUR OTP IS: ${data['data']['otp']}");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Registration step 1 success");

        Get.snackbar("Success", "OTP sent to your email");

        Get.to(() => EmailOtpView(email: emailController.text.trim()));
      } else {
        print("❌ API Error: ${data['message']}");

        Get.snackbar("Error", data['message'] ?? "Something went wrong");
      }
    } catch (e, stack) {
      print("🔥 Exception occurred");
      print("Error: $e");
      print("StackTrace: $stack");

      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
      print("✅ Loading stopped");
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
