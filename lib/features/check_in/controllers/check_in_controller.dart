import 'package:brahmakosh/common/api_services.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';

class CheckInController extends GetxController
    with GetTickerProviderStateMixin {
  final isLoading = true.obs;
  final checkInData = Rxn<Data>();

  @override
  void onInit() {
    super.onInit();
    fetchCheckInData();
  }

  Future<void> fetchCheckInData() async {
    try {
      isLoading.value = true;
      final response = await getSpiritualCheckin(this);

      if (response != null && response.success == true) {
        checkInData.value = response.data;
      }
    } catch (e) {
      print('Error fetching check-in data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
