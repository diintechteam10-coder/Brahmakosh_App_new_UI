import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';


import '../ai_rashmi_chat.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

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
  }

  void _onTapToTalk() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        autoStartVoice: true,
      
      ),
      transition: Transition.noTransition,
    );
  }

  void _onTextToChat() {
    Get.to(
      () => RashmiChat(
        backgroundImage: widget.chatBackgroundImage,
        
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
            'assets/icons/chat_bg_new.png',
            fit: BoxFit.cover,
          ),
          Image.asset(
                        widget.deityName == "Krishna"
                            ? 'assets/icons/krishna_neww.png'
                            : widget.characterImagePath,
                        fit: BoxFit.contain,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
              child: Column(
                children: [
                  // Top bar with Back Button
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 28.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 18,
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
                      fontSize: 20,
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
                      fontSize: 15,
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
                        fontSize: 14,
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
                                  const Icon(
                                    Icons.mic,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Tap To Talk",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
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
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    color: Color(0xFFFFD700),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Text To Chat",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
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