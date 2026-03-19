import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/astrologist_model.dart';
import 'package:brahmakosh/features/profile/viewmodels/profile_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'voice_call_view.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';

class AstrologistProfileView extends StatefulWidget {
  final AstrologistItem expert;

  const AstrologistProfileView({super.key, required this.expert});

  @override
  State<AstrologistProfileView> createState() => _AstrologistProfileViewState();
}

class _AstrologistProfileViewState extends State<AstrologistProfileView> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();
    final expert = widget.expert;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeader(expert),
                  const SizedBox(height: 32),

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
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildProfileTab(
                                "ABOUT",
                                _selectedTabIndex == 0,
                                () => setState(() => _selectedTabIndex = 0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildProfileTab(
                                "EXPERTISE",
                                _selectedTabIndex == 1,
                                () => setState(() => _selectedTabIndex = 1),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildProfileTab(
                                "REVIEWS",
                                _selectedTabIndex == 2,
                                () => setState(() => _selectedTabIndex = 2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Content based on selected tab
                  if (_selectedTabIndex == 0) _buildAboutContent(expert),
                  if (_selectedTabIndex == 1) _buildExpertiseContent(expert),
                  if (_selectedTabIndex == 2) _buildReviewsSection(expert),
                  
                  const SizedBox(height: 100),
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
                "${expert.experience ?? 14}+ Years",
                "Expertise",
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProfileStatCard(
                "${expert.rating ?? 4.9}",
                "Rating",
                icon: Icons.star,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bio Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Text(
            expert.profileSummary ??
                "${expert.name} is a Vedic Astrologer with ${expert.experience ?? 14}+ years of experience. Expert in Kundli analysis, career & marriage guidance, and dosha remedies. Known for accurate, clear insights that support confident life decisions.",
            style: GoogleFonts.inter(
              fontSize: 14,
              height: 1.6,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpertiseContent(AstrologistItem expert) {
    final skills = expert.expertise?.split(',').map((e) => e.trim()).toList() ?? ["Vedic Astrology"];
    final languages = expert.languages ?? ["Hindi", "English"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Core Expertise",
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: skills.map((skill) => _buildExpertiseChip(skill)).toList(),
        ),
        const SizedBox(height: 32),
        Text(
          "Languages",
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: languages.map((lang) => _buildExpertiseChip(lang, isLanguage: true)).toList(),
        ),
      ],
    );
  }

  Widget _buildExpertiseChip(String label, {bool isLanguage = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLanguage ? Icons.language : Icons.auto_awesome,
            size: 14,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
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
            width: 150,
            height: 150,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFD4AF37),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: CustomProfileAvatar(
              imageUrl: expert.profilePhoto,
              radius: 75,
              borderColor: const Color(0xFFD4AF37),
              borderWidth: 2,
            ),
          ),
          const SizedBox(height: 20),
          // Name and Category
          Text(
            expert.name ?? "Acharya Dev",
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            expert.expertise?.split(',').firstOrNull ?? "Vedic Astrology",
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          // Badges Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge(
                Icons.check_circle,
                "Verified Astrologer",
                const Color(0xFF2E7D32).withOpacity(0.2),
                const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 12),
              _buildBadge(
                null,
                "15k+ Consults",
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData? icon, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
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
              "User Reviews",
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "See All",
                style: GoogleFonts.inter(
                  color: const Color(0xFFD4AF37),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildReviewCard("Rohan Sharma", "Very accurate and helpful insights. Highly recommended!"),
        const SizedBox(height: 12),
        _buildReviewCard("Ananya Gupta", "Great session, clear guidance on my career path."),
      ],
    );
  }

  Widget _buildReviewCard(String name, String comment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Row(
                children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFD4AF37), size: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
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
        24,
        24,
        24,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildBottomButton(
              Icons.chat_bubble_outline,
              "₹${expert.chatCharge?.toInt() ?? 15}/min",
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
          const SizedBox(width: 20),
          Expanded(
            child: _buildBottomButton(
              Icons.phone_outlined,
              "₹${expert.voiceCharge?.toInt() ?? 20}/min",
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
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 22),
            const SizedBox(width: 12),
            Text(
              price,
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontSize: 16,
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          border: isSelected
              ? null
              : Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.5),
                  width: 1,
                ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.black : const Color(0xFFD4AF37),
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
          Icon(icon, color: const Color(0xFFD4AF37), size: 24),
          const SizedBox(width: 12),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
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
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF141414), // Dark background
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Chat Icon Box
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.message,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Text(
                    "START CHAT CONSULTATION",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "You're about to start a live chat session with your chosen Expert.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 16),

            // Description
            Text(
              "Connect with an astrologer or guru through live chat and end the session at any time - credits are deducted only for the minutes used, so please ensure a stable internet connection for a smooth experience.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // // Price Warning
            // Text(
            //   "This session will deduct ₹${expert.chatCharge ?? 15} per minute",
            //   style: GoogleFonts.inter(
            //     fontSize: 15,
            //     fontWeight: FontWeight.w600,
            //     color: const Color(0xFFD4AF37),
            //   ),
            // ),
            // const SizedBox(height: 8),

            // Text(
            //   "Would you like to continue?",
            //   style: GoogleFonts.inter(
            //     fontSize: 14,
            //     color: Colors.white.withOpacity(0.5),
            //   ),
            // ),
            // const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFB8860B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFD4AF37),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CONTINUE",
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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
        padding: const EdgeInsets.all(24),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF262626),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.2)),
                  ),
                  child: const Icon(
                    Icons.phone_in_talk,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "VOICE CONSULTATION",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              "You're about to start a voice call session with your chosen Expert.",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 16),

            Text(
              "Connect with an astrologer or guru through a live audio call and end the session at any time - credits are deducted only for the minutes used, so please ensure a stable internet connection for a smooth experience.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withOpacity(0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              "This session will deduct ₹${expert.voiceCharge ?? 20} per minute",
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 8),

            Text(
              "Would you like to continue?",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 24),
            Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFB8860B)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Consumer<ProfileViewModel>(
                    builder: (context, profileVM, child) {
                      if (profileVM.isLoading) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
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
                              "Insufficient Credits",
                              "You need at least ₹$minRequired for a 5-minute session.",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                            controller.showRechargeBottomSheet(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFFD4AF37),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "CONTINUE",
                          style: GoogleFonts.inter(
                            fontSize: 14,
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  void _showExpertOfflineDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF141414),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.05))),
        title: Text(
          "Expert Offline",
          style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37)),
        ),
        content: Text(
          "This expert is currently offline. Please try again later.",
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "OK",
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.white.withOpacity(0.05))),
        title: Text(
          "Chat Required",
          style: GoogleFonts.lora(fontWeight: FontWeight.bold, color: const Color(0xFFD4AF37)),
        ),
        content: Text(
          "Please initiate a chat with the expert first before making a call.",
          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "OK",
              style: GoogleFonts.inter(
                color: const Color(0xFFD4AF37),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
