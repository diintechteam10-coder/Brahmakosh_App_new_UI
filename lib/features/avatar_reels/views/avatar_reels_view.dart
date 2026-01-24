import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/avatar_reels_controller.dart';
import 'widgets/reel_item_widget.dart';

class AvatarReelsView extends StatefulWidget {
  const AvatarReelsView({super.key});

  @override
  State<AvatarReelsView> createState() => _AvatarReelsViewState();
}

class _AvatarReelsViewState extends State<AvatarReelsView> {
  late AvatarReelsController controller;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AvatarReelsController>();
    print("AvatarReelsView Init state. Initial Index: ${controller.currentIndex.value}");
    pageController = PageController(initialPage: controller.currentIndex.value);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        if (controller.reels.isEmpty) {
          return const Center(
            child: Text(
              "No Reels Available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        print("AvatarReelsView Building PageView. Controller Index: ${controller.currentIndex.value}");
        return PageView.builder(
          controller: pageController,
          scrollDirection: Axis.vertical,
          itemCount: controller.reels.length,
          onPageChanged: (index) {
            print("AvatarReelsView Page Changed to: $index");
            controller.currentIndex.value = index;
          },
          itemBuilder: (context, index) {
            return ReelItemWidget(
              reel: controller.reels[index],
              index: index,
            );
          },
        );
      }),
    );
  }
}
