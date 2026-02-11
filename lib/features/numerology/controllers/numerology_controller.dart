import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/numerology/models/numerology_detail_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';

import 'package:get/get.dart';

class NumerologyController extends GetxController
    with GetSingleTickerProviderStateMixin {
  var isLoading = false.obs;
  var userNumerology = Rxn<NumerologyDetailData>();

  @override
  void onInit() {
    super.onInit();
    fetchNumerologyDetail();
  }

  void fetchNumerologyDetail() async {
    isLoading.value = true;
    try {
      String? userId = StorageService.getString(AppConstants.keyUserId);
      if (userId == null || userId.isEmpty) {
        Utils.showToast("User ID not found");
        isLoading.value = false;
        return;
      }

      NumerologyDetailResponse? response = await getNumerologyDetail(
        this,
        userId,
      );

      if (response != null &&
          response.success == true &&
          response.data != null) {
        userNumerology.value = response.data;
      } else {
        Utils.showToast("Failed to fetch numerology details");
      }
    } catch (e) {
      Utils.print("Error in fetchNumerologyDetail: $e");
      Utils.showToast("Something went wrong");
    } finally {
      isLoading.value = false;
    }
  }
}
