import 'dart:async';

import 'package:brahmakosh/common/utils.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:http/http.dart' as http;
import 'package:brahmakosh/common/api_urls.dart';
import 'package:socket_io_client_new/socket_io_client_new.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _disposed = false;

  /// 🔵 Connection stream
  final _connectedCtrl = StreamController<bool>.broadcast();
  Stream<bool> get connected$ => _connectedCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// 🔥 Store listeners for reconnect
  final Map<String, List<Function(dynamic)>> _listeners = {};

  Future<void> initSocket() async {
    if (_disposed) return;

    // Already connected — skip
    if (_socket != null && _socket!.connected) {
      Utils.print('ℹ️ Socket already connected, skipping re-init');
      return;
    }

    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      Utils.print('❌ Cannot connect to socket: No Auth Token');
      return;
    }

    /// 🔎 TOKEN VERIFICATION
    try {
      Utils.print("🔍 Verifying token via REST API...");
      final response = await http.get(
        Uri.parse(ApiUrls.chatPartners),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 200) {
        Utils.print(
          "❌ Token verification failed (${response.statusCode}). Aborting socket connection.",
        );
        return;
      }

      Utils.print("✅ Token valid. Proceeding to socket connection.");
    } catch (e) {
      Utils.print("❌ Token verification error: $e");
      return;
    }

    disconnect(); // clear old connection

    final options = IO.OptionBuilder()
        .setPath('/socket.io/')
        .setTransports(['polling', 'websocket'])
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(2000)
        .setExtraHeaders({"Authorization": "Bearer $token"})
        .build();

    // Manually inject 'auth' object as per socktetdoc.md (Socket.IO v3+ feature)
    // The library builder might not support setAuth, so we use the map directly.
    options['auth'] = {'token': token};

    _socket = IO.io("https://prod.brahmakosh.com", options);

    _socket!.connect();

    _attachCoreListeners();
  }

  /// 🔥 Core socket listeners
  void _attachCoreListeners() {
    // 🔍 DEBUG: Log ALL events to find the missing ones
    _socket!.onAny((event, data) {
      if (event != 'ping' && event != 'pong') {
        Utils.print("🔍 SOCKET EVENT: $event");
        Utils.print("📦 DATA: $data");
      }

      // Specifically flag anything that looks like a read receipt
      if (event.toString().toLowerCase().contains('read')) {
        Utils.print("🎯 [WATCH] Read-related event detected: $event");
      }
    });

    _socket!.onConnect((_) {
      _isConnected = true;
      _connectedCtrl.add(true);

      Utils.print("✅ SOCKET CONNECTED");
      Utils.print("Socket ID: ${_socket!.id}");

      // NOTE: socket_io_client automatically persists listeners across reconnects.
      // Do NOT manually re-attach them here, or they will duplicate.
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      _connectedCtrl.add(false);
      Utils.print("⚠ SOCKET DISCONNECTED");
    });

    _socket!.onConnectError((data) {
      _isConnected = false;
      Utils.print("❌ CONNECT ERROR: $data");
    });

    _socket!.onError((data) {
      Utils.print("❌ SOCKET ERROR: $data");
    });

    _socket!.onReconnect((_) {
      Utils.print("🔁 SOCKET RECONNECTED");
    });

    // Listen for server's connection:success event (per doc)
    _socket!.on('connection:success', (data) {
      Utils.print("✅ CONNECTION SUCCESS: $data");
    });

    /// 🔥 Re-attach registered listeners to the new socket instance
    /// This is required for global listeners (like notifications) registered at app start
    _listeners.forEach((event, handlers) {
      for (var handler in handlers) {
        _socket!.on(event, handler);
      }
      Utils.print(
        "🔗 Re-attached ${handlers.length} handlers for event: $event",
      );
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    _disposed = true;
    disconnect();
    _connectedCtrl.close();
  }

  // ==============================
  // 🔥 LISTENER MANAGEMENT
  // ==============================

  void _addListener(String event, Function(dynamic) handler) {
    _listeners.putIfAbsent(event, () => []);

    // Safety: Don't add same handler instance twice
    if (_listeners[event]!.contains(handler)) {
      Utils.print(
        "ℹ️ Listener for '$event' already registered. Skipping map add.",
      );
      return;
    }

    _listeners[event]!.add(handler);
    Utils.print(
      "➕ Added listener for '$event'. Total active: ${_listeners[event]!.length}",
    );
  }

  void on(String event, Function(dynamic) handler) {
    _addListener(event, handler);
    _socket?.on(event, handler);
  }

  void off(String event, [Function(dynamic)? handler]) {
    if (handler != null) {
      final removed = _listeners[event]?.remove(handler) ?? false;
      _socket?.off(event, handler);
      Utils.print(
        "➖ Removed listener for '$event'. Success: $removed. Remaining: ${_listeners[event]?.length ?? 0}",
      );
    } else {
      _listeners.remove(event);
      _socket?.off(event);
      Utils.print("➖ Removed ALL listeners for '$event'.");
    }
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  // ==============================
  // 🔥 CONVERSATION ROOM MANAGEMENT
  // ==============================

  /// Join a conversation room (per doc: conversation:join with ack)
  void joinConversation(String conversationId) {
    Utils.print("Joining room: $conversationId");

    _socket?.emitWithAck(
      "conversation:join",
      {"conversationId": conversationId},
      ack: (data) {
        Utils.print("✅ JOIN RESPONSE: $data");
      },
    );
    // NOTE: No duplicate listener for conversation:joined here.
    // The controller/notification service register their own listeners.
  }

  /// Leave a conversation room (per doc: conversation:leave with ack)
  void leaveConversation(String conversationId) {
    Utils.print("Leaving room: $conversationId");

    _socket?.emitWithAck(
      "conversation:leave",
      {"conversationId": conversationId},
      ack: (data) {
        Utils.print("✅ LEAVE RESPONSE: $data");
      },
    );
  }

  // ==============================
  // 🔥 MESSAGING
  // ==============================

  /// Send a message with ack callback to receive the real message _id
  void sendMessage(
    String conversationId,
    String message, {
    Function(dynamic)? onAck,
  }) {
    Utils.print("📤 Sending message: $message");

    _socket?.emitWithAck(
      "message:send",
      {
        "conversationId": conversationId,
        "messageType": "text",
        "content": message,
      },
      ack: (response) {
        Utils.print("📤 SEND ACK: $response");
        onAck?.call(response);
      },
    );
  }

  void startTyping(String conversationId) {
    emit('typing:start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    emit('typing:stop', {'conversationId': conversationId});
  }

  /// Mark messages as read via socket (per doc: message:read)
  void markMessageRead(String conversationId, [List<String>? messageIds]) {
    final payload = <String, dynamic>{'conversationId': conversationId};
    if (messageIds != null && messageIds.isNotEmpty) {
      payload['messageIds'] = messageIds;
    }
    emit('message:read', payload);
  }

  // ==============================
  // 🔥 EVENT LISTENERS
  // ==============================

  // --- message:new ---
  void onNewMessage(Function(dynamic) callback) {
    on('message:new', callback);
  }

  void offNewMessage(Function(dynamic) callback) {
    off('message:new', callback);
  }

  // --- message:delivered ---
  void onMessageDelivered(Function(dynamic) callback) {
    on('message:delivered', callback);
  }

  void offMessageDelivered(Function(dynamic) callback) {
    off('message:delivered', callback);
  }

  // --- message:read:receipt (listening for both receipt and raw read event) ---
  void onMessageRead(Function(dynamic) callback) {
    on('message:read:receipt', callback);
    on('message:read', callback); // Catch-all for inconsistent naming
  }

  void offMessageRead(Function(dynamic) callback) {
    off('message:read:receipt', callback);
    off('message:read', callback);
  }

  // --- typing:status ---
  void onTypingStatus(Function(dynamic) callback) {
    on('typing:status', callback);
  }

  void offTypingStatus(Function(dynamic) callback) {
    off('typing:status', callback);
  }

  // --- partner:status:changed ---
  void onPartnerStatusChanged(Function(dynamic) callback) {
    on('partner:status:changed', callback);
  }

  void offPartnerStatusChanged(Function(dynamic) callback) {
    off('partner:status:changed', callback);
  }

  // --- notification:new:message (for out-of-room notifications) ---
  void onNotificationNewMessage(Function(dynamic) callback) {
    on('notification:new:message', callback);
  }

  void offNotificationNewMessage(Function(dynamic) callback) {
    off('notification:new:message', callback);
  }
}
