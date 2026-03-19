import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../../common/api_services.dart';
import '../../../../common/api_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/profile_model.dart';
import '../../../../core/common_imports.dart';

class ProfileViewModel extends ChangeNotifier {
  ProfileModel? _profile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  ProfileModel? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Fetch user profile from API
  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      await callWebApiGet(
        null,
        ApiUrls.getProfile,
        token: token,
        showLoader: false,
        hideLoader: false,

        // 👇 MAKE THIS ASYNC
        onResponse: (response) async {
          try {
            final responseBody = json.decode(response.body);
            print("📦 Profile Response: ${response.body}");

            if (responseBody['success'] == true &&
                responseBody['data'] != null) {
              final userData = responseBody['data']['user'];

              // optional: profile model
              _profile = ProfileModel.fromJson(userData);

              // ✅ ONLY NAME
              final String? name = userData['profile']?['name'];
              if (name != null && name.isNotEmpty) {
                await StorageService.setString(AppConstants.keyUserName, name);
                print("✅ Name saved in SharedPrefs: $name");
              }

              // Extract image URL from multiple possible locations
              final String? imageUrl = userData['profileImageUrl'] ??
                                      userData['profileImage'] ?? 
                                      userData['profile_image'] ?? 
                                      userData['profile']?['profile_image'] ??
                                      userData['profile']?['profileImage'] ??
                                      userData['image'];

              if (imageUrl != null && imageUrl.isNotEmpty) {
                await StorageService.setString(AppConstants.keyUserImage, imageUrl);
                print("✅ Image saved in SharedPrefs: $imageUrl");
              }

              print("✅ Profile loaded: ${_profile?.email}");
            } else {
              _errorMessage =
                  responseBody['message'] ?? 'Failed to load profile';
            }
          } catch (e) {
            print("❌ Error parsing profile response: $e");
            _errorMessage = 'Error parsing profile data';
          }

          _isLoading = false;
          _safeNotifyListeners();
        },

        onError: (error) {
          print("❌ Profile API Error: $error");
          _errorMessage = 'Failed to load profile';
          _isLoading = false;
          _safeNotifyListeners();
        },
      );
    } catch (e) {
      print("🔥 Exception in fetchProfile: $e");
      _errorMessage = 'Something went wrong';
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> body) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      await callWebApiPut(
        null,
        ApiUrls.getProfile, // Reuse URL /user/profile
        body,
        token: token,
        showLoader: true,
        // Assuming callWebApi defaults to POST when data is present
        // If not, we might need callWebApiPost or similar if defined
        
        onResponse: (response) async {
           try {
             final responseBody = json.decode(response.body);
             print("📦 Update Profile Response: ${response.body}");

             if (responseBody['success'] == true) {
                // Refresh profile to get updated data
                await fetchProfile();
                Get.snackbar("Success", "Profile updated successfully");
             } else {
                _errorMessage = responseBody['message'] ?? 'Failed to update profile';
                Get.snackbar("Error", _errorMessage!);
             }
           } catch (e) {
              print("❌ Error parsing update response: $e");
              _errorMessage = "Error parsing server response";
           }
           
           _isLoading = false;
           _safeNotifyListeners();
        },
        onError: (error) {
           print("❌ Update Profile API Error: $error");
           _errorMessage = "Failed to update profile";
           _isLoading = false;
           _safeNotifyListeners();
        }
      );
    } catch (e) {
       print("🔥 Exception in updateProfile: $e");
       _errorMessage = "Something went wrong";
       _isLoading = false;
       _safeNotifyListeners();
    }
  }

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await fetchProfile();
  }

  /// Upload Profile Image
  Future<void> uploadProfileImage(File imageFile) async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found';
        _isLoading = false;
        _safeNotifyListeners();
        return;
      }

      // Prepare file
      List<http.MultipartFile> files = [];
      
      String fileName = imageFile.path.split('/').last;
      String extension = fileName.split('.').last.toLowerCase();
      String mimeType = 'jpeg';
      if (extension == 'png') mimeType = 'png';
      if (extension == 'jpg' || extension == 'jpeg') mimeType = 'jpeg';
      // Add more if needed

      var multipartFile = await http.MultipartFile.fromPath(
        'image', 
        imageFile.path,
        contentType: MediaType('image', mimeType),
      );
      
      files.add(multipartFile);

      await callMultipartWebApi(
        null,
        ApiUrls.uploadProfileImage,
        {}, 
        files,
        token: token,
        showLoader: true,
        onResponse: (response) async {
           // callMultipartWebApi returns decoded JSON map directly in onResponse
           print("📦 Upload Image Response: $response");
           // Check success
           var success = response['success'];
           if (success == true) {
              await fetchProfile(); // Refresh to get new image URL
              Get.snackbar("Success", "Profile image updated successfully");
           } else {
              _errorMessage = response['message'] ?? 'Failed to upload image';
              Get.snackbar("Error", _errorMessage!);
           }
           _isLoading = false;
           _safeNotifyListeners();
        },
        onError: (error) {
           print("❌ Upload Image Error: $error");
           _errorMessage = "Failed to upload image";
           _isLoading = false;
           _safeNotifyListeners();
        }
      );

    } catch (e) {
       print("🔥 Exception in uploadProfileImage: $e");
       _errorMessage = "Something went wrong";
       _isLoading = false;
       _safeNotifyListeners();
    }
  }
}
