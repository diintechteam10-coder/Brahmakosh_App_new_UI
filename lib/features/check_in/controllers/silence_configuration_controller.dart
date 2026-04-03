import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'dart:developer';

class SilenceConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;

  // Grouped configurations by category
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      final cat = config.category ?? 'Others';
      if (!groups.containsKey(cat)) groups[cat] = [];
      groups[cat]!.add(config);
    }
    log(
      '📊 DEBUG_SILENCE_CTRL: Grouped into ${groups.length} categories: ${groups.keys.toList()}',
      name: 'SILENCE_DEBUG',
    );
    return groups;
  }

  Future<void> fetchConfigurations(String categoryId) async {
    log(
      '🚀 DEBUG_SILENCE_CTRL: Fetching Silence Configurations for Category: $categoryId',
      name: 'SILENCE_DEBUG',
    );

    isLoading.value = true;
    try {
      final response = await getSpiritualConfigurations(null, categoryId);

      if (response != null &&
          response.success == true &&
          response.data != null) {
        allConfigurations.assignAll(response.data!);
        log(
          '✅ DEBUG_SILENCE_CTRL: Silence configurations fetched. Count: ${allConfigurations.length}',
          name: 'SILENCE_DEBUG',
        );
      } else {
        log(
          '⚠️ DEBUG_SILENCE_CTRL: Silence API returned success=false or null data',
          name: 'SILENCE_DEBUG',
        );
      }
    } catch (e) {
      log(
        '❌ DEBUG_SILENCE_CTRL: Error fetching silence configurations: $e',
        name: 'SILENCE_DEBUG',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
