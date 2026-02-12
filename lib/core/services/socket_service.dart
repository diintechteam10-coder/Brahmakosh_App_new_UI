import 'dart:async';
import 'package:flutter/foundation.dart';

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

  /// 🔵 Connection stream (like your example)
  final _connectedCtrl = StreamController<bool>.broadcast();
  Stream<bool> get connected$ => _connectedCtrl.stream;

  bool get isConnected => _socket?.connected ?? false;

  /// 🔥 Store listeners for reconnect
  final Map<String, List<Function(dynamic)>> _listeners = {};

  Future<void> initSocket() async {
    if (_disposed) return;

    final token = StorageService.getString(AppConstants.keyAuthToken);

    if (token == null || token.isEmpty) {
      Utils.print('❌ Cannot connect to socket: No Auth Token');
      return;
    }

    /// 🔎 TOKEN VERIFICATION (kept as it is)
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

    _socket = IO.io(
      "https://stage.brahmakosh.com",
      IO.OptionBuilder()
          .setPath('/socket.io/')
          .setTransports(['polling'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setExtraHeaders({"Authorization": "Bearer $token"})
          .build(),
    );

    _socket!.connect();

    _attachCoreListeners();
  }

  /// 🔥 Core socket listeners
  void _attachCoreListeners() {
    _socket!.onConnect((_) {
      _isConnected = true;
      _connectedCtrl.add(true);

      Utils.print("✅ SOCKET CONNECTED");
      Utils.print("Socket ID: ${_socket!.id}");

      /// 🔁 Re-attach all stored listeners after reconnect
      _listeners.forEach((event, handlers) {
        for (final handler in handlers) {
          _socket!.on(event, handler);
        }
      });
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

    /// 🔥 Debug monitor (kept)
    _socket!.onAny((event, data) {
      Utils.print("📡 EVENT: $event");
      Utils.print("📦 DATA: $data");
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
  // 🔥 LISTENER MANAGEMENT (NEW)
  // ==============================

  void _addListener(String event, Function(dynamic) handler) {
    _listeners.putIfAbsent(event, () => []);
    _listeners[event]!.add(handler);
    Utils.print(
      "➕ Added listener for '$event'. Total: ${_listeners[event]!.length}",
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
  // 🔥 YOUR EXISTING METHODS (KEPT)
  // ==============================

  void joinConversation(String conversationId) {
    Utils.print("Joining room: $conversationId");

    _socket?.emitWithAck(
      "conversation:join",
      {"conversationId": conversationId},
      ack: (data) {
        Utils.print("✅ JOIN RESPONSE: $data");
      },
    );

    on("conversation:joined", (data) {
      Utils.print("✅ ROOM JOINED: $data");
    });
  }

  void sendMessage(String conversationId, String message) {
    Utils.print("📤 Sending message: $message");

    emit("message:send", {
      "conversationId": conversationId,
      "messageType": "text",
      "content": message,
    });
  }

  void startTyping(String conversationId) {
    emit('typing:start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    emit('typing:stop', {'conversationId': conversationId});
  }

  void markMessageRead(String conversationId, String messageId) {
    emit('message:read', {
      'conversationId': conversationId,
      'messageIds': [messageId],
    });
  }

  // Listeners
  void onNewMessage(Function(dynamic) callback) {
    on('message:new', callback);
  }

  void offNewMessage(Function(dynamic) callback) {
    off('message:new', callback);
  }

  void onMessageDelivered(Function(dynamic) callback) {
    on('message:delivered', callback);
  }

  void offMessageDelivered(Function(dynamic) callback) {
    off('message:delivered', callback);
  }

  void onMessageRead(Function(dynamic) callback) {
    on('message:read', callback);
  }

  void offMessageRead(Function(dynamic) callback) {
    off('message:read', callback);
  }

  void onTypingStatus(Function(dynamic) callback) {
    on('typing:status', callback);
  }

  void offTypingStatus(Function(dynamic) callback) {
    off('typing:status', callback);
  }

  void onPartnerStatusChanged(Function(dynamic) callback) {
    on('partner:status:changed', callback);
  }

  void offPartnerStatusChanged(Function(dynamic) callback) {
    off('partner:status:changed', callback);
  }
}
