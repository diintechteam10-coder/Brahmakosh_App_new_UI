import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_constants.dart';
import '../../agent/controllers/agent_controller.dart';
import '../../ai_rashmi/ai_rashmi_chat.dart';

class WalkthroughView extends StatefulWidget {
  const WalkthroughView({super.key});

  @override
  State<WalkthroughView> createState() => _WalkthroughViewState();
}

class _WalkthroughViewState extends State<WalkthroughView> {
  final PageController _pageController = PageController();
  Timer? _timer;

  final List<String> _images = [
    'assets/images/Krishna_walkthrough.png',
    'assets/images/Rashmi_walkthrough.png',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoFlip();
  }

  void _startAutoFlip() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.round() + 1;
        if (nextPage >= _images.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using MediaQuery for responsiveness
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;

    return Scaffold(
      body: Stack(
        children: [
          // Carousel
          PageView.builder(
            controller: _pageController,
            itemCount: _images.length,
            itemBuilder: (context, index) {
              return Image.asset(
                _images[index],
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
                  );
                },
              );
            },
          ),

          // Overlay Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),

                    // Header
                    const Text(
                      'Brahmakosh',
                      style: TextStyle(
                        fontFamily:
                            'Serif', // Using a serif font to match design
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D2E18), // Dark Brown/Maroon
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your Spiritual Operating System',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF8D6E63), // Lighter Brown
                      ),
                    ),

                    SizedBox(
                      height: size.height * 0.38,
                    ), // Spacer for image visibility
                    // Section Title
                    const Text(
                      'Choose Your Option',
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D2E18),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Option Cards
                    _buildOptionCard(
                      icon: Icons.spa_outlined, // Lotus-like
                      title: 'Are You Spiritual?',
                      subtitle:
                          'Pause, reflect, and track your spiritual growth',
                      onTap: () {
                        Get.offAllNamed(
                          AppConstants.routeDashboard,
                          arguments: 1,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      icon: Icons.auto_awesome_outlined, // Sparkles/Hand-like
                      title: 'Divine Guidance from Krishna',
                      subtitle:
                          'Seek wisdom, comfort, and clarity on your life path',
                      onTap: () {
                        if (!Get.isRegistered<AgentController>()) {
                          Get.put(AgentController());
                        }
                        Get.to(
                          () => const RashmiChat(
                            backgroundImage: 'assets/images/Krishna_chat.png',
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildOptionCard(
                      icon:
                          Icons.settings_suggest_outlined, // Chakra/Wheel-like
                      title: 'Cosmic Alignment & Energies',
                      subtitle: 'Learn Kundali, astrology, and sacred timings',
                      onTap: () {
                        Get.offAllNamed(AppConstants.routeDashboard);
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Next Button (Top Right)
          // Positioned(
          //   top: padding.top + 20,
          //   right: 20,
          //   child: GestureDetector(
          //     onTap: () {
          //       Get.offAllNamed(AppConstants.routeDashboard);
          //     },
          //     child: Container(
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 20,
          //         vertical: 10,
          //       ),
          //       decoration: BoxDecoration(
          //         color: Colors.black.withOpacity(0.5),
          //         borderRadius: BorderRadius.circular(20),
          //         border: Border.all(color: Colors.white, width: 1),
          //       ),
          //       child: const Text(
          //         'Next',
          //         style: TextStyle(
          //           color: Colors.white,
          //           fontWeight: FontWeight.bold,
          //           fontSize: 16,
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF4A1818), // Dark Maroon background
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4AF37),
            width: 1.5,
          ), // Gold border
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon Circle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFD4AF37), // Gold icon
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37), // Gold title
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFCBB2A6), // Light brownish text
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD4AF37),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
