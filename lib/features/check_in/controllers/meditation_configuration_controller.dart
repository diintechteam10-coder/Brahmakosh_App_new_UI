import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'dart:developer';

class MeditationConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;

  // Grouped configurations by category (e.g., Guided, Breathwork, Sound)
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      // Use the 'category' field for grouping, fallback to "Others"
      final cat = config.category ?? "Others";
      if (!groups.containsKey(cat)) groups[cat] = [];
      groups[cat]!.add(config);
    }
    log('📊 DEBUG_CONTROLLER: Grouped into ${groups.length} categories: ${groups.keys.toList()}', name: 'API_DEBUG');
    groups.forEach((key, value) {
      log('   - $key: ${value.length} items', name: 'API_DEBUG');
    });
    return groups;
  }

  Future<void> fetchConfigurations(String categoryId) async {
    log('🚀 DEBUG_CONTROLLER: Fetching Meditation Configurations for Category: $categoryId', name: 'API_DEBUG');
    
    isLoading.value = true;
    try {
      final response = await getSpiritualConfigurations(
        null, // TickerProvider
        categoryId,
      );

      if (response != null &&
          response.success == true &&
          response.data != null) {
        allConfigurations.assignAll(response.data!);
        log('✅ DEBUG_CONTROLLER: Meditation configurations fetched and assigned. Count: ${allConfigurations.length}', name: 'API_DEBUG');
      } else {
        log('⚠️ DEBUG_CONTROLLER: Meditation API returned success=false or null data', name: 'API_DEBUG');
      }
    } catch (e) {
      log('❌ DEBUG_CONTROLLER: Error fetching meditation configurations: $e', name: 'API_DEBUG');
    } finally {
      isLoading.value = false;
    }
  }
}
