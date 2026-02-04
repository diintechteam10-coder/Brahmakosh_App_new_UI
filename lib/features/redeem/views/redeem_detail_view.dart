import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/redeem/controllers/redeem_controller.dart';
import 'package:brahmakosh/features/redeem/models/redeem_item_model.dart';
import 'package:brahmakosh/features/redeem/widgets/redeem_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RedeemDetailView extends StatelessWidget {
  final RedeemItemModel item;

  const RedeemDetailView({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final RedeemController controller = Get.find<RedeemController>();

    return Scaffold(
      backgroundColor: AppTheme.landingBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: () => Get.back(),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff8D6E63).withOpacity(0.3),
              ),
            ),
            child: Obx(
              () => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/coin.png',
                    width: 16,
                    height: 16,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.circle, size: 16, color: Colors.amber),
                  ),
                  const SizedBox(width: 6),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${controller.userPoints.value} ",
                          style: GoogleFonts.inter(
                            color: const Color(0xff5D4037),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        TextSpan(
                          text: "Karma Points",
                          style: GoogleFonts.inter(
                            color: const Color(0xff5D4037),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                item.imagePath,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              item.title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D4037),
              ),
            ),
            const SizedBox(height: 12),

            // Detailed Description
            Text(
              item.detailedDescription,
              style: GoogleFonts.inter(
                fontSize: 14,
                height: 1.5,
                color: const Color(0xff5D4037).withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 24),

            // Devotees Count
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffFDFDF5), // Light background
                    ),
                    child: const Icon(Icons.people, color: Color(0xff8D6E63)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "${item.devoteesRedeemed} devotees have redeemed this offering",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xff5D4037),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Redeem Summary",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xff5D4037),
              ),
            ),
            const SizedBox(height: 16),

            // Redeem Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Karma Points Required",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff5D4037),
                        ),
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/coin.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.circle,
                              size: 20,
                              color: Colors.amber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "${item.requiredPoints}",
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xff5D4037),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xffEEEEEE)),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationPopup(
                            item: item,
                            onConfirm: () {
                              // Show Success
                              showDialog(
                                context: context,
                                builder: (context) => const SuccessPopup(),
                              );
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffFF8C00),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
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
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                const Expanded(
                  child: Divider(color: Color(0xff5D4037), thickness: 0.5),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "What Happens Next",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),
                const Expanded(
                  child: Divider(color: Color(0xff5D4037), thickness: 0.5),
                ),
              ],
            ),
            const SizedBox(height: 20),

            _buildStepRow(
              "Your Karma Points will be used to sponsor nutritious feed for a sacred cow.",
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              "You will receive a blessing photo and details of the cow you have nourished",
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              "A prayer of gratitude will be offered on your behalf at a local gawshala (cow sanctuary)",
            ),
            const SizedBox(height: 12),
            _buildStepRow(
              "You may receive updates on the well-being of the cows supported by this offering",
            ),

            const SizedBox(height: 40),
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
          margin: const EdgeInsets.only(top: 4),
          child: const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xff5D4037),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xff5D4037).withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
