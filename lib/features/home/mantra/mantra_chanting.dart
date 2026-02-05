import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/home/controllers/mantra_chanting_controller.dart';

class MantraChantingView extends GetView<MantraChantingController> {
  const MantraChantingView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MantraChantingController>()) {
      Get.put(MantraChantingController());
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop == true) {
          Get.back();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/chanting_backgroud.png',
                fit: BoxFit.cover,
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader(context),
                  //const Spacer(),
                  const SizedBox(height: 15),
                  _buildMantraDial(),
                  const SizedBox(
                    height: 20,
                  ), // Reduced gap to keep controls near dial
                  _buildStatusSection(),
                  const SizedBox(height: 8),
                  _buildChantButton(),
                  const Spacer(), // Added Spacer to push content up towards middle
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context) {
    return Get.dialog<bool>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xffFFF8E7), // Light beige
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xff5D4037),
              ),
              const SizedBox(height: 16),
              Text(
                "End Chanting?",
                style: GoogleFonts.merriweather(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Are you sure you want to end chanting? If you end now, you will not receive any Karma points.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xff8D6E63),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(result: false),
                      child: Text(
                        "Cancel",
                        style: GoogleFonts.poppins(
                          color: const Color(0xff8D6E63),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(result: true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff5D4037),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "End",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final shouldPop = await _showExitConfirmation(context);
                  if (shouldPop == true) {
                    Get.back();
                  }
                },
                icon: const Icon(Icons.arrow_back, color: Color(0xff5D4037)),
              ),
            ],
          ),
          Text(
            "Today' Chanting",
            style: GoogleFonts.merriweather(
              // Serif font like in design
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xff5D4037), // Dark Brown
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final mantraName = controller.chantingMantra?.name ?? "ॐ नमः शिवाय";
            return Text(
              mantraName,
              style: GoogleFonts.tiroDevanagariHindi(
                fontSize: 18,
                color: const Color(0xff5D4037),
                fontWeight: FontWeight.w500,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMantraDial() {
    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Layer 1: Layout Skeleton (keeps divider/counter in place)
          Obx(() {
            final total = controller.chantingMantra?.malaCount ?? 108;
            final current = controller.chantCount.value;
            // Ghost text to reserve space exactly matching the visible text
            final mantraText = controller.chantingMantra?.name ?? "ॐ नमः शिवाय";

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Invisible Text Placeholder to maintain layout
                Opacity(
                  opacity: 0.0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      mantraText,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tiroDevanagariHindi(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 120,
                  height: 1,
                  color: const Color(0xffFFD700).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$current",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Changing count is White
                        ),
                      ),
                      TextSpan(
                        text: " / $total",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xffFFD700), // Static part is Gold
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          // Layer 2: Animated Mantra Text (Projectile Animation)
          // Uses Explicit AnimationController (moveController)
          AnimatedBuilder(
            animation: controller.moveController,
            builder: (context, child) {
              final mantraText =
                  controller.chantingMantra?.name ?? "ॐ नमः शिवाय";

              // If animation is dismissed (initial state) or completed (cycle done),
              // show nothing or resetting state.
              // Actually, we want to show the text at center if not animating?
              // User said "mantra text... emerging from circle... only when we tap"
              // The "loop" implies tap -> animates -> disappears -> wait for next tap.

              // Let's render the text based on animation values.
              return Align(
                alignment: controller.moveAnimation.value,
                child: Opacity(
                  opacity: controller.moveOpacityAnimation.value,
                  child: Transform.scale(
                    scale: controller.moveScaleAnimation.value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        mantraText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tiroDevanagariHindi(
                          fontSize: 32,
                          color: const Color(0xffFFD700), // Yellow/Gold text
                          fontWeight: FontWeight.bold,
                          shadows: [
                            const Shadow(
                              color: Colors.black45,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Obx(
              () => Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.elapsedSeconds.value > 0
                      ? const Color(0xffFF8C00) // Active Orange
                      : Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(
              "Chanting in Progress",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xff5D4037),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            "Time : ${controller.formattedTime}",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: const Color(0xff8D6E63),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChantButton() {
    return GestureDetector(
      onTap: controller.incrementCount,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress Ring
          SizedBox(
            width: 100,
            height: 100,
            child: Obx(() {
              final total = controller.chantingMantra?.malaCount ?? 108;
              final progress = total > 0
                  ? (controller.chantCount.value / total)
                  : 0.0;
              return CircularProgressIndicator(
                value: progress,
                strokeWidth: 4,
                valueColor: const AlwaysStoppedAnimation(Color(0xffD4AF37)),
                backgroundColor: const Color(0xffD4AF37).withOpacity(0.2),
              );
            }),
          ),

          // Button
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xff5D4037), Color(0xff3E2723)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xffD4AF37), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xff3E2723).withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              "Tap to\nChant",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
