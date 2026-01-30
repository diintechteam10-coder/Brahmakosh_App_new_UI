import 'package:brahmakosh/features/astrology/controllers/astrology_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/astrologist_model.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'expert_app_bar.dart';

class AstrologistProfileView extends StatelessWidget {
  final AstrologistItem expert;

  const AstrologistProfileView({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Details",
          style: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.textPrimary),
            onPressed: () => controller.openHistory(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(color: Color(0xFFFBE6D0)),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 16),
              _buildExpertProfileCard(
                context,
                controller,
              ), // Pass context and controller
              // Removed _buildConsultationOptions(controller),
              const SizedBox(height: 16),
              _buildClientReviews(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ── EXPERT PROFILE CARD ────────────────────────────────────────────────
  Widget _buildExpertProfileCard(
    BuildContext context,
    AstrologyController controller,
  ) {
    // Helper methods to get parsed values
    List<String> getSkills() {
      if (expert.expertise != null && expert.expertise!.isNotEmpty) {
        return expert.expertise!.split(',').map((e) => e.trim()).toList();
      }
      return ['Vedic']; // Default skill
    }

    int getExperienceYears() {
      if (expert.experience != null && expert.experience!.isNotEmpty) {
        try {
          return int.parse(
            expert.experience!.replaceAll(RegExp(r'[^0-9]'), ''),
          );
        } catch (e) {
          return 0;
        }
      }
      return 0;
    }

    bool getIsOnline() {
      final status = expert.status?.toLowerCase() ?? '';
      return status == 'online' || status == 'available';
    }

    final skills = getSkills();
    final experienceYears = getExperienceYears();
    final isOnline = getIsOnline();
    final languages = expert.languages ?? ['Hindi', 'English'];
    final imageUrl =
        expert.profilePhoto ?? 'https://randomuser.me/api/portraits/men/1.jpg';
    final bio = expert.profileSummary ?? 'Experienced astrologer';
    final totalConsultations = expert.reviews ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.cardBackground,
        border: Border.all(color: AppTheme.lightGold, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightGold.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar left side + small availability
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                  const SizedBox(height: 6),
                  const SizedBox(height: 12),
                  Text(
                    "SKILLS:",
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 130,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: skills.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.lightGold,
                              width: 1.1,
                            ),
                          ),
                          child: Text(
                            skill,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.lora(
                              fontSize: 10,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Right side - all text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert.name ?? 'Astrologer',
                      style: GoogleFonts.cinzel(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    if (skills.isNotEmpty)
                      Text(
                        skills.first,
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline
                                ? AppTheme.successGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isOnline ? "Available" : "Offline",
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOnline
                                ? AppTheme.successGreen
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LANGUAGES:",
                style: GoogleFonts.cinzel(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  languages.join(", "),
                  style: GoogleFonts.lora(
                    fontSize: 10,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text("Description:", style: _sectionTitleStyle),
          const SizedBox(height: 4),
          Text(
            bio,
            style: GoogleFonts.lora(
              fontSize: 12,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.school_outlined,
                  "Experience",
                  "${experienceYears} Years",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  Icons.people_outline,
                  "Clients",
                  totalConsultations > 1000
                      ? "${(totalConsultations / 1000).toStringAsFixed(1)}K+"
                      : "$totalConsultations+",
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  Icons.workspace_premium_outlined,
                  "Awards",
                  "15+",
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _buildConsultationButtons(controller),
        ],
      ),
    );
  }

  // ── Consultation Buttons ───────────────────────────────────────────────
  Widget _buildConsultationButtons(AstrologyController controller) {
    final videoCharge = expert.videoCharge ?? 50;
    final voiceCharge = expert.voiceCharge ?? 30;
    final chatCharge = expert.chatCharge ?? 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Consultation Options",
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _buildConsultationRow(
          Icons.chat_bubble_outline,
          "Live Chat",
          "RS.$chatCharge/min",
          () => controller.startChat(expert),
        ),
        const SizedBox(height: 10),
        _buildConsultationRow(
          Icons.phone,
          "Audio Call",
          "RS.$voiceCharge/min",
          () {},
        ),
        const SizedBox(height: 10),
        _buildConsultationRow(
          Icons.videocam,
          "Video Call",
          "RS.$videoCharge/min",
          () {},
        ),
      ],
    );
  }

  Widget _buildConsultationRow(
    IconData icon,
    String title,
    String price,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.lightGold, width: 1.1),
          color: AppTheme.cardBackground,
          boxShadow: [
            BoxShadow(
              color: AppTheme.lightGold.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.lightGold,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.textPrimary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cinzel(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    price,
                    style: GoogleFonts.cinzel(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ── Reusable small widgets ─────────────────────────────────────────────
  static const TextStyle _sectionTitleStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppTheme.textPrimary,
    fontFamily: 'Inter',
  );

  Widget _buildStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lightGold, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.primaryGold, size: 32),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.cinzel(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.lora(fontSize: 9, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── CLIENT REVIEWS ─────────────────────────────────────────────────────
  Widget _buildClientReviews() {
    // AstrologistItem doesn't have reviews list, so we'll show empty state
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: AppTheme.textPrimary,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Clients Review",
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppTheme.cardBackground,
              border: Border.all(color: AppTheme.lightGold, width: 1.1),
            ),
            child: const Center(
              child: Text(
                "No reviews yet",
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(AstrologistReview review) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.lightGold, width: 1.1),
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightGold.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar (left side only)
              CircleAvatar(
                radius: 25,
                backgroundColor: AppTheme.cardBackground,
                backgroundImage: review.userImage != null
                    ? NetworkImage(review.userImage!)
                    : null,
                child: review.userImage == null
                    ? Text(
                        review.userName[0].toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name + Stars column (text starts from here)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + Stars in one line
                    Row(
                      children: [
                        Text(
                          review.userName,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              Icons.star,
                              size: 12,
                              color: i < review.rating.toInt()
                                  ? AppTheme.primaryGold
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Comment – starts directly below name + stars
                    Text(
                      review.comment,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // Time ago – directly below comment (same starting point as name)
                    Text(
                      _getTimeAgo(review.date),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0)
      return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
    if (difference.inHours > 0)
      return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
    if (difference.inMinutes > 0)
      return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
    return "Just now";
  }
}
