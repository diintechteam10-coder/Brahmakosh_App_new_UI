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
  final _categories = ["Astrology", "Tarot", "Numerology", "Vastu", "Reiki"].obs;
  final _selectedCategory = "Astrology".obs;
  final _searchQuery = "".obs;
  final searchController = TextEditingController();
  final isLoading = false.obs;
  bool _hasLoadedOnce = false;

  List<AstrologistItem> get experts => _experts;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory.value;
  
  List<AstrologistItem> get filteredExperts {
    final query = _searchQuery.value.toLowerCase();
    return _experts.where((expert) {
      // Parse skills from expertise
      final skills = expert.expertise != null && expert.expertise!.isNotEmpty
          ? expert.expertise!.split(',').map((e) => e.trim().toLowerCase()).toList()
          : <String>[];
      
      final matchesCategory = selectedCategory == "Astrology" || 
        skills.any((skill) => skill.contains(selectedCategory.toLowerCase()));
      
      final expertName = (expert.name ?? '').toLowerCase();
      final languages = expert.languages ?? [];
      
      final matchesSearch = query.isEmpty || 
        expertName.contains(query) ||
        skills.any((skill) => skill.contains(query)) ||
        languages.any((lang) => lang.toLowerCase().contains(query));
      return matchesCategory && matchesSearch;
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
    fetchExperts(); // initial load (cached by fetchExperts)
    searchController.addListener(() {
      _searchQuery.value = searchController.text;
    });
  }

  /// Fetch experts.
  /// - If experts are already loaded, this will NOT re-fetch unless [force] is true.
  /// - Shimmer (`isLoading`) is shown only on first load or manual refresh.
  Future<void> fetchExperts({bool force = false}) async {
    if (!force && _hasLoadedOnce && _experts.isNotEmpty) return;

    final shouldShowLoading = force || _experts.isEmpty;
    if (shouldShowLoading) isLoading.value = true;
    
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? '';

      await callWebApiGet(
        null,
        ApiUrls.experts,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) {
          try {
            final responseBody = json.decode(response.body);
            print("📦 Experts Response: ${response.body}");

            if (responseBody['success'] == true) {
              // Handle different response structures
              var data = responseBody['data'];
              
              if (data is List) {
                // Direct list structure
                _experts.value = data
                    .map((item) => AstrologistItem.fromJson(item))
                    .where((item) => item.isActive == true && item.isDeleted != true)
                    .toList();
              } else if (data is Map) {
                // Nested structure
                if (data['data'] != null && data['data'] is List) {
                  _experts.value = (data['data'] as List)
                      .map((item) => AstrologistItem.fromJson(item))
                      .where((item) => item.isActive == true && item.isDeleted != true)
                      .toList();
                } else {
                  // Try AstrologistModel structure
                  final expertModel = AstrologistModel.fromJson(responseBody);
                  if (expertModel.data != null) {
                    _experts.value = expertModel.data!
                        .where((item) => item.isActive == true && item.isDeleted != true)
                        .toList();
                  }
                }
              }

              // Fallback to mock data if API returns empty
              if (_experts.isEmpty) {
                _loadMockData();
              }
            } else {
              // Fallback to mock data on API error
              _loadMockData();
            }
          } catch (e) {
            print("❌ Error parsing experts: $e");
            _loadMockData(); // Fallback to mock data
          }
          _hasLoadedOnce = true;
          if (shouldShowLoading) isLoading.value = false;
        },
        onError: (error) {
          print("❌ Error fetching experts: $error");
          _loadMockData(); // Fallback to mock data
          _hasLoadedOnce = true;
          if (shouldShowLoading) isLoading.value = false;
        },
      );
    } catch (e) {
      print("❌ Exception in fetchExperts: $e");
      _loadMockData(); // Fallback to mock data
      _hasLoadedOnce = true;
      if (shouldShowLoading) isLoading.value = false;
    }
  }

  /// Manual refresh (e.g. pull-to-refresh).
  Future<void> refreshExperts() async {
    await fetchExperts(force: true);
  }

  void _loadMockData() {
    _experts.value = [
      AstrologistItem(
        id: "1",
        name: "Acharya Mukesh",
        profilePhoto: "https://randomuser.me/api/portraits/men/1.jpg",
        expertise: "Vedic, Vastu, Palmistry",
        languages: ["Hindi", "English"],
        experience: "12",
        rating: 4.8,
        reviews: 15400,
        chatCharge: 25,
        voiceCharge: 30,
        videoCharge: 50,
        status: "online",
        profileSummary: "Acharya Mukesh is a world-renowned Vedic astrologer with over 12 years of experience. He specializes in Vastu Shastra and Palmistry, providing deep insights into personal and professional life.",
        isActive: true,
        isDeleted: false,
      ),
      AstrologistItem(
        id: "2",
        name: "Tarot Sunita",
        profilePhoto: "https://randomuser.me/api/portraits/women/2.jpg",
        expertise: "Tarot, Numerology",
        languages: ["Hindi", "English", "Punjabi"],
        experience: "8",
        rating: 4.9,
        reviews: 9800,
        chatCharge: 20,
        voiceCharge: 25,
        videoCharge: 45,
        status: "online",
        profileSummary: "Sunita is an expert Tarot Reader and Numerologist. Her intuitive readings have helped thousands find their true path in life.",
        isActive: true,
        isDeleted: false,
      ),
      AstrologistItem(
        id: "3",
        name: "Pandit Rajesh",
        profilePhoto: "https://randomuser.me/api/portraits/men/3.jpg",
        expertise: "Vedic, Palmistry",
        languages: ["Hindi", "Sanskrit"],
        experience: "25",
        rating: 4.7,
        reviews: 45000,
        chatCharge: 40,
        voiceCharge: 45,
        videoCharge: 60,
        status: "offline",
        profileSummary: "One of the most senior astrologers with a vast knowledge of Sanskrit and ancient Vedic texts.",
        isActive: true,
        isDeleted: false,
      ),
      AstrologistItem(
        id: "4",
        name: "Acharya Aditya",
        profilePhoto: "https://randomuser.me/api/portraits/men/4.jpg",
        expertise: "Vedic, Nadi",
        languages: ["Hindi", "English"],
        experience: "15",
        rating: 4.9,
        reviews: 25000,
        chatCharge: 30,
        voiceCharge: 35,
        videoCharge: 55,
        status: "online",
        profileSummary: "Acharya Aditya is a highly experienced astrologer specializing in Nadi astrology.",
        isActive: true,
        isDeleted: false,
      ),
    ];
  }

  void selectCategory(String category) {
    _selectedCategory.value = category;
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
                IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close)),
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
                    Get.snackbar("Success", "Wallet recharged with \u20B9$amount",
                      backgroundColor: Colors.green, colorText: Colors.white);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Proceed to Pay",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
    Get.snackbar("Profile", "Opening Account details...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white);
  }

  void openFAQs() {
    Get.snackbar("FAQs", "Opening Help & Support...",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}