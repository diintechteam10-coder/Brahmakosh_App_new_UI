import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/views/redeem_detail_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

class RedeemCard extends StatelessWidget {
  final RedeemItemModel item;

  const RedeemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(3.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.imagePath,
                width: 25.w,
                height: 12.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 25.w,
                  height: 12.h,
                  color: const Color(0xFF1A1A1A),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFD4AF37)),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 25.w,
                  height: 12.h,
                  color: const Color(0xFF1A1A1A),
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.white24,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 4.w),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title.split(' (')[0],
                    style: GoogleFonts.lora(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.title.contains(' ('))
                    Text(
                      ' (${item.title.split(' (')[1]}',
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp,
                        color: Colors.white60,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 0.5.h),
                  Text(
                    item.description,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Required",
                            style: GoogleFonts.poppins(
                              fontSize: 8.sp,
                              color: Colors.white38,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.stars, color: const Color(0xFFD4AF37), size: 10.sp),
                              SizedBox(width: 1.w),
                              Text(
                                "${item.requiredPoints}",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Get.to(() => RedeemDetailView(item: item));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4800),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 0.5.h,
                          ),
                          minimumSize: Size(20.w, 4.h),
                          elevation: 0,
                        ),
                        child: Text(
                          "Redeem",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 9.sp,
                          ),
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

class ConfirmationPopup extends StatelessWidget {
  final RedeemItemModel item;
  final VoidCallback onConfirm;

  const ConfirmationPopup({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RedeemController>();
    final int currentBalance = controller.userPoints.value;
    final int remainingBalance = currentBalance - item.requiredPoints;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF141414),
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24),
                Text(
                  "Confirmation",
                  style: GoogleFonts.lora(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(Icons.close, color: Colors.white38, size: 20.sp),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              "You’re about to offer a sacred act using\nyour earned Karma Points.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            SizedBox(height: 3.h),

            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Offering",
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.white38,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          item.title,
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildPricingRow(
                    "Balance",
                    "$currentBalance",
                    false,
                  ),
                  SizedBox(height: 1.h),
                  _buildPricingRow(
                    "Required",
                    "- ${item.requiredPoints}",
                    false,
                    valueColor: Colors.redAccent,
                  ),
                  SizedBox(height: 1.5.h),
                  const Divider(color: Colors.white10, thickness: 1),
                  SizedBox(height: 1.5.h),
                  _buildPricingRow(
                    "Remaining Balance",
                    "$remainingBalance",
                    true,
                    valueColor: const Color(0xFFD4AF37),
                  ),
                ],
              ),
            ),

            SizedBox(height: 4.h),

            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF4800),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Confirm Now",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "This sacred act will be performed\non your behalf.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                color: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, bool isBold, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.white : Colors.white70,
          ),
        ),
        Row(
          children: [
            Icon(
              Icons.stars,
              size: 11.sp,
              color: valueColor ?? const Color(0xFFD4AF37),
            ),
            SizedBox(width: 1.5.w),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SuccessPopup extends StatelessWidget {
  const SuccessPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF141414),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 25.sp),
            ),
            SizedBox(height: 3.h),
            Text(
              "Blessing Received",
              style: GoogleFonts.lora(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "Your Karma Points have been redeemed\nsuccessfully.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 5.5.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Great",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InsufficientKarmaPopup extends StatelessWidget {
  final int requiredPoints;
  final int currentPoints;

  const InsufficientKarmaPopup({
    super.key,
    required this.requiredPoints,
    required this.currentPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFF141414),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
              ),
              child: Icon(Icons.stars_rounded, color: Colors.redAccent, size: 25.sp),
            ),
            SizedBox(height: 3.h),
            Text(
              "Incomplete Karma",
              style: GoogleFonts.lora(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              "You need $requiredPoints Karma Points for this offering. You currently have $currentPoints.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 5.5.h,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Got It",
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
