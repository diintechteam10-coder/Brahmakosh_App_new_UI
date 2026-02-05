import 'package:get/get.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
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

  @override
  void onInit() {
    super.onInit();
    fetchConfigurations();
  }

  Future<void> fetchConfigurations() async {
    isLoading.value = true;
    try {
      final response = await getSpiritualConfigurations(
        null,
        chantingCategoryId,
      );
      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        allConfigurations.assignAll(response.data!);
        _initializeSelection();
      } else {
        _addFallbackMantra();
      }
    } catch (e) {
      print("Error fetching chanting configurations: $e");
      _addFallbackMantra();
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

  void onEmotionSelected(String emotion) {
    selectedEmotion.value = emotion;

    // Filter configurations based on emotion
    final filtered = allConfigurations.where((config) {
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

  void onConfigurationSelected(SpiritualConfiguration config) {
    selectedConfiguration.value = config;
  }

  void selectCount(int count) {
    selectedCount.value = count;
  }

  void startSession() {
    if (selectedConfiguration.value == null) return;

    // Navigate to Mantra Chanting with selected config
    Get.toNamed(
      AppConstants.routeMantraChanting,
      arguments: {
        'emotion': selectedEmotion.value,
        'count': selectedCount.value,
        'configuration': selectedConfiguration.value,
        // Passing these for safety if next screen not updated yet
        'mantra_title': selectedConfiguration.value?.chantingType,
        'karma_points': selectedConfiguration.value?.karmaPoints,
      },
    );
  }
}
