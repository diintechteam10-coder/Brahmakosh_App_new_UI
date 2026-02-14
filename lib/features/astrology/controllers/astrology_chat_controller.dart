import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/api_services.dart';
import 'package:http/http.dart' as http;
import '../../../common/api_urls.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/utils.dart';
import '../../../common_imports.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/chat_notification_service.dart';
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
  final ChatNotificationService _notifService =
      Get.find<ChatNotificationService>();

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
    Utils.print("📌 ENTER _onNewMessage");
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
        bool isDuplicate =
            _processedMessageIds.contains(message.messageId) ||
            messages.any((m) => m.messageId == message.messageId);

        if (!isDuplicate) {
          // Fuzzy check: Content + Sender + Time (within 5s)
          // This catches the case where Socket ID != API ID
          isDuplicate = messages.any((existing) {
            if (existing.senderId != message.senderId) return false;
            // Trim comparison
            if (existing.content.trim() != message.content.trim()) return false;

            final timeDiff = existing.createdAt
                .difference(message.createdAt)
                .inSeconds
                .abs();
            // 5 second window for "same" message
            return timeDiff <= 5;
          });

          if (isDuplicate) {
            Utils.print(
              "⚠️ [Live] Ignored fuzzy duplicate: ${message.messageId} (matches content)",
            );
          }
        }

        if (isDuplicate) {
          Utils.print(
            "⚠️ [${hashCode}] Ignored duplicate message: ${message.messageId}",
          );
          return;
        }

        messages.add(message);
        _processedMessageIds.add(message.messageId);
        _scrollToBottom();

        // Trigger acceptance if message is from expert and not yet accepted
        if (message.senderId == expert.id && !isRequestAccepted.value) {
          isRequestAccepted.value = true;
          _startTimer();
          Get.snackbar(
            "Consultation Started",
            "Expert has joined the conversation.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }

        // Mark as read if from partner
        if (!isFromMe) {
          Utils.print(
            "📖 [Live] Message from Expert: Implicitly marking my previous messages as read",
          );
          _implicitlyMarkMyMessagesAsRead();
          markMessagesAsRead();
        }
      }
    } catch (e) {
      Utils.print("❌ Error parsing incoming message: $e");
    }
    Utils.print("📌 EXIT _onNewMessage");
  }

  /// Mark all messages sent by 'me' as read locally.
  /// Useful when expert replies (proving they've read the chat).
  void _implicitlyMarkMyMessagesAsRead() {
    bool changed = false;
    for (int i = 0; i < messages.length; i++) {
      if (isMessageFromMe(messages[i]) && !messages[i].isRead) {
        messages[i] = messages[i].copyWith(isRead: true, isDelivered: true);
        changed = true;
      }
    }
    if (changed) {
      Utils.print("✅ [Live] UI Updated via Implicit Read");
      messages.refresh();
    }
  }

  // ...
  Future<void> _fetchMessages({bool isPolling = false}) async {
    Utils.print("📌 ENTER _fetchMessages (isPolling: $isPolling)");
    if (_conversationId == null) {
      Utils.print("📌 EXIT _fetchMessages - no conversationId");
      return;
    }
    if (!isPolling) isLoadingMessages.value = true;

    // Use full URL or custom logic? The existing callWebApi logic is fine.
    // URL: /conversations/:id/messages
    // Code snippet assumes callWebApi handles full URL construction if needed
    // But existing logs show correct URL is generated.

    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      await callWebApiGet(
        null,
        "${ApiUrls.chatApiUrl}/conversations/$_conversationId/messages",
        token: token,
        showLoader: !isPolling,
        onResponse: (response) {
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['success'] == true) {
              // ✅ SUCCESS! Conversation is active (or ended, but access granted)
              if (!isRequestAccepted.value) {
                isRequestAccepted.value = true;
                Utils.print("✅ Polling detected acceptance! 403 -> 200");
                // Switch from acceptance polling to active status polling
                _startActiveStatusPolling();
                _startMessageSyncPolling(); // Fail-safe for blue ticks
                _startTimer();
              }

              final List<dynamic> msgList = data['data']['messages'];
              final loadedMessages = msgList
                  .map((m) => ChatMessage.fromJson(m))
                  .toList();

              // SMART MERGE: Union of (Fetched) and (Existing Socket Messages)
              final Map<String, ChatMessage> mergedMap = {};

              // Debug: Log fetched IDs
              Utils.print(
                "📥 Fetched ${loadedMessages.length} messages from API",
              );
              if (loadedMessages.isNotEmpty) {
                Utils.print(
                  "🔍 Sample API ID: ${loadedMessages.first.messageId} | Content: ${loadedMessages.first.content}",
                );
              }

              // 1. Add all fetched messages (Source of Truth)
              for (var m in loadedMessages) {
                mergedMap[m.messageId] = m;
              }

              // 2. Add local/socket messages only if NOT duplicate by ID
              //    AND NOT duplicate by (Content + Approx Time)
              int ignoredCount = 0;
              for (var m in messages) {
                if (m.messageId.isEmpty) continue;

                // Direct ID check
                if (mergedMap.containsKey(m.messageId)) {
                  ignoredCount++;
                  continue;
                }

                // Fuzzy check: Content + Same Sender + Time within 5s (increased window)
                final isContentDuplicate = mergedMap.values.any((existing) {
                  final sameSender = existing.senderId == m.senderId;
                  final sameContent =
                      existing.content.trim() == m.content.trim();

                  final timeDiff = existing.createdAt
                      .difference(m.createdAt)
                      .inSeconds
                      .abs();

                  // Detailed Log for debugging collisions
                  if (sameContent && sameSender && timeDiff > 5) {
                    Utils.print(
                      "🤔 Fuzzy Mismatch (Time): ${m.messageId} (${m.createdAt}) vs ${existing.messageId} (${existing.createdAt}) = Diff: ${timeDiff}s",
                    );
                  } else if (sameSender && timeDiff <= 5 && !sameContent) {
                    Utils.print(
                      "🤔 Fuzzy Mismatch (Content): '${m.content}' vs '${existing.content}'",
                    );
                  }

                  return sameSender && sameContent && timeDiff <= 5;
                });

                if (isContentDuplicate) {
                  Utils.print(
                    "⚠️ [SmartMerge] Ignored duplicate: ${m.messageId} (Content match)",
                  );
                  ignoredCount++;
                  continue;
                }

                // If unique, add it
                mergedMap[m.messageId] = m;
              }

              Utils.print(
                "📊 Merge Result [${hashCode}]: ${mergedMap.length} total messages (Ignored $ignoredCount duplicates)",
              );

              final uniqueList = mergedMap.values.toList();
              uniqueList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

              // FINAL AGGRESSIVE SCRUB
              final List<ChatMessage> finalScrubbed = [];
              final Set<String> seenIds = {};
              for (var msg in uniqueList) {
                if (seenIds.contains(msg.messageId)) continue;

                // Final fuzzy check against already added scrubbed messages
                bool isFuzzyDup = finalScrubbed.any((existing) {
                  if (existing.senderId != msg.senderId) return false;
                  if (existing.content.trim() != msg.content.trim())
                    return false;
                  return existing.createdAt
                          .difference(msg.createdAt)
                          .inSeconds
                          .abs() <=
                      5;
                });

                if (isFuzzyDup) {
                  Utils.print(
                    "🛑 [HyperScrub] Blocked duplicate: ${msg.messageId}",
                  );
                  continue;
                }

                seenIds.add(msg.messageId);
                finalScrubbed.add(msg);
              }

              Utils.print(
                "🧹 [HyperScrub] Final Count [${hashCode}]: ${finalScrubbed.length} (from ${uniqueList.length})",
              );
              messages.assignAll(finalScrubbed);

              _processedMessageIds.clear();
              _processedMessageIds.addAll(
                finalScrubbed.map((m) => m.messageId),
              );

              if (!isPolling) _scrollToBottom();

              markMessagesAsRead();
            }
          } else if (response.statusCode == 403) {
            // Still pending or blocked
            Utils.print("⏳ Polling: 403 - Waiting for acceptance...");
          }
        },
        onError: (error) {
          if (!isPolling) Utils.print("❌ Error fetching messages: $error");
        },
      );
    } catch (e) {
      Utils.print("❌ Error fetching messages: $e");
    } finally {
      if (!isPolling) isLoadingMessages.value = false;
    }
    Utils.print("📌 EXIT _fetchMessages");
  }

  final isLoadingMessages = false.obs;
  final isTyping = false.obs;

  String? _conversationId;
  Timer? _timer;
  Timer? _statusPollingTimer; // For acceptance polling
  Timer? _activeStatusTimer; // For active session polling
  Timer? _msgSyncTimer; // Fail-safe for blue ticks
  Timer? _msgDebounce; // New field for debounce
  final chatDuration = 0.obs;
  final onlineStatus = "OFFLINE".obs;
  final isRequestAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    Utils.print("📌 ENTER onInit");
    Utils.print("🟢 [${hashCode}] Controller Init for ${expert.name}");
    final token = StorageService.getString(AppConstants.keyAuthToken);
    Utils.print("🔥 DEBUG: Partner Token: $token");
    Utils.print("🔥 DEBUG: Partner ID: ${expert.id}");
    // Initialize with expert's status if available, or default
    onlineStatus.value = expert.isOnline ? "ONLINE" : "OFFLINE";
    _initializeChat();
    Utils.print("📌 EXIT onInit");
  }

  Future<void> _initializeChat() async {
    Utils.print("📌 ENTER _initializeChat");
    await _createConversation();
    if (_conversationId != null) {
      // Register this conversation with the global notification service
      _notifService.setActiveConversation(_conversationId!, expert);
      await _connectSocket();
      _fetchMessages();
      // Only reset to "waiting" state if the conversation isn't already active.
      // _createConversation sets isRequestAccepted=true for active sessions,
      // so we must NOT override it here.
      if (!isRequestAccepted.value) {
        _requestChat();
      }
    } else {
      Get.snackbar(
        "Error",
        "Could not start chat session",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
    Utils.print("📌 EXIT _initializeChat");
  }

  Future<void> _createConversation() async {
    Utils.print("📌 ENTER _createConversation");
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
            final conversationData = data['data'];
            _conversationId = conversationData['conversationId'];
            final status = conversationData['status']?.toString().toLowerCase();
            final startTimeStr =
                conversationData['startTime'] ?? conversationData['createdAt'];

            Utils.print(
              "✅ Conversation Created: $_conversationId, Status: $status, StartTime: $startTimeStr",
            );

            // Check if already active
            if (status == 'active') {
              isRequestAccepted.value = true;

              // Calculate initial duration if startTime exists
              if (startTimeStr != null) {
                try {
                  final startTime = DateTime.parse(startTimeStr).toLocal();
                  final now = DateTime.now();
                  final diff = now.difference(startTime).inSeconds;
                  if (diff > 0) {
                    chatDuration.value = diff;
                    Utils.print("⏱️ Resuming timer from: $diff seconds");
                  }
                } catch (e) {
                  Utils.print("❌ Error parsing startTime: $e");
                  chatDuration.value = 0;
                }
              }

              _startActiveStatusPolling();
              _startMessageSyncPolling(); // Fail-safe for blue ticks
              _startTimer();
            }
          } else {
            Utils.print("❌ Failed to create conversation: ${data['message']}");
          }
        },
        onError: (error) => Utils.print("❌ API Error: $error"),
      );
    } catch (e) {
      Utils.print("❌ Exception creating conversation: $e");
    }
    Utils.print("📌 EXIT _createConversation");
  }

  Future<void> _connectSocket() async {
    Utils.print("📌 ENTER _connectSocket");
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

    // Custom listeners for acceptance/rejection
    _socketService.on("conversation:joined", _onPartnerJoined);
    _socketService.on("conversation:ended", _onConversationEnded);
    // Fallback: in case the event is named slightly differently or partner leaving triggers this
    _socketService.on("conversation:left", _onConversationEnded);
    Utils.print("📌 EXIT _connectSocket");
  }

  void _onPartnerJoined(dynamic data) {
    Utils.print("📌 ENTER _onPartnerJoined");
    try {
      Utils.print("👤 Partner Joined Event: $data");
      final userId = data['userId']; // Assuming payload has userId
      // If the expert joined, consider it accepted
      if (userId == expert.id) {
        if (!isRequestAccepted.value) {
          isRequestAccepted.value = true;
          _startTimer();
          Get.snackbar(
            "Consultation Started",
            "Expert has joined the chat.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Utils.print("❌ Error parsing join event: $e");
    }
    Utils.print("📌 EXIT _onPartnerJoined");
  }

  void _onConversationEnded(dynamic data) {
    Utils.print("📌 ENTER _onConversationEnded");
    try {
      Utils.print("🛑 Conversation Ended Event: $data");
      // If not active yet, treated as rejection
      if (!isRequestAccepted.value) {
        Get.defaultDialog(
          title: "Request Declined",
          middleText:
              "The expert has declined your request. Please try again later.",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close dialog
            Get.back(); // Go back to profile
          },
          barrierDismissible: false,
        );
      } else {
        // Normal end logic
        isRequestAccepted.value = false; // BLOCK sending
        _timer?.cancel();

        // Show non-dismissible dialog
        Get.generalDialog(
          barrierDismissible: false,
          barrierLabel: "Chat Ended",
          pageBuilder: (context, _, __) {
            return WillPopScope(
              onWillPop: () async => false, // Block back button dismissal
              child: Dialog(
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF3E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.front_hand, // Stop icon concept
                          color: Color(0xFF8D6E63),
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Consultation Ended",
                        style: GoogleFonts.cinzel(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "The expert has ended the session. Thank you for consulting with ${expert.name}.",
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
                            // Correct cleanup
                            _socketService.leaveConversation(
                              _conversationId ?? '',
                            );
                            Get.back(); // Close dialog
                            Get.back(); // Leave screen
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFA1887F),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Go Back",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      Utils.print("❌ Error parsing end event: $e");
    }
    Utils.print("📌 EXIT _onConversationEnded");
  }

  void _onTypingStatus(dynamic data) {
    Utils.print("📌 ENTER _onTypingStatus");
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
    Utils.print("📌 EXIT _onTypingStatus");
  }

  void _onPartnerStatusChanged(dynamic data) {
    Utils.print("📌 ENTER _onPartnerStatusChanged");
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
    Utils.print("📌 EXIT _onPartnerStatusChanged");
  }

  void _onMessageDelivered(dynamic data) {
    Utils.print("📌 ENTER _onMessageDelivered");
    try {
      Utils.print("📩 [Live] Message Delivered Event: $data");
      final messageId = data['messageId'];
      final List<dynamic>? messageIds = data['messageIds'];
      final conversationId = data['conversationId'];

      bool changed = false;

      if (messageId != null) {
        final index = messages.indexWhere((m) => m.messageId == messageId);
        Utils.print("🔍 Delivery: Finding msg $messageId at index $index");
        if (index != -1) {
          messages[index] = messages[index].copyWith(isDelivered: true);
          changed = true;
        }
      } else if (messageIds != null) {
        Utils.print("🔍 Delivery: Batch IDs check: $messageIds");
        for (var id in messageIds) {
          final index = messages.indexWhere((m) => m.messageId == id);
          if (index != -1 && !messages[index].isDelivered) {
            messages[index] = messages[index].copyWith(isDelivered: true);
            changed = true;
          }
        }
      } else if (conversationId == _conversationId) {
        Utils.print("🔍 Delivery: Conversation-wide ($conversationId) check");
        for (int i = 0; i < messages.length; i++) {
          if (isMessageFromMe(messages[i]) && !messages[i].isDelivered) {
            messages[i] = messages[i].copyWith(isDelivered: true);
            changed = true;
          }
        }
      }

      if (changed) {
        Utils.print("✅ [Live] Refreshing UI for delivery status");
        messages.refresh();
      } else {
        Utils.print("ℹ️ [Live] No messages updated for delivered status");
      }
    } catch (e) {
      Utils.print("❌ Error parsing delivery status: $e");
    }
    Utils.print("📌 EXIT _onMessageDelivered");
  }

  void _onMessageRead(dynamic data) {
    Utils.print("📌 ENTER _onMessageRead");
    try {
      Utils.print("📩 [Live] Message Read Event: $data");
      final messageId = data['messageId'];
      final List<dynamic>? messageIds = data['messageIds'];
      final conversationId = data['conversationId'];

      bool changed = false;

      if (messageId != null) {
        final index = messages.indexWhere((m) => m.messageId == messageId);
        Utils.print("🔍 Read: Finding msg $messageId at index $index");
        if (index != -1) {
          messages[index] = messages[index].copyWith(
            isRead: true,
            isDelivered: true,
          );
          changed = true;
        }
      } else if (messageIds != null) {
        Utils.print("🔍 Read: Batch IDs check: $messageIds");
        for (var id in messageIds) {
          final index = messages.indexWhere((m) => m.messageId == id);
          if (index != -1 && !messages[index].isRead) {
            messages[index] = messages[index].copyWith(
              isRead: true,
              isDelivered: true,
            );
            changed = true;
          }
        }
      } else if (conversationId == _conversationId) {
        Utils.print("🔍 Read: Conversation-wide ($conversationId) check");
        for (int i = 0; i < messages.length; i++) {
          if (isMessageFromMe(messages[i]) && !messages[i].isRead) {
            messages[i] = messages[i].copyWith(isRead: true, isDelivered: true);
            changed = true;
          }
        }
      }

      if (changed) {
        Utils.print("✅ [Live] Refreshing UI for read status");
        messages.refresh();
      } else {
        Utils.print("ℹ️ [Live] No messages updated for read status");
      }
    } catch (e) {
      Utils.print("❌ Error parsing read status: $e");
    }
    Utils.print("📌 EXIT _onMessageRead");
  }

  Future<void> sendMessage() async {
    Utils.print("📌 ENTER sendMessage");
    if (!isRequestAccepted.value) {
      Utils.print("📌 EXIT sendMessage - request not accepted");
      return;
    }
    final text = messageController.text.trim();
    if (text.isEmpty || _conversationId == null) {
      Utils.print("📌 EXIT sendMessage - empty text or no conversationId");
      return;
    }

    // Optimistic UI Update — add temp message immediately
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

    // Emit via socket with ack to get the real message _id
    _socketService.sendMessage(
      _conversationId!,
      text,
      onAck: (response) {
        try {
          if (response is Map &&
              response['success'] == true &&
              response['message'] != null) {
            final realMsg = ChatMessage.fromJson(response['message']);
            final idx = messages.indexWhere(
              (m) => m.messageId == tempMsg.messageId,
            );
            if (idx != -1) {
              messages[idx] = realMsg;
              _processedMessageIds.add(realMsg.messageId);
              messages.refresh();
              Utils.print(
                "✅ Replaced temp message with real ID: ${realMsg.messageId}",
              );
            }
          }
        } catch (e) {
          Utils.print("❌ Error processing send ack: $e");
        }
      },
    );
    Utils.print("📌 EXIT sendMessage");
  }

  // Helper to determine if message is from current user
  bool isMessageFromMe(ChatMessage msg) {
    Utils.print("📌 ENTER isMessageFromMe (senderId: ${msg.senderId})");
    // If msg.senderId is equal to expert.id, it's incoming.
    // Otherwise it's outgoing (assuming only 2 participants).
    final result = msg.senderId != expert.id;
    Utils.print("📌 EXIT isMessageFromMe -> $result");
    return result;
  }

  void selectTopic(Topic topic) {
    Utils.print("📌 ENTER selectTopic (topic: $topic)");
    selectedTopic.value = topic;
    Utils.print("📌 EXIT selectTopic");
  }

  void selectQuestion(String question) {
    Utils.print("📌 ENTER selectQuestion (question: $question)");
    messageController.text = question;
    sendMessage();
    Utils.print("📌 EXIT selectQuestion");
  }

  void goBackToTopics() {
    Utils.print("📌 ENTER goBackToTopics");
    selectedTopic.value = null;
    Utils.print("📌 EXIT goBackToTopics");
  }

  List<Map<String, String>> getCurrentQuestions() {
    Utils.print("📌 ENTER getCurrentQuestions (topic: ${selectedTopic.value})");
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
        Utils.print("📌 EXIT getCurrentQuestions -> empty (no topic)");
        return [];
    }
  }

  void _scrollToBottom() {
    Utils.print("📌 ENTER _scrollToBottom");
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
    Utils.print("📌 EXIT _scrollToBottom");
  }

  void showEndChatDialog(String title, String message) {
    Utils.print("📌 ENTER showEndChatDialog (title: $title)");
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
    Utils.print("📌 EXIT showEndChatDialog");
  }

  void _endChat() {
    Utils.print("📌 ENTER _endChat");
    if (_conversationId == null) {
      Utils.print("📌 EXIT _endChat - no conversationId");
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

    // Leave the room but keep socket alive for global notifications
    _socketService.leaveConversation(_conversationId!);
    Get.back();
    Utils.print("📌 EXIT _endChat");
  }

  void _requestChat() {
    Utils.print("📌 ENTER _requestChat");
    // Just reset state, wait for partner message
    isRequestAccepted.value = false;
    _startPollingForAcceptance();
    Utils.print("📌 EXIT _requestChat");
  }

  void _startPollingForAcceptance() {
    Utils.print("📌 ENTER _startPollingForAcceptance");
    _statusPollingTimer?.cancel(); // Cancel any existing timer
    _statusPollingTimer = Timer.periodic(const Duration(seconds: 3), (
      timer,
    ) async {
      if (isRequestAccepted.value) {
        timer.cancel();
        return;
      }
      Utils.print("Polling for chat acceptance...");
      await _fetchMessages(isPolling: true);
    });
    Utils.print("📌 EXIT _startPollingForAcceptance (timer started)");
  }

  void _startActiveStatusPolling() {
    Utils.print("📌 ENTER _startActiveStatusPolling");
    _activeStatusTimer?.cancel();
    // Check less frequently (e.g. 5s) for end status
    _activeStatusTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      Utils.print("⏰ Tick: Active Status Poll");
      if (_conversationId == null || !isRequestAccepted.value) {
        timer.cancel();
        return;
      }

      // Check if conversation is still active via API
      try {
        final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
        // Fetch ALL conversations (no status filter) + cache buster
        final url =
            "${ApiUrls.chatApiUrl}/conversations?t=${DateTime.now().millisecondsSinceEpoch}";

        // Use direct http call to avoid the automatic exception on 403/404
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'clientId': AppConstants.clientId,
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final List<dynamic> activeConvs = data['data'];
            // Check if our conversation is in the active list AND has a valid status
            final conversation = activeConvs.firstWhere(
              (c) =>
                  c['_id'] == _conversationId ||
                  c['conversationId'] == _conversationId,
              orElse: () => null,
            );

            bool isStillActive = false;
            String? status;

            if (conversation != null) {
              status = conversation['status']?.toString().toLowerCase();
              // If found, check if the status itself indicates end
              if (status == 'ended' ||
                  status == 'completed' ||
                  status == 'closed' ||
                  status == 'rejected') {
                isStillActive = false;
              } else {
                isStillActive = true;
              }
            }

            Utils.print(
              "🔍 Status Poll: ${response.statusCode} - Found: ${conversation != null} - Status: $status",
            );

            if (status == 'active' && conversation != null) {
              // Utils.print("📝 RAW ACTIVE CONV: ${jsonEncode(conversation)}");
            }

            if (!isStillActive) {
              Utils.print(
                "🛑 Polling: Conversation ended (Found: ${conversation != null}, Status: $status)",
              );
              timer.cancel();
              _onConversationEnded(
                "Partner ended session (detected via list status check)",
              );
            }
          }
        } else {
          Utils.print(
            "⚠️ Polling Warning: API returned ${response.statusCode} - ${response.body}",
          );
          // Do NOT assume ended on generic errors (500, 502, etc), only specific logic
        }
      } catch (e) {
        Utils.print("Error in status poll: $e");
      }
    });
    Utils.print("📌 EXIT _startActiveStatusPolling (timer started)");
  }

  void _startMessageSyncPolling() {
    Utils.print("📌 ENTER _startMessageSyncPolling");
    _msgSyncTimer?.cancel();
    // Poll every 8 seconds for message status updates (blue ticks)
    _msgSyncTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (_conversationId != null && isRequestAccepted.value) {
        Utils.print("⏰ Tick: Message Sync Poll (Fail-safe for Blue Ticks)");
        _fetchMessages(isPolling: true);
      } else if (!isRequestAccepted.value) {
        Utils.print("🛑 Stopping Message Sync: Not active/accepted");
        timer.cancel();
      }
    });
    Utils.print("📌 EXIT _startMessageSyncPolling");
  }

  void _startTimer() {
    Utils.print("📌 ENTER _startTimer");
    _timer?.cancel(); // Cancel existing if any
    _statusPollingTimer?.cancel(); // Stop polling once accepted
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      chatDuration.value++;
    });
    Utils.print("📌 EXIT _startTimer");
  }

  String formatTime(int seconds) {
    Utils.print("📌 ENTER formatTime (seconds: $seconds)");
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    final result = "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
    Utils.print("📌 EXIT formatTime -> $result");
    return result;
  }

  Future<void> markMessagesAsRead() async {
    Utils.print("📌 ENTER markMessagesAsRead");
    if (_conversationId == null) {
      Utils.print("📌 EXIT markMessagesAsRead - no conversationId");
      return;
    }

    // Emit via socket (per doc: message:read)
    _socketService.markMessageRead(_conversationId!);

    // Also call REST API as fallback
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
    Utils.print("📌 EXIT markMessagesAsRead");
  }

  @override
  void onClose() {
    Utils.print("📌 ENTER onClose");
    _timer?.cancel();
    _statusPollingTimer?.cancel();
    _activeStatusTimer?.cancel();
    _msgSyncTimer?.cancel();
    _msgDebounce?.cancel();

    // Clear active conversation so global notifications can fire
    _notifService.clearActiveConversation();

    // Leave socket room (but keep connection alive for global notifications)
    if (_conversationId != null) {
      _socketService.leaveConversation(_conversationId!);
    }

    // Unregister listeners to avoid duplication
    _socketService.offNewMessage(_onNewMessage);
    _socketService.offTypingStatus(_onTypingStatus);
    _socketService.offPartnerStatusChanged(_onPartnerStatusChanged);
    _socketService.offMessageDelivered(_onMessageDelivered);
    _socketService.offMessageRead(_onMessageRead);

    // Remove custom listeners
    _socketService.off("conversation:joined", _onPartnerJoined);
    _socketService.off("conversation:ended", _onConversationEnded);
    _socketService.off("conversation:left", _onConversationEnded);

    // NOTE: Socket is NOT disconnected here so the global
    // ChatNotificationService can still receive events.
    messageController.dispose();
    scrollController.dispose();
    Utils.print("📌 EXIT onClose");
    super.onClose();
  }
}
