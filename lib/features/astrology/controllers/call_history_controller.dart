import 'dart:convert';
import 'package:get/get.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../common/utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/call_history_model.dart';

class CallHistoryController extends GetxController {
  final callLogs = <CallHistoryItem>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCallHistory();
  }

  Future<void> fetchCallHistory() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) {
        isLoading.value = false;
        hasError.value = true;
        return;
      }

      await callWebApiGet(
        null, // No context/tickerProvider needed
        ApiUrls.callHistory,
        token: token,
        showLoader: false, // Background loading via shimmer
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final parsedResponse = CallHistoryResponse.fromJson(data);
            if (parsedResponse.data != null) {
              callLogs.assignAll(parsedResponse.data!);
            }
          } else {
            hasError.value = true;
          }
        },
        onError: (error) {
          Utils.print('❌ Error fetching call history: $error');
          hasError.value = true;
        },
      );
    } catch (e) {
      Utils.print('❌ Exception fetching call history: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
      Utils.print(
        '🏁 fetchCallHistory completed. Logs count: ${callLogs.length}',
      );
    }
  }

  /// Get partner name
  String getPartnerName(CallHistoryItem item) {
    if (item.to != null && item.to!.name != null && item.to!.name!.isNotEmpty) {
      return item.to!.name!;
    }
    return 'Expert';
  }

  /// Get formatted date display
  String getFormattedDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';

    // Check if yesterday or today
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  /// Standardise duration presentation e.g 01:23
  String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '00:00';
    final m = (seconds / 60).floor();
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
