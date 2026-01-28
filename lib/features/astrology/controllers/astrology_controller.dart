import 'dart:convert';
import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:get/get.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../views/astrology_chat_view.dart';
import '../views/astrologist_profile_view.dart';

class AstrologyController extends GetxController {
  final _experts = <AstrologistItem>[].obs;
  final _categories = <Map<String, dynamic>>[].obs;
  final _selectedCategoryId = "all".obs; // Store ID of selected category
  final _searchQuery = "".obs;
  final searchController = TextEditingController();
  final categoryScrollController = ScrollController();
  final isLoading = false.obs;
  bool _hasLoadedOnce = false;

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
    fetchCategories();
    fetchExperts(); // initial load (cached by fetchExperts)
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
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
              _categories.value = categoryList.cast<Map<String, dynamic>>();

              // Select first category by default if not "all"
              // But usually "All" is the first tab.
              // If we want to slide to position, we'll handle that in the view.
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
              _experts.value = parsedExperts;

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
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
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
                  "Recharge your wallet",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            Text(
              "Insufficient balance to chat. Minimum \u20B9 100 required.",
              style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [50, 100, 200, 500].map((amount) {
                return InkWell(
                  onTap: () {
                    Get.back();
                    Get.snackbar(
                      "Success",
                      "Wallet recharged with \u20B9$amount",
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.primaryGold),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "\u20B9$amount",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void openHistory() {
    // Get.snackbar("History", "Opening Chat & Call logs...",
    //     snackPosition: SnackPosition.BOTTOM,
    //     backgroundColor: const Color(0xFF6366F1),
    //     colorText: Colors.white);
  }

  void openUserProfile() {
    Get.snackbar(
      "Profile",
      "Opening Account details...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
    );
  }

  void openFAQs() {
    Get.snackbar(
      "FAQs",
      "Opening Help & Support...",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFF59E0B),
      colorText: Colors.white,
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
