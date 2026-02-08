import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/views/redeem_detail_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RedeemCard extends StatelessWidget {
  final RedeemItemModel item;

  const RedeemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10), // Reduced from 12
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.imagePath,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12), // Reduced from 16
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: item.title.split(' (')[0],
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 16, // Reduced from 18
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5D4037),
                          ),
                        ),
                        if (item.title.contains(' ('))
                          TextSpan(
                            text: ' (${item.title.split(' (')[1]}',
                            style: GoogleFonts.inter(
                              fontSize: 12, // Reduced from 14
                              color: const Color(0xff8D6E63),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4), // Reduced from 6
                  Text(
                    item.description,
                    style: GoogleFonts.inter(
                      fontSize: 11, // Reduced from 12
                      color: const Color(0xff5D4037).withOpacity(0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10), // Reduced from 12
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Required Karma Points",
                            style: GoogleFonts.inter(
                              fontSize: 9, // Reduced from 10
                              color: const Color(0xff8D6E63),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/coin.png',
                                width: 14, // Reduced from 16
                                height: 14,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.circle,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                "${item.requiredPoints}",
                                style: GoogleFonts.inter(
                                  fontSize: 14, // Reduced from 16
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xff5D4037),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to detail
                          Get.to(() => RedeemDetailView(item: item));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xffFF8C00,
                          ), // Orange color
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12, // Reduced from 16
                            vertical: 6, // Reduced from 8
                          ),
                          minimumSize: const Size(0, 32), // Reduced height
                        ),
                        child: Text(
                          "Redeem Now",
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 11, // Reduced from 12
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
    // Determine the offering text from title for display
    // e.g. "Feed a Cow (Gau Seva)" -> "Feed a Cow (Gau Seva)"

    // Total available balance is mocked or passed ideally
    final controller = Get.find<RedeemController>();
    final int currentBalance = controller.userPoints.value;
    final int remainingBalance = currentBalance - item.requiredPoints;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 24), // Spacer for title centering
                Text(
                  "Confirmation",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff5D4037),
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "You’re about to offer a sacred act using\nyour earned Karma Points.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xff5D4037).withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffFAF3F0), // Very light beige
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffEFEFEF)),
              ),
              child: Column(
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xff5D4037),
                      ),
                      children: [
                        const TextSpan(
                          text: 'Offering:  ',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        TextSpan(
                          text: item.title,
                          style: const TextStyle(fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPricingRow(
                    "Total Available Balance",
                    "$currentBalance",
                    false,
                  ),
                  const SizedBox(height: 8),
                  _buildPricingRow(
                    "Required",
                    "- ${item.requiredPoints}",
                    false,
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _buildPricingRow(
                    "Total Renaming Balance",
                    "$remainingBalance",
                    true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close confirmation
                  onConfirm(); // Trigger success/process
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF8C00),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Redeem Now",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Once redeemed, this offering will be\nperformed on your behalf.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xff5D4037).withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xff5D4037),
          ),
        ),
        Row(
          children: [
            Image.asset(
              'assets/images/coin.png',
              width: 16,
              height: 16,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.circle, size: 16, color: Colors.amber),
            ),
            const SizedBox(width: 6),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D4037),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xff22C55E), // Green
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              "Blessing Received",
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D4037),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Your Karma Points has been redeemed\nsuccessfully.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xff5D4037).withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
