import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/features/report/controllers/report_controller.dart';
import 'package:brahmakosh/features/report/models/kundali_history_model.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:url_launcher/url_launcher.dart';

class KundaliHistoryView extends StatelessWidget {
  const KundaliHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReportController>();
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            _header(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoadingHistory.value &&
                    controller.kundaliHistory.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(AppTheme.primaryGold)),
                  );
                }
                if (controller.kundaliHistory.isEmpty) {
                  return _empty();
                }
                return RefreshIndicator(
                  onRefresh: () => controller.fetchKundaliHistory(refresh: true),
                  color: AppTheme.primaryGold,
                  backgroundColor: const Color(0xFF1A1A1C),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    itemCount: controller.kundaliHistory.length +
                        (controller.hasMoreHistory.value ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == controller.kundaliHistory.length) {
                        return _loadMore(controller);
                      }
                      return _card(controller.kundaliHistory[i], controller);
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(ReportController ctrl) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
      ),
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
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 1.8.h, color: Colors.white),
            ),
          ),
          SizedBox(width: 3.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('kundali_history'.tr,
                  style: GoogleFonts.lora(
                      fontSize: 19.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              Obx(() => Text('reports_count'.trParams({'count': ctrl.kundaliHistory.length.toString()}),
                  style: GoogleFonts.poppins(
                      fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.4)))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _card(KundaliHistoryItem item, ReportController ctrl) {
    final clrs = {
      'mini': const Color(0xFFD4AF37),
      'basic': const Color(0xFF71B280),
      'pro': const Color(0xFFA855F7),
    };
    final grads = {
      'mini': [const Color(0xFF8B6914), const Color(0xFFD4AF37)],
      'basic': [const Color(0xFF134E5E), const Color(0xFF71B280)],
      'pro': [const Color(0xFF8E2DE2), const Color(0xFF4A00E0)],
    };
    final k = (item.reportType ?? '').toLowerCase();
    final c = clrs[k] ?? AppTheme.primaryGold;
    final g = grads[k] ?? [AppTheme.primaryGold, AppTheme.primaryGold];
    String date = '';
    if (item.createdAt != null) {
      try {
        final d = DateTime.parse(item.createdAt!).toLocal();
        date = '${d.day} ${_mon(d.month)} ${d.year}';
      } catch (_) {}
    }
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: 0.15)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(top: 0, left: 0, right: 0, height: 3,
              child: Container(decoration: BoxDecoration(
                gradient: LinearGradient(colors: g, begin: Alignment.centerLeft, end: Alignment.centerRight)))),
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 0.8.h),
                  Row(children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.4.h),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: g), borderRadius: BorderRadius.circular(8)),
                      child: Text(item.reportTypeLabel.toUpperCase(),
                          style: GoogleFonts.poppins(
                              fontSize: 7.5.sp, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: 0.8)),
                    ),
                    const Spacer(),
                    Text(date, style: GoogleFonts.poppins(fontSize: 8.5.sp, color: Colors.white.withValues(alpha: 0.4))),
                  ]),
                  SizedBox(height: 1.5.h),
                  Row(children: [
                    Container(
                      padding: EdgeInsets.all(2.5.w),
                      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(Icons.picture_as_pdf_rounded, color: c, size: 2.5.h),
                    ),
                    SizedBox(width: 3.w),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('kundali_pdf_type_label'.trParams({'type': item.reportTypeLabel}),
                          style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text(item.language ?? 'English',
                          style: GoogleFonts.poppins(fontSize: 9.sp, color: Colors.white.withValues(alpha: 0.4))),
                    ]),
                  ]),
                  SizedBox(height: 2.h),
                  Row(children: [
                    Expanded(
                      child: Obx(() => GestureDetector(
                        onTap: ctrl.isDownloading.value ? null : () async {
                          final url = await ctrl.downloadKundaliReport(item.sId ?? '');
                          if (url != null && url.isNotEmpty) {
                            _open(url);
                          } else {
                            Utils.showToast('unable_download_link'.tr);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          decoration: BoxDecoration(
                            gradient: ctrl.isDownloading.value ? null
                                : LinearGradient(colors: g, begin: Alignment.centerLeft, end: Alignment.centerRight),
                            color: ctrl.isDownloading.value ? Colors.white.withValues(alpha: 0.06) : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ctrl.isDownloading.value
                              ? Center(child: SizedBox(width: 1.8.h, height: 1.8.h,
                                  child: const CircularProgressIndicator(strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(Colors.white))))
                              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.download_rounded, color: Colors.white, size: 2.h),
                                  SizedBox(width: 2.w),
                                  Text('download_pdf'.tr, style: GoogleFonts.poppins(
                                      fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                                ]),
                        ),
                      )),
                    ),
                    if (item.sId != null && item.sId!.isNotEmpty) ...[
                      SizedBox(width: 2.w),
                      Obx(() => GestureDetector(
                        onTap: ctrl.isDownloading.value ? null : () async {
                          final url = await ctrl.downloadKundaliReport(item.sId ?? '');
                          if (url != null && url.isNotEmpty) {
                            _open(url);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(2.5.w),
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
                          child: ctrl.isDownloading.value
                              ? SizedBox(width: 2.h, height: 2.h, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.4))))
                              : Icon(Icons.open_in_new_rounded,
                                  color: Colors.white.withValues(alpha: 0.6), size: 2.h),
                        ),
                      )),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadMore(ReportController ctrl) => Obx(() => Padding(
    padding: EdgeInsets.symmetric(vertical: 2.h),
    child: GestureDetector(
      onTap: ctrl.isLoadingHistory.value ? null : () => ctrl.loadMoreHistory(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Center(child: ctrl.isLoadingHistory.value
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.primaryGold), strokeWidth: 2)
            : Text('load_more'.tr, style: GoogleFonts.poppins(
                fontSize: 10.sp, color: AppTheme.primaryGold, fontWeight: FontWeight.w600))),
      ),
    ),
  ));

  Widget _empty() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.history_toggle_off_rounded, color: Colors.white.withValues(alpha: 0.12), size: 8.h),
    SizedBox(height: 2.h),
    Text('no_reports_yet'.tr, style: GoogleFonts.lora(fontSize: 16.sp,
        fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.4))),
    SizedBox(height: 1.h),
    Text('generate_first_report'.tr,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.white.withValues(alpha: 0.3), height: 1.6)),
    SizedBox(height: 3.h),
    GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
        decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF8B6914), Color(0xFFD4AF37)]),
            borderRadius: BorderRadius.circular(14)),
        child: Text('generate_report'.tr, style: GoogleFonts.poppins(
            fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.black)),
      ),
    ),
  ]));

  String _mon(int m) => ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m];

  Future<void> _open(String url) async {
    try {
      final formattedUrl = ApiUrls.getFormattedImageUrl(url) ?? url;
      final uri = Uri.parse(formattedUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Utils.showToast('could_not_open_pdf'.tr);
      }
    } catch (_) {
      Utils.showToast('could_not_open_pdf'.tr);
    }
  }
}
