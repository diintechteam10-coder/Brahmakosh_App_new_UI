import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../common/api_urls.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';

class CreditHistoryController extends GetxController {
  final isLoading = true.obs;
  final creditHistory = <Map<String, dynamic>>[].obs;
  final currentPage = 1.obs;
  final totalPages = 1.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCreditHistory();
  }

  Future<void> fetchCreditHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMore.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage.value++;
    } else {
      isLoading.value = true;
      currentPage.value = 1;
      creditHistory.clear();
    }

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';
      final url = '${ApiUrls.creditHistory}?page=${currentPage.value}&limit=20';

      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'clientId': AppConstants.clientId,
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        debugPrint('📜 Credit History Response: ${response.body}');
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['data'] ?? [];
          creditHistory.addAll(items.cast<Map<String, dynamic>>());

          final meta = data['meta'];
          if (meta != null) {
            totalPages.value = meta['totalPages'] ?? 1;
            hasMore.value = currentPage.value < totalPages.value;
          } else {
            hasMore.value = false;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching credit history: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
}