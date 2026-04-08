import 'package:brahmakosh/core/common_imports.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import '../controllers/report_controller.dart';
import 'kundali_history_view.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:url_launcher/url_launcher.dart';


class KundaliReportView extends StatefulWidget {
  const KundaliReportView({super.key});

  @override
  State<KundaliReportView> createState() => _KundaliReportViewState();
}

class _KundaliReportViewState extends State<KundaliReportView> {
  late ConfettiController _confettiController;
  final ReportController controller = Get.put(ReportController());

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    
    // Listen for success to trigger confetti
    ever(controller.lastGeneratedReport, (report) {
      if (report != null) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildTypeTabs(controller),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Column(
                        children: [
                          SizedBox(height: 2.h),
                          _buildGenerateCard(controller),
                          SizedBox(height: 3.h),
                          _buildLastGeneratedSection(controller),
                          SizedBox(height: 3.h),
                          _buildHistoryHeader(controller),
                          SizedBox(height: 1.5.h),
                          _buildHistoryList(controller),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
                AppTheme.primaryGold,
              ],
              createParticlePath: drawStar,
            ),
          ),
        ],
      ),
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to draw a star
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(-90);

    path.moveTo(size.width, halfWidth + externalRadius * sin(fullAngle));

    for (double step = 0; step < degToRad(360); step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step + fullAngle),
          halfWidth + externalRadius * sin(step + fullAngle));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep + fullAngle),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep + fullAngle));
    }
    path.close();
    return path;
  }

  // ─── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 10.w,
              height: 10.w,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 1.8.h, color: Colors.white),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'kundali_report'.tr,
                  style: GoogleFonts.lora(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'kundli_desc'.tr,
                  style: GoogleFonts.poppins(
                    fontSize: 9.sp,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          // History button
          GestureDetector(
            onTap: () => Get.to(() => const KundaliHistoryView()),
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.primaryGold.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppTheme.primaryGold, size: 1.8.h),
                  SizedBox(width: 1.5.w),
                  Text(
                    'history_cap'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: AppTheme.primaryGold,
                      fontWeight: FontWeight.w600,
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

  // ─── Type Tabs ─────────────────────────────────────────────────────────────
  Widget _buildTypeTabs(ReportController controller) {
    final types = [
      {'label': 'mini'.tr, 'icon': Icons.article_outlined, 'pages': 'pages_count'.trParams({'count': '12'})},
      {'label': 'basic'.tr, 'icon': Icons.menu_book_rounded, 'pages': 'pages_count'.trParams({'count': '35'})},
      {'label': 'pro'.tr, 'icon': Icons.auto_stories_rounded, 'pages': 'pages_count'.trParams({'count': '60+'})},
    ];
    final gradients = [
      [const Color(0xFF8B6914), const Color(0xFFD4AF37)],
      [const Color(0xFF134E5E), const Color(0xFF71B280)],
      [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    ];

    return Obx(() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: List.generate(types.length, (index) {
              final isSelected = controller.selectedKundaliType.value == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.selectedKundaliType.value = index,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: EdgeInsets.only(
                        right: index < types.length - 1 ? 2.w : 0),
                    padding: EdgeInsets.symmetric(
                        vertical: 1.5.h, horizontal: 2.w),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: gradients[index],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isSelected
                          ? null
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : Colors.white.withValues(alpha: 0.1),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Color.lerp(gradients[index][0],
                                        gradients[index][1], 0.5)!
                                    .withValues(alpha: 0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(types[index]['icon'] as IconData,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.4),
                            size: 2.2.h),
                        SizedBox(height: 0.5.h),
                        Text(
                          types[index]['label'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          types[index]['pages'] as String,
                          style: GoogleFonts.poppins(
                            fontSize: 7.5.sp,
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.85)
                                : Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ));
  }

  // ─── Generate Card ─────────────────────────────────────────────────────────
  Widget _buildGenerateCard(ReportController controller) {
    return Obx(() {
      final typeIndex = controller.selectedKundaliType.value;
      final typeNames = ['mini'.tr, 'basic'.tr, 'pro'.tr];
      final descriptions = [
        'mini_desc'.tr,
        'basic_desc'.tr,
        'pro_desc'.tr,
      ];
      final gradients = [
        [const Color(0xFF8B6914), const Color(0xFFD4AF37)],
        [const Color(0xFF134E5E), const Color(0xFF71B280)],
        [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
      ];

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppTheme.primaryGold.withValues(alpha: 0.12), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradients[typeIndex],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.auto_stories_rounded,
                      color: Colors.white, size: 2.5.h),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'kundali_pdf_type_label'.trParams({'type': typeNames[typeIndex]}),
                      style: GoogleFonts.lora(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'birth_details_fetched'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 8.5.sp,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              descriptions[typeIndex],
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.6,
              ),
            ),
            SizedBox(height: 2.5.h),
            // Info row
            _infoRow(Icons.person_rounded, 'birth_details_auto'.tr),
            SizedBox(height: 1.h),
            _infoRow(Icons.cloud_upload_rounded, 'pdf_uploaded_cloud'.tr),
            SizedBox(height: 1.h),
            _infoRow(Icons.download_rounded, 'available_history_download'.tr),
            SizedBox(height: 3.h),
            // Generate button
            GestureDetector(
              onTap: controller.isGeneratingKundali.value
                  ? null
                  : () => controller.generateKundaliReport(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 1.8.h),
                decoration: BoxDecoration(
                  gradient: controller.isGeneratingKundali.value
                      ? null
                      : LinearGradient(
                          colors: gradients[typeIndex],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  color: controller.isGeneratingKundali.value
                      ? Colors.white.withValues(alpha: 0.05)
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: controller.isGeneratingKundali.value
                      ? []
                      : [
                          BoxShadow(
                            color: Color.lerp(gradients[typeIndex][0],
                                    gradients[typeIndex][1], 0.5)!
                                .withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: controller.isGeneratingKundali.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 2.h,
                            height: 2.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            'generating_report'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 2.2.h),
                          SizedBox(width: 2.w),
                          Text(
                            'generate_kundali_pdf'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryGold.withValues(alpha: 0.7), size: 1.8.h),
        SizedBox(width: 2.w),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 9.sp,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }

  // ─── Last Generated Section ────────────────────────────────────────────────
  Widget _buildLastGeneratedSection(ReportController controller) {
    return Obx(() {
      final report = controller.lastGeneratedReport.value;
      if (report == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0F2B1A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF2ECC71).withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.check_circle_rounded,
                      color: const Color(0xFF2ECC71), size: 2.2.h),
                ),
                SizedBox(width: 2.w),
                Text(
                  'report_generated'.tr,
                  style: GoogleFonts.lora(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.5.h),
            Text(
              'report_saved_desc'.tr,
              style: GoogleFonts.poppins(
                fontSize: 9.5.sp,
                color: Colors.white.withValues(alpha: 0.7),
                height: 1.5,
              ),
            ),
            if (report.s3Url != null && report.s3Url!.isNotEmpty) ...[
              SizedBox(height: 2.h),
              GestureDetector(
                onTap: () => _openUrl(report.s3Url!),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF2ECC71).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.open_in_new_rounded,
                          color: const Color(0xFF2ECC71), size: 2.h),
                      SizedBox(width: 2.w),
                      Text(
                        'view_download_pdf'.tr,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2ECC71),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  // ─── History Header ────────────────────────────────────────────────────────
  Widget _buildHistoryHeader(ReportController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'recent_reports'.tr,
          style: GoogleFonts.lora(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () => Get.to(() => const KundaliHistoryView()),
          child: Text(
            'view_all'.tr,
            style: GoogleFonts.poppins(
              fontSize: 9.5.sp,
              color: AppTheme.primaryGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ─── History List (inline preview) ────────────────────────────────────────
  Widget _buildHistoryList(ReportController controller) {
    return Obx(() {
      if (controller.isLoadingHistory.value && controller.kundaliHistory.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryGold),
            ),
          ),
        );
      }

      if (controller.kundaliHistory.isEmpty) {
        return _buildEmptyHistory();
      }

      // Show latest 3 items
      final preview = controller.kundaliHistory.take(3).toList();
      return Column(
        children: preview.map((item) => _buildHistoryCard(item, controller)).toList(),
      );
    });
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_rounded,
              color: Colors.white.withValues(alpha: 0.2), size: 5.h),
          SizedBox(height: 1.h),
          Text(
            'no_reports_yet'.tr,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
          Text(
            'generate_first_report'.tr,
            style: GoogleFonts.poppins(
              fontSize: 9.sp,
              color: Colors.white.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
      dynamic item, ReportController controller) {
    final typeColors = {
      'mini': const Color(0xFFD4AF37),
      'basic': const Color(0xFF71B280),
      'pro': const Color(0xFF8E2DE2),
    };
    final typeColor =
        typeColors[(item.reportType ?? '').toLowerCase()] ?? AppTheme.primaryGold;

    String formattedDate = '';
    if (item.createdAt != null) {
      try {
        final dt = DateTime.parse(item.createdAt!).toLocal();
        formattedDate =
            '${dt.day} ${_monthName(dt.month)} ${dt.year}, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      } catch (_) {}
    }

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.5.w),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: typeColor.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.picture_as_pdf_rounded,
                color: typeColor, size: 2.2.h),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.3.h),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.reportTypeLabel.toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.3.h),
                Text(
                  'kundali_pdf_type_label'.trParams({'type': item.reportTypeLabel}),
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                      fontSize: 8.5.sp,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ),
          // Download button
          Obx(() => GestureDetector(
                onTap: controller.isDownloading.value
                    ? null
                    : () async {
                        final url = await controller
                            .downloadKundaliReport(item.sId ?? '');
                        if (url != null && url.isNotEmpty) {
                          _openUrl(url);
                        } else {
                          Utils.showToast('unable_download_link'.tr);
                        }
                      },
                child: Container(
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.primaryGold.withValues(alpha: 0.25)),
                  ),
                  child: controller.isDownloading.value
                      ? SizedBox(
                          width: 1.8.h,
                          height: 1.8.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor:
                                AlwaysStoppedAnimation(AppTheme.primaryGold),
                          ),
                        )
                      : Icon(Icons.download_rounded,
                          color: AppTheme.primaryGold, size: 2.h),
                ),
              )),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  Future<void> _openUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.showToast('could_not_open_pdf'.tr);
      }
    } catch (e) {
      Utils.showToast('could_not_open_pdf'.tr);
    }
  }
}
