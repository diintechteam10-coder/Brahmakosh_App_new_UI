import '../../../../core/common_imports.dart';
import '../../../common/widgets/custom_popups.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Deepest Black
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Minimal High-End Header
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  width: 10.w,
                  height: 10.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 1.8.h, color: Colors.white),
                ),
              ),
              title: Text(
                'my_reports'.tr,
                style: GoogleFonts.lora(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              centerTitle: false,
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Master Bento Header (Summary)
                  const _MasterBentoSection(),
                  SizedBox(height: 3.h),

                  // Bento Grid - Row 1
                  Row(
                    children: [
                      _BentoCard(
                        flex: 3,
                        height: 18.h,
                        title: 'kundli_report',
                        desc: 'kundli_desc'.tr,
                        icon: Icons.auto_stories_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B6914), Color(0xFFD4AF37)],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      _BentoCard(
                        flex: 2,
                        height: 18.h,
                        title: 'career_report',
                        desc: 'career_desc'.tr,
                        icon: Icons.work_history_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFF2C3E50), Color(0xFF4CA1AF)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Bento Grid - Row 2
                  Row(
                    children: [
                      _BentoCard(
                        flex: 2,
                        height: 18.h,
                        title: 'health_report',
                        desc: 'health_desc'.tr,
                        icon: Icons.spa_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [Color(0xFF134E5E), Color(0xFF71B280)],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      _BentoCard(
                        flex: 3,
                        height: 18.h,
                        title: 'marriage_report',
                        desc: 'marriage_desc'.tr,
                        icon: Icons.favorite_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Bento Grid - Row 3
                  Row(
                    children: [
                      _BentoCard(
                        flex: 1,
                        height: 17.h,
                        title: 'compatibility_report',
                        desc: 'compatibility_desc'.tr,
                        icon: Icons.people_alt_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                        ),
                      ),
                      SizedBox(width: 4.w),
                      _BentoCard(
                        flex: 1,
                        height: 17.h,
                        title: 'financial_report',
                        desc: 'financial_desc'.tr,
                        icon: Icons.account_balance_wallet_rounded,
                        gradient: const LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [Color(0xFFF09819), Color(0xFFEDDE5D)],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final int flex;
  final double height;
  final String title;
  final String desc;
  final IconData icon;
  final Gradient gradient;

  const _BentoCard({
    required this.flex,
    required this.height,
    required this.title,
    required this.desc,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => Get.dialog(ComingSoonPopup(feature: title)),
        child: Container(
          height: height,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Decorative Background Icon
                Positioned(
                  top: -15,
                  right: -15,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Icon(
                      icon,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: Colors.white, size: 2.5.h),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              title.tr,
                              style: GoogleFonts.lora(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            desc,
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
}

class _MasterBentoSection extends StatelessWidget {
  const _MasterBentoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppTheme.primaryGold.withValues(alpha: 0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Decorative Glow Path
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryGold.withValues(alpha: 0.1),
                      AppTheme.primaryGold.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.primaryGold.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Icon(
                              Icons.auto_awesome_rounded,
                              color: AppTheme.primaryGold,
                              size: 2.2.h,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'kundali_summary'.tr,
                            style: GoogleFonts.lora(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryGold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Vedic Analysis',
                          style: GoogleFonts.poppins(
                            fontSize: 7.5.sp,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    'kundali_summary_desc'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 9.5.sp,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.7,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 2.5.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.dialog(const ComingSoonPopup(feature: 'Full Kundli Report')),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFB8941F)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.file_download_rounded, size: 2.h, color: Colors.black),
                                SizedBox(width: 2.w),
                                Text(
                                  'download_full_report'.tr,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10.sp,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Icon(Icons.share_rounded, size: 2.h, color: Colors.white),
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
    );
  }
}
