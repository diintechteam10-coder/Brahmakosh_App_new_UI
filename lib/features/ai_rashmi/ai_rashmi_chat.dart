import 'package:brahmakosh/core/common_imports.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../agent/lemon_agent_page.dart';
import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';
import 'voice_agent_service.dart';
import 'package:lottie/lottie.dart';
import '../../core/services/storage_service.dart';
import '../../core/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:brahmakosh/common/utils.dart'; // Added

import 'deity_selection_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

import 'krishna_category_selection_view.dart';
import 'rashmi_category_selection_view.dart'; // New Import
import 'widgets/deity_selection_widget.dart'; // New Import
import 'widgets/neon_voice_ring.dart';
import '../gita/views/gita_chapter_screen.dart';

class RashmiChat extends StatelessWidget {
  final String? backgroundImage;
  final bool hideLearnGita;
  final bool autoStartVoice;
  final String? initialMessage;
  final bool autoAsk;
  final String? deityName;
  const RashmiChat({
    super.key,
    this.backgroundImage,
    this.hideLearnGita = false,
    this.autoStartVoice = false,
    this.initialMessage,
    this.autoAsk = false,
    this.deityName,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<AiRashmiController>()) {
      Get.put(AiRashmiController(service: AiRashmiService()));
    }
    return _RashmiChatView(
      backgroundImage: backgroundImage,
      hideLearnGita: hideLearnGita,
      autoStartVoice: autoStartVoice,
      initialMessage: initialMessage,
      autoAsk: autoAsk,
      deityName: deityName,
    );
  }
}

class _RashmiChatView extends StatefulWidget {
  final String? backgroundImage;
  final bool hideLearnGita;
  final bool autoStartVoice;
  final String? initialMessage;
  final bool autoAsk;
  final String? deityName;
  const _RashmiChatView({
    this.backgroundImage,
    this.hideLearnGita = false,
    this.autoStartVoice = false,
    this.initialMessage,
    this.autoAsk = false,
    this.deityName,
  });

  @override
  State<_RashmiChatView> createState() => _RashmiChatViewState();
}

class _RashmiChatViewState extends State<_RashmiChatView> {
  // late VideoPlayerController _vicontroller;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeitySelectionService _deityService = DeitySelectionService();
  bool _isDeitySelectionOpen = false; // Toggle state
  final VoiceAgentService _voiceService = VoiceAgentService();

  @override
  void initState() {
    super.initState();
    _voiceService.addListener(() {
      if (_voiceService.interimText.isNotEmpty &&
          _voiceService.state == VoiceAgentState.LISTENING) {
        _controller.text = _voiceService.interimText;
      }
      setState(() {});
    });

    _voiceService.onChatCreated = (String chatId) {
      if (Get.isRegistered<AiRashmiController>()) {
        final vm = Get.find<AiRashmiController>();
        if (vm.chatId == null) {
          vm.chatId = chatId;
          vm.loadHistory(); // Reload history so the sidebar updates
        }
      }
    };

    _voiceService.onUserMessage = (String text) {
      if (Get.isRegistered<AiRashmiController>()) {
        final vm = Get.find<AiRashmiController>();
        vm.messages.add(Message(role: 'user', content: text));
        vm.update();
      }
    };

    _voiceService.onAiResponse = (String text) {
      if (Get.isRegistered<AiRashmiController>()) {
        final vm = Get.find<AiRashmiController>();
        vm.messages.add(Message(role: 'assistant', content: text));
        vm.loadHistory(); // Refresh latest message preview
        vm.update();
      }
    };

    // Always start with a fresh chat when this page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<AiRashmiController>()) {
        final vm = Get.find<AiRashmiController>();
        vm.newChat();
        vm.addListener(_scrollToBottom);
      }

      if (widget.autoStartVoice) {
        _toggleVoiceChat();
      }

      if (widget.autoAsk && widget.initialMessage != null) {
        if (Get.isRegistered<AiRashmiController>()) {
          final vm = Get.find<AiRashmiController>();
          vm.sendMessage(widget.initialMessage!);
        }
      } else if (widget.initialMessage != null) {
        _controller.text = widget.initialMessage!;
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    if (Get.isRegistered<AiRashmiController>()) {
      Get.find<AiRashmiController>().removeListener(_scrollToBottom);
    }
    _voiceService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleVoiceChat() async {
    if (_voiceService.state == VoiceAgentState.IDLE ||
        _voiceService.state == VoiceAgentState.ERROR) {
      final userId =
          StorageService.getString(AppConstants.keyUserId) ?? 'default_user';
      final vm = Get.find<AiRashmiController>();

      if (vm.chatId == null) {
        try {
          vm.chatId = await vm.service.createChat(title: "Voice Chat");
          await vm.loadHistory();
        } catch (e) {
          debugPrint("Failed to pre-create voice chat: $e");
        }
      }

      _voiceService.startSession(userId, chatId: vm.chatId);
      _showVoiceOverlay();
    } else {
      _voiceService.stopSession();
    }
  }

  void _showVoiceOverlay() {
    Navigator.of(context)
        .push(
          PageRouteBuilder(
            opaque: false, // Allows background to show through if needed
            barrierDismissible: false,
            transitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (BuildContext context, _, __) {
              return _FullScreenVoiceOverlay(voiceService: _voiceService);
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        )
        .then((_) {
          // Cleanup when closed
          _voiceService.stopSession();
        });
  }

  Widget _buildMicButton() {
    IconData icon = Icons.mic_none;
    Color bgColor = Colors.transparent;
    Color iconColor = Colors.grey.shade500;

    switch (_voiceService.state) {
      case VoiceAgentState.IDLE:
      case VoiceAgentState.ERROR:
        icon = Icons.mic_none;
        break;
      case VoiceAgentState.CONNECTING:
        icon = Icons.hourglass_empty;
        iconColor = Colors.orange;
        break;
      case VoiceAgentState.LISTENING:
        icon = Icons.mic;
        bgColor = Colors.red.withOpacity(0.1);
        iconColor = Colors.red;
        break;
      case VoiceAgentState.PROCESSING:
        icon = Icons.more_horiz;
        bgColor = Colors.orange.withOpacity(0.1);
        iconColor = Colors.orange;
        break;
      case VoiceAgentState.SPEAKING:
        icon = Icons.volume_up;
        bgColor = Colors.green.withOpacity(0.1);
        iconColor = Colors.green;
        break;
    }

    return GestureDetector(
      onTap: _toggleVoiceChat,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Icon(icon, color: iconColor, size: 5.w),
      ),
    );
  }

  void _handleDeitySelection(String deityName) async {
    try {
      // Logic to find and switch deity
      if (!Get.isRegistered<AgentController>()) {
        Get.put(AgentController());
      }
      final agentController = Get.find<AgentController>();
      if (agentController.avatars.isEmpty) {
        await agentController.fetchAvatars(null);
      }

      // Find target deity
      final targetDeity = agentController.avatars.firstWhereOrNull(
        (a) => (a.name ?? '').toLowerCase().contains(deityName.toLowerCase()),
      );

      if (targetDeity != null) {
        _deityService.setSelectedDeity(targetDeity);
      }

      setState(() {
        _isDeitySelectionOpen = false;
      });
      // Switching context usually implies restarting or refreshing the chat view.
      final vm = Get.find<AiRashmiController>();
      await vm.newChat();

      // Navigate to the same screen with the new configuration to mimic Home Screen behavior
      Get.off(
        () => RashmiChat(
          backgroundImage: 'assets/icons/chat_bg_new.png',
          deityName: deityName,
        ),
        preventDuplicates: false,
      );
    } catch (e) {
      debugPrint("Error in deity selection: $e");
      // Fallback navigation even if logic fails
      Get.off(
        () => RashmiChat(
          backgroundImage: 'assets/icons/chat_bg_new.png',
          deityName: deityName,
        ),
        preventDuplicates: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiRashmiController>(
      builder: (vm) {
        final theme = Theme.of(context);
        final String currentDeityName = (widget.deityName ?? 
                                         (_deityService.selectedDeity?.name ?? 'Krishna'));
        final bool isRashmiChat = currentDeityName.toLowerCase().contains('rashmi');
        final bool isKrishnaChat = !isRashmiChat; // Everything else defaults to Krishna
        
        final String displayDeityName = isRashmiChat ? 'Rashmi' : 'Krishna';
        final String deityImageAsset = isRashmiChat ? 'assets/icons/rashmi_new_avatar.png' : 'assets/images/Small_krishna.png';
        final String hintText = isRashmiChat ? 'Ask Rashmi anything' : 'Ask Krishna anything';

        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(vm),
          body: Stack(
            children: [
              Builder(
                builder: (context) {
                  String? currentBg = widget.backgroundImage;
                  // Use the premium new chat background for both Krishna and Rashmi
                  if (isKrishnaChat || isRashmiChat) {
                    currentBg = 'assets/icons/chat_bg_new.png';
                  } else if (vm.messages.isNotEmpty) {
                    currentBg = 'assets/images/Chat_background.png';
                  }
                  
                  if (currentBg != null) {
                    return Positioned.fill(
                      child: Image.asset(currentBg, fit: BoxFit.cover),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),

              // Dark overlay for Rashmi chat (kept subtle)
              if (isRashmiChat)
                Positioned.fill(
                  child: Container(color: Colors.black.withOpacity(0.15)),
                ),

              // Character overlay (Krishna/Rashmi)
              if (isKrishnaChat || isRashmiChat)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Image.asset(
                      isKrishnaChat 
                        ? 'assets/icons/krishna_neww.png' 
                        : 'assets/icons/Rashmi_new_chat.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Main UI Content
              Column(
                children: [
                   SizedBox(height: 12.h), // Spacing for header
                  Expanded(
                    child: vm.messages.isEmpty
                        ? (isKrishnaChat
                              ? _buildKrishnaEmptyState(context, vm, theme, displayDeityName, hintText)
                              : _buildRashmiEmptyState(context, vm, theme, displayDeityName, hintText))
                        : ListView.builder(
                            controller: _scrollController,
                             padding: EdgeInsets.symmetric(
                               horizontal: 3.w,
                               vertical: 2.h,
                             ),
                            itemCount:
                                vm.messages.length + (vm.isSending ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (vm.isSending && index == vm.messages.length) {
                                return _buildTypingIndicator(context);
                              }
                              final msg = vm.messages[index];
                              return _buildMessageBubble(context, msg, theme);
                            },
                          ),
                  ),
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
                      child: _buildInputArea(context, vm, theme, deityName: displayDeityName, hintText: hintText),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),

              // Custom Header
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.5.w,
                      vertical: 1.h,
                    ),
                    child: _buildHeader(context, displayDeityName, deityImageAsset),
                  ),
                ),
              ),

              // Deity Selection Overlay
              if (_isDeitySelectionOpen)
                Positioned(
                  top:
                      100, // Just below the header (adjust based on header height)
                  left: 16,
                  right: 16,
                  child: DeitySelectionWidget(
                    onSelectKrishna: () => _handleDeitySelection('Krishna'),
                    onSelectRashmi: () => _handleDeitySelection('Rashmi'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(
    BuildContext context,
    AiRashmiController vm,
    ThemeData theme, {
    required String deityName,
    required String hintText,
  }) {

    // Check if chat has started (messages exist) to hide FAQs
    final bool hasMessages = vm.messages.isNotEmpty;

    // Professional, responsive input area
    if (hasMessages) {
      // Compact inline input during active chat
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 1.5.w, vertical: 0.75.h),
        decoration: BoxDecoration(
          color: const Color(0xFF18151B).withOpacity(0.9),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 10,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.4,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.transparent,
                  focusColor: Colors.transparent,

                  hintText: 'Send message...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 1.25.h,
                    horizontal: 3.w,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _buildMicButton(),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: GestureDetector(
                onTap: vm.isSending
                    ? null
                    : () async {
                        final text = _controller.text;
                        if (text.trim().isNotEmpty) {
                          _controller.clear();
                          await vm.sendMessage(text);
                        }
                      },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(2.5.w),
                  decoration: BoxDecoration(
                    color: vm.isSending
                        ? Colors.grey.shade800
                        : const Color(0xFFF1C453),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vm.isSending
                        ? Icons.hourglass_top_rounded
                        : Icons.play_arrow_rounded,
                    color: vm.isSending ? Colors.grey.shade400 : Colors.black,
                    size: 5.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Expanded input for empty state (first message)
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF18151B).withOpacity(0.9), // Dark color
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFF100E13,
              ).withOpacity(0.6), // Darker text field
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                height: 1.4,
              ),
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                filled: true,
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
              ),
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  _controller.clear();
                  await vm.sendMessage(value);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.description_outlined,
                      size: 4.w,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "FAQ's",
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 4.5.w,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildMicButton(),
              const Spacer(),
              GestureDetector(
                onTap: vm.isSending
                    ? null
                    : () async {
                        final text = _controller.text;
                        if (text.trim().isNotEmpty) {
                          _controller.clear();
                          await vm.sendMessage(text);
                        }
                      },
                child: Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1C453), // Yellow color from screenshot
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow_rounded, // Play icon
                    color: Colors.black,
                    size: 6.w,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String deityName, String imageAsset) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(1.5.w), // Reduced from 8
                decoration: BoxDecoration(
                  color: const Color(0xffFFFFFF).withOpacity(0.1), // Off-white
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.menu,
                  color: const Color(0xFFFFF8E7),
                  size: 4.5.w,
                ), // Reduced from 20
              ),
              // const SizedBox(width: 8),
              // // TEST BUTTON FOR BOSS
              // GestureDetector(
              //   onTap: () => Utils.showInsufficientCreditsDialog(),
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              //     decoration: BoxDecoration(
              //       color: Colors.red.withOpacity(0.2),
              //       borderRadius: BorderRadius.circular(12),
              //       border: Border.all(color: Colors.red.withOpacity(0.5)),
              //     ),
              //     child: Text(
              //       "Show Alert",
              //       style: TextStyle(fontSize: 8.sp, color: Colors.white),
              //     ),
              //   ),
              // ),
          
            ],
          ),
        ),

        // Center "Krishna" Button/Dropdown with Toggle
        Container(
          height: 4.5.h, // Reduced from 40
          padding: EdgeInsets.symmetric(
            horizontal: 2.5.w,
          ), // Reduced from 12
          decoration: BoxDecoration(
            color: const Color(0xFF18151B), // Off-white
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isDeitySelectionOpen = !_isDeitySelectionOpen;
                });
              },
              child: Row(
                children: [
                  // Small Avatar Image
                  Container(
                    width: 6.w, // Reduced from 28
                    height: 6.w, // Reduced from 28
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(imageAsset),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    deityName,
                    style: GoogleFonts.lora(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 9.sp, // Reduced from 14
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isDeitySelectionOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.orange.shade800,
                    size: 4.5.w, // Reduced from 20
                  ),
                ],
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Container(
            padding: EdgeInsets.all(1.5.w), // Reduced from 8
            decoration: BoxDecoration(
              color: const Color(0xffFFFFFF).withOpacity(0.1), // Off-white
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 4.w, // Reduced from 18
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKrishnaEmptyState(
    BuildContext context,
    AiRashmiController vm,
    ThemeData theme,
    String deityName,
    String hintText,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The main image is already in background, so we just add the card overlays
            SizedBox(
              height: 39.h,
            ), // Push cards down

            if (!widget.hideLearnGita)
              _buildKrishnaOptionCard(
                context,
                "Learn Gita Shloaks",
                "Get the meaning from Gita Shloak",
                Icons.auto_awesome,
                Colors.orange,
                () {
                  Get.to(() => const GitaChapterScreen());
                },
              ),
            if (!widget.hideLearnGita) const SizedBox(height: 12),
            _buildKrishnaOptionCard(
              context,
              "Ask Doubt",
              "Ask Your life's questions from Krishna", // Text from design seems repetitive, keeping as is or generic
              Icons.auto_awesome,
              Colors.orange,
              () {
                Get.to(
                  () => KrishnaCategorySelectionView(
                    vm: vm,
                    inputAreaBuilder: (ctx, controller) => _buildInputArea(
                      ctx,
                      controller,
                      theme,
                      deityName: deityName,
                      hintText: hintText,
                    ),
                    onSwitchDeity: (deityName) async {
                      // Switching context usually implies restarting or refreshing the chat view.
                      final vm = Get.find<AiRashmiController>();
                      await vm.newChat();

                      // Navigate to the same screen with the new configuration to mimic Home Screen behavior
                      Get.off(
                        () => RashmiChat(
                          backgroundImage: 'assets/icons/chat_bg_new.png',
                          deityName: deityName,
                        ),
                        preventDuplicates: false,
                      );
                    },
                  ),
                );
              },
            ),
            // The static "Krishna is my dharma..." card was here, but we removed it because it's now the input field
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRashmiEmptyState(
    BuildContext context,
    AiRashmiController vm,
    ThemeData theme,
    String deityName,
    String hintText,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The main image is already in background, so we just add the card overlays
            SizedBox(
              height: 50.h,
            ), // Push cards down

            _buildKrishnaOptionCard(
              context,
              "Ask Rashmi", // Or "Chat with Rashmi"
              "Talk to your AI companion",
              Icons.chat_bubble_outline,
              Colors.orange, // Icon color could be different if desired
              () {
                Get.to(
                  () => RashmiCategorySelectionView(
                    vm: vm,
                    inputAreaBuilder: (ctx, controller) => _buildInputArea(
                      ctx,
                      controller,
                      theme,
                      deityName: deityName,
                      hintText: hintText,
                    ),
                    onSwitchDeity: (deityName) async {
                      // Switching context usually implies restarting or refreshing the chat view.
                      final vm = Get.find<AiRashmiController>();
                      await vm.newChat();

                      // Navigate to the same screen with the new configuration to mimic Home Screen behavior
                      Get.off(
                        () => RashmiChat(
                          backgroundImage: 'assets/icons/chat_bg_new.png',
                          deityName: deityName,
                        ),
                        preventDuplicates: false,
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildKrishnaOptionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFF18151B).withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Icon(icon, color: const Color(0xFFF1C453), size: 6.w)],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    // Simplified typing indicator reused or simplified
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: const TypingIndicator(),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message msg,
    ThemeData theme,
  ) {
    final isUser = msg.role == 'user';
    final bubbleColor = isUser
        ? const Color.fromARGB(255, 255, 199, 193)
        : Color(0xff705500);
    final textColor = Colors.white;
    final radius = BorderRadius.only(
      topLeft: Radius.circular(4.5.w),
      topRight: Radius.circular(4.5.w),
      bottomLeft: Radius.circular(isUser ? 4.5.w : 1.w),
      bottomRight: Radius.circular(isUser ? 1.w : 4.5.w),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 75.w,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.25.h),
              child: isUser
                  ? Text(
                      msg.content,
                      style: TextStyle(color: textColor, height: 1.4),
                    )
                  : MarkdownBody(
                      data: msg.content,
                      selectable: true,
                      shrinkWrap: true,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.poppins(
                          color: textColor,
                          height: 1.4,
                          fontSize: 10.5.sp,
                        ),
                        strong: GoogleFonts.poppins(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5.sp,
                        ),
                        h1: GoogleFonts.lora(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                        ),
                        h2: GoogleFonts.lora(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5.sp,
                        ),
                        h3: GoogleFonts.lora(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                         listBullet: GoogleFonts.poppins(color: textColor, fontSize: 10.5.sp),
                        blockSpacing: 8,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Drawer _buildDrawer(AiRashmiController vm) {
    String deityName = 'Krishna';
    String imageAsset = 'assets/images/Small_krishna.png';

    if (_deityService.selectedDeity != null) {
      final name = _deityService.selectedDeity!.name ?? '';
      if (name.toLowerCase().contains('rashmi')) {
        deityName = 'Rashmi';
        imageAsset = 'assets/images/Small_rashmi.png';
      } else if (name.toLowerCase().contains('krishna')) {
        deityName = 'Krishna';
        imageAsset = 'assets/images/Small_krishna.png';
      }
    }

    // Check widget config for explicit override
    if (widget.backgroundImage?.toLowerCase().contains('rashmi') == true) {
      deityName = 'Rashmi';
      imageAsset = 'assets/images/Small_rashmi.png';
    } else if (widget.backgroundImage?.toLowerCase().contains('krishna') == true) {
      deityName = 'Krishna';
      imageAsset = 'assets/images/Small_krishna.png';
    }

    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(5.w, 6.h, 5.w, 2.5.h),
            decoration: const BoxDecoration(
              color: Color(0xFF18151B), // Dark theme header
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 6.w,
                      backgroundImage: AssetImage(imageAsset),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      deityName,
                      style: GoogleFonts.lora(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Updated for dark theme
                      ),
                    ),
                    Text(
                      'Powered By BI',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5.sp,
                        color: Colors.white70,
                      ), // Updated
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close drawer
                      Get.to(() => AvatarAgentPage());
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1), // Updated
                        borderRadius: BorderRadius.circular(5.w),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.08),
                        ), // Updated
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Icon(
                            Icons.swap_horiz,
                            size: 4.w,
                            color: Colors.white, // Updated
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Avatar",
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Updated
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

          Expanded(
            child: Container(
              color: const Color(0xFF100E13), // Darker background for body
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Chat Button
                  Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Material(
                      color: const Color(0xFF18151B), // Dark theme
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          Get.back();
                          await vm.newChat();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: const Color(0xFFF1C453),
                              ), // Yellow icon
                              const SizedBox(width: 12),
                              Text(
                                'New Chat',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white, // White text
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                    child:                    Text(
                      'HISTORY',
                      style: GoogleFonts.lora(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Chat History List
                  if (vm.isLoadingHistory)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (vm.history.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(5.w),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 12.w,
                              color: Colors.grey[300],
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              'No chat history',
                              style: TextStyle(color: Colors.grey[500], fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: vm.history.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 1), // Reduced height from 4
                        itemBuilder: (context, index) {
                          final chat = vm.history[index];
                          final isSelected = chat.chatId == vm.chatId;

                          return Material(
                            color: isSelected
                                ? const Color(0xFF18151B) // Dark selected bg
                                : Colors.transparent,
                            elevation: isSelected ? 2 : 0,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              dense: true, // Reduces vertical height
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 0,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: 0,
                                vertical: -4,
                              ), // Further compact
                              leading: Container(
                                padding: EdgeInsets.all(1.5.w), // Reduced from 8
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFF1C453).withOpacity(
                                          0.2,
                                        ) // Yellow tinted bg
                                      : const Color(0xFF18151B), // Dark box bg
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  chat.title.toLowerCase().contains('voice')
                                      ? Icons.mic
                                      : Icons.chat_bubble_outline,
                                  size: 4.w, // Reduced from 18
                                  color: isSelected
                                      ? const Color(
                                          0xFFF1C453,
                                        ) // Yellow icon when selected
                                      : Colors.grey[500],
                                ),
                              ),
                                title: Text(
                                  chat.title,
                                  style: GoogleFonts.lora(
                                    fontSize: 9.75.sp, // Reduced size
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.grey[400],
                                  ),
                                ),
                                subtitle: Text(
                                  chat.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 8.25.sp, // Reduced from 12
                                    color: Colors.grey[600],
                                  ),
                                ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: isSelected
                                    ? BorderSide(
                                        color: Colors.white.withOpacity(0.08),
                                      )
                                    : BorderSide.none,
                              ),
                              onTap: () async {
                                Get.back();
                                await vm.selectChat(chat);
                              },
                            ),
                          );
                        },
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

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(3, (index) {
      return AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
    });

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
    }).toList();

    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -1.h * _animations[index].value),
                  child: Container(
                    width: 1.5.w,
                    height: 1.5.w,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(
                        0.6 + (0.4 * _animations[index].value),
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

class _FullScreenVoiceOverlay extends StatefulWidget {
  final VoiceAgentService voiceService;

  const _FullScreenVoiceOverlay({Key? key, required this.voiceService})
    : super(key: key);

  @override
  State<_FullScreenVoiceOverlay> createState() =>
      _FullScreenVoiceOverlayState();
}

class _FullScreenVoiceOverlayState extends State<_FullScreenVoiceOverlay> {
  Timer? _timer;
  int _seconds = 0;
  VoiceAgentState? _previousState;

  @override
  void initState() {
    super.initState();
    widget.voiceService.addListener(_onVoiceStateChanged);
    _onVoiceStateChanged(); // Check initial state
  }

  @override
  void dispose() {
    widget.voiceService.removeListener(_onVoiceStateChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _onVoiceStateChanged() {
    final currentState = widget.voiceService.state;
    if (currentState != _previousState) {
      if (currentState == VoiceAgentState.LISTENING ||
          currentState == VoiceAgentState.PROCESSING ||
          currentState == VoiceAgentState.SPEAKING) {
        _startTimer();
      } else {
        _stopTimer();
      }
      _previousState = currentState;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _seconds = 0;
      });
    }
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Static Aura Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF2A1B38), // Deep purple core
                  Color(0xFF1E1E1E), // Dark exterior
                ],
                radius: 0.8,
              ),
            ),
          ),

          SafeArea(
            child: ListenableBuilder(
              listenable: widget.voiceService,
              builder: (context, child) {
                String title = "Connecting...";
                IconData currentActionIcon = Icons.mic_none;
                Color actionColor = Colors.grey;
                bool isProcessingOrSpeaking = false;

                switch (widget.voiceService.state) {
                  case VoiceAgentState.IDLE:
                  case VoiceAgentState.ERROR:
                    title = "Disconnected";
                    break;
                  case VoiceAgentState.CONNECTING:
                    title = "Connecting...";
                    actionColor = Colors.orange;
                    currentActionIcon = Icons.hourglass_empty;
                    break;
                  case VoiceAgentState.LISTENING:
                    title = _formattedTime;
                    actionColor = Colors.redAccent;
                    currentActionIcon = Icons.fiber_manual_record;
                    break;
                  case VoiceAgentState.PROCESSING:
                    title = _formattedTime;
                    isProcessingOrSpeaking = true;
                    actionColor = Colors.orangeAccent;
                    currentActionIcon = Icons.more_horiz;
                    break;
                  case VoiceAgentState.SPEAKING:
                    title = _formattedTime;
                    isProcessingOrSpeaking = true;
                    actionColor = Colors.greenAccent;
                    currentActionIcon = Icons.volume_up;
                    break;
                }

                return Stack(
                  children: [
                    // Neon Voice Ring Animation Background (Centered)
                    Positioned.fill(
                      child: NeonVoiceRing(
                        isListening:
                            widget.voiceService.state ==
                            VoiceAgentState.LISTENING,
                        isSpeaking:
                            widget.voiceService.state ==
                            VoiceAgentState.SPEAKING,
                      ),
                    ),
                    Column(
                      children: [
                        // Top App Bar Area
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.5.h,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 48), // Balance
                              Text(
                                "",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              // GestureDetector(
                              //   behavior: HitTestBehavior.opaque,
                              //   onTap: () => _showVoiceSettingsSheet(context),
                              //   child: Container(
                              //     padding: EdgeInsets.all(2.w),
                              //     decoration: BoxDecoration(
                              //       color: Colors.white.withOpacity(0.1),
                              //       shape: BoxShape.circle,
                              //     ),
                              //     child: Icon(
                              //       Icons.settings,
                              //       color: Colors.white,
                              //       size: 6.w,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Status and Lottie Waves
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Status Title
                              Text(
                                title,
                                style: TextStyle(
                                  color: actionColor,
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(height: 4.h),

                              // Lottie Waves
                              if (widget.voiceService.state ==
                                  VoiceAgentState.LISTENING)
                                Lottie.asset(
                                  'assets/lotties/listening_waves.json',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(height: 120),
                                )
                              else if (widget.voiceService.state ==
                                      VoiceAgentState.PROCESSING ||
                                  widget.voiceService.state ==
                                      VoiceAgentState.CONNECTING)
                                const SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white70,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                )
                              else if (widget.voiceService.state ==
                                  VoiceAgentState.SPEAKING)
                                Lottie.asset(
                                  'assets/lotties/speaking_waves.json',
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox(height: 120),
                                )
                              else
                                const SizedBox(height: 120),
                            ],
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Live Transcription / AI Text
                        // Expanded(
                        //   child: Container(
                        //     padding: const EdgeInsets.symmetric(horizontal: 32),
                        //     alignment: Alignment.topCenter,
                        //     child: SingleChildScrollView(
                        //       physics: const BouncingScrollPhysics(),
                        //       padding: const EdgeInsets.only(bottom: 20),
                        //       child: AnimatedSwitcher(
                        //         duration: const Duration(milliseconds: 300),
                        //         child: Text(
                        //           isProcessingOrSpeaking
                        //               ? widget.voiceService.aiText
                        //               : widget.voiceService.interimText.isEmpty
                        //               ? "How can I help you today?"
                        //               : widget.voiceService.interimText,
                        //           key: ValueKey<String>(
                        //             isProcessingOrSpeaking
                        //                 ? widget.voiceService.aiText
                        //                 : widget.voiceService.interimText,
                        //           ),
                        //           textAlign: TextAlign.center,
                        //           style: const TextStyle(
                        //             color: Colors.white,
                        //             fontSize: 26,
                        //             fontWeight: FontWeight.w300,
                        //             height: 1.3,
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const Spacer(),

                        // Bottom Action Button
                        Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              widget.voiceService.stopSession();
                              Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(
                                color: actionColor.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: actionColor.withOpacity(0.5),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: actionColor.withOpacity(0.2),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                currentActionIcon == Icons.fiber_manual_record
                                    ? Icons.stop
                                    : Icons.close,
                                color: actionColor,
                                size: 9.w,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // void _showVoiceSettingsSheet(BuildContext context) {
  //   // List of available voices - adjust IDs based on your backend expectations
  //   final voices = [
  //     {'id': 'voice_1', 'name': 'Rashmi (Female 1)'},
  //     {'id': 'voice_2', 'name': 'Priya (Female 2)'},
  //     {'id': 'voice_3', 'name': 'Krishna (Male 1)'},
  //     {'id': 'voice_4', 'name': 'Arjun (Male 2)'},
  //   ];

  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     builder: (BuildContext sheetContext) {
  //       return Container(
  //         padding: EdgeInsets.all(6.w),
  //         decoration: BoxDecoration(
  //           color: const Color(0xFFFFE0B2), // Match other modals
  //           borderRadius: BorderRadius.vertical(top: Radius.circular(6.w)),
  //         ),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               "Voice Settings",
  //               style: GoogleFonts.lora(
  //                 fontSize: 15.sp,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black87,
  //               ),
  //             ),
  //             const SizedBox(height: 8),
  //             Text(
  //               "Select your preferred AI voice:",
  //               style: GoogleFonts.poppins(fontSize: 10.5.sp, color: Colors.black54),
  //             ),
  //             const SizedBox(height: 20),
  //             ...voices.map((voice) {
  //               // Get the currently saved voice (default to voice_1)
  //               final currentVoice =
  //                   StorageService.getString('ai_selected_voice') ?? 'voice_1';
  //               final isSelected = currentVoice == voice['id'];

  //               return Padding(
  //                 padding: const EdgeInsets.only(bottom: 12),
  //                 child: InkWell(
  //                   onTap: () {
  //                     StorageService.setString(
  //                       'ai_selected_voice',
  //                       voice['id']!,
  //                     );
  //                     Navigator.pop(sheetContext);
  //                     Get.snackbar(
  //                       "Voice Changed",
  //                       "Switched to ${voice['name']}. Reconnect to apply.",
  //                       snackPosition: SnackPosition.TOP,
  //                       backgroundColor: const Color(0xFFA67C00),
  //                       colorText: Colors.white,
  //                       duration: const Duration(seconds: 2),
  //                     );
  //                   },
  //                   borderRadius: BorderRadius.circular(12),
  //                   child: Container(
  //                     padding: EdgeInsets.all(4.w),
  //                     decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? Colors.white
  //                           : Colors.white.withOpacity(0.5),
  //                       border: Border.all(
  //                         color: isSelected
  //                             ? const Color(0xFFA67C00)
  //                             : Colors.transparent,
  //                         width: isSelected ? 2 : 1,
  //                       ),
  //                       borderRadius: BorderRadius.circular(12),
  //                     ),
  //                     child: Row(
  //                       children: [
  //                         Icon(
  //                           Icons.record_voice_over,
  //                           color: isSelected
  //                               ? const Color(0xFFA67C00)
  //                               : Colors.black54,
  //                         ),
  //                         const SizedBox(width: 16),
  //                         Expanded(
  //                           child: Text(
  //                             voice['name']!,
  //                             style: GoogleFonts.poppins(
  //                               fontSize: 12.sp,
  //                               fontWeight: isSelected
  //                                   ? FontWeight.bold
  //                                   : FontWeight.normal,
  //                               color: isSelected
  //                                   ? const Color(0xFFA67C00)
  //                                   : Colors.black87,
  //                             ),
  //                           ),
  //                         ),
  //                         if (isSelected)
  //                           const Icon(
  //                             Icons.check_circle,
  //                             color: Color(0xFFA67C00),
  //                           ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             }).toList(),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

}

