import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/views/redemption_history_view.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/widgets/redeem_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class RedeemDetailView extends StatelessWidget {
  final RedeemItemModel item;

  const RedeemDetailView({super.key, required this.item});

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
                  imageUrl: item.imagePath,
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
              item.title,
              style: GoogleFonts.lora(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 1.5.h),

            // Detailed Description
            Text(
              item.detailedDescription,
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
                      "${item.devoteesRedeemed} devotees have redeemed this offering",
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
              "Redeem Summary",
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
                        "Karma Points Required",
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
                            "${item.requiredPoints}",
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
                        if (controller.userPoints.value < item.requiredPoints) {
                          showDialog(
                            context: context,
                            builder: (context) => InsufficientKarmaPopup(
                              requiredPoints: item.requiredPoints,
                              currentPoints: controller.userPoints.value,
                            ),
                          );
                          return;
                        }
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationPopup(
                            item: item,
                            onConfirm: () {
                              controller.redeemReward(
                                item.id,
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
                        "Redeem Now",
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
                    "What Happens Next",
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
              "Your Karma Points will be used to sponsor nutritious feed for a sacred cow.",
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "You will receive a blessing photo and details of the cow you have nourished",
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "A prayer of gratitude will be offered on your behalf at a local gawshala (cow sanctuary)",
            ),
            SizedBox(height: 1.5.h),
            _buildStepRow(
              "You may receive updates on the well-being of the cows supported by this offering",
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

