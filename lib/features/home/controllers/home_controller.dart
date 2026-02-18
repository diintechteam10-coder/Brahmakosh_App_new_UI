import 'dart:convert';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/features/home/models/founder_message_model.dart';
import 'package:brahmakosh/common/models/sponsor_model.dart';
import 'package:brahmakosh/features/home/models/panchang_model.dart';
import 'package:brahmakosh/features/home/models/dosha_dasha_model.dart';
import 'package:brahmakosh/features/home/models/remedies_model.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:get/get.dart';

import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class HomeController extends GetxController {
  final _founderMessageModel = Rxn<FounderMessageModel>();
  final _isLoading = false.obs;
  final _isSponsorLoading = false.obs;
  final RxList<Sponsor> sponsors = <Sponsor>[].obs;
  final _userCompleteDetails = Rxn<UserCompleteDetailsModel>();
  final _isUserDetailsLoading = false.obs;

  // Panchang Data
  final _panchangData = Rxn<PanchangData>();
  final _isPanchangLoading = false.obs;

  FounderMessageModel? get founderMessageModel => _founderMessageModel.value;
  bool get isLoading => _isLoading.value;
  bool get isSponsorLoading => _isSponsorLoading.value;
  UserCompleteDetailsModel? get userCompleteDetails =>
      _userCompleteDetails.value;
  Rxn<UserCompleteDetailsModel> get userCompleteDetailsRx =>
      _userCompleteDetails;
  bool get isUserDetailsLoading => _isUserDetailsLoading.value;

  PanchangData? get panchangData => _panchangData.value;
  bool get isPanchangLoading => _isPanchangLoading.value;

  // Dosha Dasha Data
  final _doshaDashaData = Rxn<DoshaDashaModel>();
  final _isDoshaDashaLoading = false.obs;

  DoshaDashaModel? get doshaDashaData => _doshaDashaData.value;
  Rxn<DoshaDashaModel> get doshaDashaDataRx => _doshaDashaData;
  bool get isDoshaDashaLoading => _isDoshaDashaLoading.value;

  @override
  void onInit() {
    super.onInit();
    _loadCache();
    refreshHomeData();
  }

  void _loadCache() {
    // Load Panchang
    try {
      final String? panchangJson = StorageService.getString(
        AppConstants.cachePanchangData,
      );
      if (panchangJson != null && panchangJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(panchangJson);
        _panchangData.value = PanchangData.fromJson(data);
      }
    } catch (e) {
      debugPrint("Error loading Panchang cache: $e");
    }

    // Load Founder Messages
    try {
      final String? founderJson = StorageService.getString(
        AppConstants.cacheFounderMessage,
      );
      if (founderJson != null && founderJson.isNotEmpty) {
        _founderMessageModel.value = FounderMessageModel.fromJson(
          jsonDecode(founderJson),
        );
      }
    } catch (e) {
      debugPrint("Error loading Founder Message cache: $e");
    }

    // Load Sponsors
    try {
      final String? sponsorJson = StorageService.getString(
        AppConstants.cacheSponsors,
      );
      if (sponsorJson != null && sponsorJson.isNotEmpty) {
        final SponsorModel model = SponsorModel.fromJson(
          jsonDecode(sponsorJson),
        );
        if (model.data?.sponsors != null) {
          sponsors.assignAll(model.data!.sponsors!);
        }
      }
    } catch (e) {
      debugPrint("Error loading Sponsor cache: $e");
    }

    // Load User Details
    try {
      final String? userJson = StorageService.getString(
        AppConstants.cacheUserCompleteDetails,
      );
      if (userJson != null && userJson.isNotEmpty) {
        _userCompleteDetails.value = UserCompleteDetailsModel.fromJson(
          jsonDecode(userJson),
        );
      }
    } catch (e) {
      debugPrint("Error loading User Details cache: $e");
    }
  }

  Future<void> refreshHomeData() async {
    //Fire all requests in parallel
    await Future.wait([
      fetchPanchang(null),
      fetchFounderMessages(null),
      fetchSponsors(null),
      fetchUserCompleteDetails(null),
      fetchSponsors(null),
      fetchUserCompleteDetails(null),
      fetchDoshaDasha(null),
      fetchRemedies(null),
    ]);
  }

  Future<void> fetchUserCompleteDetails(TickerProvider? tickerProvider) async {
    if (_userCompleteDetails.value == null) _isUserDetailsLoading.value = true;
    try {
      final userId = StorageService.getString(AppConstants.keyUserId) ?? "";
      if (userId.isEmpty) return;

      final response = await getUserCompleteDetails(tickerProvider, userId);
      if (response != null && response.data != null) {
        _userCompleteDetails.value = response;
        StorageService.setString(
          AppConstants.cacheUserCompleteDetails,
          jsonEncode(response.toJson()),
        );
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
    } finally {
      _isUserDetailsLoading.value = false;
    }
  }

  Future<void> fetchPanchang(TickerProvider? tickerProvider) async {
    if (_panchangData.value == null) _isPanchangLoading.value = true;
    print("🚀 Fetching Panchang Data...");
    try {
      final userId = StorageService.getString(AppConstants.keyUserId) ?? "";
      if (userId.isEmpty) {
        debugPrint('User ID not found for Panchang fetch');
        return;
      }
      final response = await getPanchang(tickerProvider, userId);

      if (response != null && response['success'] == true) {
        final data = response['data'];
        _panchangData.value = PanchangData.fromJson(data);
        // Cache the data part
        StorageService.setString(
          AppConstants.cachePanchangData,
          jsonEncode(data),
        );
        print("✅ Panchang Data Parsed & Stored");
        print("✅ Panchang Data ${data}");
      } else {
        print("⚠️ Panchang API returned failure or null");
      }
    } catch (e) {
      debugPrint('Error fetching panchang: $e');
    } finally {
      _isPanchangLoading.value = false;
    }
  }

  Future<void> fetchFounderMessages(TickerProvider? tickerProvider) async {
    if (_founderMessageModel.value == null) _isLoading.value = true;
    try {
      final response = await getFounderMessages(tickerProvider);
      if (response != null && response.success) {
        _founderMessageModel.value = response;
        StorageService.setString(
          AppConstants.cacheFounderMessage,
          jsonEncode(response.toJson()),
        );
      }
    } catch (e) {
      debugPrint('Error fetching founder messages: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSponsors(TickerProvider? tickerProvider) async {
    if (sponsors.isEmpty) _isSponsorLoading.value = true;
    try {
      final response = await getSponsors(tickerProvider);
      if (response?.data?.sponsors != null) {
        sponsors.assignAll(response!.data!.sponsors!);
        StorageService.setString(
          AppConstants.cacheSponsors,
          jsonEncode(response!.toJson()),
        );
      } else {
        if (response?.success == true) {
          sponsors.clear();
        }
      }
    } catch (e) {
      debugPrint('Error fetching sponsors: $e');
    } finally {
      _isSponsorLoading.value = false;
    }
  }

  // Helper to get first active message
  FounderMessage? get activeFounderMessage {
    if (_founderMessageModel.value == null ||
        _founderMessageModel.value!.data.isEmpty) {
      return null;
    }
    return _founderMessageModel.value!.data.firstWhere(
      (m) => m.isActive & !m.isDeleted,
      orElse: () => _founderMessageModel.value!.data.first,
    );
  }

  Future<void> fetchDoshaDasha(TickerProvider? tickerProvider) async {
    if (_doshaDashaData.value == null) _isDoshaDashaLoading.value = true;
    try {
      final userId = StorageService.getString(AppConstants.keyUserId) ?? "";
      if (userId.isEmpty) return;

      final response = await getDoshaDasha(tickerProvider, userId);

      if (response != null && response.success == true) {
        _doshaDashaData.value = response;
        // Optionally cache validation
      }
    } catch (e) {
      debugPrint('Error fetching dosha dasha: $e');
    } finally {
      _isDoshaDashaLoading.value = false;
    }
  }

  // Remedies Data
  final _remediesData = Rxn<RemediesModel>();
  final _isRemediesLoading = false.obs;

  RemediesModel? get remediesData => _remediesData.value;
  Rxn<RemediesModel> get remediesDataRx => _remediesData;
  bool get isRemediesLoading => _isRemediesLoading.value;

  Future<void> fetchRemedies(TickerProvider? tickerProvider) async {
    if (_remediesData.value == null) _isRemediesLoading.value = true;
    try {
      final userId = StorageService.getString(AppConstants.keyUserId) ?? "";
      if (userId.isEmpty) return;

      final response = await getRemedies(tickerProvider, userId);

      if (response != null && response.success == true) {
        _remediesData.value = response;
      }
    } catch (e) {
      debugPrint('Error fetching remedies: $e');
    } finally {
      _isRemediesLoading.value = false;
    }
  }
}
