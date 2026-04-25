import 'dart:async';
import 'package:get/get.dart';
import '../../common/models/astrologist_model.dart';
import '../../common/utils.dart';
import '../../features/astrology/views/astrology_chat_view.dart';
import 'socket_service.dart';
import 'push_notification_service.dart';

/// Global service that manages in-app notification banners for chat events.
///
/// It listens to socket events and shows a notification banner when the user
/// is NOT on the active chat screen.
///
/// Events handled:
/// - `conversation:joined` — partner accepted the chat request
/// - `message:new` — new message in a tracked conversation (in-room)
/// - `notification:new:message` — server-side notification for out-of-room messages
class ChatNotificationService extends GetxService {
  final SocketService _socketService = SocketService();

  // ── Reactive state consumed by the banner widget ──
  final showNotification = false.obs;
  final notificationTitle = ''.obs;
  final notificationBody = ''.obs;
  final notificationImage = ''.obs;

  // ── Internal tracking ──
  /// The conversationId currently being viewed on screen (null = not on chat).
  String? _activeConversationId;

  /// Map of conversationId → expert data for pending conversations.
  /// Populated when a user opens a chat and leaves; the controller registers it.
  final Map<String, _PendingConversation> _trackedConversations = {};

  Timer? _autoDismissTimer;

  // ── Pending navigation data ──
  Astrologist? _pendingExpert;

  @override
  void onInit() {
    super.onInit();
    Utils.print('📢 ChatNotificationService: onInit START');
    // Ensure socket is connected so global listeners work even before
    // the user opens a chat screen.
    _socketService.initSocket();
    _registerGlobalSocketListeners();
    Utils.print('📢 ChatNotificationService: onInit COMPLETE');
  }

  // ───────────────────────────────────────────────
  // PUBLIC API – called by AstrologyChatController
  // ───────────────────────────────────────────────

  /// Call when the user opens a chat screen.
  void setActiveConversation(String conversationId, Astrologist expert) {
    _activeConversationId = conversationId;
    // Also track it for future notifications after user leaves
    _trackedConversations[conversationId] = _PendingConversation(
      conversationId: conversationId,
      expert: expert,
    );
    // Dismiss any notification for this conversation since user is now viewing it
    if (showNotification.value && _pendingExpert?.id == expert.id) {
      dismissNotification();
    }
    Utils.print('📢 Active conversation set: $conversationId');
  }

  /// Call when the user leaves the chat screen.
  void clearActiveConversation() {
    Utils.print('📢 Active conversation cleared: $_activeConversationId');
    _activeConversationId = null;
  }

  /// Track a conversation so we can receive notifications for it later.
  void trackConversation(String conversationId, Astrologist expert) {
    _trackedConversations[conversationId] = _PendingConversation(
      conversationId: conversationId,
      expert: expert,
    );
  }

  /// Stop tracking a conversation (e.g. when chat ends).
  void untrackConversation(String conversationId) {
    _trackedConversations.remove(conversationId);
  }

  /// Dismiss the current notification.
  void dismissNotification() {
    _autoDismissTimer?.cancel();
    showNotification.value = false;
    notificationTitle.value = '';
    notificationBody.value = '';
    notificationImage.value = '';
  }

  /// Navigate to the chat screen for the pending notification.
  void onNotificationTapped() {
    dismissNotification();
    if (_pendingExpert != null) {
      Get.to(() => AstrologyChatView(expert: _pendingExpert!));
    }
  }

  /// New method to handle system notification taps via conversationId lookup
  void handleNotificationTap(String? conversationId) {
    Utils.print('📢 ChatNotificationService: Handling tap for $conversationId');
    if (conversationId == null) return;

    final tracked = _trackedConversations[conversationId];
    if (tracked != null) {
      Utils.print('📢 ChatNotificationService: Found tracked expert ${tracked.expert.name}');
      Get.to(() => AstrologyChatView(expert: tracked.expert));
    } else {
      Utils.print('⚠️ ChatNotificationService: No tracked expert for $conversationId');
      // If not tracked, we might need to fetch from API, but for now let's hope it's tracked.
    }
  }

  // ───────────────────────────────────────────────
  // SOCKET LISTENERS
  // ───────────────────────────────────────────────

  void _registerGlobalSocketListeners() {
    _socketService.on('conversation:joined', _onGlobalPartnerJoined);
    _socketService.on('message:new', _onGlobalNewMessage);
    // Per doc: notification:new:message is sent when user is online but NOT in the room
    _socketService.on('notification:new:message', _onNotificationNewMessage);
  }

  /// Handles `conversation:joined` — partner accepted the chat request
  void _onGlobalPartnerJoined(dynamic data) {
    try {
      Utils.print('📢 [Global] Partner Joined Event Received: $data');
      final conversationId = data['conversationId'] as String?;
      final userId = data['userId'] as String?;

      if (conversationId == null) {
        Utils.print('❌ [Global] No conversationId in join event');
        return;
      }

      // If user is viewing this conversation, don't show notification
      if (_activeConversationId == conversationId) {
        Utils.print(
          '🚫 [Global] Suppressed Join: User is active in this conversation',
        );
        return;
      }

      // Look up the tracked conversation
      final tracked = _trackedConversations[conversationId];
      if (tracked == null) {
        Utils.print(
          '⚠️ [Global] Join Event for untracked conversation $conversationId',
        );
        return;
      }

      // Only show if the joining user is the expert (not self)
      if (userId == tracked.expert.id) {
        Utils.print(
          '✅ [Global] Showing Start Banner for ${tracked.expert.name}',
        );
        _showBanner(
          title: 'Consultation Started',
          body: '${tracked.expert.name} has joined the chat.',
          image: tracked.expert.image,
          expert: tracked.expert,
          conversationId: conversationId,
        );
      }
    } catch (e) {
      Utils.print('❌ [Global] Error in partner joined handler: $e');
    }
  }

  /// Handles `message:new` — in-room broadcast for new messages
  void _onGlobalNewMessage(dynamic data) {
    try {
      Utils.print('📢 [Global] New Message Event Received: $data');
      final messageData = data['message'];
      if (messageData == null) {
        Utils.print('❌ [Global] No message data in payload');
        return;
      }

      final conversationId =
          data['conversationId'] as String? ??
          messageData['conversationId'] as String?;
      final senderId = messageData['senderId'] is Map
          ? messageData['senderId']['_id'] as String?
          : messageData['senderId'] as String?;
      final content = messageData['content'] as String? ?? '';

      Utils.print(
        '🔍 [Global] Parsing message: convId=$conversationId, sender=$senderId',
      );

      if (conversationId == null || senderId == null) {
        Utils.print('❌ [Global] Missing convId or senderId');
        return;
      }

      // If user is viewing this conversation, don't show notification
      if (_activeConversationId == conversationId) {
        Utils.print(
          '🚫 [Global] Suppressed: User is currently on this chat screen',
        );
        return;
      }

      // Look up the tracked conversation
      final tracked = _trackedConversations[conversationId];
      if (tracked == null) {
        Utils.print(
          '⚠️ [Global] Not tracking conversation $conversationId. Current tracked: ${_trackedConversations.keys.toList()}',
        );
        return;
      }

      // Only show if message is from the expert (partner), not from self
      if (senderId == tracked.expert.id) {
        Utils.print('✅ [Global] Showing Banner for ${tracked.expert.name}');
        _showBanner(
          title: tracked.expert.name,
          body: content.length > 80 ? '${content.substring(0, 80)}…' : content,
          image: tracked.expert.image,
          expert: tracked.expert,
          conversationId: conversationId,
        );
      } else {
        Utils.print('ℹ️ [Global] Message is from user (self), ignoring banner');
      }
    } catch (e) {
      Utils.print('❌ [Global] Error in new message handler: $e');
    }
  }

  /// Handles `notification:new:message` — server-side notification
  /// for when user is online but NOT in the conversation room (per doc)
  void _onNotificationNewMessage(dynamic data) {
    try {
      Utils.print('📢 [Global] Notification New Message Event Received: $data');
      final conversationId = data['conversationId'] as String?;
      final msgData = data['message'];

      Utils.print(
        '🔍 [Global] Parsing: convId=$conversationId, msgData=${msgData != null}',
      );

      if (conversationId == null || msgData == null) {
        Utils.print('❌ [Global] Invalid payload');
        return;
      }

      // If user is viewing this conversation, skip
      if (_activeConversationId == conversationId) {
        Utils.print(
          '🚫 [Global] Suppressed: User is active in this conversation',
        );
        return;
      }

      final senderName = msgData['senderName'] as String? ?? 'Partner';
      final content = msgData['content'] as String? ?? '';

      // Look up tracked conversation for expert info
      final tracked = _trackedConversations[conversationId];
      final expert = tracked?.expert;

      Utils.print('✅ [Global] Showing Banner for $senderName');

      _showBanner(
        title: senderName,
        body: content.length > 80 ? '${content.substring(0, 80)}…' : content,
        image: expert?.image ?? '',
        expert: expert ?? _createFallbackExpert(senderName, conversationId),
        conversationId: conversationId,
      );
    } catch (e) {
      Utils.print('❌ [Global] Error in notification handler: $e');
    }
  }

  /// Creates a minimal Astrologist for notifications from unknown conversations
  Astrologist _createFallbackExpert(String name, String conversationId) {
    return Astrologist(
      id: conversationId,
      name: name,
      image: '',
      skills: [],
      languages: [],
      experience: 0,
      rating: 0,
      totalConsultations: 0,
      pricePerMinute: 0,
      isOnline: true,
      bio: '',
    );
  }

  // ───────────────────────────────────────────────
  // BANNER LOGIC
  // ───────────────────────────────────────────────

  void _showBanner({
    required String title,
    required String body,
    required String image,
    required Astrologist expert,
    required String conversationId,
  }) {
    Utils.print('📢 [Global] TRIGGERING SYSTEM NOTIFICATION: $title - $body');
    _pendingExpert = expert;
    
    // Use device notification instead of in-app banner
    PushNotificationService.showSimpleNotification(
      title: title,
      body: body,
      payload: conversationId, // Use conversationId for lookup on tap
    );

    /* 
    // Commenting out in-app banner logic as requested
    notificationTitle.value = title;
    notificationBody.value = body;
    notificationImage.value = image;
    showNotification.value = true;

    // Auto-dismiss after 5 seconds
    _autoDismissTimer?.cancel();
    _autoDismissTimer = Timer(const Duration(seconds: 5), () {
      Utils.print('📢 [Global] Auto-dismissing banner');
      dismissNotification();
    });
    */
  }

  @override
  void onClose() {
    _autoDismissTimer?.cancel();
    _socketService.off('conversation:joined', _onGlobalPartnerJoined);
    _socketService.off('message:new', _onGlobalNewMessage);
    _socketService.off('notification:new:message', _onNotificationNewMessage);
    super.onClose();
  }
}

/// Internal data class to hold tracked conversation info.
class _PendingConversation {
  final String conversationId;
  final Astrologist expert;

  _PendingConversation({required this.conversationId, required this.expert});
}
