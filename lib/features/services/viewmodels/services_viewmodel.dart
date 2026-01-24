import 'dart:convert';
import 'package:get/get.dart';
import 'package:brahmakosh/features/astrology/views/astrology_experts_view.dart';
import '../../../../core/common_imports.dart';
import '../../../../common/api_services.dart';
import '../../../../common/api_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../model.dart';
import '../views/service_detail_view.dart';

class ServicesViewModel extends ChangeNotifier {
  List<ServiceModel> _services = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDisposed = false;

  List<ServiceModel> get services => _services; // Only dynamic API data, no static fallback
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ServicesViewModel() {
    fetchServices();
  }

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

  Future<void> fetchServices() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';

      await callWebApiGet(
        null,
        ApiUrls.sadhnaServices,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) {
          try {
            final responseBody = json.decode(response.body);
            print("📦 Services Response: ${response.body}");

            if (responseBody['success'] == true) {
              // Handle nested data structure
              var data = responseBody['data'];
              if (data is Map && data['data'] != null) {
                // Nested structure: {success: true, data: {success: true, data: [...]}}
                data = data['data'];
              }

              if (data is List) {
                // Direct list
                _services = data
                    .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
                    .where((item) => item.isActive == true && item.isDeleted != true)
                    .map((item) => ServiceModel.fromServiceItem(item))
                    .toList();
              } else if (data is Map && data['data'] != null) {
                // ServiceListData structure
                final serviceListData = ServiceListData.fromJson(data as Map<String, dynamic>);
                _services = (serviceListData.data ?? [])
                    .where((item) => item.isActive == true && item.isDeleted != true)
                    .map((item) => ServiceModel.fromServiceItem(item))
                    .toList();
              } else {
                // Try ServiceModelResponse structure
                final serviceResponse = ServiceModelResponse.fromJson(responseBody as Map<String, dynamic>);
                if (serviceResponse.data != null) {
                  _services = (serviceResponse.data!.data ?? [])
                      .where((item) => item.isActive == true && item.isDeleted != true)
                      .map((item) => ServiceModel.fromServiceItem(item))
                      .toList();
                }
              }
              // No fallback - only use dynamic API data
            } else {
              // API returned success: false - keep empty list
              _services = [];
            }
          } catch (e) {
            print("❌ Error parsing services: $e");
            _errorMessage = 'Failed to parse services';
            _services = []; // No fallback - only dynamic data
          }
          _isLoading = false;
          _safeNotifyListeners();
        },
        onError: (error) {
          print("❌ Error fetching services: $error");
          _errorMessage = 'Failed to load services';
          _services = []; // No fallback - only dynamic data
          _isLoading = false;
          _safeNotifyListeners();
        },
      );
    } catch (e) {
      print("❌ Exception in fetchServices: $e");
      _errorMessage = 'Failed to load services';
      _services = []; // No fallback - only dynamic data
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  void navigateToServiceDetail(BuildContext context, ServiceModel service) {
    if (service.title.toLowerCase().contains('astrology')) {
      Get.to(() => const AstrologyExpertsView());
      return;
    }

    Get.to(
      () => ServiceDetailView(service: service),
      transition: Transition.zoom,
      duration: const Duration(milliseconds: 400),
    );
  }
}
