import 'dart:math';

import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:brahmakosh/common/models/astrologist_model.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'voice_call_view.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import '../../../core/utils/app_snackbar.dart';

class AstrologistProfileView extends StatefulWidget {
  final AstrologistItem expert;

  const AstrologistProfileView({super.key, required this.expert});

  @override
  State<AstrologistProfileView> createState() => _AstrologistProfileViewState();
}

class _AstrologistProfileViewState extends State<AstrologistProfileView> {
  int _selectedTabIndex = 0;
  
  // Translated Data
  String? _translatedSummary;
  String? _translatedExperience;
  String? _translatedExpertise;
  List<String> _translatedLanguages = [];

  @override
  void initState() {
    super.initState();
    
    // Initialize with original values
    _translatedSummary = widget.expert.profileSummary;
    _translatedExperience = widget.expert.experience;
    _translatedExpertise = widget.expert.expertise;
    _translatedLanguages = widget.expert.languages ?? [];
    
    _translateExpertData();
  }

  Future<void> _translateExpertData() async {
    if (Get.locale?.languageCode != 'hi') return;

    if (_translatedSummary != null) {
      TranslateHelper.translate(_translatedSummary).then((val) {
        if (mounted) setState(() => _translatedSummary = val);
      });
    }

    if (_translatedExperience != null) {
      TranslateHelper.translate(_translatedExperience).then((val) {
        if (mounted) setState(() => _translatedExperience = val);
      });
    }

    if (_translatedExpertise != null) {
      TranslateHelper.translate(_translatedExpertise).then((val) {
        if (mounted) setState(() => _translatedExpertise = val);
      });
    }

    if (_translatedLanguages.isNotEmpty) {
      TranslateHelper.translateList(_translatedLanguages).then((val) {
        if (mounted) setState(() => _translatedLanguages = val);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();
    final expert = widget.expert;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.white, size: 8.w),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () => controller.openHistory(),
          ),
          const SizedBox(width: 8),
        ],
        excludeHeaderSemantics: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 1.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(expert),
                  SizedBox(height: 4.h),

                  // Custom Tab Bar
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Bottom baseline divider
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 2,
                          color: const Color(0xFFFFD700),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildProfileTab(
                                "about".tr,
                                _selectedTabIndex == 0,
                                () => setState(() => _selectedTabIndex = 0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildProfileTab(
                                "expertise".tr,
                                _selectedTabIndex == 1,
                                () => setState(() => _selectedTabIndex = 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildProfileTab(
                                "reviews".tr,
                                _selectedTabIndex == 2,
                                () => setState(() => _selectedTabIndex = 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),

                  // Content based on selected tab
                  if (_selectedTabIndex == 0) _buildAboutContent(expert),
                  if (_selectedTabIndex == 1) _buildExpertiseContent(expert),
                  if (_selectedTabIndex == 2) _buildReviewsSection(expert),
                  
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(context, controller, expert),
        ],
      ),
    );
  }

  Widget _buildAboutContent(AstrologistItem expert) {
    return Column(
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildProfileStatCard(
                "${_translatedExperience ?? "No experience"}",
                "experience".tr,
                icon: Icons.auto_awesome,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildProfileStatCard(
                "${expert.rating ?? 4.9}",
                "rating".tr,
                icon: Icons.star,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),

        // Bio Card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Text(
            _translatedSummary ??
                "${expert.name} ${'is_vedic_astrologer'.tr} ${_translatedExperience ?? '14+'} ${'years_experience'.tr}. ${'expert_in_kundli'.tr}.",
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              height: 1.6,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseContent(AstrologistItem expert) {
    final skills = _translatedExpertise?.split(',').map((e) => e.trim()).toList() ?? ["Vedic Astrology"];
    final languages = _translatedLanguages.isNotEmpty ? _translatedLanguages : ["Hindi", "English"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "core_expertise".tr,
          style: GoogleFonts.lora(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.5.h,
          children: skills.map((skill) => _buildExpertiseChip(skill)).toList(),
        ),
        SizedBox(height: 4.h),
        Text(
          "languages".tr,
          style: GoogleFonts.lora(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 3.w,
          runSpacing: 1.5.h,
          children: languages.map((lang) => _buildExpertiseChip(lang, isLanguage: true)).toList(),
        ),
      ],
    );
  }

  Widget _buildExpertiseChip(String label, {bool isLanguage = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLanguage ? Icons.language : Icons.auto_awesome,
            size: 3.5.w,
            color: const Color(0xFFFFD700),
          ),
          SizedBox(width: 2.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AstrologistItem expert) {
    return Center(
      child: Column(
        children: [
          // Large Avatar with Golden Ring
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFFFD700),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomProfileAvatar(
              imageUrl: expert.profilePhoto,
              radius: 19.w,
              borderColor: const Color(0xFFFFD700),
              borderWidth: 2,
            ),
          ),
          SizedBox(height: 2.5.h),
          // Name and Category
          Text(
            expert.name ?? "Acharya Dev",
            style: GoogleFonts.lora(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            _translatedExpertise?.split(',').firstOrNull ?? "Vedic Astrology",
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 2.5.h),
          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                Icons.check_circle,
                "verified_astrologer".tr,
                const Color(0xFF2E7D32).withValues(alpha: 0.2),
                const Color(0xFF2E7D32),
              ),
              SizedBox(width: 3.w),
              _buildBadge(
                null,
                "15k+ ${"consults".tr}",
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData? icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 3.5.w, color: textColor),
            SizedBox(width: 1.5.w),
          ],
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8.sp,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(AstrologistItem expert) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "user_reviews".tr,
              style: GoogleFonts.lora(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "see_all".tr,
                style: GoogleFonts.poppins(
                  color: const Color(0xFFFFD700),
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        _buildReviewCard("Rohan Sharma", "accurate_review".tr),
        SizedBox(height: 1.5.h),
        _buildReviewCard("Ananya Gupta", "clear_guidance_review".tr),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 11.sp,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) => Icon(Icons.star, color: const Color(0xFFFFD700), size: 3.w)),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            comment,
            style: GoogleFonts.poppins(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 9.sp,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(
    BuildContext context,
    AstrologyController controller,
    AstrologistItem expert,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        6.w,
        2.h,
        6.w,
        1.h + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBottomButton(
              Icons.chat_bubble_outline,
              "₹${expert.chatCharge?.toInt() ?? 15}${"per_min".tr}",
              () {
                final status = expert.status?.toLowerCase() ?? 'offline';
                if (status != 'online') {
                  _showExpertOfflineDialog(context);
                  return;
                }
                _showChatConfirmationBottomSheet(context, controller, expert);
              }
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: _buildBottomButton(
              Icons.phone_outlined,
              "₹${expert.voiceCharge?.toInt() ?? 20}${"per_min".tr}",
              () {
                final status = expert.status?.toLowerCase() ?? 'offline';
                if (status != 'online') {
                  _showExpertOfflineDialog(context);
                  return;
                }

                final hasInit =
                    StorageService.getBool('chat_initiated_${expert.id}') ??
                    false;
                if (!hasInit) {
                  _showInitiateChatFirstDialog(context);
                } else {
                  _showVoiceCallConfirmationBottomSheet(
                    context,
                    expert,
                    controller,
                  );
                }
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, String price, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 7.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 5.w),
            SizedBox(width: 2.w),
            Text(
              price,
              style: GoogleFonts.poppins(
                color: const Color(0xFFFFD700),
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTab(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(15),
        topRight: Radius.circular(15),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFD700) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : const Color(0xFFFFD700),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStatCard(String value, String label, {IconData? icon}) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: const Color(0xFFFFD700), size: 6.w),
          SizedBox(width: 3.w),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showChatConfirmationBottomSheet(
    BuildContext context,
    AstrologyController controller,
    AstrologistItem expert,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(6.w),
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.message,
                    color: const Color(0xFFFFD700),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "chat_consultation_title".tr,
                    style: GoogleFonts.lora(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            Text(
              "start_chat_desc".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 2.h),

            Text(
              "chat_instruction".tr,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),

            Text(
              "deduction_msg".trParams({'charge': (expert.chatCharge ?? 15).toString()}),
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD700),
              ),
            ),
            SizedBox(height: 1.h),

            Text(
              "continue_question".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 3.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 3.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "cancel_cap".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "continue_cap".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
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
        decoration: const BoxDecoration(
          color: Color(0xFF141414),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                  ),
                  child: Icon(
                    Icons.phone_in_talk,
                    color: const Color(0xFFFFD700),
                    size: 5.w,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    "voice_consultation_title".tr,
                    style: GoogleFonts.lora(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            Text(
              "voice_session_desc".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.4,
              ),
            ),
            SizedBox(height: 2.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 2.h),

            Text(
              "voice_disclaimer".tr,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),

            Text(
              "deduction_msg".trParams({'charge': (expert.voiceCharge ?? 20).toString()}),
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFFFD700),
              ),
            ),
            SizedBox(height: 1.h),

            Text(
              "continue_question".tr,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: 3.h),
            Divider(color: Colors.white.withValues(alpha: 0.1), thickness: 1),
            SizedBox(height: 3.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      side: const BorderSide(color: Color(0xFFFFD700)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "cancel_cap".tr,
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                            AppSnackBar.showError(
                              "insufficient_credits".tr,
                              "insufficient_credits_desc".trParams({'min': minRequired.toString()}),
                            );
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                          backgroundColor: const Color(0xFFFFD700),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "continue_cap".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
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
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Text(
          "expert_offline_title".tr,
          style: GoogleFonts.lora(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700)),
        ),
        content: Text(
          "expert_offline_msg".tr,
          style: GoogleFonts.poppins(
              fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7)),
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
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
        title: Text(
          "chat_required_title".tr,
          style: GoogleFonts.lora(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFFD700)),
        ),
        content: Text(
          "chat_required_msg".tr,
          style: GoogleFonts.poppins(
              fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.7)),
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
}