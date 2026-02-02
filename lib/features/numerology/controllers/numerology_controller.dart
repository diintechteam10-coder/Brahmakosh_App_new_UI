import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/numerology/models/numerology_history_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';

import 'package:get/get.dart';

class NumerologyController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = false.obs;
  var numerologyHistory = <NumerologyHistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNumerologyHistory();
  }

  void fetchNumerologyHistory() async {
    isLoading.value = true;
    try {
      String? userId = StorageService.getString(AppConstants.keyUserId);
      if (userId == null || userId.isEmpty) {
        Utils.showToast("User ID not found");
        isLoading.value = false;
        return;
      }

      NumerologyHistoryResponse? response = await getNumerologyHistory(
        this,
        userId,
      );

      if (response != null &&
          response.success == true &&
          response.data != null) {
        if (response.data!.history != null) {
          numerologyHistory.assignAll(response.data!.history!);
        }
      } else {
        Utils.showToast("Failed to fetch numerology history");
      }
    } catch (e) {
      Utils.print("Error in fetchNumerologyHistory: $e");
      Utils.showToast("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
