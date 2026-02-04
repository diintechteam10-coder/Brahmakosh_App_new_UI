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
  final selectedEmotion = Rxn<String>('Happy'); // Default
  final selectedDuration = 1.obs; // Default 1 min
  final selectedConfig = Rxn<SpiritualConfiguration>();

  // Parameters passed from previous screen
  String? categoryId;

  // Available durations for slider/selector
  final List<int> availableDurations = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Emotion mapping
  final Map<String, String> emotionEmojis = {
    'Loved': '🥰',
    'Surprised': '😲',
    'Calm': '😌',
    'Happy': '😊',
    'Stressed': '😣',
    'Neutral': '😐',
    'Sad': '😢',
    'Angry': '😠',
    'Afraid': '😨',
    'Disgusted': '🤢',
  };

  @override
  void onInit() {
    super.onInit();
    categoryId = Get.arguments as String?;
    if (categoryId != null) {
      fetchConfigurations();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchConfigurations() async {
    try {
      isLoading.value = true;
      final response = await getSpiritualConfigurations(this, categoryId!);

      if (response != null && response.success == true) {
        configResponse.value = response;
        if (response.data != null) {
          configurations.assignAll(response.data!);
          _updateSelectedConfig();
        }
      }
    } catch (e) {
      print('❌ CONTROLLER_DEBUG: Error fetching configurations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void onEmotionSelected(String emotion) {
    selectedEmotion.value = emotion;
    _updateSelectedConfig();
  }

  void updateDuration(double value) {
    selectedDuration.value = value.toInt();
    _updateSelectedConfig();
  }

  void selectDuration(int duration) {
    selectedDuration.value = duration;
    _updateSelectedConfig();
  }

  void _updateSelectedConfig() {
    if (configurations.isEmpty) {
      selectedConfig.value = null;
      return;
    }

    // Attempt to find exact match
    final exactMatch = configurations.firstWhereOrNull((c) {
      // Check emotion match
      final emotionMatch =
          c.emotion?.toLowerCase() == selectedEmotion.value?.toLowerCase();

      // Check duration match
      // Duration string format usually "5 minutes" or "1 hour"
      // We need to parse c.duration to compare with selectedDuration
      bool durationMatch = false;
      if (c.duration != null) {
        final parsed = _parseDuration(c.duration!);
        durationMatch = parsed == selectedDuration.value;
      }

      return emotionMatch && durationMatch;
    });

    if (exactMatch != null) {
      selectedConfig.value = exactMatch;
    } else {
      // Fallback to first available config with same emotion to show metadata (Karma, etc)
      // even if duration doesn't match exactly.
      final fallback = configurations.firstWhereOrNull(
        (c) => c.emotion?.toLowerCase() == selectedEmotion.value?.toLowerCase(),
      );
      selectedConfig.value = fallback;
    }
  }

  int _parseDuration(String durationStr) {
    final parts = durationStr.toLowerCase().split(' ');
    if (parts.isEmpty) return 0;

    double val = double.tryParse(parts[0]) ?? 0.0;
    if (durationStr.contains('hour')) {
      return (val * 60).toInt();
    }
    return val.toInt();
  }

  Future<void> startSession() async {
    // If no config matches, what to do?
    // Maybe try to find *any* config for the emotion as fallback?
    if (selectedConfig.value == null) {
      // Try fallback to any config with same emotion
      final fallback = configurations.firstWhereOrNull(
        (c) => c.emotion?.toLowerCase() == selectedEmotion.value?.toLowerCase(),
      );
      if (fallback != null) {
        selectedConfig.value = fallback;
      } else {
        // Fallback to first available if totally desperate, or show error
        // But better to just show error if strict
        Utils.showToast('No session found for this selection');
        return;
      }
    }

    if (selectedConfig.value?.sId == null) {
      Utils.showToast('Invalid configuration');
      return;
    }

    try {
      final response = await getClipsByConfigurationId(
        this,
        selectedConfig.value!.sId!,
      );

      Get.toNamed(
        AppConstants.routeMeditationStart,
        arguments: {
          'duration': selectedDuration.value, // User selected duration
          'config': selectedConfig.value,
          'clips': (response?.success == true && response?.data != null)
              ? response!.data
              : [],
        },
      );
    } catch (e) {
      print('Error starting session: $e');
      // Fallback
      Get.toNamed(
        AppConstants.routeMeditationStart,
        arguments: {
          'duration': selectedDuration.value,
          'config': selectedConfig.value,
          'clips': [],
        },
      );
    }
  }
}
