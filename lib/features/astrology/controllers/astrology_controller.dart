import 'dart:convert';
import 'package:brahmakosh/common_imports.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../views/astrology_chat_view.dart';
import '../views/astrologist_profile_view.dart';
import '../views/conversation_history_view.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/localization/translate_helper.dart';

class AstrologyController extends GetxController {
  final _experts = <AstrologistItem>[].obs;
  final _categories = <Map<String, dynamic>>[].obs;
  final _selectedCategoryId = "all".obs; // Store ID of selected category
  final _searchQuery = "".obs;
  final searchController = TextEditingController();
  final categoryScrollController = ScrollController();
  final isLoading = false.obs;
  bool _hasLoadedOnce = false;

  // Dynamic Translation Maps
  final RxMap<String, String> _translatedData = <String, String>{}.obs;
  String _lastLang = 'en';

  Map<String, String> get translatedData => _translatedData;


  List<AstrologistItem> get experts => _experts;
  List<Map<String, dynamic>> get categories => _categories;
  String get selectedCategoryId => _selectedCategoryId.value;

  List<AstrologistItem> get filteredExperts {
    final query = _searchQuery.value.toLowerCase();

    // Find selected category name for filtering - REMOVED as we don't filter by name anymore
    // String selectedCategoryName = "Astrology";
    // if (_selectedCategoryId.value != "all") { ... }

    return _experts.where((expert) {
      // Parse skills from expertise
      final skills = expert.expertise != null && expert.expertise!.isNotEmpty
          ? expert.expertise!
                .split(',')
                .map((e) => e.trim().toLowerCase())
                .toList()
          : <String>[];

      // Note: We do NOT filter by category name here anymore.
      // The API already filters by category ID when we call fetchExperts(categoryId: ...).
      // Client-side filtering by name was causing issues (e.g. "Healer" vs "Energy Healing").

      final expertName = (expert.name ?? '').toLowerCase();
      final languages = expert.languages ?? [];

      final matchesSearch =
          query.isEmpty ||
          expertName.contains(query) ||
          skills.any((skill) => skill.contains(query)) ||
          languages.any((lang) => lang.toLowerCase().contains(query));

      return matchesSearch;
    }).toList();
  }

  List<AstrologistItem> get trendingExperts {
    // Return top rated experts as trending
    final sorted = List<AstrologistItem>.from(_experts);
    sorted.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
    return sorted.take(4).toList();
  }

  @override
  void onInit() {
    super.onInit();
    _lastLang = Get.locale?.languageCode ?? 'en';
    fetchCategories();
    fetchExperts(); // initial load (cached by fetchExperts)
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }


  Future<void> _translateAll() async {
    if (_lastLang == 'en') {
      _translatedData.clear();
      return;
    }

    final Set<String> toTranslate = {};

    // Categories
    for (var cat in _categories) {
      if (cat['name'] != null) toTranslate.add(cat['name']);
    }

    // Experts
    for (var expert in _experts) {
      if (expert.name != null) toTranslate.add(expert.name!);
      if (expert.expertise != null) toTranslate.add(expert.expertise!);
    }

    if (toTranslate.isEmpty) return;

    final list = toTranslate.toList();
    final results = await TranslateHelper.translateList(list);

    final Map<String, String> newTranslations = {};
    for (int i = 0; i < list.length; i++) {
      newTranslations[list[i]] = results[i];
    }
    _translatedData.assignAll(newTranslations);
  }


  Future<void> fetchCategories() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';
      await callWebApiGet(
        null,
        ApiUrls.sadhnaServices,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) {
          print("📦 Categories Response Code: ${response.statusCode}");
          print("📦 Categories Response Body: ${response.body}");

          final responseBody = json.decode(response.body);
          if (responseBody['success'] == true && responseBody['data'] != null) {
            final data = responseBody['data'];
            List<dynamic> categoryList = [];

            if (data is Map && data['data'] is List) {
              categoryList = data['data'];
            } else if (data is List) {
              categoryList = data;
            }

            print("✅ Parsed ${categoryList.length} categories");

            if (categoryList.isNotEmpty) {
              final castedCategories = categoryList.cast<Map<String, dynamic>>();
              _categories.value = castedCategories;
              _translateAll();
            }

          } else {
            print("❌ Categories API Success is false or data null");
          }
        },
        onError: (error) {
          print("❌ Error fetching categories: $error");
        },
      );
    } catch (e) {
      print("Error in fetchCategories: $e");
    }
  }

  void selectCategory(String id) {
    _selectedCategoryId.value = id;
    fetchExperts(force: true, categoryId: id);
  }

  /// Fetch experts.
  /// - If [categoryId] is provided and not 'all', it filters by category.
  Future<void> fetchExperts({bool force = false, String? categoryId}) async {
    final targetCategory = categoryId ?? _selectedCategoryId.value;
    if (!force &&
        _hasLoadedOnce &&
        _experts.isNotEmpty &&
        targetCategory == _selectedCategoryId.value)
      return;

    final shouldShowLoading = force || _experts.isEmpty;
    if (shouldShowLoading) isLoading.value = true;

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';

      String url = ApiUrls.experts;
      // final targetCategory = categoryId ?? _selectedCategoryId.value; // Already defined above
      if (targetCategory != "all") {
        url += "?category=$targetCategory";
      }

      print("🚀 Fetching Experts from: $url");

      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) {
          try {
            print("📦 Experts Response Code: ${response.statusCode}");
            print("📦 Experts Response Body: ${response.body}");

            final responseBody = json.decode(response.body);

            if (responseBody['success'] == true) {
              // Handle different response structures
              var data = responseBody['data'];
              List<AstrologistItem> parsedExperts = [];

              if (data is List) {
                // Direct list structure
                parsedExperts = data
                    .map((item) => AstrologistItem.fromJson(item))
                    .where(
                      (item) => item.isActive == true && item.isDeleted != true,
                    )
                    .toList();
              } else if (data is Map) {
                // Nested structure
                if (data['data'] != null && data['data'] is List) {
                  parsedExperts = (data['data'] as List)
                      .map((item) => AstrologistItem.fromJson(item))
                      .where(
                        (item) =>
                            item.isActive == true && item.isDeleted != true,
                      )
                      .toList();
                } else {
                  // Try AstrologistModel structure
                  final expertModel = AstrologistModel.fromJson(responseBody);
                  if (expertModel.data != null) {
                    parsedExperts = expertModel.data!
                        .where(
                          (item) =>
                              item.isActive == true && item.isDeleted != true,
                        )
                        .toList();
                  }
                }
              }

              print("✅ Parsed ${parsedExperts.length} experts");
              // Print raw expert data for debugging
              for (var expert in parsedExperts) {
                print("👤 Expert Data: ${json.encode(expert.toJson())}");
              }
              _experts.value = parsedExperts;
              _translateAll();

              // Fallback to mock data if API returns empty
              if (_experts.isEmpty) {
                print("⚠️ API returned 0 experts.");
                // _loadMockData(); // REMOVED MOCK DATA FALLBACK
              }
            } else {
              print("❌ API Success is false: ${responseBody['message']}");
              // Fallback to mock data on API error
              // _loadMockData(); // REMOVED MOCK DATA FALLBACK
            }
          } catch (e) {
            print("❌ Error parsing experts: $e");
            // _loadMockData(); // Fallback to mock data // REMOVED MOCK DATA FALLBACK
          }
          _hasLoadedOnce = true;
          if (shouldShowLoading) isLoading.value = false;
        },
        onError: (error) {
          print("❌ Error fetching experts: $error");
          // _loadMockData(); // Fallback to mock data // REMOVED MOCK DATA FALLBACK
          _hasLoadedOnce = true;
          if (shouldShowLoading) isLoading.value = false;
        },
      );
    } catch (e) {
      print("❌ Exception in fetchExperts: $e");
      // _loadMockData(); // Fallback to mock data // REMOVED MOCK DATA FALLBACK
      _hasLoadedOnce = true;
      if (shouldShowLoading) isLoading.value = false;
    }
  }

  /// Manual refresh (e.g. pull-to-refresh).
  Future<void> refreshExperts() async {
    await fetchExperts(force: true);
  }

  void navigateToProfile(AstrologistItem expert) {
    Get.to(() => AstrologistProfileView(expert: expert));
  }

  void startChat(AstrologistItem expert) {
    Get.to(() => AstrologyChatView(expert: expert.toAstrologist()));
  }

  void filterExperts() {
    // This is handled by Obx in the view using the searchController listener
    // but we can add explicit logic here if needed.
  }

  void showRechargeBottomSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "recharge_wallet".tr.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "insufficient_balance_msg".tr,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 24),
            
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [100, 200, 500, 1000].map((amount) {
                return InkWell(
                  onTap: () {
                    Get.back();
                    AppSnackBar.showInfo(
                      "processing".tr,
                      "starting_payment".trParams({'amount': amount.toString()}),
                    );
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "₹$amount",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                ),
                child: Text(
                  "proceed_to_pay".tr.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void openHistory() {
    Get.to(() => const ConversationHistoryView());
  }

  void openUserProfile() {
    AppSnackBar.showSuccess(
      "profile_title".tr,
      "opening_profile_msg".tr,
    );
  }

  void openFAQs() {
    launchUrl(Uri.parse('https://www.brahmakosh.com/privacy-policy'));
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

