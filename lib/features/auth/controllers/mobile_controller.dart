import 'dart:convert';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/features/auth/views/complete_profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class MobileOtpController extends GetxController {
  /// 📧 email from step-1 (REQUIRED)
  final String email;

  MobileOtpController({required this.email});

  /// state
  RxBool isOtpSent = false.obs;
  RxBool isLoading = false.obs;

  /// controllers
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  /// observables for dynamic logic
  RxString countryCode = "91".obs; // Default to India
  RxString selectedChannel = "whatsapp".obs; // 'whatsapp' or 'phone'

  @override
  void onInit() {
    super.onInit();
    print("📧 MobileOtpController INIT with email = $email");
  }

  /// ✏️ EDIT NUMBER
  void editNumber() {
    otpController.clear();
    isOtpSent.value = false;
  }

  /// 🔁 RESEND OTP
  Future<void> resendOtp() async {
    await sendOtp();
  }

  Future<void> sendOtp() async {
    print("📞 SEND OTP CALLED");

    final mobile = phoneController.text.trim();

    if (mobile.isEmpty) {
      Get.snackbar("Error", "Enter mobile number");
      return;
    }

    // Determine OTP Method
    String otpMethod = "whatsapp";
    if (selectedChannel.value == "phone") {
      // otpMethod = (countryCode.value == "91") ? "gupshup" : "twilio";
      otpMethod = "twilio";
    }

    final fullMobile = "+${countryCode.value}$mobile";

    final payload = {
      "email": email.trim(),
      "mobile": fullMobile,
      "otpMethod": otpMethod,
      "clientId": "CLI-KBHUMT",
    };

    print("➡️ Sending OTP to $fullMobile via $otpMethod");
    print("➡️ API URL: ${ApiUrls.mobileRegister}");
    print("➡️ PAYLOAD JSON: ${jsonEncode(payload)}");

    try {
      isLoading.value = true;
      print("⏳ Loading = TRUE");

      final res = await http.post(
        Uri.parse(ApiUrls.mobileRegister),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode(payload), // 🔥 MUST BE JSON
      );

      print("⬅️ STATUS: ${res.statusCode}");
      print("⬅️ RAW RESPONSE: ${res.body}");

      final data = jsonDecode(res.body);
      print("⬅️ DECODED RESPONSE: $data");

      if (otpMethod == "whatsapp") {
        print("🟢 WHATSAPP OTP REQUESTED");
      }

      if (data['otp'] != null) {
        print("YOUR OTP IS: ${data['otp']}");
      } else if (data['data'] != null && data['data']['otp'] != null) {
        print("YOUR OTP IS: ${data['data']['otp']}");
      } else {
        print(
          "❌ OTP NOT FOUND IN RESPONSE (Check backend logs or if it's disabled in prod)",
        );
      }

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("✅ OTP SENT SUCCESSFULLY");
        isOtpSent.value = true;
        Get.snackbar("Success", data['message'] ?? "OTP sent to mobile");
      } else {
        print("❌ API ERROR: ${data['message']}");
        Get.snackbar("Error", data['message'] ?? "Failed to send OTP");
      }
    } catch (e, stack) {
      print("🔥 EXCEPTION: $e");
      print("🔥 STACK TRACE: $stack");
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
      print("✅ Loading = FALSE");
    }
  }

  Future<void> verifyOtp() async {
    print("🔐 VERIFY OTP CALLED");

    if (otpController.text.length != 6) {
      print("❌ Invalid OTP: ${otpController.text}");
      Get.snackbar("Error", "Enter valid OTP");
      return;
    }

    // Determine OTP Method for verification too (if original API requires it)
    String otpMethod = "whatsapp";
    if (selectedChannel.value == "phone") {
      // otpMethod = (countryCode.value == "91") ? "gupshup" : "twilio";
      otpMethod = "twilio";
    }

    final payload = {
      "email": email,
      "otp": otpController.text.trim(),
      "otpMethod": otpMethod,
      "clientId": "CLI-KBHUMT",
    };

    print("➡️ VERIFY API: ${ApiUrls.mobileVerify}");
    print("➡️ PAYLOAD: $payload");

    try {
      isLoading.value = true;

      final res = await http.post(
        Uri.parse(ApiUrls.mobileVerify),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("⬅️ STATUS: ${res.statusCode}");
      print("⬅️ RESPONSE: ${res.body}");

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 || res.statusCode == 201) {
        print("🎉 MOBILE VERIFICATION COMPLETE");
        Get.snackbar("Success", "Mobile verified successfully");

        /// 👉 Navigate to complete profile with email
        print("➡️ Navigating to Complete Profile with email: $email");
        Get.offAll(() => CompleteProfileView(email: email));
      } else {
        print("❌ VERIFY FAILED: ${data['message']}");
        Get.snackbar("Error", data['message'] ?? "Invalid OTP");
      }
    } catch (e, stack) {
      print("🔥 VERIFY ERROR: $e");
      print("🔥 STACK: $stack");
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
