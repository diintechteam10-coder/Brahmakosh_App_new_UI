import 'dart:convert';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/report/models/kundali_generate_model.dart';
import 'package:brahmakosh/features/report/models/kundali_history_model.dart';
import 'package:brahmakosh/features/report/models/match_making_model.dart';
import 'package:get/get.dart';

class ReportController extends GetxController with GetSingleTickerProviderStateMixin {

  // ─── Loading States ─────────────────────────────────────────────────────────
  var isGeneratingKundali = false.obs;
  var isLoadingHistory = false.obs;
  var isDownloading = false.obs;
  var isGeneratingMatchMaking = false.obs;

  // ─── Selected Kundali Type (0=mini, 1=basic, 2=pro) ──────────────────────
  var selectedKundaliType = 0.obs;

  // ─── Data ────────────────────────────────────────────────────────────────────
  var kundaliHistory = <KundaliHistoryItem>[].obs;
  var lastGeneratedReport = Rxn<KundaliGenerateData>();
  var matchMakingResult = Rxn<MatchMakingData>();
  var downloadUrl = ''.obs;

  // ─── Pagination ──────────────────────────────────────────────────────────────
  var currentPage = 1.obs;
  var hasMoreHistory = false.obs;
  static const int pageLimit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchKundaliHistory();
  }

  String get _userId => StorageService.getString(AppConstants.keyUserId) ?? '';
  String get _token => StorageService.getString(AppConstants.keyAuthToken) ?? '';

  // ─── Get report type string ───────────────────────────────────────────────
  String get _currentReportType {
    switch (selectedKundaliType.value) {
      case 1:
        return 'basic';
      case 2:
        return 'pro';
      default:
        return 'mini';
    }
  }

  // ─── Generate Kundali (mini/basic/pro) ───────────────────────────────────
  Future<void> generateKundaliReport() async {
    if (_userId.isEmpty) {
      Utils.showToast('User not found. Please login again.');
      return;
    }
    isGeneratingKundali.value = true;
    lastGeneratedReport.value = null;

    try {
      final url =
          '${ApiUrls.kundaliReport}/$_userId/reports/kundali/$_currentReportType';
      final body = {'language': 'en', 'timezone': 5.5};

      Utils.print('🔮 KUNDALI GENERATE URL: $url');

      await callWebApi(
        this,
        url,
        body,
        token: _token,
        showLoader: false,
        onResponse: (response) {
          Utils.print('✅ KUNDALI GENERATE RESPONSE: ${response.body}');
          try {
            final parsed =
                KundaliGenerateResponse.fromJson(jsonDecode(response.body));
            if (parsed.success == true && parsed.data != null) {
              lastGeneratedReport.value = parsed.data;
              // Refresh history after successful generation
              fetchKundaliHistory(refresh: true);
              Utils.showToast('Kundali report generated successfully!');
            } else {
              Utils.showToast(
                  parsed.message ?? 'Failed to generate Kundali report');
            }
          } catch (e) {
            Utils.print('❌ KUNDALI PARSE ERROR: $e');
            Utils.showToast('Error processing report data');
          }
        },
        onError: (error) {
          Utils.print('❌ KUNDALI GENERATE ERROR: $error');
        },
        shouldLogoutOn401: false,
      );
    } catch (e) {
      Utils.print('❌ KUNDALI EXCEPTION: $e');
    } finally {
      isGeneratingKundali.value = false;
    }
  }

  // ─── Fetch Kundali History ────────────────────────────────────────────────
  Future<void> fetchKundaliHistory({bool refresh = false}) async {
    if (_userId.isEmpty) return;
    if (refresh) {
      currentPage.value = 1;
      kundaliHistory.clear();
    }
    isLoadingHistory.value = true;

    try {
      final url =
          '${ApiUrls.kundaliReport}/$_userId/reports/kundali/history?page=${currentPage.value}&limit=$pageLimit';
      Utils.print('📜 KUNDALI HISTORY URL: $url');

      await callWebApiGet(
        this,
        url,
        token: _token,
        showLoader: false,
        onResponse: (response) {
          Utils.print('✅ KUNDALI HISTORY RESPONSE: ${response.body}');
          try {
            final parsed =
                KundaliHistoryResponse.fromJson(jsonDecode(response.body));
            if (parsed.success == true && parsed.data != null) {
              if (refresh) {
                kundaliHistory.assignAll(parsed.data!.history ?? []);
              } else {
                kundaliHistory.addAll(parsed.data!.history ?? []);
              }
              hasMoreHistory.value = parsed.data!.hasMore ?? false;
            }
          } catch (e) {
            Utils.print('❌ KUNDALI HISTORY PARSE ERROR: $e');
          }
        },
        onError: (error) {
          Utils.print('❌ KUNDALI HISTORY ERROR: $error');
        },
        shouldLogoutOn401: false,
      );
    } catch (e) {
      Utils.print('❌ KUNDALI HISTORY EXCEPTION: $e');
    } finally {
      isLoadingHistory.value = false;
    }
  }

  // ─── Load More History ────────────────────────────────────────────────────
  Future<void> loadMoreHistory() async {
    if (!hasMoreHistory.value || isLoadingHistory.value) return;
    currentPage.value++;
    await fetchKundaliHistory();
  }

  // ─── Download Kundali PDF ─────────────────────────────────────────────────
  Future<String?> downloadKundaliReport(String reportId) async {
    if (_userId.isEmpty || reportId.isEmpty) return null;
    isDownloading.value = true;
    String? presignedUrl;

    try {
      final url =
          '${ApiUrls.kundaliReport}/$_userId/reports/kundali/$reportId/download';
      Utils.print('⬇️ KUNDALI DOWNLOAD URL: $url');

      await callWebApiGet(
        this,
        url,
        token: _token,
        showLoader: false,
        onResponse: (response) {
          Utils.print('✅ KUNDALI DOWNLOAD RESPONSE: ${response.body}');
          try {
            final parsed =
                KundaliDownloadResponse.fromJson(jsonDecode(response.body));
            if (parsed.success == true && parsed.data?.presignedUrl != null) {
              presignedUrl = parsed.data!.presignedUrl!;
              downloadUrl.value = presignedUrl!;
            } else {
              // Try to get url directly from root
              final raw = jsonDecode(response.body) as Map<String, dynamic>;
              presignedUrl = raw['url'] ??
                  raw['presignedUrl'] ??
                  raw['download_url'];
              if (presignedUrl != null) downloadUrl.value = presignedUrl!;
            }
          } catch (e) {
            Utils.print('❌ KUNDALI DOWNLOAD PARSE ERROR: $e');
          }
        },
        onError: (error) {
          Utils.print('❌ KUNDALI DOWNLOAD ERROR: $error');
        },
        shouldLogoutOn401: false,
      );
    } catch (e) {
      Utils.print('❌ KUNDALI DOWNLOAD EXCEPTION: $e');
    } finally {
      isDownloading.value = false;
    }
    return presignedUrl;
  }

  // ─── Generate Match Making Report ────────────────────────────────────────
  Future<void> generateMatchMaking(MatchMakingRequest request) async {
    if (_userId.isEmpty) {
      Utils.showToast('User not found. Please login again.');
      return;
    }
    isGeneratingMatchMaking.value = true;
    matchMakingResult.value = null;

    try {
      final url =
          '${ApiUrls.matchMakingReport}/$_userId/reports/match-making';
      final body = request.toJson();

      Utils.print('💑 MATCH MAKING URL: $url');
      Utils.print('💑 MATCH MAKING BODY: $body');

      await callWebApi(
        this,
        url,
        body,
        token: _token,
        showLoader: false,
        onResponse: (response) {
          Utils.print('✅ MATCH MAKING RESPONSE: ${response.body}');
          try {
            final parsed =
                MatchMakingResponse.fromJson(jsonDecode(response.body));
            if (parsed.success == true && parsed.data != null) {
              matchMakingResult.value = parsed.data;
            } else {
              Utils.showToast(
                  parsed.message ?? 'Failed to generate match making report');
            }
          } catch (e) {
            Utils.print('❌ MATCH MAKING PARSE ERROR: $e');
            Utils.showToast('Error processing match making data');
          }
        },
        onError: (error) {
          Utils.print('❌ MATCH MAKING ERROR: $error');
        },
        shouldLogoutOn401: false,
      );
    } catch (e) {
      Utils.print('❌ MATCH MAKING EXCEPTION: $e');
    } finally {
      isGeneratingMatchMaking.value = false;
    }
  }

  // ─── Reset match making ───────────────────────────────────────────────────
  void resetMatchMaking() {
    matchMakingResult.value = null;
  }
}
