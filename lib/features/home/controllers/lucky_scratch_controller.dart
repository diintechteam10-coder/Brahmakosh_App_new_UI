import 'package:brahmakosh/core/common_imports.dart';
import 'package:confetti/confetti.dart';
import 'package:get/get.dart';

class LuckyScratchController extends GetxController with GetTickerProviderStateMixin {
  final VoidCallback? onScratchComplete;

  LuckyScratchController({this.onScratchComplete});

  late AnimationController entranceController;
  late AnimationController revealController;
  late ConfettiController confettiController;

  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  var scratchProgress = 0.0.obs;
  var isRevealed = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Entrance animation controller
    entranceController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800),
    );

    // Reveal animation controller
    revealController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
    );

    confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Scale animation
    scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Curves.elasticOut,
      ),
    );

    // Fade animation
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Curves.easeInOut,
      ),
    );

    // Slide animation
    slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: entranceController,
        curve: Curves.easeOut,
      ),
    );

    entranceController.forward();
  }

  void updateProgress(double progress) {
    scratchProgress.value = progress;
    if (!isRevealed.value && progress >= 0.6) {
      isRevealed.value = true;
      revealController.forward();
      // On scratch complete logic
      onScratchComplete?.call();
    }
  }

  @override
  void onClose() {
    entranceController.dispose();
    revealController.dispose();
    confettiController.dispose();
    super.onClose();
  }
}
