import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/chanting_mantra.dart';

class MantraChantingController extends GetxController
    with GetTickerProviderStateMixin {
  var chantCount = 0.obs;
  var isCompleted = false.obs;
  final _chantingMantras = <Data>[].obs; // Observable for list of mantras
  final _selectedIndex = 0.obs; // Observable for selected mantra index
  final _isLoading = false.obs; // Observable for loading state

  List<Data> get chantingMantras => _chantingMantras.value;
  Data? get chantingMantra =>
      _chantingMantras.isNotEmpty ? _chantingMantras[_selectedIndex.value] : null;
  RxInt get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading.value;
  late AnimationController scaleController;
  late AnimationController rippleController;
  late AnimationController glowController;
  late AnimationController celebrationController;

  late Animation<double> scaleAnimation;
  late Animation<double> rippleAnimation;
  late Animation<double> glowAnimation;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInit() {
    super.onInit();
    fetchChantingMantras();

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
    rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: rippleController, curve: Curves.easeOut),
    );

    glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );

    celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  Future<void> fetchChantingMantras() async {
    _isLoading.value = true;
    try {
      final response = await getChantingMantras(null);
      if (response != null && response.success == true && response.data != null) {
        _chantingMantras.assignAll(response.data!);
        if (_chantingMantras.isNotEmpty) {
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
    if (chantingMantra == null || chantCount.value >= (chantingMantra!.malaCount ?? 108)) return;

    chantCount.value++;

    // Trigger animations
    scaleController.forward().then((_) => scaleController.reverse());
    rippleController.forward(from: 0.0);

    // Check if completed 108
    if (chantCount.value == (chantingMantra!.malaCount ?? 108)) {
      isCompleted.value = true;
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
  }

  void resetCount() {
    chantCount.value = 0;
    isCompleted.value = false;
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
    super.onClose();
  }
}
