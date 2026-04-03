import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../../core/common_imports.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/common/widgets/translated_text.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmupTranslations();
    });
  }

  void _warmupTranslations() {
    final List<String> stringsToWarmup = [
      "Rewards",
      "MEMBERSHIP - SILVER",
      "Silver",
      "Gold",
      "Platinum",
      "Rewards Overview",
      "Karma",
      "+40 earned today",
      "more to reach",
      "DAILY ACTIVITIES",
      "Spiritual Check -In",
      "Daily Check-in +40karma day",
      "Share App",
      "Invite Friend >",
      "GOALS & LEARNING",
      "Sankalp Rewards",
      "Set Goals Earn Up to 500 Karma",
      "Course Completion",
      "1,500 Karma / +800 bonus",
      "View Courses >",
      "CONTINUE",
      "PURCHASE",
      "membership",
      "You are already a silver member.",
      "You are already a gold member.",
      "You are already a platinum member.",
    ];
    TranslateHelper.warmup(stringsToWarmup);
  }

  @override
  Widget build(BuildContext context) {
    final profileVM = context.watch<ProfileViewModel>();
    final currentKarma = profileVM.profile?.karmaPoints ?? 0;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final isLargeTablet = screenWidth > 900;
    final horizontalPadding = isLargeTablet ? 6.w : (isTablet ? 4.w : 4.w);
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: Colors.black,
      padding: EdgeInsets.only(top: topPadding),
      child: CustomScrollView(
        slivers: [
          _buildAppBar(context, horizontalPadding),
          _buildMembershipSection(context, horizontalPadding, isTablet, currentKarma),
          _buildRewardsOverview(context, horizontalPadding, isTablet),
          _buildNextTierBanner(horizontalPadding, currentKarma),
          _buildDailyActivities(context, horizontalPadding, isTablet),
          _buildGoalsAndLearning(context, horizontalPadding, isTablet),
          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, double horizontalPadding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 1.h,
        ),
        child: TranslatedText(
          "Rewards",
          style: GoogleFonts.lora(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildMembershipSection(
    BuildContext context,
    double horizontalPadding,
    bool isTablet,
    int currentKarma,
  ) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 2.h,
        ),
        height: isTablet ? 30.h : 18.5.h,
        child: Stack(
          children: [
            // Background Image
            ClipRRect(
              borderRadius: BorderRadius.circular(20),

              child: Image.asset(
                'assets/rewards/topCover.jpg.jpeg',
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // // Frame Overlay
            // Positioned.fill(
            //   child: SvgPicture.asset(
            //     'assets/rewards/second frame.svg',
            //     fit: BoxFit.fill,
            //   ),
            // ),
            // // Content
            Column(
              children: [
                // const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TranslatedText(
                    "MEMBERSHIP - SILVER",
                    style: GoogleFonts.lora(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCrownItem(
                        context,
                        'assets/rewards/silver.svg',
                        "Silver",
                        currentKarma: currentKarma,
                        requiredKarma: 0,
                        isActive: true, // Assuming starting tier
                      ),
                      _buildCrownItem(
                        context,
                        'assets/rewards/gold.svg',
                        "Gold",
                        currentKarma: currentKarma,
                        requiredKarma: 5000,
                        isActive: currentKarma >= 5000,
                      ),
                      _buildCrownItem(
                        context,
                        'assets/rewards/platinum.svg',
                        "Platinum",
                        currentKarma: currentKarma,
                        requiredKarma: 10000,
                        isActive: currentKarma >= 10000,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrownItem(
    BuildContext context,
    String assetPath,
    String title, {
    required int currentKarma,
    required int requiredKarma,
    bool isActive = false,
  }) {
    final bool isSilver = title.toLowerCase() == "silver";
    return GestureDetector(
      onTap: isSilver ? null : () => _showRewardPopup(context, title, assetPath, currentKarma, requiredKarma),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(assetPath, height: isActive ? 7.h : 5.h),
          const SizedBox(height: 4),
          TranslatedText(
            title,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.6),
              fontSize: 10.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsOverview(
    BuildContext context,
    double horizontalPadding,
    bool isTablet,
  ) {
    return SliverToBoxAdapter(
      child: Consumer<ProfileViewModel>(
        builder: (context, profileVM, child) {
          final karma = profileVM.profile?.karmaPoints ?? 2450;
          return Container(
            margin: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 1.5.h,
            ),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TranslatedText(
                        "Rewards Overview",
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            karma.toString().replaceAllMapped(
                              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                              (Match m) => '${m[1]},',
                            ),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          TranslatedText(
                            "Karma",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Progress Bar
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFF262626),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (karma / 5000).clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37),
                                // gradient: const LinearGradient(
                                //   colors: [
                                //     Color(0xFFFDBB2D),
                                //     Color(0xFFE59400),
                                //   ],
                                // ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFFDBB2D,
                                    ).withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text("🔥", style: TextStyle(fontSize: 14.sp)),
                          const SizedBox(width: 8),
                          TranslatedText(
                            "+40 earned today",
                            style: GoogleFonts.crimsonPro(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: Offset(10, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFDBB2D).withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: SvgPicture.asset(
                      'assets/rewards/stars.svg',
                      height: 14.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNextTierBanner(double horizontalPadding, int currentKarma) {
    if (currentKarma >= 10000) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final isNextPlatinum = currentKarma >= 5000;
    final targetKarma = isNextPlatinum ? 10000 : 5000;
    final int diff = targetKarma - currentKarma;
    final nextTierName = isNextPlatinum ? "Platinum" : "Gold";
    final nextTierIcon = isNextPlatinum ? "platinum.svg" : "gold.svg";

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 1.h,
        ),
        height: 6.h,
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SvgPicture.asset(
                  'assets/rewards/second frame.svg',
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TranslatedText(
                      "+${diff.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} more to reach $nextTierName",
                      style: GoogleFonts.crimsonPro(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SvgPicture.asset('assets/rewards/$nextTierIcon', height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyActivities(BuildContext context, double horizontalPadding, bool isTablet) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: 2.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              "DAILY ACTIVITIES",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 18,
                  child: _buildActivityCard(
                    "Spiritual Check -In",
                    "Daily Check-in +40karma day",
                    icon: Icons.auto_awesome,
                    iconColor: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(flex: 10, child: _buildShareCard(context)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(
    String title,
    String subtitle, {
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 13.h,
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF262626),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD4AF37), size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TranslatedText(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TranslatedText(
            subtitle,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showComingSoonDialog(context),
      child: Container(
        height: 13.h,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SvgPicture.asset(
                  'assets/rewards/spiderframe.svg',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TranslatedText(
                        "Share App",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SvgPicture.asset('assets/rewards/Facebook.svg', width: 20),
                      const SizedBox(width: 4),
                      SvgPicture.asset('assets/rewards/WhatsApp.svg', width: 20),
                      const SizedBox(width: 4),
                      SvgPicture.asset('assets/rewards/Telegram.svg', width: 20),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: TranslatedText(
                        "Invite Friend >",
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsAndLearning(BuildContext context, double horizontalPadding, bool isTablet) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslatedText(
              "GOALS & LEARNING",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            _buildGoalListItem(
              "Sankalp Rewards",
              "Set Goals Earn Up to 500 Karma",
              'assets/icons/sankalptracker.png',
              onTap: () => Get.toNamed(AppConstants.routeSankalp),
              glowColor: const Color(0xFF9C27B0).withOpacity(0.3),
            ),
            const SizedBox(height: 14),
            _buildGoalListItem(
              "Course Completion",
              "1,500 Karma / +800 bonus",
              'assets/icons/courses.png',
              trailingText: "View Courses >",
              onTap: () => _showComingSoonDialog(context),
              glowColor: const Color(0xFFFFD700).withOpacity(0.25),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalListItem(
    String title,
    String subtitle,
    String iconPath, {
    String? trailingText,
    Color? glowColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                shape: BoxShape.circle,
                boxShadow: [
                  if (glowColor != null)
                    BoxShadow(color: glowColor, blurRadius: 20, spreadRadius: 8),
                ],
              ),
              child: Image.asset(iconPath, width: 30, height: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TranslatedText(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TranslatedText(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (trailingText != null)
                        TranslatedText(
                          trailingText,
                          style: GoogleFonts.lora(
                            color: const Color(0xFFD4AF37),
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (trailingText == null)
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withOpacity(0.2),
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  void _showRewardPopup(BuildContext context, String tier, String assetPath, int currentKarma, int requiredKarma) {
    final int diff = (requiredKarma - currentKarma).clamp(0, requiredKarma);
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown Icon
                SvgPicture.asset(assetPath, height: 8.h, fit: BoxFit.contain),
                const SizedBox(height: 16),
                // Tier Title with Glow
                TranslatedText(
                  "${tier.toUpperCase()} - MEMBERSHIP",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.white.withOpacity(0.5),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Description
                TranslatedText(
                  currentKarma >= requiredKarma
                      ? "You are already a ${tier.toLowerCase()} member."
                      : "You need ${diff.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Karma Points to become ${tier.toLowerCase()} member.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                // Continue Button
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.zero,
                  ),
                  child: TranslatedText(
                    "CONTINUE",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Close Button
                SizedBox(
                  width: 180,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: TranslatedText(
                      "CLOSE",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showComingSoonDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Color(0xFFD4AF37),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),
                TranslatedText(
                  "Coming Soon!",
                  style: GoogleFonts.lora(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TranslatedText(
                  "We are working hard to bring this feature to you. Stay tuned for updates!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: TranslatedText(
                    "GOT IT",
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
