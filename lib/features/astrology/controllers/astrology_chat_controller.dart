import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/utils.dart';
import '../../../common_imports.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../astrology/models/chat_models.dart';
import '../../../core/services/socket_service.dart';

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

enum Topic { career, relationship, finance, health }

class AstrologyChatController extends GetxController {
  final Astrologist expert;
  final SocketService _socketService = SocketService();

  AstrologyChatController({required this.expert});

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final messages = <ChatMessage>[].obs;
  // Use a Set for O(1) lookups and to track processed IDs across async gaps
  final _processedMessageIds = <String>{};

  final showSuggestions = true.obs;
  final selectedTopic = Rxn<Topic>();
  // ...
  void _onNewMessage(dynamic data) {
    try {
      Utils.print("📥 [${hashCode}] Raw Message Data: $data");
      final messageData = data['message'];
      if (messageData != null) {
        final message = ChatMessage.fromJson(messageData);

        // Check if this message is from us (the user)
        bool isFromMe = message.senderId != expert.id;

        if (isFromMe) {
          // Find if we have a temporary message with same content
          final tempIndex = messages.indexWhere(
            (m) =>
                m.messageId.startsWith('temp_') &&
                m.content.trim() == message.content.trim(),
          );

          if (tempIndex != -1) {
            messages[tempIndex] = message;
            _processedMessageIds.add(message.messageId); // Add real ID
            Utils.print(
              "✅ [${hashCode}] Replaced temp message with real ID: ${message.messageId}",
            );
            messages.refresh();
            return;
          }
        }

        // Robust duplicate check
        if (_processedMessageIds.contains(message.messageId) ||
            messages.any((m) => m.messageId == message.messageId)) {
          Utils.print(
            "⚠️ [${hashCode}] Ignored duplicate message: ${message.messageId}",
          );
          return;
        }

        messages.add(message);
        _processedMessageIds.add(message.messageId);
        _scrollToBottom();

        // Mark as read if from partner
        if (!isFromMe) {
          markMessagesAsRead();
        }
      }
    } catch (e) {
      Utils.print("❌ Error parsing incoming message: $e");
    }
  }

  // ...
  Future<void> _fetchMessages() async {
    if (_conversationId == null) return;
    isLoadingMessages.value = true;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final url = "${ApiUrls.getChatMessages}/${_conversationId!}/messages";

      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true && data['data'] != null) {
            final List<dynamic> msgList = data['data']['messages'];
            final loadedMessages = msgList
                .map((m) => ChatMessage.fromJson(m))
                .toList();

            messages.assignAll(loadedMessages);

            // Rebuild the Set from source of truth
            _processedMessageIds.clear();
            _processedMessageIds.addAll(loadedMessages.map((m) => m.messageId));

            // Sort by date if backend doesn't guarantee order
            messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            _scrollToBottom();

            // Mark conversation as read on open
            markMessagesAsRead();
          }
        },
        onError: (e) => Utils.print("❌ Error fetching messages: $e"),
      );
    } catch (e) {
      Utils.print("❌ Exception fetching messages: $e");
    } finally {
      isLoadingMessages.value = false;
    }
  }

  final isLoadingMessages = false.obs;
  final isTyping = false.obs;

  String? _conversationId;
  Timer? _timer;
  final secondsRemaining = 300.obs;
  final onlineStatus = "OFFLINE".obs;

  @override
  void onInit() {
    super.onInit();
    Utils.print("🟢 [${hashCode}] Controller Init for ${expert.name}");
    final token = StorageService.getString(AppConstants.keyAuthToken);
    Utils.print("🔥 DEBUG: Partner Token: $token");
    Utils.print("🔥 DEBUG: Partner ID: ${expert.id}");
    // Initialize with expert's status if available, or default
    onlineStatus.value = expert.isOnline ? "ONLINE" : "OFFLINE";
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _createConversation();
    if (_conversationId != null) {
      await _connectSocket();
      _fetchMessages();
      _startTimer();
    } else {
      Get.snackbar(
        "Error",
        "Could not start chat session",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createConversation() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      final body = {
        "partnerId": expert.id,
        // Add birth details if needed
      };

      await callWebApi(
        null, // No ticker provider needed for silent background call usually, or pass if needed
        ApiUrls.createConversation,
        body,
        token: token,
        showLoader: true,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            _conversationId = data['data']['conversationId'];
            Utils.print("✅ Conversation Created: $_conversationId");
          } else {
            Utils.print("❌ Failed to create conversation: ${data['message']}");
          }
        },
        onError: (error) => Utils.print("❌ API Error: $error"),
      );
    } catch (e) {
      Utils.print("❌ Exception creating conversation: $e");
    }
  }

  Future<void> _connectSocket() async {
    await _socketService.initSocket();

    // Join conversation room
    if (_conversationId != null) {
      _socketService.joinConversation(_conversationId!);
    }

    // Register listeners
    // Safety check: remove old ones first
    _socketService.offNewMessage(_onNewMessage);
    _socketService.offTypingStatus(_onTypingStatus);
    _socketService.offPartnerStatusChanged(_onPartnerStatusChanged);
    _socketService.offMessageDelivered(_onMessageDelivered);
    _socketService.offMessageRead(_onMessageRead);

    _socketService.onNewMessage(_onNewMessage);
    _socketService.onTypingStatus(_onTypingStatus);
    _socketService.onPartnerStatusChanged(_onPartnerStatusChanged);
    _socketService.onMessageDelivered(_onMessageDelivered);
    _socketService.onMessageRead(_onMessageRead);
  }

  void _onTypingStatus(dynamic data) {
    try {
      Utils.print("Typing Event: $data");
      final isPeerTyping = data['isTyping'] ?? false;
      final userId = data['userId'];
      if (userId == expert.id) {
        isTyping.value = isPeerTyping;
      }
    } catch (e) {
      Utils.print("Error parsing typing status: $e");
    }
  }

  void _onPartnerStatusChanged(dynamic data) {
    try {
      Utils.print("Partner Status Event: $data");
      final partnerId = data['partnerId'];
      final status = data['status'];
      if (partnerId == expert.id && status != null) {
        onlineStatus.value = status.toString().toUpperCase();
      }
    } catch (e) {
      Utils.print("Error parsing partner status: $e");
    }
  }

  void _onMessageDelivered(dynamic data) {
    try {
      Utils.print("Message Delivered Event: $data");
      final messageId = data['messageId'];
      final conversationId = data['conversationId'];

      if (messageId != null) {
        final index = messages.indexWhere((m) => m.messageId == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(isDelivered: true);
          messages.refresh();
        }
      } else if (conversationId == _conversationId) {
        bool changed = false;
        for (int i = 0; i < messages.length; i++) {
          if (isMessageFromMe(messages[i]) && !messages[i].isDelivered) {
            messages[i] = messages[i].copyWith(isDelivered: true);
            changed = true;
          }
        }
        if (changed) messages.refresh();
      }
    } catch (e) {
      Utils.print("Error parsing delivery status: $e");
    }
  }

  void _onMessageRead(dynamic data) {
    try {
      Utils.print("Message Read Event: $data");
      final messageId = data['messageId'];
      final conversationId = data['conversationId'];

      bool changed = false;

      if (messageId != null) {
        final index = messages.indexWhere((m) => m.messageId == messageId);
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            isRead: true,
            isDelivered: true,
          );
          changed = true;
        }
      } else if (conversationId == _conversationId) {
        for (int i = 0; i < messages.length; i++) {
          if (isMessageFromMe(messages[i]) && !messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true, isDelivered: true);
            changed = true;
          }
        }
      }

      if (changed) {
        messages.refresh();
      }
    } catch (e) {
      Utils.print("Error parsing read status: $e");
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    // Emit via socket
    _socketService.sendMessage(_conversationId!, text);

    // Optimistic UI Update
    final tempMsg = ChatMessage(
      messageId: "temp_${DateTime.now().millisecondsSinceEpoch}",
      senderId: "user_me", // Placeholder, logic in view handles alignment
      content: text,
      messageType: 'text',
      createdAt: DateTime.now(),
      isRead: false,
    );
    messages.add(tempMsg);

    messageController.clear();
    showSuggestions.value = false;
    _scrollToBottom();
  }

  // Helper to determine if message is from current user
  bool isMessageFromMe(ChatMessage msg) {
    // If msg.senderId is equal to expert.id, it's incoming.
    // Otherwise it's outgoing (assuming only 2 participants).
    return msg.senderId != expert.id;
  }

  void selectTopic(Topic topic) {
    selectedTopic.value = topic;
  }

  void selectQuestion(String question) {
    messageController.text = question;
    sendMessage();
  }

  void goBackToTopics() {
    selectedTopic.value = null;
  }

  List<Map<String, String>> getCurrentQuestions() {
    switch (selectedTopic.value) {
      case Topic.career:
        return [
          {"q": "Which career is best for me?"},
          {"q": "When will I get promotion or growth?"},
          {"q": "Should I change my job now?"},
        ];
      case Topic.relationship:
        return [
          {"q": "When will I meet my life partner?"},
          {"q": "Is my relationship stable?"},
          {"q": "Will my marriage be successful?"},
        ];
      case Topic.finance:
        return [
          {"q": "When will my income improve?"},
          {"q": "Is this a good time to invest?"},
          {"q": "Why is money getting blocked?"},
        ];
      case Topic.health:
        return [
          {"q": "Why do I feel low energy?"},
          {"q": "Are there health concerns ahead?"},
        ];
      default:
        return [];
    }
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      // Small delay to allow list build
      Future.delayed(const Duration(milliseconds: 100), () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void showEndChatDialog(String title, String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF3E0),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Color(0xFF8D6E63),
                      size: 28,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                "End Conversation?",
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to end your session with ${expert.name}?",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF8D6E63),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    _endChat(); // Call End Chat API
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA1887F),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "End Chat",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: Get.back,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF8D6E63)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8D6E63),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void _endChat() {
    if (_conversationId == null) {
      Get.back();
      return;
    }

    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    // Use patch for end chat
    callWebApiPatch(
      null,
      "${ApiUrls.endConversation}/${_conversationId!}/end",
      {},
      token: token,
      onResponse: (_) {
        Utils.print("Chat ended successfully");
      },
    );

    _socketService.disconnect();
    Get.back();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        showEndChatDialog("Time Over", "Your consultation session has ended.");
      }
    });

    // Also check balance via API periodically or rely on socket events?
    // User mentioned "Stop chat when balance reaches zero" via API 11.
    // Implementation detail: we could poll or wait for backend to cut us off.
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  Future<void> markMessagesAsRead() async {
    if (_conversationId == null) return;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final url = "${ApiUrls.markConversationRead}/${_conversationId!}/read";

      await callWebApiPatch(
        null,
        url,
        {}, // Empty body
        token: token,
        onResponse: (response) {
          Utils.print("✅ Messages marked as read for $_conversationId");
        },
        onError: (e) => Utils.print("❌ Error marking read: $e"),
      );
    } catch (e) {
      Utils.print("❌ Exception marking read: $e");
    }
  }

  @override
  void onClose() {
    _timer?.cancel();

    // Unregister listeners to avoid duplication
    _socketService.offNewMessage(_onNewMessage);
    _socketService.offTypingStatus(_onTypingStatus);
    _socketService.offPartnerStatusChanged(_onPartnerStatusChanged);
    _socketService.offMessageDelivered(_onMessageDelivered);
    _socketService.offMessageRead(_onMessageRead);

    _socketService.disconnect();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
