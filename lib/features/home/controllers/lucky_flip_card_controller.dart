import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:get/get.dart';

class LuckyFlipCardController extends GetxController {
  final String cardId;
  LuckyFlipCardController(this.cardId);

  var isScratched = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkIsScratched();
  }

  void checkIsScratched() {
    final storageKey = 'lastScratchDate_$cardId';
    final lastScratchDate = StorageService.getString(storageKey);
    final today = DateTime.now();
    final todayString =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    isScratched.value = (lastScratchDate == todayString);
  }

  void markAsScratched() {
    // This might be called after scratch overlay completes
    // Actually the overlay itself saves to storage.
    // We just need to refresh our state.
    checkIsScratched();
  }
}
