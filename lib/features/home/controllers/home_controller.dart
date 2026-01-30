import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/features/home/models/founder_message_model.dart';
import 'package:brahmakosh/common/models/sponsor_model.dart';
import 'package:brahmakosh/features/home/models/panchang_model.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final _founderMessageModel = Rxn<FounderMessageModel>();
  final _isLoading = false.obs;
  final _isSponsorLoading = false.obs;
  final RxList<Sponsor> sponsors = <Sponsor>[].obs;

  // Panchang Data
  final _panchangData = Rxn<PanchangData>();
  final _isPanchangLoading = false.obs;

  FounderMessageModel? get founderMessageModel => _founderMessageModel.value;
  bool get isLoading => _isLoading.value;
  bool get isSponsorLoading => _isSponsorLoading.value;

  PanchangData? get panchangData => _panchangData.value;
  bool get isPanchangLoading => _isPanchangLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchPanchang(null);
  }

  Future<void> fetchPanchang(TickerProvider? tickerProvider) async {
    _isPanchangLoading.value = true;
    print("🚀 Fetching Panchang Data...");
    try {
      final userId = StorageService.getString(AppConstants.keyUserId) ?? "";
      print("👤 User ID: $userId");

      if (userId.isEmpty) {
        debugPrint('User ID not found for Panchang fetch');
        return;
      }
      final response = await getPanchang(tickerProvider, userId);

      print("📦 Raw Panchang Response: $response");

      if (response != null && response['success'] == true) {
        _panchangData.value = PanchangData.fromJson(response['data']);
        print("✅ Panchang Data Parsed & Stored");
      } else {
        print("⚠️ Panchang API returned failure or null");
      }
    } catch (e) {
      debugPrint('Error fetching panchang: $e');
    } finally {
      print("🏁 Fetching Panchang Data Completed");
      _isPanchangLoading.value = false;
    }
  }

  Future<void> fetchFounderMessages(TickerProvider? tickerProvider) async {
    _isLoading.value = true;
    try {
      final response = await getFounderMessages(tickerProvider);
      if (response != null && response.success) {
        _founderMessageModel.value = response;
      }
    } catch (e) {
      debugPrint('Error fetching founder messages: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> fetchSponsors(TickerProvider? tickerProvider) async {
    _isSponsorLoading.value = true;
    try {
      final response = await getSponsors(tickerProvider);
      if (response?.data?.sponsors != null) {
        sponsors.assignAll(response!.data!.sponsors!);
      } else {
        sponsors.clear();
      }
    } catch (e) {
      debugPrint('Error fetching sponsors: $e');
      sponsors.clear();
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
}
