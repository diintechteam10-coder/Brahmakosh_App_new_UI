import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';

import 'deity_selection_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';

import 'krishna_category_selection_view.dart';
import 'rashmi_category_selection_view.dart'; // New Import
import 'widgets/deity_selection_widget.dart'; // New Import
import '../gita/views/gita_chapter_screen.dart';

class RashmiChat extends StatelessWidget {
  final String? backgroundImage;
  const RashmiChat({super.key, this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<AiRashmiController>()) {
      Get.put(AiRashmiController(service: AiRashmiService()));
    }
    return _RashmiChatView(backgroundImage: backgroundImage);
  }
}

class _RashmiChatView extends StatefulWidget {
  final String? backgroundImage;
  const _RashmiChatView({this.backgroundImage});

  @override
  State<_RashmiChatView> createState() => _RashmiChatViewState();
}

class _RashmiChatViewState extends State<_RashmiChatView> {
  // late VideoPlayerController _vicontroller;
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final DeitySelectionService _deityService = DeitySelectionService();
  bool _isDeitySelectionOpen = false; // Toggle state

  @override
  void initState() {
    super.initState();
    // ... (video init code commented out)
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
          backgroundImage: deityName == 'Krishna'
              ? 'assets/images/Krishna_chat.png'
              : 'assets/images/Rashmi_chat.png',
        ),
        preventDuplicates: false,
      );
    } catch (e) {
      debugPrint("Error in deity selection: $e");
      // Fallback navigation even if logic fails
      Get.off(
        () => RashmiChat(
          backgroundImage: deityName == 'Krishna'
              ? 'assets/images/Krishna_chat.png'
              : 'assets/images/Rashmi_chat.png',
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
        final isKrishnaChat =
            widget.backgroundImage?.contains('Krishna') ?? false;

        return Scaffold(
          key: _scaffoldKey,
          drawer: _buildDrawer(vm),
          body: Stack(
            children: [
              Builder(
                builder: (context) {
                  String? currentBg = widget.backgroundImage;
                  if (vm.messages.isNotEmpty && !isKrishnaChat) {
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

              // Dark overlay
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              // Main UI Content
              Column(
                children: [
                  const SizedBox(height: 110), // Spacing for header
                  Expanded(
                    child: vm.messages.isEmpty
                        ? (isKrishnaChat
                              ? _buildKrishnaEmptyState(context, vm, theme)
                              : _buildRashmiEmptyState(context, vm, theme))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
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
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: _buildInputArea(context, vm, theme),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 1.0,
                    ),
                    child: _buildHeader(context),
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
    String? explicitDeityName,
  }) {
    // Determine the current deity name for hint text
    String deityName = explicitDeityName ?? 'Krishna';

    if (explicitDeityName == null) {
      // Check widget config for default
      if (widget.backgroundImage?.contains('Rashmi') == true) {
        deityName = 'Rashmi';
      }
      // Check selected deity or fallback
      if (_deityService.selectedDeity != null) {
        final name = _deityService.selectedDeity!.name ?? '';
        if (name.toLowerCase().contains('rashmi')) {
          deityName = 'Rashmi';
        } else if (name.toLowerCase().contains('krishna')) {
          deityName = 'Krishna';
        }
      }
    }

    // Check if chat has started (messages exist) to hide FAQs
    final bool hasMessages = vm.messages.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            minLines: 1,
            maxLines: 4,
            style: const TextStyle(
              fontSize: 12, // Reduced from 16
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.0,
            ),
            decoration: InputDecoration(
              hintText: hasMessages ? 'Send message...' : 'Ask $deityName',
              hintStyle: const TextStyle(color: Colors.black54),
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              isDense: true,
            ),
            onSubmitted: (value) async {
              if (value.trim().isNotEmpty) {
                _controller.clear();
                await vm.sendMessage(value);
              }
            },
          ),

          if (!hasMessages) const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!hasMessages)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Reduced from 16
                          vertical: 4, // Reduced from 8
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description_outlined,
                              size: 14, // Reduced from 16
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "FAQ's",
                              style: TextStyle(
                                fontSize: 12, // Reduced from 13
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16, // Reduced from 18
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
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
                  padding: const EdgeInsets.all(8), // Reduced from 10
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 20, // Reduced from 24
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Determine the current deity name and image logic
    String deityName = 'Krishna';
    String imageAsset = 'assets/images/Small_krishna.png';

    // Check widget config for default
    if (widget.backgroundImage?.contains('Rashmi') == true) {
      deityName = 'Rashmi';
      imageAsset = 'assets/images/Small_rashmi.png';
    }

    // Check selected deity or fallback
    if (_deityService.selectedDeity != null) {
      final name = _deityService.selectedDeity!.name ?? '';
      if (name.toLowerCase().contains('rashmi')) {
        deityName = 'Rashmi';
        imageAsset = 'assets/images/Small_rashmi.png';
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Container(
            padding: const EdgeInsets.all(6), // Reduced from 8
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7), // Off-white
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.menu,
              color: Colors.black,
              size: 18,
            ), // Reduced from 20
          ),
        ),

        // Center "Krishna" Button/Dropdown with Toggle
        Container(
          height: 36, // Reduced from 40
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ), // Reduced from 12
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E7), // Off-white
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
                    width: 24, // Reduced from 28
                    height: 24, // Reduced from 28
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
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 12, // Reduced from 14
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    _isDeitySelectionOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.orange.shade800,
                    size: 18, // Reduced from 20
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
            padding: const EdgeInsets.all(6), // Reduced from 8
            decoration: const BoxDecoration(
              color: Color(0xFFFFF8E7), // Off-white
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.close,
              color: Colors.black,
              size: 16, // Reduced from 18
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
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The main image is already in background, so we just add the card overlays
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.40,
            ), // Push cards down

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
            const SizedBox(height: 12),
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
                      explicitDeityName: 'Krishna',
                    ),
                    onSwitchDeity: (deityName) async {
                      // Switching context usually implies restarting or refreshing the chat view.
                      final vm = Get.find<AiRashmiController>();
                      await vm.newChat();

                      // Navigate to the same screen with the new configuration to mimic Home Screen behavior
                      Get.off(
                        () => RashmiChat(
                          backgroundImage: deityName == 'Krishna'
                              ? 'assets/images/Krishna_chat.png'
                              : 'assets/images/Rashmi_chat.png',
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
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // The main image is already in background, so we just add the card overlays
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.50,
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
                      explicitDeityName: 'Rashmi',
                    ),
                    onSwitchDeity: (deityName) async {
                      // Switching context usually implies restarting or refreshing the chat view.
                      final vm = Get.find<AiRashmiController>();
                      await vm.newChat();

                      // Navigate to the same screen with the new configuration to mimic Home Screen behavior
                      Get.off(
                        () => RashmiChat(
                          backgroundImage: deityName == 'Krishna'
                              ? 'assets/images/Krishna_chat.png'
                              : 'assets/images/Rashmi_chat.png',
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFBE6D0),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Icon(icon, color: iconColor, size: 22)],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.black, size: 12),
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
        : Colors.white;
    final textColor = Colors.black87;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                msg.content,
                style: TextStyle(color: textColor, height: 1.4),
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

    // Check widget config for default
    if (widget.backgroundImage?.contains('Rashmi') == true) {
      deityName = 'Rashmi';
      imageAsset = 'assets/images/Small_rashmi.png';
    }
    if (_deityService.selectedDeity != null) {
      final name = _deityService.selectedDeity!.name ?? '';
      if (name.toLowerCase().contains('rashmi')) {
        deityName = 'Rashmi';
        imageAsset = 'assets/images/Small_rashmi.png';
      }
    }

    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFFBE6D0), // Krishna Theme Background for Header
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 24,
                      backgroundImage: AssetImage(imageAsset),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      deityName,
                      style: const TextStyle(
                        fontSize:
                            24, // Reverted to original suggested size or kept as is
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Text(
                      'Powered By BI',
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: () async {
                      if (!Get.isRegistered<AgentController>()) {
                        Get.put(AgentController());
                      }
                      final agentController = Get.find<AgentController>();
                      if (agentController.avatars.isEmpty) {
                        await agentController.fetchAvatars(null);
                      }

                      final currentId = _deityService.selectedDeity?.sId;
                      final otherDeity = agentController.avatars
                          .firstWhereOrNull(
                            (a) =>
                                (a.name?.toLowerCase().contains('rashmi') ==
                                        true ||
                                    a.name?.toLowerCase().contains('krishna') ==
                                        true) &&
                                a.sId != currentId,
                          );

                      if (otherDeity != null) {
                        _deityService.setSelectedDeity(otherDeity);
                        setState(() {});
                        Get.back(); // Close drawer
                        await vm.newChat(); // Start new chat with new deity
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.swap_horiz,
                            size: 16,
                            color: Colors.black87,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            deityName == 'Krishna' ? "Avatar" : "Chat",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
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
              color: Colors.white, // Light color for body as requested
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Chat Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                      color: const Color(0xFFFBE6D0),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () async {
                          Get.back();
                          await vm.newChat();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, color: Colors.black87),
                              const SizedBox(width: 12),
                              Text(
                                'New Chat',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'HISTORY',
                      style: TextStyle(
                        fontSize: 12,
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
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No chat history',
                              style: TextStyle(color: Colors.grey[500]),
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
                                ? Colors.white
                                : Colors.transparent,
                            elevation: isSelected ? 2 : 0,
                            borderRadius: BorderRadius.circular(12),
                            child: ListTile(
                              dense: true, // Reduces vertical height
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              visualDensity: const VisualDensity(
                                horizontal: 0,
                                vertical: -4,
                              ), // Further compact
                              leading: Container(
                                padding: const EdgeInsets.all(
                                  6,
                                ), // Reduced from 8
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFFBE6D0)
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16, // Reduced from 18
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Text(
                                chat.title,
                                style: TextStyle(
                                  fontSize: 13, // Reduced size
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.black87
                                      : Colors.black54,
                                ),
                              ),
                              subtitle: Text(
                                chat.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11, // Reduced from 12
                                  color: Colors.grey[500],
                                ),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(20),
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
                  offset: Offset(0, -4 * _animations[index].value),
                  child: Container(
                    width: 6,
                    height: 6,
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
