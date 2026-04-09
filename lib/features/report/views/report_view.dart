import '../../../../core/common_imports.dart';
import '../../../../common/utils.dart';
import '../controllers/report_controller.dart';
import 'kundali_report_view.dart';
import 'match_making_view.dart';
import 'kundali_history_view.dart';
import '../../numerology/views/numerology_history_view.dart';
import '../../swapna_decoder/views/swapna_decoder_screen.dart';

class ReportView extends StatelessWidget {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is ready before navigating into sub-screens
    Get.put(ReportController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header
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
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 1.8.h, color: Colors.white),
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
              actions: [
                GestureDetector(
                          onTap: () => Get.to(() => const KundaliHistoryView()),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 3.w, vertical: 0.8.h),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.primaryGold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: AppTheme.primaryGold
                                      .withValues(alpha: 0.3)),
                            ),
                            child: Row(children: [
                              Icon(Icons.history_rounded,
                                  color: AppTheme.primaryGold, size: 1.5.h),
                              SizedBox(width: 1.5.w),
                              Text('history_cap'.tr,
                                  style: GoogleFonts.poppins(
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryGold)),
                            ]),
                          ),
                        ),
                SizedBox(width: 3.w),
              ],
            ),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Kundali Master Card ──────────────────────────────────
                  _KundaliMasterCard(),
                  SizedBox(height: 3.h),

                  // Section label
                  Text(
                    'all_reports'.tr,
                    style: GoogleFonts.lora(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 1.5.h),

                  // ── Bento Grid - Row 1 ───────────────────────────────────
                  Row(children: [
                    _BentoCard(
                      flex: 3,
                      height: 18.h,
                      title: 'kundali_report'.tr,
                      desc: 'kundli_desc'.tr,
                      icon: Icons.auto_stories_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF8B6914), Color(0xFFD4AF37)],
                      ),
                      onTap: () => Get.to(() => const KundaliReportView()),
                      badge: 'PDF',
                    ),
                    SizedBox(width: 4.w),
                    _BentoCard(
                      flex: 2,
                      height: 18.h,
                      title: 'compatibility_report'.tr,
                      desc: 'compatibility_desc'.tr,
                      icon: Icons.favorite_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF8E2DE2), Color(0xFFDD2476)],
                      ),
                      onTap: () => Get.to(() => const MatchMakingView()),
                      badge: 'NEW',
                    ),
                  ]),
                  SizedBox(height: 2.h),

                  // ── Bento Grid - Row 2 (New) ──────────────────────────────
                  Row(children: [
                    _BentoCard(
                      flex: 2,
                      height: 18.h,
                      title: 'Numerology'.tr,
                      desc: 'numerology_desc'.tr,
                      icon: Icons.onetwothree_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
                      ),
                      onTap: () => Get.to(() => const NumerologyHistoryView()),
                      badge: 'FREE',
                    ),
                    SizedBox(width: 4.w),
                    
                  ]),
                  SizedBox(height: 2.h),

                  // ── Bento Grid - Row 3 (Coming Soon) ──────────────────────
                  Row(children: [
                    _BentoCard(
                      flex: 2,
                      height: 18.h,
                      title: 'career_report'.tr,
                      desc: 'career_desc'.tr,
                      icon: Icons.work_history_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF232526), Color(0xFF414345)],
                      ),
                      onTap: null,
                      badge: 'Soon',
                    ),
                    SizedBox(width: 4.w),
                    _BentoCard(
                      flex: 3,
                      height: 18.h,
                      title: 'health_report'.tr,
                      desc: 'health_desc'.tr,
                      icon: Icons.spa_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Color(0xFF1D2671), Color(0xFFC33764)],
                      ),
                      onTap: null,
                      badge: 'Soon',
                    ),
                  ]),
                  SizedBox(height: 2.h),

                  // ── Bento Grid - Row 4 (Coming Soon) ──────────────────────
                  Row(children: [
                    _BentoCard(
                      flex: 1,
                      height: 17.h,
                      title: 'financial_report'.tr,
                      desc: 'financial_desc'.tr,
                      icon: Icons.account_balance_wallet_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [Color(0xFF614385), Color(0xFF516395)],
                      ),
                      onTap: null,
                      badge: 'Soon',
                    ),
                    SizedBox(width: 4.w),
                    _BentoCard(
                      flex: 1,
                      height: 17.h,
                      title: 'marriage_report'.tr,
                      desc: 'marriage_desc'.tr,
                      icon: Icons.people_alt_rounded,
                      gradient: const LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Color(0xFF000046), Color(0xFF1CB5E0)],
                      ),
                      onTap: null,
                      badge: 'Soon',
                    ),
                  ]),
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

// ── Kundali Master Card ──────────────────────────────────────────────────────
class _KundaliMasterCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => const KundaliReportView()),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.primaryGold.withValues(alpha: 0.18),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withValues(alpha: 0.07),
              blurRadius: 24,
              spreadRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Ambient glow
              Positioned(
                right: -30, top: -30,
                child: Container(
                  width: 160, height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      AppTheme.primaryGold.withValues(alpha: 0.1),
                      AppTheme.primaryGold.withValues(alpha: 0),
                    ]),
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
                        Row(children: [
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.primaryGold.withValues(alpha: 0.25)),
                            ),
                            child: Icon(Icons.auto_awesome_rounded,
                                color: AppTheme.primaryGold, size: 2.2.h),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'kundali_pdf_reports'.tr,
                            style: GoogleFonts.lora(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                                letterSpacing: 0.3),
                          ),
                        ]),
                       
                      ],
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      'kundali_master_desc'.tr,
                      style: GoogleFonts.poppins(
                          fontSize: 9.5.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.7,
                          letterSpacing: 0.2),
                    ),
                    SizedBox(height: 2.5.h),
                    // Report type chips
                    Row(children: [
                      _typeChip('mini'.tr, const Color(0xFFD4AF37)),
                      SizedBox(width: 2.w),
                      _typeChip('basic'.tr, const Color(0xFF71B280)),
                      SizedBox(width: 2.w),
                      _typeChip('pro'.tr, const Color(0xFFA855F7)),
                    ]),
                    SizedBox(height: 2.5.h),
                    // CTA
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFB8941F)]),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withValues(alpha: 0.35),
                            blurRadius: 12, offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.auto_awesome_rounded, size: 2.h, color: Colors.black),
                        SizedBox(width: 2.w),
                        Text('generate_kundali_pdf'.tr,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5.sp,
                                color: Colors.black)),
                      ]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(width: 1.5.w, height: 1.5.w,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
        SizedBox(width: 1.5.w),
        Text(label, style: GoogleFonts.poppins(
            fontSize: 8.5.sp, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ── Bento Card ───────────────────────────────────────────────────────────────
class _BentoCard extends StatelessWidget {
  final int flex;
  final double height;
  final String title;
  final String desc;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;
  final String? badge;

  const _BentoCard({
    required this.flex,
    required this.height,
    required this.title,
    required this.desc,
    required this.icon,
    required this.gradient,
    this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: onTap ?? () => Utils.showToast('coming_soon'.tr),
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
            child: Stack(children: [
              // Decorative icon
              Positioned(
                top: -15, right: -15,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(icon, size: 80,
                      color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              // Badge
              if (badge != null)
                Positioned(
                  top: 10, right: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(badge!,
                        style: GoogleFonts.poppins(
                            fontSize: 7.sp, fontWeight: FontWeight.w700,
                            color: Colors.white)),
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
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(title,
                            style: GoogleFonts.lora(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            maxLines: 1),
                      ),
                      SizedBox(height: 0.4.h),
                      Text(desc,
                          style: GoogleFonts.poppins(
                              fontSize: 8.5.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                              height: 1.3),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ]),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
