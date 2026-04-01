import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import '../../../../common/api_services.dart';
import '../../../../common/api_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/services/push_notification_service.dart';

class LoginController extends GetxController {
  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Loading state
  final isLoading = false.obs;

  void login(GlobalKey<FormState> formKey) {
    if (formKey.currentState?.validate() ?? false) {
      _performLogin();
    }
  }

  Future<void> _performLogin() async {
    isLoading.value = true;

    // Prepare request body
    final requestBody = {
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
    };

    await callWebApi(
      null, // TickerProvider - pass null, we'll handle loading with GetX
      ApiUrls.login,
      requestBody,
      onResponse: (response) async {
        isLoading.value = false;
        try {
          final responseBody = json.decode(response.body);

          // Extract token and user data
          final token = responseBody['data']?['token'] ?? '';
          final userId = responseBody['data']?['user']?['_id'] ?? '';
          final email = emailController.text.trim();

          // Save token and session data to SharedPreferences
          if (token.isNotEmpty) {
            await StorageService.setString(AppConstants.keyAuthToken, token);
            await StorageService.setString(AppConstants.keyUserId, userId);
            await StorageService.setString(AppConstants.keyUserEmail, email);
            await StorageService.setBool(AppConstants.keyIsLoggedIn, true);
            print("✅ Token saved to SharedPreferences: $token");
            print("🔑 DEBUG_TOKEN: $token");

            // Initialize Push Notifications
            try {
              await PushNotificationService.instance.initialize();
            } catch (e) {
              print("❌ Push Notification Init Error: $e");
            }
          }

          Get.snackbar(
            'Success',
            responseBody['message'] ?? 'Login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          // Navigate to dashboard
          Get.offAllNamed(AppConstants.routeDashboard);
        } catch (e) {
          print("❌ Error parsing login response: $e");
          Get.snackbar(
            'Success',
            'Login successful!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );
          Get.offAllNamed(
            AppConstants.mobileOtp,
            arguments: emailController.text.trim(),
          );
        }
      },
      onError: (error) {
        isLoading.value = false;
        Get.offAllNamed(AppConstants.routeDashboard);
        if (error is SocketException) {
          Get.snackbar(
            'Connection Error',
            'Unable to connect to server. Please make sure the server is running on ${ApiUrls.baseUrl}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );
        }
        // Other error handling is done in api_services.dart
      },
      showLoader: false, // We're using GetX loading state
      hideLoader: false,
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
