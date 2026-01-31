import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';

import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpiritualConfigurationController extends GetxController
    with GetTickerProviderStateMixin {
  final isLoading = true.obs;
  final configResponse = Rxn<SpiritualConfigurationResponse>();
  final configurations = <SpiritualConfiguration>[].obs;

  // Selected state
  final selectedEmotion = Rxn<String>();
  final selectedConfig = Rxn<SpiritualConfiguration>();
  final sliderValue = 0.0.obs;

  // Parameters passed from previous screen
  String? categoryId;

  // Emotion mapping (Emoji map as requested)
  final Map<String, String> emotionEmojis = {
    'Happy': '😊',
    'Sad': '😢',
    'Angry': '😠',
    'Afraid': '😨',
    'Loved': '🥰',
    'Surprised': '😲',
    'Calm': '😌',
    'Disgusted': '🤢',
  };

  @override
  void onInit() {
    super.onInit();
    categoryId = Get.arguments as String?;
    if (categoryId != null) {
      fetchConfigurations();
    } else {
      // Fallback or error handling
      isLoading.value = false;
    }
  }

  Future<void> fetchConfigurations() async {
    try {
      isLoading.value = true;
      print("🔍 CONTROLLER_DEBUG: Fetching for categoryId: $categoryId");

      final response = await getSpiritualConfigurations(this, categoryId!);
      print("✅ CONTROLLER_DEBUG: Response received: ${response?.success}");

      if (response != null && response.success == true) {
        configResponse.value = response;
        if (response.data != null) {
          print("✅ CONTROLLER_DEBUG: Data count: ${response.data!.length}");
          configurations.assignAll(response.data!);

          // Set default selected config if available
          if (configurations.isNotEmpty) {
            // Find a default or just pick first
            selectConfig(configurations.first);
          }
        } else {
          print("⚠️ CONTROLLER_DEBUG: Response data is null");
        }
      } else {
        print("⚠️ CONTROLLER_DEBUG: Response not successful or null");
      }
    } catch (e) {
      print('❌ CONTROLLER_DEBUG: Error fetching configurations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectConfig(SpiritualConfiguration config) {
    selectedConfig.value = config;
    // Set emotion from config if matches
    if (config.emotion != null) {
      // Capitalize first letter to match keys if needed, assuming backend sends lowercase
      // Adjust matching logic as per actual API response values
      final emotion = config.emotion!.toLowerCase();
      // Find key that matches
      final key = emotionEmojis.keys.firstWhere(
        (k) => k.toLowerCase() == emotion,
        orElse: () => '',
      );
      if (key.isNotEmpty) {
        selectedEmotion.value = key;
      }
    }

    // Parse duration string "X minutes" to double for slider
    if (config.duration != null) {
      final parts = config.duration!.split(' ');
      if (parts.isNotEmpty) {
        final minutes = double.tryParse(parts[0]);
        if (minutes != null) {
          sliderValue.value = minutes;
        }
      }
    }
  }

  void onEmotionSelected(String emotion) {
    selectedEmotion.value = emotion;
    // Scroll to middle logic is handled in View via ScrollController usually,
    // or we can manipulate the list order if "move to middle" means reordering.
    // User request: "if we select any emoji my selected emotion emoji should move into middle"
    // This implies UI scroll positioning.

    // Also user said: "api should response according to emotion".
    // Filter configurations by emotion if needed?
    // "api should response according to emotion it will add from backend later" -> sounds like filtering logic might be future work or client side now.
    // However, "api should response according to emotion" usually means we fetch *based* on emotion or filter.
    // Since we fetched ALL by categoryId, we likely filter relevant configs?
    // User: "if any emoji missing according to emotion please add"

    // For now, let's just update selection.

    // If we need to filter configs based on emotion:
    final relevantConfig = configurations.firstWhereOrNull(
      (c) => c.emotion?.toLowerCase() == emotion.toLowerCase(),
    );
    if (relevantConfig != null) {
      selectConfig(relevantConfig);
    }
  }

  void updateDuration(double value) {
    sliderValue.value = value;
  }

  Future<void> startSession() async {
    if (selectedConfig.value == null) {
      Utils.showToast('Please select a configuration');
      return;
    }

    if (selectedConfig.value!.sId == null) {
      Utils.showToast('Invalid configuration');
      return;
    }

    // Indicate loading if you want, but api_services handles loader dialog usually if TickerProvider provided
    // getClipsByConfigurationId uses showLoader: true with TickerProvider (this)

    try {
      final response = await getClipsByConfigurationId(
        this,
        selectedConfig.value!.sId!,
      );

      // Navigate regardless, passing data if available
      Get.toNamed(
        AppConstants.routeMeditationStart,
        arguments: {
          'duration': sliderValue.value.toInt(),
          'config': selectedConfig.value,
          'clips': (response?.success == true && response?.data != null)
              ? response!.data
              : [],
        },
      );
    } catch (e) {
      print('Error starting session: $e');
      // Fallback navigation
      Get.toNamed(
        AppConstants.routeMeditationStart,
        arguments: {
          'duration': sliderValue.value.toInt(),
          'config': selectedConfig.value,
          'clips': [],
        },
      );
    }
  }
}
