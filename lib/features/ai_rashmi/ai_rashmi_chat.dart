import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'ai_rashmi_service.dart';
import 'ai_rashmi_view_model.dart';
import '../dashboard/viewmodels/dashboard_viewmodel.dart';
import 'deity_selection_service.dart';

class RashmiChat extends StatelessWidget {
  const RashmiChat({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    if (!Get.isRegistered<AiRashmiController>()) {
      Get.put(AiRashmiController(service: AiRashmiService()));
    }
    return const _RashmiChatView();
  }
}

class _RashmiChatView extends StatefulWidget {
  const _RashmiChatView();

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
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Get.back();
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

                  // Messages List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                      itemCount: vm.messages.length + (vm.isSending ? 1 : 0),
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
}
