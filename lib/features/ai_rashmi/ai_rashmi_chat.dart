import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:collection/collection.dart';

import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';
import '../dashboard/viewmodels/dashboard_viewmodel.dart';
import 'deity_selection_service.dart';
import 'package:brahmakosh/features/agent/controllers/agent_controller.dart';
import '../../common/models/avtar_list.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    // _vicontroller = VideoPlayerController.asset('assets/images/bi_bg.mp4')
    //   ..initialize()
    //       .then((_) {
    //         if (mounted) {
    //           _vicontroller.setLooping(true);
    //           _vicontroller.setVolume(0);
    //           _vicontroller.play();
    //           setState(() {});
    //         }
    //       })
    //       .catchError((error) {
    //         print('Video initialization error: $error');
    //       });
  }

  @override
  void dispose() {
    _controller.dispose();
    // _vicontroller.pause();
    // _vicontroller.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiRashmiController>(
      builder: (vm) {
        final theme = Theme.of(context);
        return Scaffold(
          key: _scaffoldKey,
          // Reusing the same drawer logic if possible, or we can copy it.
          // Since _buildDrawer is private in the other file, we need to copy it here.
          drawer: _buildDrawer(vm),
          body: Stack(
            children: [
              // Video Background
              // Video Background
              // Positioned.fill(
              //   child: _vicontroller.value.isInitialized
              //       ? FittedBox(
              //           fit: BoxFit.cover,
              //           child: SizedBox(
              //             width: _vicontroller.value.size.width,
              //             height: _vicontroller.value.size.height,
              //             child: VideoPlayer(_vicontroller),
              //           ),
              //         )
              //       : Container(color: Colors.black),
              // ),
              Builder(
                builder: (context) {
                  String? currentBg = widget.backgroundImage;
                  // If user has started chatting (messages exist), switch to default background
                  if (vm.messages.isNotEmpty) {
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

              // Custom Top Bar (Menu & Close Icons)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.white),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer();
                          },
                        ),
                        // IconButton(
                        //   icon: const Icon(Icons.close, color: Colors.white),
                        //   onPressed: () {
                        //     Get.back();
                        //   },
                        // ),
                        PopupMenuButton<Data>(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          onSelected: (avatar) async {
                            // Update selected deity
                            _deityService.setSelectedDeity(avatar);
                            setState(() {});
                            final vm = Get.find<AiRashmiController>();
                            await vm.newChat();
                          },
                          itemBuilder: (context) {
                            if (!Get.isRegistered<AgentController>()) {
                              Get.put(AgentController());
                            }
                            final agentController = Get.find<AgentController>();

                            // Ensure avatars are loaded
                            if (agentController.avatars.isEmpty) {
                              agentController.fetchAvatars(null);
                              return [
                                const PopupMenuItem(
                                  enabled: false,
                                  child: Text('Loading...'),
                                ),
                              ];
                            }

                            final currentId = _deityService.selectedDeity?.sId;

                            // Filter for Rashmi and Krishna
                            final relevantAvatars = agentController.avatars
                                .where((a) {
                                  final name = (a.name ?? '').toLowerCase();
                                  return name.contains('rashmi') ||
                                      name.contains('krishna');
                                })
                                .toList();

                            // Find the one that is NOT the current one
                            // If relevantAvatars is empty (fallback), use all avatars
                            final sourceList = relevantAvatars.isNotEmpty
                                ? relevantAvatars
                                : agentController.avatars;

                            final otherDeity = sourceList.firstWhereOrNull(
                              (a) => a.sId != currentId,
                            );

                            if (otherDeity == null) {
                              return [
                                const PopupMenuItem(
                                  enabled: false,
                                  child: Text('No other option'),
                                ),
                              ];
                            }

                            return [
                              PopupMenuItem(
                                value: otherDeity,
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: Theme.of(context).primaryColor,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Switch to Talk to ${otherDeity.name}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main UI Content
              Column(
                children: [
                  // Spacing for top icons
                  const SizedBox(height: 80),

                  // Messages List or Suggestions
                  Expanded(
                    child: vm.messages.isEmpty
                        ? _buildSuggestions(context, vm)
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

                  // Input Area - Text Focused
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement mic functionality
                              },
                              child: Icon(
                                Icons.mic,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _controller,
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message...',
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                onSubmitted: (value) async {
                                  if (value.trim().isNotEmpty) {
                                    _controller.clear();
                                    await vm.sendMessage(value);
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: vm.isSending
                                      ? theme.disabledColor
                                      : theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Bottom padding adjustment
                  SizedBox(height: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    // Simplified typing indicator reused or simplified
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.all(12),
          child: const Text(
            '...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    Message msg,
    ThemeData theme,
  ) {
    final isUser = msg.role == 'user';
    final bubbleColor = isUser ? theme.colorScheme.primary : Colors.white;
    final textColor = isUser ? Colors.white : Colors.black87;
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
    return Drawer(
      child: Column(
        children: [
          // Custom Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 24,
                  child: Icon(
                    Icons.auto_awesome,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _deityService.selectedDeityName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Your Personal Assistant',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // New Chat Button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Material(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                              Icon(
                                Icons.add_circle,
                                color: Theme.of(context).primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'New Chat',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
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
                            const SizedBox(height: 4),
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
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1)
                                      : Colors.grey[200],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  size: 18,
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey[600],
                                ),
                              ),
                              title: Text(
                                chat.title,
                                style: TextStyle(
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
                                  fontSize: 12,
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

  Widget _buildSuggestions(BuildContext context, AiRashmiController vm) {
    final suggestions = [
      "Why does my mind keep pulling me in different directions?",
      "What is the right action when I feel completely stuck?",
      "How do I choose correctly when every option feels uncertain?",
      "How can I act with clarity instead of doubt?",
    ];

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
            ), // Spacer to push content down
            Text(
              'Try asking...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...suggestions.map((question) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: InkWell(
                  onTap: () {
                    vm.sendMessage(question);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white.withOpacity(0.7),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
