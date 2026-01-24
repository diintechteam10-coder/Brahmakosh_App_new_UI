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

class ServicesController extends GetxController {
  final _services = <ServiceModel>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;

  List<ServiceModel> get services => _services;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    _isLoading.value = true;
    _errorMessage.value = '';

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
                _services.value = data
                    .map((item) => ServiceItem.fromJson(item as Map<String, dynamic>))
                    .where((item) => item.isActive == true && item.isDeleted != true)
                    .map((item) => ServiceModel.fromServiceItem(item))
                    .toList();
              } else if (data is Map && data['data'] != null) {
                // ServiceListData structure
                final serviceListData = ServiceListData.fromJson(data as Map<String, dynamic>);
                _services.value = (serviceListData.data ?? [])
                    .where((item) => item.isActive == true && item.isDeleted != true)
                    .map((item) => ServiceModel.fromServiceItem(item))
                    .toList();
              } else {
                // Try ServiceModelResponse structure
                final serviceResponse = ServiceModelResponse.fromJson(responseBody as Map<String, dynamic>);
                if (serviceResponse.data != null) {
                  _services.value = (serviceResponse.data!.data ?? [])
                      .where((item) => item.isActive == true && item.isDeleted != true)
                      .map((item) => ServiceModel.fromServiceItem(item))
                      .toList();
                }
              }
              // No fallback - only use dynamic API data
            } else {
              // API returned success: false - keep empty list
              _services.value = [];
            }
          } catch (e) {
            print("❌ Error parsing services: $e");
            _errorMessage.value = 'Failed to parse services';
            _services.value = []; // No fallback - only dynamic data
          }
          _isLoading.value = false;
        },
        onError: (error) {
          print("❌ Error fetching services: $error");
          _errorMessage.value = 'Failed to load services';
          _services.value = []; // No fallback - only dynamic data
          _isLoading.value = false;
        },
      );
    } catch (e) {
      print("❌ Exception in fetchServices: $e");
      _errorMessage.value = 'Failed to load services';
      _services.value = []; // No fallback - only dynamic data
      _isLoading.value = false;
    }
  }

void navigateToServiceDetail(BuildContext context, ServiceModel service) {
  if (service.title.toLowerCase().contains('astrology')) {
    Get.to(() => AstrologyExpertsView(
          screenTitle: service.title,     // ← pass real name here
        ));
    return;
  }

  // other services...
  Get.to(
    () => ServiceDetailView(service: service),
    transition: Transition.zoom,
  );
}

  void refreshServices() {
    fetchServices();
  }
}
