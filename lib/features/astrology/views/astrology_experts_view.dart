import 'dart:developer' as developer;
import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:brahmakosh/common/models/astrologist_model.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'voice_call_view.dart'; // Added VoiceCallView import
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import '../../../../common/widgets/custom_profile_avatar.dart';

class AstrologyExpertsView extends StatelessWidget {
  final String? screenTitle;
  final ScrollController? scrollController;

  const AstrologyExpertsView({
    super.key,
    this.screenTitle,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller =
        Get.isRegistered<AstrologyController>()
        ? Get.find<AstrologyController>()
        : Get.put(AstrologyController(), permanent: true);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 8.w),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              try {
                // If we can't pop, we might be a tab in the Dashboard.
                // Navigate back to the Home tab (index 0).
                final dashboardVM =
                    Provider.of<DashboardViewModel>(context, listen: false);
                dashboardVM.changeTab(0);
              } catch (e) {
                // Fallback to standard GetX back behavior if DashboardViewModel is not available
                Navigator.of(context).maybePop();
              }
            }
          },
        ),
        title: Text(
          "connect".tr,
          style: GoogleFonts.lora(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => controller.openHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 0.5.h),
            child: _buildSearchBar(context, controller),
          ),
          SizedBox(height: 1.h),

          // Categories / Filters
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: Container(
              height: 5.5.h,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Obx(() {
                final allCategories = [
                  {'name': 'all'.tr, '_id': 'all'},
                  ...controller.categories,
                ];
                final selectedId = controller.selectedCategoryId;
                return ListView.builder(
                  controller: controller.categoryScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final id = cat['_id'];
                    final name = cat['name'];
                    final isSelected = selectedId == id;
                    return _buildFilterChip(
                      context,
                      controller.translatedData[name] ?? name,
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
                          size: 15.w,
                          color: AppTheme.textSecondary.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'no_experts_found'.tr,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.only(
                    left: 4.w,
                    top: 1.h,
                    right: 4.w,
                    bottom: 2.h + MediaQuery.of(context).padding.bottom,
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
      height: 6.h,
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller.searchController,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          hintText: "search".tr,
          hintStyle: GoogleFonts.poppins(color: Colors.white.withValues(alpha: 0.4)),
          prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.4)),
          filled: false,
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
    return InkWell(
      onTap: () {
        controller.selectCategory(id);
        
        // Centering logic: (index * approx_width) - (screen_width / 2) + (approx_width / 2)
        // Adjusting for the capsule container padding and horizontal scroll physics
        final screenWidth = MediaQuery.of(context).size.width;
        const itemWidth = 110.0; // Approx width of a chip
        double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
        
        // Clamp offset to scroll bounds
        if (offset < 0) offset = 0;
        final maxScroll = controller.categoryScrollController.position.maxScrollExtent;
        if (offset > maxScroll) offset = maxScroll;

        controller.categoryScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.symmetric(vertical: 0.5.h, horizontal: 1.w),
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.5),
            letterSpacing: 0.5,
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
    developer.log(
      '🔍 [Partner Details] id: ${expert.id}, name: ${expert.name}',
      name: 'AstrologyExpertsView',
    );

    final status = expert.status?.toLowerCase() ?? 'offline';
    final isOnline = status == 'online';
    final isBusy = status == 'busy';

    Color statusColor = Colors.grey;
    if (isOnline) {
      statusColor = Colors.green;
    } else if (isBusy) {
      statusColor = Colors.orange;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF18151B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => controller.navigateToProfile(expert),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with status
                    Stack(
                      children: [
                        Container(
                          width: 16.w,
                          height: 16.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1.5,
                            ),
                          ),
                          child: CustomProfileAvatar(
                            imageUrl: expert.profilePhoto,
                            radius: 8.w,
                            borderWidth: 0,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 3.5.w,
                            height: 3.5.w,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  controller.translatedData[expert.name] ?? expert.name ?? 'astrologer'.tr,
                                  style: GoogleFonts.lora(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(Icons.star, color: const Color(0xFFFFD700), size: 4.w),
                                  SizedBox(width: 1.w),
                                  Text(
                                    "${expert.rating ?? 4.9}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.translatedData[expert.expertise] ?? expert.expertise?.split(',').take(2).join(", ") ?? "vedic_astrology".tr,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.white.withValues(alpha: 0.5),
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Icon(Icons.work_outline, color: const Color(0xFFFFD700), size: 3.5.w),
                              SizedBox(width: 2.w),
                              Text(
                                "${expert.experience ?? '0'}+ ${"years_exp".tr}",
                                style: GoogleFonts.poppins(
                                  fontSize: 9.sp,
                                  color: const Color(0xFFFFD700),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_outlined,
                        price: "₹${expert.chatCharge?.toInt() ?? ""}${"per_min".tr}",
                        onTap: () {
                          if (status != 'online') {
                            _showExpertOfflineDialog(context);
                            return;
                          }
                          _showChatConfirmationBottomSheet(context, expert, controller);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.phone_outlined,
                        price: "₹${expert.voiceCharge?.toInt() ?? 0}${"per_min".tr}",
                        onTap: () {
                          if (status != 'online') {
                            _showExpertOfflineDialog(context);
                            return;
                          }
                          final hasInit = StorageService.getBool('chat_initiated_${expert.id}') ?? false;
                          if (!hasInit) {
                            _showInitiateChatFirstDialog(context);
                          } else {
                            _showVoiceCallConfirmationBottomSheet(context, expert, controller);
                          }
                        },
                      ),
                    ),
                  ],
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
        padding: EdgeInsets.symmetric(vertical: 0.8.h, horizontal: 2.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(24),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 3.5.w, color: const Color(0xFFFFD700)),
            SizedBox(width: 1.5.w),
            Flexible(
              child: Text(
                price,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFD700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showChatConfirmationBottomSheet(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: const Color(0xFF18151B), // Premium Dark
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.message_rounded,
                    color: const Color(0xFFFFD700),
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "start_chat_consultation".tr,
                    style: GoogleFonts.lora(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            Text(
              "chat_session_desc".tr,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 2.h),

            Text(
              "chat_disclaimer".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "cancel_cap".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
                      }

                      return ElevatedButton(
                        onPressed: () {
                          final credits = profileVM.profile?.credits ?? 0;
                          Navigator.pop(context);

                          if (credits >= 100) {
                            StorageService.setBool('chat_initiated_${expert.id}', true);
                            controller.startChat(expert);
                          } else {
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "continue_cap".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 2.h),
          ],
        ),
      ),
    );
  }

  void _showVoiceCallConfirmationBottomSheet(
    BuildContext context,
    AstrologistItem expert,
    AstrologyController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: const Color(0xFF18151B), // Premium Dark
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.phone_in_talk_rounded,
                    color: const Color(0xFFFFD700),
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "voice_consultation".tr,
                    style: GoogleFonts.lora(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            Text(
              "voice_session_desc".tr,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 2.h),

            Text(
              "voice_disclaimer".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "session_cost".tr,
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    "₹${expert.voiceCharge?.toInt() ?? 20} ${"per_min".tr}",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFFFD700),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "cancel_cap".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
                      }
                      return ElevatedButton(
                        onPressed: () {
                          final credits = profileVM.profile?.credits ?? 0;
                          final minRequired = (expert.voiceCharge ?? 20) * 5;

                          Navigator.pop(context);

                          if (credits >= minRequired) {
                            Get.to(() => VoiceCallView(expert: expert.toAstrologist()));
                          } else {
                            Get.snackbar(
                              "insufficient_credits".tr,
                              "insufficient_credits_desc".trParams({'min': minRequired.toString()}),
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "continue_cap".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 2.h),
          ],
        ),
      ),
    );
  }

  void _showExpertOfflineDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF18151B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
        title: Text(
          "expert_offline_title".tr,
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            fontSize: 14.sp,
          ),
        ),
        content: Text(
          "expert_offline_msg".tr,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "ok".tr.toUpperCase(),
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInitiateChatFirstDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF18151B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
        title: Text(
          "chat_required_title".tr,
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
            fontSize: 14.sp,
          ),
        ),
        content: Text(
          "chat_required_msg".tr,
          style: GoogleFonts.poppins(
            color: Colors.white70,
            fontSize: 11.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "ok".tr.toUpperCase(),
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildExpertCardShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF262626),
      highlightColor: const Color(0xFF333333),
      child: Container(
        margin: EdgeInsets.only(bottom: 2.h),
        height: 18.h,
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}

