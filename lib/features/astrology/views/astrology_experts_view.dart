import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/models/astrologist_model.dart';

class AstrologyExpertsView extends StatelessWidget {
  final String? screenTitle;

  const AstrologyExpertsView({super.key, this.screenTitle});

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller =
        Get.isRegistered<AstrologyController>()
        ? Get.find<AstrologyController>()
        : Get.put(AstrologyController(), permanent: true);

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0), // Matches screenshot background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          "Connect",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        titleSpacing: 20,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.textPrimary),
            onPressed: () => controller.openHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildSearchBar(context, controller),
          ),
          const SizedBox(height: 10),

          // Categories / Filters
          Padding(
            padding: const EdgeInsets.only(bottom: 4),

            child: SizedBox(
              height: 35,
              child: Obx(() {
                // Ensure "All" is always first
                final allCategories = [
                  {'name': 'All', '_id': 'all'},
                  ...controller.categories,
                ];

                // Access selectedCategoryId here to register dependency with Obx
                final selectedId = controller.selectedCategoryId;

                return ListView.builder(
                  controller: controller.categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final id = cat['_id'];
                    final name = cat['name'];
                    final isSelected = selectedId == id;

                    return _buildFilterChip(
                      context,
                      name,
                      id,
                      isSelected,
                      controller,
                      index,
                    );
                  },
                );
              }),
            ),
          ),

          // Expert List
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryGold,
              onRefresh: controller.refreshExperts,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (context, index) => _buildExpertCardShimmer(),
                  );
                }

                final list = controller.filteredExperts;
                if (list.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No experts found',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.only(
                    left: 16,
                    top: 8,
                    right: 16, // Fixed indentation
                    bottom: 20 + MediaQuery.of(context).padding.bottom,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildExpertCard(context, list[index], controller);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, AstrologyController controller) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller.searchController,
        style: GoogleFonts.inter(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppTheme.textPrimary),
          filled: false, // Prevent double background
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String id,
    bool isSelected,
    AstrologyController controller,
    int index,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () {
          controller.selectCategory(id);
          // Scroll to position (simple implementation: scroll to index * approx width)
          // For exact "first position", we'd need keys or a specific package.
          // Here we try to center it or move it to start.
          double offset = index * 100.0; // Approx width + margin
          if (index > 0) offset -= 10; // Adjust for padding

          controller.categoryScrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryGold
                : Colors.transparent, // Dark gold for selected
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : const Color(0xFFA67C00).withOpacity(0.5),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF5D4037),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpertCard(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    final imageUrl =
        expert.profilePhoto ?? 'https://randomuser.me/api/portraits/men/1.jpg';
    // Use lowercase for comparison to be safe
    final status = expert.status?.toLowerCase() ?? 'offline';
    final isOnline = status == 'online';
    final isBusy = status == 'busy';

    // Status Color & Text
    Color statusColor = Colors.grey;
    String statusText = "Offline";

    if (isOnline) {
      statusColor = Colors.green;
      statusText = "Available";
    } else if (isBusy) {
      statusColor = Colors.orange;
      statusText = "Busy";
    }

    // Skills processing
    final skills = expert.expertise != null && expert.expertise!.isNotEmpty
        ? expert.expertise!
              .split(',')
              .map((e) => "• ${e.trim()}")
              .take(2)
              .join("   ")
        : "";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0), // Light cream card background
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.lightGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => controller.navigateToProfile(expert),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Avatar + Status
                Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      statusText,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Right Column: Details + Buttons
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name ?? 'Astrologer',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${expert.experience ?? '0'} Years Exp.",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        skills,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Action Buttons Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.chat_bubble_outline,
                              price: expert.chatCharge?.toString() ?? "20",
                              onTap: () => controller.startChat(expert),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.phone_outlined,
                              price: expert.voiceCharge?.toString() ?? "20",
                              onTap: () {}, // Add call logic
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildActionButton(
                              icon: Icons.videocam_outlined,
                              price: expert.videoCharge?.toString() ?? "20",
                              onTap: () {}, // Add video call logic
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String price,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFA67C00),
            width: 1,
          ), // Gold/Brown border
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromARGB(
            0,
            255,
            255,
            255,
          ), // Transparant or very light fill
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: const Color(0xFFA67C00)),
            const SizedBox(width: 4),
            Text(
              "₹$price/min",
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFA67C00),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
