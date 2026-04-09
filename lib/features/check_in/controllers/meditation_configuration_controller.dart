import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'dart:developer';

class MeditationConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;
  
  // 🔹 Real durations cache: {trackId: "3:45"}
  final realDurations = <String, String>{}.obs;
  final _repository = SpiritualRepository();
  final _metaPlayer = AudioPlayer();

  // Grouped configurations by category (e.g., Guided, Breathwork, Sound)
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      // Use the 'category' field for grouping, fallback to "Others"
      final cat = config.category ?? "Others";
      if (!groups.containsKey(cat)) {
        groups[cat] = [];
      }
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
        
        // 🔹 Start fetching real durations in background
        _fetchAllRealDurations();
      } else {
        log('⚠️ DEBUG_CONTROLLER: Meditation API returned success=false or null data', name: 'API_DEBUG');
      }
    } catch (e) {
      log('❌ DEBUG_CONTROLLER: Error fetching meditation configurations: $e', name: 'API_DEBUG');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchAllRealDurations() async {
    for (var track in allConfigurations) {
      if (track.sId == null || realDurations.containsKey(track.sId)) {
        continue;
      }
      
      try {
        final clipsResponse = await _repository.getClips(track.sId!);
        if (clipsResponse != null && 
            clipsResponse.success == true && 
            clipsResponse.data != null && 
            clipsResponse.data!.isNotEmpty) {
          
          final audioUrl = clipsResponse.data!.first.audioUrl;
          if (audioUrl != null && audioUrl.startsWith('http')) {
            await _metaPlayer.setSourceUrl(audioUrl);
            final duration = await _metaPlayer.getDuration();
            if (duration != null) {
              final minutes = duration.inMinutes;
              final seconds = duration.inSeconds % 60;
              realDurations[track.sId!] = "$minutes:${seconds.toString().padLeft(2, '0')} MIN";
            }
          }
        }
      } catch (e) {
        log('⚠️ Error fetching duration for ${track.title}: $e', name: 'API_DEBUG');
      }
      
      // Small delay to avoid hammering the network too hard
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void onClose() {
    _metaPlayer.dispose();
    super.onClose();
  }
}
