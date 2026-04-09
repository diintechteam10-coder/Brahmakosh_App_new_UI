import 'dart:ui';

import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_theme.dart';

class LuckInFavourSection extends StatelessWidget {
  const LuckInFavourSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "luck_in_favour".tr,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final prediction =
                homeController.panchangData?.numeroDailyPrediction;
            final nakshatraPrediction =
                homeController.panchangData?.dailyNakshatraPrediction;

            // Default to '--' and empty/grey if API response is null or loading
            final luckyNumber = prediction?.luckyNumber ?? '';
            final luckyColor = prediction?.luckyColor ?? '';
            final dayEnergy = prediction?.prediction ?? ''; // Default

            return Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: "lucky_no".tr,
                    frontImagePath: 'assets/images/YourLuckyNumber_outside.png',
                    backImagePath: 'assets/images/YourLuckyNumber_inside.png',
                    backContent: Text(
                      luckyNumber,
                      style: GoogleFonts.lora(
                        fontSize: 48, // Reduced from 64
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3A0C),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Expanded(
                  child: _buildCard(
                    title: "lucky_color".tr,
                    frontImagePath: 'assets/images/YourLuckyColor_outside.png',
                    backImagePath: 'assets/images/YourLuckyColor_inside.png',
                    backContent: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        textAlign: TextAlign.center,
                        luckyColor,
                        style: GoogleFonts.lora(
                          fontSize: 16, // Reduced from 64
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D3A0C),
                        ),
                      ),
                    ),

                  ),
                ),
                const SizedBox(width: 8), // Reduced spacing
                Expanded(
                  child: _buildCard(
                    title: "day_energy".tr,
                    frontImagePath: 'assets/images/YourDayEnergy_outside.png',
                    backImagePath: 'assets/images/YourDayEnergy_inside.png',
                    backContent: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: GestureDetector(
                        onTap: () => _showReadMoreDialog(context, dayEnergy),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                dayEnergy,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lora(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF6D3A0C),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'read_more'.tr,
                              style: GoogleFonts.lora(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF874101),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  ),
                ),
              ],
            );
          }),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children:  [
                Icon(
                  Icons.touch_app,
                  color: AppTheme.textSecondary,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  "tap_to_reveal".tr,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

          ),
        ],
      ),
    );
  }
  void _showReadMoreDialog(BuildContext context, String fullText) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "read_more".tr,
      barrierColor: Colors.black.withOpacity(0.4), // Slightly lighter to show blur
      transitionDuration: const Duration(milliseconds: 500), // Slightly slower for elegance
      pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (context, anim1, anim2, child) {
        // 📈 Use a swift OutBack curve for that "pop" feel
        final curvedValue = Curves.easeInOutBack.transform(anim1.value);

        return BackdropFilter(
          // ✨ Added background blur
          filter: ImageFilter.blur(sigmaX: 4 * anim1.value, sigmaY: 4 * anim1.value),
          child: Align(
            alignment: Alignment.bottomRight, // 📍 Align target to bottom right
            child: Transform(
              // 🎯 Origin is set to 1.0, 1.0 (Bottom Right)
              alignment: Alignment.bottomRight,
              transform: Matrix4.identity()
                ..scale(curvedValue)
                ..translate(
                  (1 - curvedValue) * 100, // Slide in from the right
                  (1 - curvedValue) * 100, // Slide in from the bottom
                ),
              child: Opacity(
                opacity: anim1.value.clamp(0.0, 1.0),
                child: Dialog(
                  // Margin to keep it away from the screen edges
                  insetPadding: const EdgeInsets.only(right: 20, bottom: 40, left: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      color: const Color(0xFFFFF6E5),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🌟 Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFD89B), Color(0xFFFFC67A)],
                            ),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFF6D3A0C), size: 24),
                              const SizedBox(height: 8),
                              Text(
                                'todays_energy'.tr,
                                style: GoogleFonts.lora(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6D3A0C),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 📜 Content
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                            child: Text(
                              fullText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lora(
                                fontSize: 15,
                                color: const Color(0xFF596072),
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),

                        // 🔘 Action
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20, top: 8),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF6D3A0C).withOpacity(0.08),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            ),
                            child: Text(
                              'blessings'.tr,
                              style: GoogleFonts.lora(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF6D3A0C),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'pink':
        return Colors.pink;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'brown':
        return Colors.brown;
      case 'cyan':
        return Colors.cyan;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.green; // Default fallback
    }
  }

  Widget _buildCard({
    required String title,
    required String frontImagePath,
    required String backImagePath,
    required Widget backContent,
  }) {
    return Column(
      children: [
        _FlipCard(
          front: _buildFrontCard(frontImagePath),
          back: _buildBackCard(frontImagePath, backImagePath, backContent),
        ),
        const SizedBox(height: 8),
        // Text(
        //   title,
        //   textAlign: TextAlign.center,
        //   style: GoogleFonts.lora(
        //     fontSize: 12, // Reduced font size
        //     fontWeight: FontWeight.bold,
        //     color: const Color(0xFF6D3A0C),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildFrontCard(String imagePath) {
    return Container(
      height: 180, // Reduced from 300
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Reduced radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _buildAssetImage(
          imagePath,
          height: 180,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildBackCard(String frontPath, String imagePath, Widget content) {
    return Container(
      height: 180, // Reduced from 300
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(child: _buildAssetImage(imagePath)),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetImage(String path, {double? height, double? width}) {
    if (path.toLowerCase().endsWith('.svg')) {
      return SvgPicture.asset(
        path,
        fit: BoxFit.fill,
        height: height,
        width: width,
        placeholderBuilder: (context) =>
            const Center(child: CircularProgressIndicator()),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.fill,
      height: height,
      width: width,
      errorBuilder: (context, error, stackTrace) {
        return const Center(child: Icon(Icons.error, color: Colors.red));
      },
    );
  }
}

class _FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const _FlipCard({required this.front, required this.back});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _animation.value < 0.5
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
