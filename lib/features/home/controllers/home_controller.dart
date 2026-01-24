import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/features/home/models/founder_message_model.dart';
import 'package:brahmakosh/common/models/sponsor_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final _founderMessageModel = Rxn<FounderMessageModel>();
  final _isLoading = false.obs;
  final _isSponsorLoading = false.obs;
  final RxList<Sponsor> sponsors = <Sponsor>[].obs;

  FounderMessageModel? get founderMessageModel => _founderMessageModel.value;
  bool get isLoading => _isLoading.value;
  bool get isSponsorLoading => _isSponsorLoading.value;

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
    if (_founderMessageModel.value == null || _founderMessageModel.value!.data.isEmpty) {
      return null;
    }
    return _founderMessageModel.value!.data.firstWhere(
      (m) => m.isActive & !m.isDeleted,
      orElse: () => _founderMessageModel.value!.data.first,
    );
  }
}
