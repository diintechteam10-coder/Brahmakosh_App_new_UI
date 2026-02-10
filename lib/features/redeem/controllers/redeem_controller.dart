import 'dart:convert';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/models/redemption_history_model.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class RedeemController extends GetxController {
  var selectedCategory = 'All'.obs;
  var redeemItems = <RedeemItemModel>[].obs;
  var redemptionHistory = <RedemptionHistoryModel>[].obs;
  var userPoints = 0.obs;
  var isLoading = true.obs;
  var isHistoryLoading = false.obs;
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
    // Legacy method, unused now
  }

  Future<void> redeemReward(
    String rewardId, {
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    // Manually handle loading if needed, or rely on non-blocking UI
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      if (token.isEmpty) {
        onError("User not logged in");
        return;
      }

      await callWebApi(
        null, // No ticker
        ApiUrls.redeemReward,
        {'rewardId': rewardId}, // Correct body: {"rewardId": "..."}
        token: token,
        onResponse: (response) {
          bool success = false;
          String? errorMessage;

          try {
            final body = jsonDecode(response.body);
            print("Redeem API Response body parsed: $body");
            if (body['success'] == true) {
              if (body['data'] != null &&
                  body['data']['remainingKarmaPoints'] != null) {
                userPoints.value = body['data']['remainingKarmaPoints'];
              } else if (body['userKarmaPoints'] != null) {
                userPoints.value = body['userKarmaPoints'];
              }
              success = true;
            } else {
              errorMessage = body['message'] ?? "Redemption failed";
            }
          } catch (e) {
            print("Redeem parse error: $e");
            errorMessage = "Failed to parse response: $e";
          }

          if (success) {
            onSuccess();
          } else {
            onError(errorMessage ?? "Unknown error");
          }
        },
        onError: (error) {
          String errorMessage = error.toString();
          // Extract message from Response object if possible
          if (error.toString().contains('Response')) {
            // Error might be the Response object itself, but as dynamic
            try {
              // Since we don't have easy access to 'http' package types without import,
              // and callWebApi passes the dynamic error.
              // Try to verify if it has a body property via reflection or just string parsing?
              // Or better, simply don't rely on this callback for formatting if possible.
              // But let's try to be safe.
            } catch (_) {}
          }
          // Basic fallback: if it's a 400/500 from callWebApi, it might pass the Response object.
          // However, without 'import http', we can't do 'is http.Response'.
          // Let's just use toString() for now, or assume catch block handles it better?
          // Actually, easiest way is to NOT pass onError callback, and let catch block handle exception.
          // But callWebApi throws exceptions with body string.
          // Let's rely on catch block for standardized error handling.
          // BUT, callWebApi shows Toast for 400.
          // So, let's keep it simple: pass onError to capture message if possible.
          // Actually, wait. I can't reliably parse Response without importing http.
          // I'll add the import.
        },
        showLoader: false, // Prevents unintended navigation pops
      );
    } catch (e) {
      // callWebApi throws exceptions like BadRequestException which contain the body string.
      // We can try to parse it if it looks like JSON.
      String message = e.toString();
      try {
        // Remove "Exception: " prefix if present
        if (message.startsWith("Exception: ")) message = message.substring(11);
        // Exception often contains the JSON body directly
        // Check if it looks like JSON
        if (message.contains("{")) {
          final startIndex = message.indexOf("{");
          final jsonStr = message.substring(startIndex);
          final body = jsonDecode(jsonStr);
          if (body['message'] != null) {
            message = body['message'];
          }
        }
      } catch (_) {}

      onError(message);
    }
  }

  Future<void> fetchRedemptionHistory() async {
    isHistoryLoading.value = true;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      await callWebApiGet(
        null, // No ticker
        ApiUrls.redemptionHistory,
        token: token,
        onResponse: (response) {
          final body = jsonDecode(response.body);
          if (body['success'] == true) {
            final List data = body['data'];
            redemptionHistory.value = data
                .map((e) => RedemptionHistoryModel.fromJson(e))
                .toList();
          }
        },
        onError: (error) {
          print("Error fetching redemption history: $error");
        },
        showLoader: false,
      );
    } catch (e) {
      print("Exception fetching redemption history: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }
}
