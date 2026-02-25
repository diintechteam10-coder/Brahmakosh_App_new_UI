import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:brahmakosh/features/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../deity_selection_service.dart';
import 'ai_guide_view.dart'; // Added Import

class AskBiView extends StatelessWidget {
  const AskBiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0), // home background match
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppTheme.textPrimary,
                    ),
                    onPressed: () {
                      // Go back to home
                      Provider.of<DashboardViewModel>(
                        context,
                        listen: false,
                      ).changeTab(0);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              "ASK YOUR BI",
              style: GoogleFonts.lora(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "BRAHMAKOSH ",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFD97706), // Orange
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: "INTELLIGENCE",
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppTheme.primaryGold, width: 1.5),
                  ),
                ),
                child: Text(
                  "CHOOSE YOURS SPIRITUAL GUIDE TO PROCEED",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Rashmi Card
            Flexible(
              flex: 12,
              child: _buildGuideCard(
                context,
                title: "Rashmi",
                subtitle: "Personal Spiritual Guide",
                description: "Ask About Life, Career & Astrology",
                buttonText: "Explore",
                buttonGradient: const LinearGradient(
                  colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                ),
                characterImagePath:
                    'assets/images/Rashmi_Withoutbackground.png',
                backgroundColor: const Color(
                  0xFFF0E5D8,
                ), // Light taupe/cream color from image
                onTap: () async {
                  if (!Get.isRegistered<AgentController>()) {
                    Get.put(AgentController());
                  }
                  final agentController = Get.find<AgentController>();
                  if (agentController.avatars.isEmpty) {
                    await agentController.fetchAvatars(null);
                  }
                  // Find Rashmi avatar
                  try {
                    final rashmiData = agentController.avatars.firstWhere(
                      (a) => (a.name ?? '').toLowerCase().contains('rashmi'),
                    );
                    DeitySelectionService().setSelectedDeity(rashmiData);
                  } catch (e) {
                    // Fallback
                  }

                  Get.to(
                    () => const AiGuideView(
                      deityName: "Rashmi",
                      subtitle: "Your Spiritual Guide",
                      backgroundImage: 'assets/images/rashmi_background.jpeg',
                      characterImagePath:
                          'assets/images/Rashmi_Withoutbackground.png',
                      chatBackgroundImage: 'assets/images/Rashmi_chat.png',
                    ),
                  );
                },
                textColor: AppTheme.textPrimary,
                dividerColor: AppTheme.textSecondary.withOpacity(0.3),
                isLockIcon: false,
              ),
            ),

            const Spacer(flex: 2),

            // Krishna Card
            Flexible(
              flex: 12,
              child: _buildGuideCard(
                context,
                title: "Krishna",
                subtitle: "Divine Cosmic Intelligence",
                description: "Karma, Destiny, Deep Truths",
                buttonText: "Unlock To Talk",
                buttonGradient: const LinearGradient(
                  colors: [Color(0xFFE6C17A), Color(0xFFC79E59)],
                ),
                characterImagePath:
                    'assets/images/Krishna_WithoutBackground.png',
                backgroundColor: const Color(
                  0xFF5F66B6,
                ), // Purple-blue color from image
                onTap: () async {
                  if (!Get.isRegistered<AgentController>()) {
                    Get.put(AgentController());
                  }
                  final agentController = Get.find<AgentController>();
                  if (agentController.avatars.isEmpty) {
                    await agentController.fetchAvatars(null);
                  }
                  // Find Krishna avatar
                  try {
                    final krishnaData = agentController.avatars.firstWhere(
                      (a) => (a.name ?? '').toLowerCase().contains('krishna'),
                    );
                    DeitySelectionService().setSelectedDeity(krishnaData);
                  } catch (e) {
                    // Fallback
                  }

                  Get.to(
                    () => const AiGuideView(
                      deityName: "Krishna",
                      subtitle: "Divine Cosmic Intelligence",
                      backgroundImage: 'assets/images/rashmi_background.jpeg',
                      characterImagePath:
                          'assets/images/Krishna_WithoutBackground.png',
                      chatBackgroundImage: 'assets/images/Krishna_chat.png',
                    ),
                  );
                },
                textColor: Colors.white,
                dividerColor: Colors.white.withOpacity(0.5),
                isLockIcon: true,
                buttonTextColor: AppTheme.textPrimary,
              ),
            ),

            const Spacer(flex: 4),

            // Bottom Mantra
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "|| ॐ भूर्भुव: स्व: तत्सवितुर्वरेण्यं भर्गो देवस्य\nधीमहि धियो यो न: प्रचोदयात् ||",
                textAlign: TextAlign.center,
                style: GoogleFonts.rozhaOne(
                  fontSize: 13, // Reduced from 15
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  height: 1.4, // Reduced line height slightly
                ),
              ),
            ),

            const SizedBox(height: 100), // Reduced from 120 to fit better
          ],
        ),
      ),
    );
  }

  Widget _buildGuideCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String description,
    required String buttonText,
    required Gradient buttonGradient,
    required String characterImagePath,
    required Color backgroundColor,
    required VoidCallback onTap,
    required Color textColor,
    required Color dividerColor,
    required bool isLockIcon,
    Color buttonTextColor = Colors.white,
  }) {
    // We recreate the card layout carefully matching the mockup
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Constraints to prevent infinite height in Flexible but allow it to shrink
          constraints: const BoxConstraints(maxHeight: 160),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Character Image
              Positioned(
                left: -10,
                bottom: -5,
                top: 5,
                child: Image.asset(
                  characterImagePath,
                  fit: BoxFit.contain,
                  alignment: Alignment.bottomCenter,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox.shrink(),
                ),
              ),

              // Text Content aligned to right/center-right
              Positioned(
                left: 140, // Space for the person in the image
                right: 16,
                top: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: GoogleFonts.lora(
                        fontSize: 18, // Reduced from 22
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),

                    // Divider
                    Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                      ), // Reduced from 6
                      height: 1,
                      width: double.infinity,
                      color: dividerColor,
                    ),

                    // Subtitle
                    Text(
                      subtitle,
                      style: GoogleFonts.lora(
                        fontSize: 11, // Reduced from 12
                        fontWeight: FontWeight.w500,
                        color: textColor.withOpacity(0.9),
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Description
                    Text(
                      description,
                      style: GoogleFonts.lora(
                        fontSize: 10, // Reduced from 11
                        fontStyle: FontStyle.italic,
                        color: textColor.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 8), // Reduced from 12
                    // Action Button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, // Reduced from 16
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: buttonGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLockIcon) ...[
                            Icon(
                              Icons.lock,
                              size: 10,
                              color: buttonTextColor,
                            ), // Reduced from 12
                            const SizedBox(width: 4),
                          ],
                          Text(
                            buttonText,
                            style: GoogleFonts.lora(
                              fontSize: 11, // Reduced from 12
                              fontWeight: FontWeight.bold,
                              color: buttonTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
