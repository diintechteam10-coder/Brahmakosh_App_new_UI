import 'dart:io';

import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class GenerateAvatarController extends GetxController {
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (image != null) {
      selectedImage.value = File(image.path);
    }
  }

  /// Get MIME type from file extension
  String _getImageContentType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg'; // default
    }
  }

  /// Get file name from file path
  String _getImageFileName(String filePath) {
    // Handle both Windows (\) and Unix (/) path separators
    return filePath.split(RegExp(r'[/\\]')).last;
  }

  void generateAvatar() async {
    if (selectedImage.value == null) {
      Get.snackbar("Error", "Please upload an image first");
      return;
    }

    // Get email from storage
    final email = StorageService.getString(AppConstants.keyUserEmail);
    if (email == null || email.isEmpty) {
      Get.snackbar("Error", "Email not found. Please login again.");
      return;
    }

    isLoading.value = true;

    try {
      final imageFile = selectedImage.value!;
      final imagePath = imageFile.path;
      final imageFileName = _getImageFileName(imagePath);
      final imageContentType = _getImageContentType(imagePath);

      print("📤 Sending avatar request:");
      print("   Email: $email");
      print("   Image File Name: $imageFileName");
      print("   Image Content Type: $imageContentType");

      // Get auth token
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';

      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imagePath,
        filename: imageFileName,
        contentType: MediaType.parse(imageContentType),
      );

      await callMultipartWebApi(
        null,
        ApiUrls.uploadProfileImage,
        {'email': email},
        [multipartFile],
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (responseJson) async {
          isLoading.value = false;
          print("✅ Avatar upload response: $responseJson");
          Get.offAllNamed(AppConstants.routeDashboard);
          Get.snackbar("Success", "Upload Image successfully 🎉");
        },
        onError: (error) {
          isLoading.value = false;
          print("❌ Avatar upload error: $error");
          Get.snackbar("Error", "Failed to upload avatar. Please try again.");
        },
      );
    } catch (e) {
      isLoading.value = false;
      print("❌ Error: $e");
      Get.snackbar("Error", "Something went wrong. Please try again.");
    }
  }
}
