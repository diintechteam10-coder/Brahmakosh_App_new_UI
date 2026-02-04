import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/features/auth/controllers/avtar_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

class GenerateAvatarView extends StatelessWidget {
  GenerateAvatarView({super.key});

  final GenerateAvatarController controller = Get.put(
    GenerateAvatarController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.landingBackground, // Light beige
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
          onPressed: Get.back,
        ),
      ),
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(top: 100, left: -20, child: _buildBubble(size: 60)),
          Positioned(top: 150, right: 40, child: _buildBubble(size: 40)),
          Positioned(top: 250, left: 30, child: _buildBubble(size: 80)),
          Positioned(bottom: 200, right: -10, child: _buildBubble(size: 100)),
          Positioned(bottom: 100, left: 50, child: _buildBubble(size: 50)),
          Positioned(top: 300, right: 80, child: _buildBubble(size: 30)),
          Positioned(bottom: 300, left: -30, child: _buildBubble(size: 90)),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Center(
                  child: Text(
                    "One Last Thing",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff5D4037),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Add a photo to personalize your journey",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xff5D4037),
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 2),

                /// IMAGE PICKER (Dashed Circle with Outer Line)
                Obx(
                  () => GestureDetector(
                    onTap: () => _showImageSourceSheet(context),
                    child: Column(
                      children: [
                        // Outer Solid Circle
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xff5D4037).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: CustomPaint(
                            painter: DashedCirclePainter(
                              color: const Color(0xff8D6E63),
                              dashWidth: 8,
                              dashSpace: 6,
                              strokeWidth: 2,
                            ),
                            child: Container(
                              width: 200,
                              height: 200,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.transparent, // Transparent inside
                              ),
                              child: controller.selectedImage.value != null
                                  ? ClipOval(
                                      child: Image.file(
                                        controller.selectedImage.value!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Center(
                                      child: Icon(
                                        Icons.camera_alt_outlined,
                                        size: 40,
                                        color: const Color(0xff5D4037),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "UPLOAD PHOTO",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff5D4037),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                /// SUBMIT BUTTON
                Obx(
                  () => GestureDetector(
                    onTap: controller.isLoading.value
                        ? null
                        : controller.generateAvatar,
                    child: Container(
                      height: 54,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.landingButton, // Flat brown
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: controller.isLoading.value
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                "Submit",
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // SKIP
                GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : () => Get.offAllNamed(AppConstants.routeDashboard),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Skip",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xff5D4037),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Color(0xff5D4037),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTheme.primaryGold.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Profile Photo",
              style: GoogleFonts.playfairDisplay(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Selfie",
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.camera);
                  },
                ),
                _sourceOption(
                  icon: Icons.image_outlined,
                  label: "Gallery",
                  onTap: () {
                    Get.back();
                    controller.pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom Painter for Dashed Circle
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;
  final double strokeWidth;

  DashedCirclePainter({
    required this.color,
    this.dashWidth = 8,
    this.dashSpace = 6,
    this.strokeWidth = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double radius = math.min(size.width, size.height) / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double circumference = 2 * math.pi * radius;

    double currentAngle = 0;
    final double dashAngle = (dashWidth / circumference) * 2 * math.pi;
    final double spaceAngle = (dashSpace / circumference) * 2 * math.pi;

    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
