import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../controllers/rashmi_ai_controller.dart';
import '../../dashboard/viewmodels/dashboard_viewmodel.dart';

class AvatarUniversePage extends StatefulWidget {
  const AvatarUniversePage({super.key});

  @override
  State<AvatarUniversePage> createState() => _AvatarUniversePageState();
}

class _AvatarUniversePageState extends State<AvatarUniversePage>
    with WidgetsBindingObserver {
  late RashmiAiController controller;
  bool _hasTriggeredPlay = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = Get.put(RashmiAiController(), permanent: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardViewModel>(
      builder: (context, dashboardVM, _) {
        final isVisible = dashboardVM.currentIndex == 2;

        /// 🔒 PLAY VIDEO ONLY ONCE
        if (isVisible && !_hasTriggeredPlay) {
          _hasTriggeredPlay = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.playVideoOnce();
          });
        }

        return Scaffold(
          body: Stack(
            children: [
              /// 🌌 BACKGROUND
              Positioned.fill(
                child: Image.asset(
                  'assets/images/bi_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.45)),
              ),

              /// ✨ FLOATING STARS
              ...List.generate(5, (i) {
                final r = Random(i);
                return Positioned(
                  left: r.nextDouble() * MediaQuery.of(context).size.width,
                  top: r.nextDouble() * MediaQuery.of(context).size.height,
                  child: AnimatedBuilder(
                    animation: controller.animationController,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          sin(
                                controller.animationController.value * 2 * pi +
                                    i,
                              ) *
                              10,
                        ),
                        child: child,
                      );
                    },
                    child: Icon(
                      Icons.circle,
                      size: r.nextDouble() * 8 + 4,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                );
              }),

              /// 🤖 AVATAR
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() {
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: controller.isTalkModeEnabled.value
                                  ? Colors.cyanAccent.withOpacity(0.8)
                                  : Colors.cyanAccent.withOpacity(0.6),
                              blurRadius: 45,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: controller.isVideoInitialized.value
                              ? SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: VideoPlayer(
                                    controller.videoController!,
                                  ),
                                )
                              : const SizedBox(
                                  width: 170,
                                  height: 170,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    const Text(
                      'BI Rashmi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Your AI Guide',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),

              /// 💬 BUTTONS
              Positioned(
                left: 24,
                right: 24,
                bottom: 40,
                child: Row(
                  children: [
                    _btn(
                      icon: Icons.chat_bubble_outline,
                      label: 'Chat',
                      onTap: controller.onChatTap,
                    ),
                    const SizedBox(width: 16),
                    Obx(
                      () => _btn(
                        icon: Icons.mic,
                        label: 'Talk',
                        active: controller.isTalkModeEnabled.value,
                        onTap: controller.onTalkTap,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _btn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: active
                ? Colors.cyanAccent.withOpacity(0.2)
                : Colors.white.withOpacity(0.15),
            border: Border.all(
              color: active ? Colors.cyanAccent : Colors.white24,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: active ? Colors.cyanAccent : Colors.white),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.cyanAccent : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
