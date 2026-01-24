import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final int totalStatus = 8;

  late PageController pageController;
  late AnimationController progressController;

  RxInt currentIndex = 0.obs;
  RxBool isViewerOpen = false.obs;

  @override
  void onInit() {
    super.onInit();

    pageController = PageController();
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  void startProgress() {
    progressController.forward(from: 0).whenComplete(() {
      goToNextStatus();
    });
  }

  void onTapStatus(int index) {
    isViewerOpen.value = true;

    // Reset progress
    progressController.stop();
    progressController.reset();

    // Recreate page controller with the tapped index as initial page
    pageController.dispose();
    pageController = PageController(initialPage: index);

    currentIndex.value = index;

    // Start progress after the first frame so PageView is attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      startProgress();
    });
  }

  void goToNextStatus() {
    if (currentIndex.value < totalStatus - 1) {
      currentIndex.value++;
      if (pageController.hasClients) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        startProgress();
      } else {
        // If not attached yet, try again on next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (pageController.hasClients) {
            pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            startProgress();
          } else {
            // As a fallback, just restart progress on the same index
            startProgress();
          }
        });
      }
    } else {
      closeViewer();
    }
  }

  void closeViewer() {
    isViewerOpen.value = false;
    progressController.stop();
    progressController.reset();
    currentIndex.value = 0;
  }
}
