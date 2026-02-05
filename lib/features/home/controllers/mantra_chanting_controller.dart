import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/chanting_mantra.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';

class MantraChantingController extends GetxController
    with GetTickerProviderStateMixin {
  var chantCount = 0.obs;
  var isCompleted = false.obs;
  final _chantingMantras = <Data>[].obs; // Observable for list of mantras
  final _selectedIndex = 0.obs; // Observable for selected mantra index
  final _isLoading = false.obs; // Observable for loading state

  // Projectile Animation Controllers
  late AnimationController moveController;
  late Animation<Alignment> moveAnimation;
  late Animation<double> moveScaleAnimation;
  late Animation<double> moveOpacityAnimation;

  List<Data> get chantingMantras => _chantingMantras.value;
  Data? get chantingMantra => _chantingMantras.isNotEmpty
      ? _chantingMantras[_selectedIndex.value]
      : null;
  RxInt get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading.value;
  late AnimationController scaleController;
  late AnimationController rippleController;
  late AnimationController glowController;
  late AnimationController celebrationController;

  late Animation<double> scaleAnimation;
  late Animation<double> rippleAnimation;
  late Animation<double> glowAnimation;

  // Animation State for Mantra Text Emergence
  final isMantraVisible = false.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _timer;
  final elapsedSeconds = 0.obs;

  String get formattedTime {
    final minutes = (elapsedSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      elapsedSeconds.value++;
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void onInit() {
    super.onInit();
    fetchChantingMantras();

    // Initial state: visible at top (or hidden until first tap if preferred,
    // but usually user wants to see it.
    // Requirement says "work only when we tap... like every time it will happen when it will click button only"
    // So initially it can be static at top or hidden. Let's keep it visible static at top?
    // User said: "mantra text which coing... emerging from circle... only when we tap"
    // So maybe initially it's just there? Or maybe it emerges once and then re-emerges on tap?
    // "work only when we tap... if it will not click then transition will not work"
    // This implies ON LOAD no transition. So just set visible = true initially so it's visible,
    // but no transition.
    isMantraVisible.value = true;

    // Mantra Projectile Animation
    moveController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
      ), // 0.6 seconds flight time for fast tapping
      vsync: this,
    );

    moveAnimation = Tween<Alignment>(
      begin: Alignment.center,
      end: const Alignment(0, -0.9), // Near top of screen
    ).animate(CurvedAnimation(parent: moveController, curve: Curves.easeInOut));

    moveScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.5, // Shrink to half size
    ).animate(CurvedAnimation(parent: moveController, curve: Curves.easeInOut));

    moveOpacityAnimation =
        Tween<double>(
          begin: 1.0,
          end: 0.0, // Fade out completely
        ).animate(
          CurvedAnimation(
            parent: moveController,
            curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
          ),
        ); // Fade out in second half

    scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
    );

    rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    rippleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: rippleController, curve: Curves.easeOut));

    glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    glowAnimation = Tween<double>(
      begin: 0.3,
      end: 0.7,
    ).animate(CurvedAnimation(parent: glowController, curve: Curves.easeInOut));

    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Check for arguments
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('count')) {
        // If count is passed, we might need a way to override the mantra's default count
        // For now, let's store it and apply it when a mantra is selected or if we use a dummy mantra
        // But logic below fetches mantras.
      }
    }
  }

  Future<void> fetchChantingMantras() async {
    _isLoading.value = true;
    try {
      final response = await getChantingMantras(null);
      if (response != null &&
          response.success == true &&
          response.data != null) {
        _chantingMantras.assignAll(response.data!);

        // Apply arguments override
        if (Get.arguments != null && Get.arguments is Map) {
          final args = Get.arguments as Map;

          // 1. Handle Selection of Mantra
          if (args.containsKey('mantra')) {
            final selectedM = args['mantra'];
            if (selectedM != null && selectedM is Data) {
              // Find matching ID in fetched list to ensure reference validity or just use it
              // Better to look it up in the list to keep everything in sync
              final index = _chantingMantras.indexWhere(
                (m) => m.sId == selectedM.sId,
              );
              if (index != -1) {
                _selectedIndex.value = index;
              } else {
                // Fallback: If not in list (weird?), use the passed one
                // This is tricky if UI depends on it being in the list.
                // For now, assume it's in the list since we fetch same API.
              }
            }
          }

          // 2. Handle Count Override
          final count = args['count'];
          if (count != null && count is int) {
            // Apply to ALL mantras or just the selected one?
            // User likely wants the selected count for THIS session regardless of mantra.
            // So modifying the object is "safest" for UI to read it back.
            for (var mantra in _chantingMantras) {
              mantra.malaCount = count;
            }
          }
        } else if (_chantingMantras.isNotEmpty) {
          // Default to first if no args
          _selectedIndex.value = 0;
        }
      }
    } catch (e) {
      debugPrint('Error fetching chanting mantras: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> incrementCount() async {
    if (chantingMantra == null ||
        chantCount.value >= (chantingMantra!.malaCount ?? 108))
      return;

    // Start timer if first chant
    startTimer();

    chantCount.value++;

    // Trigger animations
    scaleController.forward().then((_) => scaleController.reverse());
    rippleController.forward(from: 0.0);

    // Trigger Projectile Animation
    moveController.forward(from: 0.0);

    // Check if completed 108
    if (chantCount.value == (chantingMantra!.malaCount ?? 108)) {
      isCompleted.value = true;
      stopTimer(); // Stop timer
      celebrationController.forward();
      await _celebrateCompletion();
    }
  }

  Future<void> _celebrateCompletion() async {
    // Vibrate the device
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 500, amplitude: 128);
    }

    // Play completion sound
    try {
      await _audioPlayer.play(AssetSource('sounds/bell.mp3'));
    } catch (e) {
      debugPrint('Sound file not found: $e');
    }

    // Show Completion Dialog
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xffFFF8E7),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Color(0xff4CAF50),
              ),
              const SizedBox(height: 16),
              const Text(
                "Completed!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff5D4037),
                  fontFamily:
                      'Merriweather', // Assuming direct font family usage or need GoogleFonts
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You have successfully completed your chanting session.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xff8D6E63)),
              ),
              const SizedBox(height: 8),
              const Text(
                "+10 Karma Points Earned",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xffFF8C00),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.close(1); // Close dialog
                    // Navigate to Dashboard at index 1 (CheckInView)
                    Get.offAllNamed(AppConstants.routeDashboard, arguments: 1);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff5D4037),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("OK", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void resetCount() {
    chantCount.value = 0;
    isCompleted.value = false;
    stopTimer();
    elapsedSeconds.value = 0;
    celebrationController.reset();
  }

  void selectMantra(int index) {
    if (index >= 0 && index < _chantingMantras.length) {
      _selectedIndex.value = index;
      resetCount(); // Reset count when changing mantra
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    scaleController.dispose();
    rippleController.dispose();
    glowController.dispose();
    celebrationController.dispose();
    moveController.dispose();
    stopTimer();
    super.onClose();
  }
}
