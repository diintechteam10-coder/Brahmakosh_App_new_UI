import 'package:get/get.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_clip_model.dart';
import 'package:brahmakosh/features/check_in/repositories/spiritual_repository.dart';

import 'dart:async';
import 'dart:developer';

class PrayerConfigurationController extends GetxController {
  final isLoading = false.obs;

  // Store all fetched configurations
  final allConfigurations = <SpiritualConfiguration>[].obs;

  // 🔹 Real durations cache: {trackId: "3:45 MIN"}
  final realDurations = <String, String>{}.obs;

  // 🔹 Prefetched clip responses: {configId: SpiritualClipResponse}
  final _cachedClips = <String, SpiritualClipResponse>{};

  // 🔹 In-flight prefetch futures to avoid duplicate requests
  final _inflightRequests = <String, Future<SpiritualClipResponse?>>{};

  final _repository = SpiritualRepository();

  // Grouped configurations by category (e.g., 🌅 Daily Time-Based Prayers)
  Map<String, List<SpiritualConfiguration>> get groupedConfigurations {
    final Map<String, List<SpiritualConfiguration>> groups = {};
    for (var config in allConfigurations) {
      final cat = config.category ?? 'Others';
      if (!groups.containsKey(cat)) {
        groups[cat] = [];
      }
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
        // 🔹 Disabled background duration probing because it spawns parallel audio streams
        // which massively congest the network bandwidth and delay the primary audio stream.
        // _fetchAllRealDurations();
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

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔹 CLIP PREFETCHING — Eliminates API latency on "Begin Journey" tap
  // ═══════════════════════════════════════════════════════════════════════════

  /// Prefetch clips for a single track (called when sheet opens).
  /// Returns the cached response instantly if already prefetched.
  Future<SpiritualClipResponse?> prefetchClips(String configId) async {
    // Return cached immediately
    if (_cachedClips.containsKey(configId)) {
      log('⚡ PREFETCH: Cache HIT for $configId', name: 'PRAYER_DEBUG');
      return _cachedClips[configId];
    }

    // Return in-flight request if one is already running
    if (_inflightRequests.containsKey(configId)) {
      log('⏳ PREFETCH: Joining in-flight request for $configId',
          name: 'PRAYER_DEBUG');
      return _inflightRequests[configId];
    }

    // Start new fetch
    log('🌐 PREFETCH: Fetching clips for $configId', name: 'PRAYER_DEBUG');
    final future = _fetchAndCacheClips(configId);
    _inflightRequests[configId] = future;

    try {
      final result = await future;
      return result;
    } finally {
      _inflightRequests.remove(configId);
    }
  }

  Future<SpiritualClipResponse?> _fetchAndCacheClips(String configId) async {
    try {
      final response = await _repository.getClips(configId);
      if (response != null &&
          response.success == true &&
          response.data != null &&
          response.data!.isNotEmpty) {
        _cachedClips[configId] = response;
        log('✅ PREFETCH: Cached clips for $configId', name: 'PRAYER_DEBUG');
      }
      return response;
    } catch (e) {
      log('❌ PREFETCH: Error fetching clips for $configId: $e',
          name: 'PRAYER_DEBUG');
      return null;
    }
  }

  /// Get cached clips instantly (returns null if not yet prefetched).
  SpiritualClipResponse? getCachedClips(String configId) {
    return _cachedClips[configId];
  }

  /// Aggressively prefetch clips for all tracks in a category.
  /// Called when a category expands — fires requests in parallel batches.
  Future<void> prefetchAllVisibleClips(
      List<SpiritualConfiguration> tracks) async {
    final tracksToFetch = tracks
        .where((t) =>
            t.sId != null &&
            !_cachedClips.containsKey(t.sId) &&
            !_inflightRequests.containsKey(t.sId))
        .toList();

    if (tracksToFetch.isEmpty) return;

    log(
      '🚀 PREFETCH: Aggressively prefetching ${tracksToFetch.length} tracks',
      name: 'PRAYER_DEBUG',
    );

    // Process in batches of 4 to avoid overwhelming the network
    const int batchSize = 4;
    for (int i = 0; i < tracksToFetch.length; i += batchSize) {
      final batch = tracksToFetch.sublist(
        i,
        i + batchSize > tracksToFetch.length
            ? tracksToFetch.length
            : i + batchSize,
      );
      await Future.wait(
        batch.map((track) => prefetchClips(track.sId!)),
        eagerError: false,
      );
    }
  }



  @override
  void onClose() {
    _inflightRequests.clear();
    _cachedClips.clear();
    super.onClose();
  }
}
