import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/views/redemption_history_view.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/widgets/redeem_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';
import 'package:sizer/sizer.dart';

class RedeemDetailView extends StatefulWidget {
  final RedeemItemModel item;

  const RedeemDetailView({super.key, required this.item});

  @override
  State<RedeemDetailView> createState() => _RedeemDetailViewState();
}

class _RedeemDetailViewState extends State<RedeemDetailView> {
  final Map<String, String> _dynamicTranslations = {};
  String _lastLang = 'en';

  Future<void> _translateAllContents(RedeemItemModel item) async {
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
    if (item.title.isNotEmpty) toTranslate.add(item.title);
    if (item.detailedDescription.isNotEmpty) toTranslate.add(item.detailedDescription);

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
  void initState() {
    super.initState();
    _translateAllContents(widget.item);
  }

  @override
  Widget build(BuildContext context) {
    final RedeemController controller = Get.find<RedeemController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 18.sp),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 1.w, top: 1.h, bottom: 1.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars, color: const Color(0xFFD4AF37), size: 14.sp),
                  SizedBox(width: 1.5.w),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.userPoints.value} ",
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.sp,
                          ),
                        ),
                        TextSpan(
                          text: "Karma",
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 9.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              Get.to(() => const RedemptionHistoryView());
            },
            icon: Icon(Icons.history, color: Colors.white, size: 18.sp),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Image
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.item.imagePath,
                  width: double.infinity,
                  height: 25.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 25.h,
                    color: const Color(0xFF1A1A1A),
                    child: const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 25.h,
                    color: const Color(0xFF1A1A1A),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40.sp,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 3.h),

            // Title
            Text(
              _dynamicTranslations[widget.item.title] ?? widget.item.title,
              style: GoogleFonts.lora(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.5.h),

            // Detailed Description
            Text(
              _dynamicTranslations[widget.item.detailedDescription] ?? widget.item.detailedDescription,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                height: 1.6,
                color: Colors.white70,
              ),
            ),

            SizedBox(height: 3.h),

            // Devotees Count
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    ),
                    child: Icon(Icons.people, color: const Color(0xFFD4AF37), size: 16.sp),
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      "devotees_count".trParams({'count': '${widget.item.devoteesRedeemed}'}),
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              "redeem_summary".tr,
              style: GoogleFonts.lora(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),

            // Redeem Summary Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "karma_label".tr,
                        style: GoogleFonts.lora(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.stars, color: const Color(0xFFD4AF37), size: 16.sp),
                          SizedBox(width: 2.w),
                          Text(
                            "${widget.item.requiredPoints}",
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  const Divider(color: Colors.white10),
                  SizedBox(height: 2.h),

                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.userPoints.value < widget.item.requiredPoints) {
                          showDialog(
                            context: context,
                            builder: (context) => InsufficientKarmaPopup(
                              requiredPoints: widget.item.requiredPoints,
                              currentPoints: controller.userPoints.value,
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationPopup(
                            item: widget.item,
                            onConfirm: () {
                              controller.redeemReward(
                                widget.item.id,
                                onSuccess: () {
                                  // Show Success
                                  Get.dialog(const SuccessPopup());
                                },
                                onError: (error) {
                                  Get.snackbar(
                                    "Error",
                                    error,
                                    snackPosition: SnackPosition.BOTTOM,
                                    margin: EdgeInsets.all(5.w),
                                    backgroundColor: Colors.red.withValues(alpha: 0.8),
                                    colorText: Colors.white,
                                    duration: const Duration(seconds: 2),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4800),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "redeem_cap".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            Row(
              children: [
                const Expanded(
                  child: Divider(color: Colors.white24, thickness: 0.5),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3.w),
                  child: Text(
                    "what_happens_next".tr,
                    style: GoogleFonts.lora(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Colors.white24, thickness: 0.5),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            _buildStepRow(
              "redeem_step_1".tr,
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "redeem_step_2".tr,
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "redeem_step_3".tr,
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "redeem_step_4".tr,
            ),

            SizedBox(height: 5.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 0.5.h),
          child: Icon(
            Icons.check_circle,
            size: 14.sp,
            color: const Color(0xFFD4AF37),
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

