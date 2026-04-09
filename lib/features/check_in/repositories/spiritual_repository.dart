import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';

import 'package:brahmakosh/features/check_in/models/spiritual_checkin_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_configuration_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_clip_model.dart';
import 'package:brahmakosh/features/check_in/models/spiritual_session_model.dart';

// Actually API calls need TickerProvider. We might need to pass one or refactor api_services to be cleaner.
import 'package:brahmakosh/features/check_in/models/spiritual_stats_model.dart';
// For now, let's pass null as TickerProvider to API services if we want to avoid UI dependency in Repository,
// OR we might need to change how `callWebApi` works.
// However, the existing `callWebApi` in `api_services.dart` takes `TickerProvider?` for showing loader.
// Since we are moving to BLoC, the BLoC/UI will handle loading states, so we can pass `showLoader: false`
// and `tickerProvider: null`.

class SpiritualRepository {
  /// Fetches spiritual check-in data (Activities list).
  /// Caches result to [StorageService].
  Future<SpiritualCheckinResponse?> getCheckIn() async {
    SpiritualCheckinResponse? response;

    // We use callWebApiGet but disable its internal loader since BLoC handles state.
    await callWebApiGet(
      null, // TickerProvider
      ApiUrls.spiritualCheckin,

      token: StorageService.getString(AppConstants.keyAuthToken) ?? "",
      showLoader: false, // BLoC handles loading UI
      hideLoader: false,
      onResponse: (httpResponse) {
        // Parse on main thread for now, or use compute if needed.
        // The plan said "Use clean architecture... move heavy work to isolates using compute()".
        // API service returns the raw response object or calls onResponse.
        // In `api_services.dart`, `callWebApiGet` calls `onResponse(response)`.
        // response.body is String. We can pass that to compute.

        // Wait, callWebApiGet is weird. It calls onResponse with `http.Response`.
        // Let's grab bodies here.
        // Actually, `callWebApiGet` decoding logic is inside `_returnResponse`.
        // But `onResponse` is a callback.
      },
    );

    // The `callWebApiGet` structure is a bit legacy/callback based.
    // It returns `await _returnResponse(...)`.
    // And `_returnResponse` calls `onResponse(response)`.
    // So we can wrap this better.

    // Let's simplify and just use the existing helper but capture the result.
    // However, the existing helper is void or dynamic.

    // Cleaner approach: Use a modified version or just use http directly?
    // User said "Replace GetX controllers... API service method".
    // I should stick to using `api_services.dart` methods if they are clean,
    // BUT `getSpiritualCheckin` in `api_services.dart` is tied to TickerProvider.
    // I should use `callWebApiGet` directly.

    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    // We need to implement a way to get the result out.
    // The current `callWebApiGet` returns the result of `_returnResponse`.
    // `_returnResponse` returns 'responseJson' (String) after calling onResponse callback.
    // This is messy.

    // Let's re-examine `api_services.dart`.
    // `getSpiritualCheckin` calls `callWebApiGet` and sets a local variable.

    // We will mimic that pattern but use `compute`.

    String? responseBody;

    try {
      await callWebApiGet(
        null,
        ApiUrls.spiritualCheckin,
        token: token,
        showLoader: false,
        hideLoader: false,
        shouldLogoutOn401: true,
        onResponse: (httpResponse) {
          responseBody = httpResponse.body;
        },
      );
    } catch (e) {
      rethrow;
    }

    if (responseBody != null) {
      print('************************************************');
      print('🚀 SPIRITUAL CHECK-IN ACTIVITIES:');
      final decoded = jsonDecode(responseBody!);
      if (decoded['data'] != null && decoded['data']['activities'] != null) {
        for (var activity in decoded['data']['activities']) {
          print('📌 ${activity['title']}: ${activity['id']}');
        }
        // ══════════════════════════════════════════════════════════════
        // 🔕 SILENCE CATEGORY ID — highlighted for easy reference
        // ══════════════════════════════════════════════════════════════
        final silenceActivity = (decoded['data']['activities'] as List)
            .cast<Map<String, dynamic>>()
            .firstWhere(
              (a) =>
                  (a['title'] as String?)?.toLowerCase().contains('silence') ==
                  true,
              orElse: () => {},
            );
        if (silenceActivity.isNotEmpty) {
          print('');
          print('╔══════════════════════════════════════════════════════╗');
          print('║  🔕 SILENCE  category ID: ${silenceActivity['id']}  ║');
          print('╚══════════════════════════════════════════════════════╝');
          print('');
        } else {
          print('⚠️  No "Silence" activity found in check-in response!');
        }
        // ══════════════════════════════════════════════════════════════
      }
      print('************************************************');

      return await compute(_parseCheckInResponse, responseBody!);
    }
    return null;
  }

  /// Fetches configurations for a specific activity/category.
  /// Caches to Disk.
  Future<SpiritualConfigurationResponse?> getConfigurations(
    String categoryId,
  ) async {
    String? responseBody;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    // Construct URL properly
    // api_services.dart: final url = "${ApiUrls.spiritualConfigurations}/$categoryId"; (implied)
    // Wait, let's check `getSpiritualConfigurations` implementation in api_services.dart
    // It uses `callWebApiGet(..., "${ApiUrls.spiritualConfigurations}/$categoryId", ...)`

    print('🔍 DEBUG_REPO: getConfigurations called for $categoryId');
    final url = "${ApiUrls.spiritualConfigurations}?categoryId=$categoryId";
    print('🔍 DEBUG_REPO: Requesting URL: $url');

    try {
      final startTime = DateTime.now();
      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        hideLoader: false,
        shouldLogoutOn401: true,
        onResponse: (httpResponse) {
          responseBody = httpResponse.body;
          print(
            '✅ DEBUG_REPO: Response received in ${DateTime.now().difference(startTime).inMilliseconds}ms',
          );
          print(
            '✅ DEBUG_REPO: Response size: ${responseBody?.length ?? 0} bytes',
          );
          print('✅ DEBUG_REPO: Response size: $responseBody bytes');
        },
      );
    } catch (e) {
      print('❌ DEBUG_REPO: Network Error: $e');
      rethrow;
    }

    if (responseBody != null) {
      print('🔍 DEBUG_REPO: parsing response...');
      final parseStart = DateTime.now();
      // Remove compute for debugging/stability
      final response = _parseConfigResponse(responseBody!);
      print(
        '✅ DEBUG_REPO: Parsing done in ${DateTime.now().difference(parseStart).inMilliseconds}ms',
      );

      // Cache to Disk (Write-through)
      if (response != null && response.success == true) {
        _cacheConfigToDisk(categoryId, response);
      }

      return response;
    }
    return null;
  }

  /// Gets cached config from Disk
  Future<SpiritualConfigurationResponse?> getCachedConfiguration(
    String categoryId,
  ) async {
    try {
      final cachedJson = StorageService.getString('cache_config_$categoryId');
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return _parseConfigJson(cachedJson);
      }
    } catch (e) {
      print('SpiritualRepository: Error reading cache: $e');
    }
    return null;
  }

  /// Fetches clips for a configuration.
  Future<SpiritualClipResponse?> getClips(String configId) async {
    String? responseBody;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    final url = "${ApiUrls.spiritualClipsByConfig}/$configId";

    try {
      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (httpResponse) {
          responseBody = httpResponse.body;
          print('✅ DEBUG_REPO: Response my data: $responseBody bytes');
        },
      );
    } catch (e) {
      rethrow;
    }

    if (responseBody != null) {
      return await compute(_parseClipResponse, responseBody!);
    }
    return null;
  }

  /// Saves a session.
  Future<Map<String, dynamic>> saveSession(
    SpiritualSessionRequest request,
  ) async {
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    Map<String, dynamic>? responseData;

    try {
      await callWebApi(
        null,
        ApiUrls.saveSpiritualSession,
        request.toJson(),
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (httpResponse) {
          // callWebApi receives http.Response if successful
          final body = httpResponse.body;
          responseData = jsonDecode(body);
        },
        onError: (error) {
          throw error;
        },
      );
    } catch (e) {
      rethrow;
    }

    return responseData ?? {};
  }

  /// Fetches user profile image if missing from cache
  Future<String?> fetchUserProfileImage() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null || token.isEmpty) return null;

      final Completer<String?> completer = Completer<String?>();

      await callWebApiGet(
        null,
        ApiUrls.getProfile,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (httpResponse) async {
          try {
            final responseBody = json.decode(httpResponse.body);
            if (responseBody['success'] == true &&
                responseBody['data'] != null) {
              final userData = responseBody['data']['user'];
              final String? imageUrl = userData['profile']?['profile_image'];
              if (imageUrl != null && imageUrl.isNotEmpty) {
                await StorageService.setString(
                  AppConstants.keyUserImage,
                  imageUrl,
                );
                completer.complete(imageUrl);
              } else {
                completer.complete(null);
              }
            } else {
              completer.complete(null);
            }
          } catch (e) {
            completer.complete(null);
          }
        },
      );
      return completer.future;
    } catch (e) {
      return null;
    }
  }

  /// Fetches spiritual stats for a user.
  Future<SpiritualStatsResponse?> getSpiritualStats() async {
    String? responseBody;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    final userId = StorageService.getString(AppConstants.keyUserId) ?? "";

    if (userId.isEmpty) {
      print('❌ DEBUG_REPO: API Error: User ID not found in storage');
      return null;
    }

    final url = "${ApiUrls.spiritualStatsUser}/$userId";

    try {
      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (httpResponse) {
          responseBody = httpResponse.body;
        },
      );
    } catch (e) {
      rethrow;
    }

    if (responseBody != null) {
      return await compute(_parseStatsResponse, responseBody!);
    }
    return null;
  }

  // --- Private Helpers & Static Parsers for Compute ---

  Future<void> _cacheConfigToDisk(
    String categoryId,
    SpiritualConfigurationResponse response,
  ) async {
    try {
      final jsonStr = _encodeConfigResponse(response);
      await StorageService.setString('cache_config_$categoryId', jsonStr);
    } catch (e) {
      print('SpiritualRepository: Cache write error: $e');
    }
  }

  static SpiritualCheckinResponse? _parseCheckInResponse(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return SpiritualCheckinResponse.fromJson(json);
    } catch (e) {
      print('Error parsing checkin response: $e');
      return null;
    }
  }

  static SpiritualConfigurationResponse? _parseConfigResponse(
    String responseBody,
  ) {
    try {
      final json = jsonDecode(responseBody);
      return SpiritualConfigurationResponse.fromJson(json);
    } catch (e) {
      print('Error parsing config response: $e');
      return null;
    }
  }

  static SpiritualConfigurationResponse? _parseConfigJson(String jsonStr) {
    try {
      final json = jsonDecode(jsonStr);
      return SpiritualConfigurationResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static SpiritualClipResponse? _parseClipResponse(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return SpiritualClipResponse.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  static String _encodeConfigResponse(SpiritualConfigurationResponse response) {
    return jsonEncode(response.toJson());
  }

  static SpiritualStatsResponse? _parseStatsResponse(String responseBody) {
    try {
      final json = jsonDecode(responseBody);
      return SpiritualStatsResponse.fromJson(json);
    } catch (e) {
      print('Error parsing stats response: $e');
      return null;
    }
  }
}
