import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:get/get.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../common/utils.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/socket_service.dart';
import '../models/chat_models.dart';

import '../../../common/models/astrologist_model.dart';

class ChatHistoryController extends GetxController {
  final conversations = <Map<String, dynamic>>[].obs;
  final messages = <ChatMessage>[].obs;
  final isLoading = true.obs;
  final isLoadingMessages = true.obs;
  final unreadCounts = <String, int>{}.obs;
  final sessionDetails =
      <String, dynamic>{}.obs; // Stores summary, duration etc.
  final selectedStatus =
      'all'.obs; // Filter: all, pending, accepted, active, ended
  final filterScrollController = ScrollController();

  // Store partner info for the currently viewed conversation
  String currentPartnerName = '';
  String currentPartnerPhoto = '';
  String currentPartnerId = '';
  String currentPartnerExpertise = '';
  String currentPartnerExperience = '';
  double currentPartnerRating = 0.0;
  String currentSessionStatus = '';
  String currentSessionDate = '';
  String _currentConversationId = ''; // Track which conversation is loaded

  @override
  void onInit() {
    super.onInit();
    fetchConversations();
    fetchUnreadCount();
    _initSocketListeners();
  }

  @override
  void onClose() {
    _socketService.off('message:new', _onNewMessage);
    filterScrollController.dispose();
    super.onClose();
  }

  // Socket & Deduplication Logic
  final SocketService _socketService = SocketService();
  final Set<String> _processedMessageIds = {};
  final List<Map<String, dynamic>> _recentMessages = [];

  void _initSocketListeners() {
    _socketService.initSocket();
    _socketService.on('message:new', _onNewMessage);
  }

  void _onNewMessage(dynamic data) {
    try {
      final msgData = data['message'];
      if (msgData == null) return;

      final messageId = msgData['_id']?.toString() ?? '';
      final content = msgData['content']?.toString().trim() ?? '';
      final senderId = msgData['senderId'] is Map
          ? msgData['senderId']['_id']?.toString()
          : msgData['senderId']?.toString();
      final conversationId =
          data['conversationId']?.toString() ??
          msgData['conversationId']?.toString();

      final userId = StorageService.getString(AppConstants.keyUserId) ?? '';

      // Ignore own messages
      if (senderId == userId) {
        Utils.print(
          '🚫 _onNewMessage: Creating user message, ignored for unread count',
        );
        return;
      }

      // Deduplication: Check ID
      if (messageId.isNotEmpty && _processedMessageIds.contains(messageId)) {
        Utils.print('🚫 _onNewMessage: Duplicate ID $messageId');
        return;
      }
      if (messageId.isNotEmpty) _processedMessageIds.add(messageId);

      // Deduplication: Fuzzy Content Check (last 2 seconds)
      final now = DateTime.now();
      _recentMessages.removeWhere(
        (m) => now.difference(m['time']).inSeconds > 2,
      );

      final isDuplicate = _recentMessages.any(
        (m) =>
            m['senderId'] == senderId &&
            m['content'] == content &&
            now.difference(m['time']).inSeconds <= 2,
      );

      if (isDuplicate) {
        Utils.print(
          '🚫 _onNewMessage: Fuzzy duplicate detected for content: "$content"',
        );
        return;
      }

      // Add to recent cache
      _recentMessages.add({
        'senderId': senderId,
        'content': content,
        'time': now,
      });

      // Increment Unread Count
      if (conversationId != null) {
        final current = unreadCounts[conversationId] ?? 0;
        Utils.print(
          '✅ _onNewMessage: Incrementing unread count for $conversationId from $current to ${current + 1}',
        );
        unreadCounts[conversationId] = current + 1;
        // Also update conversation list lastMessage potentially?
        // For now just unread count as requested.
      }
    } catch (e) {
      Utils.print('Error in _onNewMessage: $e');
    }
  }

  Future<void> changeStatus(String status) async {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    await fetchConversations();
  }

  Future<void> fetchConversations() async {
    isLoading.value = true;
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) {
        isLoading.value = false;
        return;
      }

      String url = ApiUrls.getConversations;
      if (selectedStatus.value != 'all') {
        url += '?status=${selectedStatus.value}';
      }

      await callWebApiGet(
        null,
        url,
        token: token,
        showLoader: false,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            final List<dynamic> requestList = data['data'] ?? [];
            var list = requestList
                .map((e) => Map<String, dynamic>.from(e))
                .toList();

            // Client-side filtering fallback in case backend ignores query param
            if (selectedStatus.value != 'all') {
              final filterStatus = selectedStatus.value.toLowerCase();
              list = list.where((c) {
                final s = (c['status'] ?? '').toString().toLowerCase();
                return s == filterStatus;
              }).toList();
            }

            conversations.assignAll(list);

            // Populate unread counts from initial fetch
            for (var conv in conversations) {
              final cId = getConversationId(conv);
              final count = conv['unreadCount'] ?? 0;
              if (cId.isNotEmpty) {
                final parsed = count is int
                    ? count
                    : int.tryParse(count.toString()) ?? 0;
                // HEURISTIC FIX: Backend returns double the actual count (e.g., 4 for 2 messages).
                // We divide by 2 to display the correct number to the user.
                final corrected = (parsed / 2).floor();
                if (corrected > 0) {
                  Utils.print(
                    '📥 fetchConversations: Corrected unread count for $cId: $parsed -> $corrected',
                  );
                }
                unreadCounts[cId] = corrected;
              }
            }

            Utils.print(
              '✅ Fetched ${conversations.length} conversation requests',
            );
            // Debug: print full structure of first conversation
            if (conversations.isNotEmpty) {
              Utils.print('🔍 Conv[0] keys: ${conversations[0].keys.toList()}');
              Utils.print('🔍 Conv[0] full data: ${conversations[0]}');
            }
          }
        },
        onError: (error) {
          Utils.print('❌ Error fetching conversation history: $error');
        },
      );
    } catch (e) {
      Utils.print('❌ Exception fetching conversation history: $e');
    } finally {
      isLoading.value = false;
      Utils.print(
        '🏁 fetchConversations finished, isLoading set to false. Count: ${conversations.length}',
      );
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      await callWebApiGet(
        null,
        ApiUrls.unreadCount,
        token: token,
        showLoader: false,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            // Assuming data['data'] is a list of objects { conversationId: '...', count: 5 }
            // or a map { 'convId': 5 }
            // Let's log it to be sure
            Utils.print('🔍 Unread Count API Response: $data');

            // If it's a total count, we might not be able to map it to specific conversations
            // But if the user wants it on conversation in chat history, it implies breakdown.
            // For now, let's parse if it is a list of breakdown.
            // If the API just returns total unread count, we can't update individual rows easily.
            // Based on typical patterns, let's assume it might return a total or a list.

            // If the API returns a breakdown:
            if (data['data'] is List) {
              Utils.print(
                '📥 fetchUnreadCount: Processing ${data['data'].length} items',
              );
              for (var item in data['data']) {
                final cId = item['conversationId'] ?? item['_id'];
                final count = item['count'] ?? item['unreadCount'] ?? 0;
                if (cId != null) {
                  // HEURISTIC FIX: Backend returns double count
                  final parsed = count is int
                      ? count
                      : int.tryParse(count.toString()) ?? 0;
                  final corrected = (parsed / 2).floor();
                  Utils.print(
                    '📥 fetchUnreadCount: Update $cId = $corrected (raw: $count)',
                  );
                  unreadCounts[cId.toString()] = corrected;
                }
              }
            }
          }
        },
        onError: (error) {},
      );
    } catch (e) {
      Utils.print('❌ Exception fetching unread count: $e');
    }
  }

  Future<void> markConversationAsRead(String conversationId) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) return;

      Utils.print(
        '📤 markConversationAsRead: Requesting read for $conversationId',
      );
      await callWebApiPatch(
        null,
        '${ApiUrls.chatApiUrl}/conversations/$conversationId/read',
        {},
        token: token,
        showLoader: false, // Don't block UI for this background task
        onResponse: (response) {
          Utils.print('✅ markConversationAsRead: Success for $conversationId');
          // Update local state
          unreadCounts[conversationId] = 0;
          // Also update the conversation list item if needed
          final index = conversations.indexWhere(
            (c) => getConversationId(c) == conversationId,
          );
          if (index != -1) {
            conversations[index]['unreadCount'] = 0;
            conversations.refresh();
          }
        },
        onError: (error) {
          Utils.print('❌ markConversationAsRead failed: $error');
          // Optionally show toast only if debugging
          // Utils.showToast('Failed to mark read: $error');
        },
      );
    } catch (e) {
      Utils.print('❌ Exception marking conversation as read: $e');
    }
  }

  Future<void> fetchMessages(String conversationId) async {
    // Skip if already showing the requested conversation (avoids flicker on rebuild)
    if (_currentConversationId == conversationId &&
        messages.isNotEmpty &&
        !isLoadingMessages.value) {
      Utils.print(
        '⏭️ fetchMessages: Already showing $conversationId, skipping',
      );
      return;
    }
    _currentConversationId = conversationId;
    isLoadingMessages.value = true;
    messages.clear();
    sessionDetails.clear(); // Clear previous session details
    Utils.print('📤 fetchMessages: Requesting messages for $conversationId');
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null) {
        isLoadingMessages.value = false;
        return;
      }

      await callWebApiGet(
        null,
        '${ApiUrls.chatApiUrl}/conversations/$conversationId/messages?page=1&limit=50',
        token: token,
        showLoader: false,
        onResponse: (response) {
          final data = jsonDecode(response.body);
          if (data['success'] == true) {
            // Parse Session Details if available
            if (data['data'] != null && data['data']['sessionDetails'] is Map) {
              sessionDetails.value = Map<String, dynamic>.from(
                data['data']['sessionDetails'],
              );
              Utils.print(
                '✅ fetchMessages: Session details found: $sessionDetails',
              );
            }

            final List<dynamic> msgList = data['data']['messages'] ?? [];
            final loaded = msgList.map((m) => ChatMessage.fromJson(m)).toList();

            // HyperScrub: Deduplicate by messageId using a Map
            final Map<String, ChatMessage> deduped = {};
            for (var m in loaded) {
              if (m.messageId.isNotEmpty && !deduped.containsKey(m.messageId)) {
                // Also check for fuzzy duplicates (same sender + content within 5s)
                bool isFuzzyDup = deduped.values.any(
                  (existing) =>
                      existing.senderId == m.senderId &&
                      existing.content.trim() == m.content.trim() &&
                      existing.createdAt
                              .difference(m.createdAt)
                              .inSeconds
                              .abs() <=
                          5,
                );
                if (!isFuzzyDup) {
                  deduped[m.messageId] = m;
                }
              }
            }

            final uniqueList = deduped.values.toList();
            uniqueList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
            messages.assignAll(uniqueList);
            Utils.print(
              '✅ Fetched ${loaded.length} messages, ${uniqueList.length} after dedup',
            );
          }
        },
        onError: (error) {
          Utils.print('❌ Error fetching messages: $error');
        },
      );
    } catch (e) {
      Utils.print('❌ Exception fetching messages: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Helper to determine if a message is from the current user.
  /// Compares senderId against the stored userId for reliable identification.
  bool isMessageFromMe(ChatMessage msg) {
    final userId = StorageService.getString(AppConstants.keyUserId) ?? '';
    return msg.senderId == userId;
  }

  /// Extract partner name from a conversation object.
  /// API returns partner data under 'otherUser' (or 'partnerId' as fallback).
  String getPartnerName(Map<String, dynamic> conv) {
    // Primary: 'otherUser' from /api/chat/conversations
    final otherUser = conv['otherUser'];
    if (otherUser is Map) {
      return otherUser['name'] ?? 'Astrologer';
    }
    // Fallback: 'partnerId' (populated object)
    final partner = conv['partnerId'];
    if (partner is Map) {
      return partner['name'] ?? 'Astrologer';
    }
    return 'Astrologer';
  }

  String getPartnerPhoto(Map<String, dynamic> conv) {
    final otherUser = conv['otherUser'];
    String? photoUrl;
    if (otherUser is Map) {
      photoUrl = otherUser['profilePicture'] ??
          otherUser['profilePhoto'] ??
          otherUser['profile_picture'] ??
          otherUser['profile_photo'] ??
          otherUser['profileImage'] ??
          otherUser['image'] ??
          '';
    } else {
      final partner = conv['partnerId'];
      if (partner is Map) {
        photoUrl = partner['profilePicture'] ??
            partner['profilePhoto'] ??
            partner['profile_picture'] ??
            partner['profile_photo'] ??
            partner['profileImage'] ??
            partner['image'] ??
            '';
      }
    }
    return ApiUrls.getFormattedImageUrl(photoUrl) ?? '';
  }

  /// Extract partner expertise from a conversation object.
  String getPartnerExpertise(Map<String, dynamic> conv) {
    final otherUser = conv['otherUser'];
    if (otherUser is Map) {
      return _parseExpertise(otherUser['expertise']);
    }
    final partner = conv['partnerId'];
    if (partner is Map) {
      return _parseExpertise(partner['expertise']);
    }
    return '';
  }

  /// Handle expertise being either a List or a String from the API.
  String _parseExpertise(dynamic value) {
    if (value is List) {
      return value.join(', ');
    }
    if (value is String) {
      return value;
    }
    return '';
  }

  /// Extract partner experience from a conversation object.
  String getPartnerExperience(Map<String, dynamic> conv) {
    final otherUser = conv['otherUser'];
    if (otherUser is Map) {
      return otherUser['experience']?.toString() ?? '';
    }
    final partner = conv['partnerId'];
    if (partner is Map) {
      return partner['experience']?.toString() ?? '';
    }
    return '';
  }

  /// Extract partner rating from a conversation object.
  double getPartnerRating(Map<String, dynamic> conv) {
    final otherUser = conv['otherUser'];
    if (otherUser is Map) {
      return (otherUser['rating'] ?? 0).toDouble();
    }
    final partner = conv['partnerId'];
    if (partner is Map) {
      return (partner['rating'] ?? 0).toDouble();
    }
    return 0.0;
  }

  /// Extract partner ID string.
  String getPartnerId(Map<String, dynamic> conv) {
    // Primary: 'otherUser' from /api/chat/conversations
    final otherUser = conv['otherUser'];
    if (otherUser is Map) {
      final id = otherUser['_id'] ?? '';
      Utils.print('🔍 getPartnerId from otherUser: $id');
      return id;
    }
    // Fallback: 'partnerId' (populated object or string)
    final partner = conv['partnerId'];
    if (partner is Map) {
      return partner['_id'] ?? '';
    }
    if (partner is String) return partner;
    return '';
  }

  /// Extract conversationId from a request object.
  String getConversationId(Map<String, dynamic> conv) {
    final cId = conv['conversationId'];
    if (cId is Map) {
      return cId['_id'] ?? '';
    }
    if (cId is String) return cId;
    return conv['_id'] ?? '';
  }

  /// Get status from the conversation request.
  String getStatus(Map<String, dynamic> conv) {
    return conv['status'] ?? 'ended';
  }

  /// Get the formatted date string.
  String getFormattedDate(Map<String, dynamic> conv) {
    final dateStr =
        conv['lastMessageAt'] ??
        conv['updatedAt'] ??
        conv['acceptedAt'] ??
        conv['createdAt'];
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr.toString());
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  AstrologistItem getAstrologistItemForConversation(String conversationId) {
    // Find the conversation object
    final conv = conversations.firstWhere(
      (c) => getConversationId(c) == conversationId,
      orElse: () => {},
    );

    if (conv.isEmpty) {
      // Fallback if not found in list, use stored current partner details
      return AstrologistItem(
        id: currentPartnerId.isNotEmpty ? currentPartnerId : conversationId,
        name: currentPartnerName,
        profilePhoto: currentPartnerPhoto,
        experience: currentPartnerExperience,
        expertise: currentPartnerExpertise,
        rating: currentPartnerRating > 0 ? currentPartnerRating : 4.5,
        chatCharge: 15, // Default or fetch if available
      );
    }

    // Try to parse rating safely
    double rating = 4.5;
    try {
      rating = getPartnerRating(conv);
    } catch (e) {
      rating = 4.5;
    }

    // Ensure strings are not null
    final photo = getPartnerPhoto(conv);
    final exp = getPartnerExperience(conv);
    final expertise = getPartnerExpertise(conv);

    return AstrologistItem(
      id: getPartnerId(conv),
      name: getPartnerName(conv),
      profilePhoto: photo,
      experience: exp,
      expertise: expertise,
      rating: rating,
      chatCharge: 15, // Default as history doesn't store current price
      languages: ['Hindi', 'English'], // Default
    );
  }
}