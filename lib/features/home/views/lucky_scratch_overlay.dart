import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/features/home/controllers/lucky_scratch_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scratcher/widgets.dart';
import 'package:get/get.dart';

class LuckyScratchOverlay extends StatelessWidget {
  final String luckyNumber;
  final Color luckyColor;
  final String luckyColorName;
  final String title;
  final IconData icon;
  final BuildContext dialogContext;
  final VoidCallback? onScratchComplete;

  const LuckyScratchOverlay({
    super.key,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyColorName,
    required this.title,
    required this.icon,
    required this.dialogContext,
    this.onScratchComplete,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.85;
    final maxCardHeight = screenHeight * 0.75;
    
    // Use a unique tag to ensure fresh controller
    final tag = 'lucky_scratch_${DateTime.now().microsecondsSinceEpoch}';
    final controller = Get.put(
        LuckyScratchController(onScratchComplete: onScratchComplete),
        tag: tag);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: FadeTransition(
          opacity: controller.fadeAnimation,
          child: SlideTransition(
            position: controller.slideAnimation,
            child: ScaleTransition(
              scale: controller.scaleAnimation,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: maxCardHeight),
                child: Container(
                  width: cardWidth,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.cardBackground,
                        AppTheme.backgroundLight,
                        AppTheme.cardBackground,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.4),
                        blurRadius: 50,
                        offset: const Offset(0, 25),
                        spreadRadius: 2,
                      ),
                    ],
                    border: Border.all(
                      color: AppTheme.primaryGold.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: Stack(
                          children: [
                            // Decorative top curve
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.topRight,
                                    colors: [
                                      AppTheme.primaryGold.withOpacity(0.2),
                                      AppTheme.primaryGold.withOpacity(0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                ),
                              ),
                            ),

                            // Main content
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 30,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 16),
                                  Text(
                                    title,
                                    style: GoogleFonts.lora(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      shadows: [
                                        Shadow(
                                          color: AppTheme.primaryGold
                                              .withOpacity(0.4),
                                          offset: const Offset(0, 2),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scratch to reveal your luck! ✨',
                                    style: GoogleFonts.lora(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 28),

                                  // Scratch card
                                  Container(
                                    width: double.infinity,
                                    height: 240,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.25),
                                          blurRadius: 30,
                                          offset: const Offset(0, 15),
                                          spreadRadius: 2,
                                        ),
                                        BoxShadow(
                                          color: AppTheme.primaryGold
                                              .withOpacity(0.35),
                                          blurRadius: 40,
                                          offset: const Offset(0, 20),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(28),
                                      child: Scratcher(
                                        accuracy: ScratchAccuracy.low,
                                        threshold: 60,
                                        brushSize: 50,
                                        color: AppTheme.primaryGold
                                            .withOpacity(0.95),
                                        image: Image.asset(
                                          'assets/images/rashmi_background.jpeg',
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error,
                                              stackTrace) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                gradient:
                                                    AppTheme.goldGradient,
                                              ),
                                              child: Center(
                                                child: Icon(
                                                  Icons.stars,
                                                  size: 80,
                                                  color: AppTheme.primaryGold,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        onChange: (value) =>
                                            controller.updateProgress(value / 100),
                                        onThreshold: () {
                                            // Handle threshold reached implicitly via logic in updateProgress
                                            // But standard Scratcher might need explicit callback?
                                            // If updateProgress checks threshold, it's fine.
                                            // But we might want to ensure 'onThreshold' triggers the logic too.
                                            // The original used onThreshold -> setState(revealed).
                                            // updateProgress has logic for >=0.6.
                                            // We can check if isRevealed is true.
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                AppTheme.cardBackground,
                                                AppTheme.backgroundLight,
                                                AppTheme.cardBackground,
                                              ],
                                            ),
                                          ),
                                          child: Center(
                                            child: FadeTransition(
                                              opacity: controller.revealController,
                                              child: ScaleTransition(
                                                scale: Tween<double>(
                                                  begin: 0.5,
                                                  end: 1.0,
                                                ).animate(
                                                  CurvedAnimation(
                                                    parent: controller.revealController,
                                                    curve: Curves
                                                        .elasticOut,
                                                  ),
                                                ),
                                                child: Text(
                                                  luckyNumber,
                                                  style: GoogleFonts
                                                      .playfairDisplay(
                                                    fontSize: 80,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                    color:
                                                        luckyColor,
                                                    height: 1.0,
                                                    shadows: [
                                                      Shadow(
                                                        color: luckyColor
                                                            .withOpacity(0.6),
                                                        offset:
                                                            const Offset(0, 4),
                                                        blurRadius: 20,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),

                                  Obx(() {
                                    if (!controller.isRevealed.value) {
                                      return Column(
                                        children: [
                                          Text(
                                            '${(controller.scratchProgress.value * 100).toInt()}% scratched',
                                            style: GoogleFonts.lora(
                                              fontSize: 11,
                                              color: AppTheme.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            width: cardWidth * 0.6,
                                            height: 6,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(3),
                                              color: AppTheme.lightGold
                                                  .withOpacity(0.3),
                                              border: Border.all(
                                                color: AppTheme.primaryGold
                                                    .withOpacity(0.2),
                                                width: 1,
                                              ),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: controller.scratchProgress.value,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  gradient:
                                                      AppTheme.goldGradient,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme.primaryGold
                                                          .withOpacity(0.5),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return FadeTransition(
                                        opacity: controller.revealController,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 28,
                                            vertical: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.goldGradient,
                                            borderRadius:
                                                BorderRadius.circular(24),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppTheme.primaryGold
                                                    .withOpacity(0.5),
                                                blurRadius: 16,
                                                offset: const Offset(0, 6),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Revealed!',
                                                style: GoogleFonts.lora(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Close button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                             Get.delete<LuckyScratchController>(tag: tag);
                             Navigator.of(dialogContext).pop();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGold.withOpacity(0.3),
                              border: Border.all(
                                color: AppTheme.primaryGold.withOpacity(0.6),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(0.5),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 24,
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
      ),
    );
  }
}
