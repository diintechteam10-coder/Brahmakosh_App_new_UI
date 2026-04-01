import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/models/redemption_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class RedemptionHistoryView extends StatefulWidget {
  const RedemptionHistoryView({super.key});

  @override
  State<RedemptionHistoryView> createState() => _RedemptionHistoryViewState();
}

class _RedemptionHistoryViewState extends State<RedemptionHistoryView> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(List<RedemptionHistoryModel> items) async {
    final currentLang = Get.locale?.languageCode ?? 'en';
    if (currentLang == 'en') {
      if (_dynamicTranslations.isNotEmpty) {
        setState(() {
          _dynamicTranslations.clear();
          _lastLang = 'en';
        });
      }
      return;
    }

    final Set<String> toTranslate = {};

    for (var h in items) {
      final title = h.reward?.title;
      if (title != null && title.isNotEmpty) toTranslate.add(title);
    }

    if (toTranslate.isEmpty) return;

    final list = toTranslate.toList();
    final results = await TranslateHelper.translateList(list);

    bool changed = false;
    for (int i = 0; i < list.length; i++) {
      if (_dynamicTranslations[list[i]] != results[i]) {
        _dynamicTranslations[list[i]] = results[i];
        changed = true;
      }
    }

    if (changed || _lastLang != currentLang) {
      if (mounted) {
        setState(() {
          _lastLang = currentLang;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final RedeemController controller = Get.find<RedeemController>();

    // Initial fetch if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.redemptionHistory.isEmpty) {
        controller.fetchRedemptionHistory();
      }
    });

    if (controller.redemptionHistory.isNotEmpty) {
      _translateAllContents(controller.redemptionHistory);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          "history_cap".tr,
          style: GoogleFonts.lora(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isHistoryLoading.value && controller.redemptionHistory.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
        }

        if (controller.redemptionHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 50.sp, color: Colors.white10),
                SizedBox(height: 2.h),
                Text(
                  "no_history_found".tr,
                  style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12.sp),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFFD4AF37),
          onRefresh: () => controller.fetchRedemptionHistory(),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
            itemCount: controller.redemptionHistory.length,
            itemBuilder: (context, index) {
              final item = controller.redemptionHistory[index];
              return _buildHistoryCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildHistoryCard(RedemptionHistoryModel item) {
    // Determine status color
    Color statusColor;
    String status = item.status.toLowerCase();
    
    switch (status) {
      case 'completed':
      case 'success':
        statusColor = const Color(0xFF22C55E);
        break;
      case 'failed':
      case 'cancelled':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFFD4AF37);
    }

    String dateStr = '';
    try {
      DateTime dt = DateTime.parse(item.redeemedAt);
      dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      dateStr = item.redeemedAt;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dynamicTranslations[item.reward?.title] ?? (item.reward?.title ?? 'sacred_offering'.tr),
                      style: GoogleFonts.lora(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      dateStr,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          const Divider(color: Colors.white10),
          SizedBox(height: 1.5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "spent_karma".tr,
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.white70,
                ),
              ),
              Row(
                children: [
                   Icon(Icons.stars, color: const Color(0xFFD4AF37), size: 12.sp),
                  SizedBox(width: 1.w),
                  Text(
                    "${item.karmaPointsSpent}",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
