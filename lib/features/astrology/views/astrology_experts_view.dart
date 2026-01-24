import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../common/models/astrologist_model.dart';

class AstrologyExpertsView extends StatelessWidget {
  final String? screenTitle;           // ← NEW

  const AstrologyExpertsView({
    super.key,
    this.screenTitle,                  // ← optional, can be null
  });

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.isRegistered<AstrologyController>()
        ? Get.find<AstrologyController>()
        : Get.put(AstrologyController(), permanent: true);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AstrologyAppBar(
        customTitle: screenTitle ?? "Expert Connect",   // ← use dynamic title
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.lightGoldGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: _buildSearchBar(context, controller),
              ),

              Expanded(
                child: RefreshIndicator(
                  color: AppTheme.primaryGold,
                  onRefresh: controller.refreshExperts,
                  child: Obx(() {
                  if (controller.isLoading.value) {
                    return ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 12),
                        _buildAllExpertsHeaderShimmer(),
                        const SizedBox(height: 12),
                        ...List.generate(6, (i) => _buildExpertCardShimmer()),
                        const SizedBox(height: 100),
                      ],
                    );
                  }

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 12),

                      Obx(() {
                        final list = controller.filteredExperts;
                        if (list.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Center(
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
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: List.generate(
                            list.length,
                            (i) => _buildExpertCard(context, list[i], controller),
                          ),
                        );
                      }),

                      const SizedBox(height: 100),
                    ],
                  );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //-------------------------------- SEARCH BAR ------------------------------
  Widget _buildSearchBar(BuildContext context, AstrologyController controller) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: AppTheme.lightGold,
          width: 1.4,
        ),
      ),
      child: TextField(
        controller: controller.searchController,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
        decoration: InputDecoration(
          hintText: "Search by name, skill, or concern",
          hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primaryGold, size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.tune, color: AppTheme.primaryGold, size: 20),
            onPressed: () {},
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  //---------------------------- EXPERT CARD ----------------------------
Widget _buildExpertCard(
  BuildContext context,
  AstrologistItem expert,
  AstrologyController controller,
) {
  final imageUrl =
      expert.profilePhoto ?? 'https://randomuser.me/api/portraits/men/1.jpg';

  final skills = expert.expertise != null && expert.expertise!.isNotEmpty
      ? expert.expertise!.split(',').map((e) => e.trim()).toList()
      : <String>[];

  final languages = expert.languages ?? ['Hindi', 'English'];

  final isOnline = expert.status?.toLowerCase() == 'online' ||
      expert.status?.toLowerCase() == 'available';

  final experienceYears =
      expert.experience != null && expert.experience!.isNotEmpty
          ? (int.tryParse(
                  expert.experience!.replaceAll(RegExp(r'[^0-9]'), '')) ??
              0)
          : 0;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: InkWell(
      onTap: () => controller.navigateToProfile(expert),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.cardBackground,
          border: Border.all(color: AppTheme.lightGold, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightGold.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// LEFT – Avatar + Status
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.successGreen
                                : AppTheme.textSecondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppTheme.cardBackground, width: 1),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOnline
                                  ? AppTheme.successGreen
                                  : AppTheme.textSecondary,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            isOnline ? "Available" : "Offline",
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                /// MIDDLE – Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// NAME (FIXED)
                      Padding(
                        padding: const EdgeInsets.only(right: 80),
                        child: Text(
                          expert.name ?? 'Astrologer',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "$experienceYears Years exp.",
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 8),

                      /// SKILLS
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Skills:",
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: skills.take(3).map((skill) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: AppTheme.textLight, width: 0.9),
                                ),
                                child: Text(
                                  skill,
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      /// LANGUAGES
                      Padding(
  padding: const EdgeInsets.only(right: 80),
  child: Text(
    "Languages: ${languages.join(", ")}",
    style: GoogleFonts.inter(
      fontSize: 10,
      color: AppTheme.textSecondary,
      height: 1.25,
    ),
    maxLines: 2,
    softWrap: true,
    overflow: TextOverflow.ellipsis,
  ),
),

                    ],
                  ),
                ),
              ],
            ),

            /// TOP RIGHT – CALL / VIDEO
            Positioned(
              top: -8,
              right: -8,
              child: Row(
                children: [
                  _smallActionButton(Icons.phone_outlined, "15", () {}),
                  const SizedBox(width: 12),
                  _smallActionButton(Icons.video_call_outlined, "20", () {}),
                ],
              ),
            ),

            /// BOTTOM RIGHT – CHAT
            Positioned(
              bottom: -10,
              right: -8,
              child: _chatActionButton(
                "10",
                () => controller.startChat(expert),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// SMALL ACTION BUTTON
Widget _smallActionButton(
    IconData icon, String price, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.cardBackground,
            border:
                Border.all(color: AppTheme.primaryGold.withOpacity(0.6)),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryGold),
        ),
        Positioned(
          top: -8,
          right: -8,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "₹$price",
              style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}

/// CHAT ACTION BUTTON (FIXED)
Widget _chatActionButton(String price, VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: AppTheme.goldGradient,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_bubble_outline,
                  size: 12, color: Colors.black87),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  "Chat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: -9,
          right: -6,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "₹$price",
              style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}



  Widget _buildAllExpertsHeaderShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.lightGold.withOpacity(0.35),
      highlightColor: AppTheme.primaryGold.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 120,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertCardShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.lightGold.withOpacity(0.35),
      highlightColor: AppTheme.primaryGold.withOpacity(0.45),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          constraints: const BoxConstraints(minHeight: 140),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFF8208BF).withOpacity(0.3),
              width: 1.1,
            ),
            color: Colors.white.withOpacity(0.05),
          ),
          child: Row(
            children: [
              // Avatar Section Shimmer
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    width: 60,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              // Info Section Shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          width: 50,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      width: 100,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Buttons Section Shimmer
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    width: 60,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== REUSABLE WIDGETS ====================

/// Reusable AppBar with background image for Astrology screens
class AstrologyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? customTitle;   // ← NEW

  const AstrologyAppBar({
    super.key,
    this.customTitle,
  });

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.goldGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.25),
              blurRadius: 14,
              spreadRadius: 4,
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 24),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Text(
        customTitle ?? "Expert Connect",     // ← dynamic
        style: GoogleFonts.cinzel(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      centerTitle: false,
      actions: [
        // ... your wallet & history icons remain same
        Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.currency_rupee,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 6),
              Text(
                "2,500",
                style: GoogleFonts.cinzel(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history, color: AppTheme.textPrimary, size: 24),
          onPressed: () => controller.openHistory(),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Reusable Section Header Widget
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String iconPath;
  final LinearGradient? gradient;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    required this.iconPath,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
              gradient: gradient ?? AppTheme.goldGradient,
                  boxShadow: [
                    BoxShadow(
                  color: (gradient?.colors.first ?? AppTheme.primaryGold)
                      .withOpacity(0.35),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Image.asset(
                  iconPath,
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (onViewAll != null)
            GestureDetector(
              onTap: onViewAll,
              child: Text(
                'View All',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Reusable Action Chip Button
class ActionChipButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? iconColor;

  const ActionChipButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.borderColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor ?? AppTheme.primaryGold,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: iconColor ?? AppTheme.textPrimary,
            ),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: iconColor ?? AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}