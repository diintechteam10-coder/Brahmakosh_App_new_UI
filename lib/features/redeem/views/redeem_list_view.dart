import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/views/redemption_history_view.dart';
import 'package:brahmakosh/features/redeem/widgets/redeem_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import 'package:sizer/sizer.dart';

class RedeemListView extends StatefulWidget {
  const RedeemListView({super.key});

  @override
  State<RedeemListView> createState() => _RedeemListViewState();
}

class _RedeemListViewState extends State<RedeemListView> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(List<RedeemItemModel> items, List<String> categories) async {
    final currentLang = Get.locale?.languageCode ?? 'en';
    if (currentLang == 'en') {
      if (_dynamicTranslations.isNotEmpty) {
        setState(() {
          _dynamicTranslations.clear();
          _lastLang = 'en';
        });
      }
      return;
    }

    final Set<String> toTranslate = {};

    for (var item in items) {
      if (item.title.isNotEmpty) toTranslate.add(item.title);
      if (item.description.isNotEmpty) toTranslate.add(item.description);
    }

    for (var cat in categories) {
      if (cat != 'All' && cat.isNotEmpty) toTranslate.add(cat);
    }

    if (toTranslate.isEmpty) return;

    final list = toTranslate.toList();
    final results = await TranslateHelper.translateList(list);

    bool changed = false;
    for (int i = 0; i < list.length; i++) {
      if (_dynamicTranslations[list[i]] != results[i]) {
        _dynamicTranslations[list[i]] = results[i];
        changed = true;
      }
    }

    if (changed || _lastLang != currentLang) {
      if (mounted) {
        setState(() {
          _lastLang = currentLang;
        });
      }
    }
  }

  // Helper to translate categories
  String _getTranslatedCategory(String category) {
    if (category == 'All') return 'category_all'.tr;
    final lower = category.toLowerCase();
    if (lower == 'donations') return 'category_donations'.tr;
    if (lower == 'puja') return 'category_puja'.tr;
    if (lower == 'merch') return 'category_merch'.tr;
    if (lower == 'mantra') return 'category_mantra'.tr;
    return _dynamicTranslations[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final RedeemController controller = Get.put(RedeemController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "redeem_cap".tr,
          style: GoogleFonts.lora(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 1.w, top: 1.h, bottom: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Icon(Icons.stars, color: const Color(0xFFD4AF37), size: 14.sp),
                  SizedBox(width: 1.5.w),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.userPoints.value} ",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                        TextSpan(
                          text: "Karma",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => const RedemptionHistoryView());
            },
            icon: Icon(Icons.history, color: Colors.white, size: 18.sp),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Image (Mock)
          Padding(
            padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 2.h),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/redeem_poster.png',
                  width: double.infinity,
                  height: 18.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 18.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1A1A1A), const Color(0xFF0A0A0A)],
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stars, size: 30.sp, color: const Color(0xFFD4AF37)),
                          SizedBox(height: 1.h),
                          Text(
                            "redeem_subtitle".tr,
                            style: GoogleFonts.lora(
                              color: Colors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Obx(
              () {
                // Trigger translation in post frame callback to avoid build-time setState
                if (controller.redeemItems.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _translateAllContents(controller.redeemItems, controller.categories);
                  });
                }
                
                return Row(
                  children: controller.categories
                      .map(
                        (category) {
                          return Padding(
                            padding: EdgeInsets.only(right: 3.w),
                            child: _buildFilterChip(category, controller),
                          );
                        }
                      )
                      .toList(),
                );
              },
            ),
          ),

          SizedBox(height: 2.h),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
              }
              final items = controller.filteredItems;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    "no_items_found".tr,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12.sp),
                  ),
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return RedeemCard(
                    item: items[index],
                    translatedTitle: _dynamicTranslations[items[index].title],
                    translatedDescription: _dynamicTranslations[items[index].description],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, RedeemController controller) {
    return Obx(() {
      final bool isSelected = controller.selectedCategory.value == label;
      return GestureDetector(
        onTap: () => controller.filterByCategory(label),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFD4AF37) : const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: Colors.white10,
                  ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            _getTranslatedCategory(label),
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.white70,
            ),
          ),
        ),
      );
    });
  }
}

