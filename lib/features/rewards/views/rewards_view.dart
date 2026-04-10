import '../../../../core/common_imports.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import 'package:brahmakosh/common/widgets/custom_profile_avatar.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:intl/intl.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({super.key});

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> {
  final RedeemController redeemController = Get.put(RedeemController());

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
    final userName = profileVM.profile?.profile?.name ?? "Sushant Singh";
    final profileImage = profileVM.profile?.profileImageUrl;
    final tier = _getTierInfo(currentKarma);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final horizontalPadding = 5.w;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: topPadding + 2.h, bottom: 4.h),
          child: Column(
            children: [
              // Header
              Center(
                child: Text(
                  "BRAHMAKOSH",
                  style: GoogleFonts.lora(
                    color: AppTheme.primaryGold,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // Profile Section
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Ring (Decorative)
                    Container(
                      width: 35.w,
                      height: 35.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryGold.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                    ),
                    // Profile Image
                    CustomProfileAvatar(
                      imageUrl: profileImage,
                      radius: 15.w,
                      borderWidth: 3,
                      borderColor: Colors.white,
                    ),
                    // Silver Badge
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Image.asset(
                          tier['icon']!,
                          height: 25,
                          width: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                "Namaste $userName",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 1.h),

              // Status Chip
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Text(
                  "STATUS ${tier['label']}",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[400],
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 4.h),

              // Karma Card
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildKarmaCard(currentKarma, tier),
              ),
              SizedBox(height: 3.h),

              // Progress Section
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildProgressSection(currentKarma, tier),
              ),
              SizedBox(height: 3.h),

              // Check-in Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildCheckInButton(),
              ),
              SizedBox(height: 4.h),

              // Stats Section
              _buildStatsSection(horizontalPadding, currentKarma),
              SizedBox(height: 13.5.h),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, String> _getTierInfo(int karma) {
    if (karma < 1000) {
      return {
        'label': 'BEGINNER',
        'icon': 'assets/icons/begener.png',
        'nextTarget': '1000',
        'nextLabel': 'Silver',
      };
    } else if (karma < 5000) {
      return {
        'label': 'SILVER',
        'icon': 'assets/icons/Silver.png',
        'nextTarget': '5000',
        'nextLabel': 'Gold',
      };
    } else if (karma < 10000) {
      return {
        'label': 'GOLD',
        'icon': 'assets/icons/Gold.png',
        'nextTarget': '10000',
        'nextLabel': 'Platinum',
      };
    } else {
      return {
        'label': 'PLATINUM',
        'icon': 'assets/icons/platinum.png',
        'nextTarget': '10000',
        'nextLabel': 'Max Level',
      };
    }
  }

  Widget _buildKarmaCard(int currentKarma, Map<String, String> tier) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Mandala Icon
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Image.asset(
              'assets/icons/Group 2085665598.png',
              height: 70,
              width: 70,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.stars, color: AppTheme.primaryGold, size: 70),
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      NumberFormat("#,###").format(currentKarma),
                      style: GoogleFonts.lora(
                        color: Colors.white,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Karma",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  "Keep growing, Keep going",
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF8E8E93),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppConstants.routeCheckIn),
      child: Container(
        height: 7.h,
        decoration: BoxDecoration(
          color: AppTheme.primaryGold,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "CHECK-IN FOR  +100 KARMA \u2192",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(double horizontalPadding, int currentKarma) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "YOUR STATS",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(AppConstants.routeRedeem),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGold, width: 1),
                  ),
                  child: Text(
                    "REDEEM",
                    style: GoogleFonts.poppins(
                      color: AppTheme.primaryGold,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildStatItem(
                      "KARMA POINTS",
                      NumberFormat("#,###").format(currentKarma),
                      Icon(Icons.stars, color: AppTheme.primaryGold, size: 16),
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                  Expanded(
                    child: Obx(() {
                      final completedCount = redeemController.redemptionHistory
                          .where((item) => item.status.toLowerCase() == 'completed')
                          .length;
                      return _buildStatItem(
                        "Seva Done",
                        completedCount.toString(),
                        Icon(Icons.volunteer_activism, color: Colors.orange[300], size: 16),
                      );
                    }),
                  ),
                  VerticalDivider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      "Alignment",
                      "9.0",
                      Text(
                        "/10",
                        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                      ),
                      isTrailing: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Widget? decoration, {bool isTrailing = false}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            color: Colors.grey[600],
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                color: isTrailing ? const Color(0xFFFFD4AF) : Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (decoration != null) ...[
              SizedBox(width: 4),
              decoration,
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProgressSection(int currentKarma, Map<String, String> tier) {
    // Dummy values for targets
    int nextTierTarget = int.parse(tier['nextTarget']!);
    int progressPercent = (currentKarma / nextTierTarget * 100).clamp(0, 100).toInt();
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1A1A1A),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Image.asset(
                  tier['icon']!,
                  height: 30,
                  width: 30,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${tier['label']![0]}${tier['label']!.substring(1).toLowerCase()} Status",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (currentKarma < 10000)
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: Colors.grey,
                          fontSize: 10.sp,
                        ),
                        children: [
                          TextSpan(text: "Earn "),
                          TextSpan(
                            text: "${nextTierTarget - currentKarma} more Karma ",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "to attain "),
                          TextSpan(
                            text: "${tier['nextLabel']} ",
                            style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: "level."),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "GROWTH PROGESS",
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "$progressPercent%",
                  style: GoogleFonts.poppins(
                    color: Colors.green,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Custom Progress Bar
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progressPercent / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
