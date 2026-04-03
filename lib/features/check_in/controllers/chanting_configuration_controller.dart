import 'dart:convert';
import 'package:get/get.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';

class ChantingConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Selected Emotion
  final selectedEmotion = Rxn<String>();

  // Use SpiritualConfiguration instead of Data/ChantingMantra
  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;

  // Filtered configurations based on selected emotion
  final filteredConfigurations = <SpiritualConfiguration>[].obs;

  // Selected Configuration (Represents the mantra choice)
  final selectedConfiguration = Rxn<SpiritualConfiguration>();

  // Grouped configurations by category
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      final cat = config.category ?? "Others";
      if (!groups.containsKey(cat)) groups[cat] = [];
      groups[cat]!.add(config);
    }
    return groups;
  }

  // Available Counts
  final List<int> availableCounts = [27, 51, 108, 216, 324, 434, 540, 646];

  // Selected Count (Default 108)
  final selectedCount = 108.obs;

  // Static emotion map for UI (Emojis)
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

  // Hardcoded Category ID for "Chanting" from requirements
  final String chantingCategoryId = "69787dcbbeaf7e42675a2212";

  final String _cacheKey = 'spiritual_configurations_cache';

  @override
  void onInit() {
    super.onInit();
    fetchConfigurations();
  }

  Future<void> fetchConfigurations() async {
    print("🚀 DEBUG_CONTROLLER: Fetching Chanting Configurations for Category: $chantingCategoryId");
    isLoading.value = true;
    try {
      // 1. Try to load from cache first
      final cachedData = StorageService.getString(_cacheKey);
      if (cachedData != null && cachedData.isNotEmpty) {
        try {
          final jsonList = (jsonDecode(cachedData) as List)
              .cast<Map<String, dynamic>>();
          final cachedConfigs = jsonList
              .map((e) => SpiritualConfiguration.fromJson(e))
              .toList();
          if (cachedConfigs.isNotEmpty) {
            allConfigurations.assignAll(cachedConfigs);
            _initializeSelection();
            // If we have cached data, we can stop loading for UI but still fetch fresh data
            isLoading.value = false;
          }
        } catch (e) {
          print("Error parsing cached chanting configurations: $e");
        }
      }

      // 2. Fetch fresh data from API
      final response = await getSpiritualConfigurations(
        null,
        chantingCategoryId,
      );

      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        allConfigurations.assignAll(response.data!);

        // 3. Update cache
        final jsonList = response.data!.map((e) => e.toJson()).toList();
        await StorageService.setString(_cacheKey, jsonEncode(jsonList));

        // Re-initialize only if we didn't have data before or if selection is invalid
        if (selectedConfiguration.value == null) {
          _initializeSelection();
        } else {
          // Refresh filtered list based on current emotion
          if (selectedEmotion.value != null) {
            onEmotionSelected(selectedEmotion.value!);
          }
        }
      } else if (allConfigurations.isEmpty) {
        // Only fallback if we have NO data at all (neither cache nor api)
        _addFallbackMantra();
      }
    } catch (e) {
      print("Error fetching chanting configurations: $e");
      if (allConfigurations.isEmpty) {
        _addFallbackMantra();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeSelection() {
    // Logic to set initial emotion
    final availableEmotions = allConfigurations
        .map((e) => e.emotion)
        .where((e) => e != null)
        .toSet();

    if (availableEmotions.isNotEmpty) {
      // Default to 'Happy' if available, or first available
      // Normalize comparison
      bool hasHappy = availableEmotions.any((e) => e!.toLowerCase() == 'happy');
      if (hasHappy) {
        onEmotionSelected('Happy');
      } else {
        // Map the API emotion string to our valid keys if possible
        String? firstApiEmotion = availableEmotions.first!;
        // Simple case-insensitive match against our map keys
        String? matchedKey = emotionEmojis.keys.firstWhere(
          (k) => k.toLowerCase() == firstApiEmotion.toLowerCase(),
          orElse: () => firstApiEmotion, // fallback
        );
        onEmotionSelected(matchedKey);
      }
    }
  }

  void _addFallbackMantra() {
    print("Adding Fallback Mantra: Radhe Radhe");
    final fallback = SpiritualConfiguration(
      sId: "fallback_radhe",
      chantingType: "Radhe Radhe",
      emotion: "Happy", // Default to Happy so it shows up
      karmaPoints: 11, // Default points
      description: "Radhe Radhe Chanting",
      isActive: true,
    );
    allConfigurations.assignAll([fallback]);
    onEmotionSelected("Happy");
  }

  void onEmotionSelected(String? emotion) {
    if (emotion == null) return;
    selectedEmotion.value = emotion;

    // Filter configurations based on emotion
    // Logic: Show all mantras that match the selected emotion
    final filtered = allConfigurations.where((config) {
      // Case-insensitive match.
      // Note: The UI emojis keys are Capitalized (Happy, Stress etc), API might return lowercase or mixed.
      return config.emotion?.toLowerCase() == emotion.toLowerCase();
    }).toList();

    filteredConfigurations.assignAll(filtered);

    // Auto-select first mantra if list changed
    if (filteredConfigurations.isNotEmpty) {
      selectedConfiguration.value = filteredConfigurations.first;
    } else {
      selectedConfiguration.value = null;
    }
  }

  // Helper to get display text
  String getDisplayMantraText(SpiritualConfiguration config) {
    if (config.chantingType != null &&
        config.chantingType!.isNotEmpty &&
        config.chantingType != "Other") {
      return config.chantingType!;
    } else if (config.customChantingType != null &&
        config.customChantingType!.isNotEmpty) {
      return config.customChantingType!;
    }
    return "Mantra";
  }

  void onConfigurationSelected(SpiritualConfiguration config) {
    selectedConfiguration.value = config;
  }

  void selectCount(int count) {
    selectedCount.value = count;
  }

  void startSession(SpiritualConfiguration config) {
    selectedConfiguration.value = config;
    
    // Navigate to Mantra Chanting with selected config
    Get.toNamed(
      AppConstants.routeMantraChanting,
      arguments: {
        'emotion': selectedEmotion.value,
        'count': selectedCount.value,
        'configuration': selectedConfiguration.value,
        'mantra_title': selectedConfiguration.value?.title ?? selectedConfiguration.value?.chantingType,
        'karma_points': selectedConfiguration.value?.karmaPoints,
      },
    );
  }
}
