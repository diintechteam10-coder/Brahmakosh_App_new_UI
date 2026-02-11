import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/home/views/lucky_scratch_overlay.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/controllers/lucky_flip_card_controller.dart';

class LuckyFlipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String luckyNumber;
  final Color luckyColor;
  final String luckyColorName;
  final String cardId;

  const LuckyFlipCard({
    super.key,
    required this.icon,
    required this.title,
    required this.luckyNumber,
    required this.luckyColor,
    required this.luckyColorName,
    required this.cardId,
  });

  void _showScratchOverlay(BuildContext context, LuckyFlipCardController controller) async {
    if (controller.isScratched.value) return;

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return LuckyScratchOverlay(
          luckyNumber: luckyNumber,
          luckyColor: luckyColor,
          luckyColorName: luckyColorName,
          title: title,
          icon: icon,
          dialogContext: dialogContext,
          onScratchComplete: () {
            final today = DateTime.now();
            final todayString =
                '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
            StorageService.setString(
                'lastScratchDate_$cardId', todayString);
            
            // Update controller state immediately
            controller.markAsScratched();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
            ),
            child: child,
          ),
        );
      },
    );

    // Re-check after overlay is closed (just in case)
    controller.checkIsScratched();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LuckyFlipCardController(cardId), tag: cardId);

    return Obx(() => GestureDetector(
      onTap: () => _showScratchOverlay(context, controller),
      child: controller.isScratched.value ? _buildRevealed() : _buildFront(),
    ));
  }

  Widget _buildRevealed() {
    return _baseCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            luckyNumber,
            style: GoogleFonts.playfairDisplay(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: luckyColor,
              shadows: [
                Shadow(
                  color: luckyColor.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            luckyColorName,
            style: GoogleFonts.lora(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
            ),
            child: Text(
              "Revealed",
              style: GoogleFonts.cinzel(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFront() {
    return _baseCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.45),
                  blurRadius: 18,
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
               title,
              style: GoogleFonts.cinzel(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 3),
          Flexible(
            child: Text(
              "Tap to reveal",
              style: GoogleFonts.lora(
                fontSize: 9,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _baseCard({required Widget child}) {
    return Container(
      height: 140,
      width: 120,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBackground,
            AppTheme.cardBackground.withOpacity(0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.25)),
      ),
      child: child,
    );
  }
}
