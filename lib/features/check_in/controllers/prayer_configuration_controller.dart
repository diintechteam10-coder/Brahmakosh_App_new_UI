import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'dart:developer';

class PrayerConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;

  // Grouped configurations by category (e.g., 🌅 Daily Time-Based Prayers)
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      final cat = config.category ?? 'Others';
      if (!groups.containsKey(cat)) groups[cat] = [];
      groups[cat]!.add(config);
    }
    log(
      '📊 DEBUG_PRAYER_CTRL: Grouped into ${groups.length} categories: ${groups.keys.toList()}',
      name: 'PRAYER_DEBUG',
    );
    groups.forEach((key, value) {
      log('   - $key: ${value.length} items', name: 'PRAYER_DEBUG');
    });
    return groups;
  }

  Future<void> fetchConfigurations(String categoryId) async {
    log(
      '🚀 DEBUG_PRAYER_CTRL: Fetching Prayer Configurations for Category: $categoryId',
      name: 'PRAYER_DEBUG',
    );

    isLoading.value = true;
    try {
      final response = await getSpiritualConfigurations(
        null, // TickerProvider — BLoC handles UI state
        categoryId,
      );

      if (response != null &&
          response.success == true &&
          response.data != null) {
        allConfigurations.assignAll(response.data!);
        log(
          '✅ DEBUG_PRAYER_CTRL: Prayer configurations fetched. Count: ${allConfigurations.length}',
          name: 'PRAYER_DEBUG',
        );
      } else {
        log(
          '⚠️ DEBUG_PRAYER_CTRL: Prayer API returned success=false or null data',
          name: 'PRAYER_DEBUG',
        );
      }
    } catch (e) {
      log(
        '❌ DEBUG_PRAYER_CTRL: Error fetching prayer configurations: $e',
        name: 'PRAYER_DEBUG',
      );
    } finally {
      isLoading.value = false;
    }
  }
}
