import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/views/redemption_history_view.dart';
import 'package:brahmakosh/features/redeem/widgets/redeem_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RedeemListView extends StatelessWidget {
  const RedeemListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final RedeemController controller = Get.put(RedeemController());

    return Scaffold(
      backgroundColor: AppTheme.landingBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Transform.translate(
          offset: const Offset(-10, 0),
          child: Text(
            "Redeem",
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5D4037),
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff8D6E63).withOpacity(0.3),
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/coin.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.circle, size: 16, color: Colors.amber),
                  ),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.userPoints.value} ",
                          style: GoogleFonts.inter(
                            color: const Color(0xff5D4037),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "Karma Points",
                          style: GoogleFonts.inter(
                            color: const Color(0xff5D4037),
                            fontSize: 10,
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
            icon: const Icon(Icons.history, color: Color(0xff5D4037)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Image (Mock)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                'assets/images/redeem_poster.png',
                width: double.infinity,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 160,
                  color: Colors.grey[300], // Placeholder color
                  child: const Center(
                    child: Icon(Icons.image, size: 40, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Obx(
              () => Row(
                children: controller.categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildFilterChip(category, controller),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.filteredItems;
              if (items.isEmpty) {
                return const Center(child: Text("No items found"));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return RedeemCard(item: items[index]);
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xffFF8C00) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(
                    color: Colors.transparent,
                  ), // Can add border if needed
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xffFF8C00).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : const Color(0xff5D4037).withOpacity(0.6),
            ),
          ),
        ),
      );
    });
  }
}
