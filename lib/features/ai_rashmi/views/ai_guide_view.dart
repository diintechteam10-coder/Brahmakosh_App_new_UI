import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../ai_rashmi_chat.dart';
import '../ai_rashmi_service.dart';
import '../deity_selection_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import 'package:brahmakosh/core/services/storage_service.dart';

class AiGuideView extends StatefulWidget {
  final String deityName;
  final String subtitle;
  final String backgroundImage;
  final String characterImagePath;
  final String chatBackgroundImage;
  final String? firstMessage;

  const AiGuideView({
    super.key,
    required this.deityName,
    required this.subtitle,
    required this.backgroundImage,
    required this.characterImagePath,
    required this.chatBackgroundImage,
    this.firstMessage,
  });

  @override
  State<AiGuideView> createState() => _AiGuideViewState();
}

class _AiGuideViewState extends State<AiGuideView> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AgentController>()) {
      Get.put(AgentController());
    }
    // Sync the deity selection so RashmiChat uses the correct agent
    _syncDeitySelection();
  }

  /// Fetch agents from the API and set the correct deity in
  /// DeitySelectionService + StorageService so that both voice
  /// and text chat use the right AI persona.
  Future<void> _syncDeitySelection() async {
    try {
      final agentController = Get.find<AgentController>();
      if (agentController.avatars.isEmpty) {
        await agentController.fetchAvatars(null);
      }

      // Match by deityName in the avatar list (same logic as ask_bi_view)
      final targetAvatar = agentController.avatars.firstWhereOrNull(
        (a) => (a.name ?? '')
            .toLowerCase()
            .contains(widget.deityName.toLowerCase()),
      );

      if (targetAvatar != null) {
        DeitySelectionService().setSelectedDeity(targetAvatar);
      }

      // Also fetch the agents API to get the correct agent _id
      // (the avatar list uses agentId, but StorageService needs the _id)
      final agents = await AiRashmiService().fetchAgents();
      final matchingAgent = agents.firstWhereOrNull(
        (a) => (a.name ?? '')
            .toLowerCase()
            .contains(widget.deityName.toLowerCase()),
      );

      if (matchingAgent != null) {
        StorageService.setString(
          'ai_selected_agent_id',
          matchingAgent.id ?? '',
        );
        StorageService.setString(
          'ai_selected_agent_name',
          matchingAgent.name ?? '',
        );
        debugPrint(
          '[AiGuideView] Synced deity: ${matchingAgent.name} (${matchingAgent.id})',
        );
      }
    } catch (e) {
      debugPrint('[AiGuideView] Error syncing deity selection: $e');
    }
  }

  void _onTapToTalk() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        autoStartVoice: true,
        deityName: widget.deityName,
      ),
      transition: Transition.noTransition,
    );
  }

  void _onTextToChat() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        deityName: widget.deityName,
      ),
      transition: Transition.noTransition,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            widget.backgroundImage,
            fit: BoxFit.cover,
          ),
          Image.asset(
            widget.characterImagePath,
            fit: BoxFit.cover,
          ),
          // Dark gradient overlay for better text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Safe area content
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                children: [
                  // Top bar with Back Button
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 3.5.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 4.5.w,
                            ),
                          ),
                          onPressed: () => Get.back(),
                        ),
                      ],
                    ),
                  ),
          
                  // const SizedBox(height: 10),
          
                  // Title
                  Text(
                    "BRAHMAKOSH INTELLIGENCE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFD700), // Gold color
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
          
                  // Subtitle
                  Text(
                    "(${widget.deityName} - ${widget.subtitle})",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 11.25.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withOpacity(0.9),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          
                   SizedBox(height: MediaQuery.of(context).size.height * 0.45),
          
                  // Bottom feature text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      "Ask ${widget.deityName} about destiny, Karma, Horoscope or life guidance",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ),
          
                  const SizedBox(height: 40),
          
                  // Action Buttons
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Tap To Talk Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _onTapToTalk,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFDB913),
                                    Color(0xFF9E7B15),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFDB913).withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.mic,
                                    color: Colors.black,
                                    size: 4.5.w,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Tap To Talk",
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.75.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Text To Chat Button
                        Expanded(
                          child: GestureDetector(
                            onTap: _onTextToChat,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: const Color(0xFFFFD700).withOpacity(0.8),
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFFFFD700),
                                    size: 4.w,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Text To Chat",
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.75.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFFFD700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
