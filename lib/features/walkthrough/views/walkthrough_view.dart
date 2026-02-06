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
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Carousel Background
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

          // Main Content
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.02),

                // Header
                Column(
                  children: [
                    Text(
                      'Brahmakosh',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Serif',
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D2E18),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your Spiritual Operating System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.04,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3), // Pushes button down
                // Talk to Krishna Button
                GestureDetector(
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
                  child: Container(
                    width: size.width > 600 ? 400 : size.width * 0.75,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.020,
                      horizontal: size.width * 0.05,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFE082), Color(0xFFFFB300)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Talk to Krishna',
                          style: TextStyle(
                            fontFamily: 'Serif',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5D2E18),
                          ),
                        ),
                        const Text(
                          'Powered by BI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF5D2E18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Section Title
                const Text(
                  'Choose a path that resonates with you',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Serif',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D2E18),
                  ),
                ),

                //const Spacer(flex: 1), // Space between title and cards
                const SizedBox(height: 10),
                // Option Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildOptionCard(
                        icon: Icons.spa_outlined,
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
                      const SizedBox(height: 6),
                      _buildOptionCard(
                        icon: Icons.auto_awesome_outlined,
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
                      const SizedBox(height: 6),
                      _buildOptionCard(
                        icon: Icons.settings_suggest_outlined,
                        title: 'Cosmic Alignment & Energies',
                        subtitle:
                            'Learn Kundali,  Astrology, Numerology and Sacred Timings',
                        onTap: () {
                          Get.offAllNamed(AppConstants.routeDashboard);
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.02),
              ],
            ),
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4A1818),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFD4AF37), width: 1.5),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFCBB2A6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFFD4AF37),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
