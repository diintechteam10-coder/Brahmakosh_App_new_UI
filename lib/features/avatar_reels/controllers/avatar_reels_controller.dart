import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/brahm_reel.dart';

class AvatarReelsController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isLoading = false.obs;

  final RxList<ReelItem> reels = <ReelItem>[].obs;

  final RxMap<int, bool> likedReels = <int, bool>{}.obs;

  @override
  void onInit() {
    print("AvatarReelsController: onInit called");
    super.onInit();
    fetchReels();
  }

  Future<void> fetchReels() async {
    isLoading.value = true;
    try {
      final response = await getBrahmReels(null);
      if (response != null && response.data?.data != null) {
        reels.assignAll(response.data!.data!);
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch reels");
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
  }

  void toggleLike(int index) {
    likedReels[index] = !(likedReels[index] ?? false);
  }

  void shareReel(int index) {
    Get.snackbar("Share", "Sharing reel ${index + 1}...");
  }

  void downloadReel(int index) {
    Get.snackbar("Download", "Downloading reel ${index + 1}...");
  }
}
