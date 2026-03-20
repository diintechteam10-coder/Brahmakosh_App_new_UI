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
      backgroundColor: AppTheme.authBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: Get.back,
        ),
      ),
      body: Stack(
        children: [
          // Wavy Background Pattern
          Positioned.fill(
            child: Image.asset(
              'assets/images/auth_wavy_bg.png',
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.4),
            ),
          ),

          // Main Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 100),

                Center(
                  child: Text(
                    "One Last Thing",
                    style: GoogleFonts.lora(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Add a photo to personalize your journey",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: AppTheme.authTextSecondary,
                    height: 1.5,
                  ),
                ),

                const Spacer(flex: 2),

                /// IMAGE PICKER
                Obx(
                  () => GestureDetector(
                    onTap: () => _showImageSourceSheet(context),
                    child: Column(
                      children: [
                        // Outer Solid Circle
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.authPrimaryGold.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: CustomPaint(
                            painter: DashedCirclePainter(
                              color: AppTheme.authPrimaryGold.withOpacity(0.5),
                              dashWidth: 10,
                              dashSpace: 8,
                              strokeWidth: 2,
                            ),
                            child: Container(
                              width: 220,
                              height: 220,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: controller.selectedImage.value != null
                                  ? ClipOval(
                                      child: Image.file(
                                        controller.selectedImage.value!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.authInputFill,
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.camera_alt_outlined,
                                          size: 48,
                                          color: AppTheme.authPrimaryGold,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "UPLOAD PHOTO",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.authPrimaryGold,
                            letterSpacing: 2.0,
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
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.authPrimaryGold,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!controller.isLoading.value)
                            BoxShadow(
                              color: AppTheme.authPrimaryGold.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
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
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                "Continue to Journey",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // SKIP
                GestureDetector(
                  onTap: controller.isLoading.value
                      ? null
                      : () => Get.offAllNamed(AppConstants.routeRegistrationSuccess),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Skip for now",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.authTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppTheme.authTextSecondary,
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

  void _showImageSourceSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          color: AppTheme.authSurface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Select Photo Source",
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _sourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
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
            const SizedBox(height: 20),
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
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: AppTheme.authInputFill,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.authPrimaryGold, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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

    double currentAngle = -math.pi / 2;
    final double dashAngle = (dashWidth / circumference) * 2 * math.pi;
    final double spaceAngle = (dashSpace / circumference) * 2 * math.pi;

    while (currentAngle < 1.5 * math.pi) {
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
