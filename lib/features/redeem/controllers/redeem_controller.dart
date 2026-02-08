import 'dart:convert';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:get/get.dart';

class RedeemController extends GetxController {
  var selectedCategory = 'All'.obs;
  var redeemItems = <RedeemItemModel>[].obs;
  var userPoints = 0.obs;
  var isLoading = true.obs;
  var categories = <String>['All'].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRewards();
  }

  void filterByCategory(String category) {
    selectedCategory.value = category;
  }

  List<RedeemItemModel> get filteredItems {
    if (selectedCategory.value == 'All') {
      return redeemItems;
    }
    return redeemItems
        .where((item) => item.category == selectedCategory.value)
        .toList();
  }

  Future<void> fetchRewards() async {
    isLoading.value = true;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      await callWebApiGet(
        null, // No ticker provider for now
        ApiUrls.spiritualRewards,
        token: token,
        onResponse: (response) {
          final body = jsonDecode(response.body);
          if (body['success'] == true) {
            final List data = body['data'];
            redeemItems.value = data
                .map((e) => RedeemItemModel.fromJson(e))
                .toList();

            // Update user points
            if (body['userKarmaPoints'] != null) {
              userPoints.value = body['userKarmaPoints'];
            }

            // Extract unique categories
            final uniqueCategories = <String>{'All'};
            for (var item in redeemItems) {
              if (item.category.isNotEmpty) {
                uniqueCategories.add(item.category);
              }
            }
            categories.value = uniqueCategories.toList();

            // If selected category is no longer valid, reset to All
            if (!categories.contains(selectedCategory.value)) {
              selectedCategory.value = 'All';
            }
          }
        },
        onError: (error) {
          print("Error fetching spiritual rewards: $error");
        },
        showLoader: false,
        shouldLogoutOn401: false, // Prevent logout if this API fails
      );
    } catch (e) {
      print("Exception fetching spiritual rewards: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void redeemItem(item) {
    // Implement redeem logic if API available, currently just mock deduction in UI or handled by view
    // The prompt only asked to integrate the listing API.
    // However, if we need to deduct locally for immediate feedback:
    if (userPoints.value >= item.requiredPoints) {
      // logic to deduct would go here or call an API
    }
  }
}
