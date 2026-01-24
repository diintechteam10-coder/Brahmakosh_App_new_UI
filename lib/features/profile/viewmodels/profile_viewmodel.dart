import 'dart:convert';
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

              final String? imageUrl = userData['profile']?['profile_image'];
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

  /// Refresh profile data
  Future<void> refreshProfile() async {
    await fetchProfile();
  }
}
