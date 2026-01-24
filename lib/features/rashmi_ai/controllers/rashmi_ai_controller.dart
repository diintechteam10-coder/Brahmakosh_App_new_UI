import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class RashmiAiController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;

  VideoPlayerController? videoController;

  final isVideoInitialized = false.obs;
  final isTalkModeEnabled = false.obs;

  bool _hasPlayedOnce = false;

  @override
  void onInit() {
    super.onInit();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _initVideo() async {
    if (videoController != null) return;

    videoController = VideoPlayerController.asset(
      'assets/images/welcome_bi.mp4',
    );

    await videoController!.initialize();
    videoController!.setLooping(false);
    isVideoInitialized.value = true;
  }

  /// 🔒 PLAY ONLY ONCE
  Future<void> playVideoOnce() async {
    if (_hasPlayedOnce) return;

    await _initVideo();

    await videoController!.seekTo(Duration.zero);
    await videoController!.play();

    _hasPlayedOnce = true;

    Future.delayed(const Duration(milliseconds: 600), () {
      isTalkModeEnabled.value = true;
    });
  }

  void onChatTap() {
    debugPrint('Chat tapped');
  }

  void onTalkTap() {
    isTalkModeEnabled.toggle();
  }

  @override
  void onClose() {
    videoController?.dispose();
    animationController.dispose();
    super.onClose();
  }
}
