import 'dart:convert';
import 'dart:io';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/auth/views/create_avtar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CompleteProfileController extends GetxController {
  /// Text controllers
  final nameController = TextEditingController();
  final dobController = TextEditingController();
  final timeController = TextEditingController();
  final placeController = TextEditingController();
  final gowthraController = TextEditingController();

  /// Focus Node for Place
  final FocusNode placeFocusNode = FocusNode();

  /// Selected image
  Rx<File?> profileImage = Rx<File?>(null);

  /// Loading state
  RxBool isLoading = false.obs;

  /// User email (from previous step)
  final String email;

  CompleteProfileController({required this.email});

  String formatDobForApi(String input) {
    try {
      // Input format is DD-MM-YYYY from the view
      List<String> parts = input.split('-');
      if (parts.length == 3) {
        // Create YYYY-MM-DD string
        return "${parts[2]}-${parts[1]}-${parts[0]}";
      }

      // Fallback to standard parsing if format is different
      DateTime parsedDate = DateTime.parse(input);
      return "${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}";
    } catch (_) {
      return "";
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      profileImage.value = File(pickedFile.path);
      print("📸 Image picked: ${pickedFile.path}");
    } else {
      print("❌ No image selected");
    }
  }

  Future<void> submitProfile() async {
    if (nameController.text.isEmpty ||
        dobController.text.isEmpty ||
        timeController.text.isEmpty ||
        placeController.text.isEmpty ||
        gowthraController.text.isEmpty) {
      Get.snackbar("Error", "Please fill all fields");
      return;
    }

    print("📩 Submit profile called");

    isLoading.value = true;

    try {
      final payload = {
        "email": email,
        "name": nameController.text.trim(),
        "dob": formatDobForApi(dobController.text.trim()),
        "timeOfBirth": timeController.text.trim(),
        "placeOfBirth": placeController.text.trim(),
        "gowthra": gowthraController.text.trim(),
        "clientId": "CLI-KBHUMT",
      };

      print("➡️ API URL: ${ApiUrls.completeProfile}");
      print("➡️ PAYLOAD: $payload");

      final res = await http.post(
        Uri.parse(ApiUrls.completeProfile),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      print("⬅️ STATUS CODE: ${res.statusCode}");
      print("⬅️ RAW RESPONSE: ${res.body}");

      final responseBody = jsonDecode(res.body);
      print("✅ DECODED RESPONSE: $responseBody");

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = responseBody['data'];

        /// 🔐 CORRECT TOKEN PATH
        final token = data?['token'] ?? '';
        final userId = data?['user']?['_id'] ?? '';

        print("🪙 TOKEN FROM API: $token");
        print("👤 USER ID: $userId");

        /// ✅ SAVE LIKE LOGIN CONTROLLER
        if (token.isNotEmpty) {
          await StorageService.setString(AppConstants.keyAuthToken, token);
          await StorageService.setString(AppConstants.keyUserId, userId);
          await StorageService.setString(AppConstants.keyUserEmail, email);
          await StorageService.setBool(AppConstants.keyIsLoggedIn, true);

          print("✅ Token saved to SharedPreferences");
        }

        Get.snackbar(
          "Success",
          responseBody['message'] ?? "Profile completed",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.to(GenerateAvatarView());
      } else {
        Get.snackbar(
          "Error",
          responseBody['message'] ?? "Failed to submit profile",
        );
      }
    } catch (e, stack) {
      print("🔥 ERROR: $e");
      print("🔥 STACK: $stack");
      Get.snackbar("Error", "Server error");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    dobController.dispose();
    timeController.dispose();
    placeController.dispose();
    placeFocusNode.dispose();
    gowthraController.dispose();
    super.onClose();
  }
}
