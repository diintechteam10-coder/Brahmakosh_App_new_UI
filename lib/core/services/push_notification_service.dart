import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/notifications/repositories/notification_repository.dart';
import 'chat_notification_service.dart';
import '../../common/utils.dart';
import 'package:get/get.dart';

class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._internal();
  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final NotificationRepository _repository = NotificationRepository();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Request permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      Utils.print('User granted permission');
    } else {
      Utils.print('User declined or has not accepted permission');
      return;
    }

    // 2. Setup Local Notifications for Foreground
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap when app is in foreground
        Utils.print('Notification Tapped: ${response.payload}');
        if (response.payload != null) {
          try {
            final ChatNotificationService notifService = Get.find<ChatNotificationService>();
            notifService.handleNotificationTap(response.payload);
          } catch (e) {
            Utils.print('❌ Error handling notification tap: $e');
          }
        }
      },
    );

    // 3. Listen for Messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    
    // Create high importance channel for Android
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      const AndroidNotificationChannel urgentChannel = AndroidNotificationChannel(
        'brahmakosh_urgent_notifications', // id
        'Urgent Notifications', // title
        description: 'This channel is used for important app notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
        'brahmakosh_chat_notifications', // id
        'Chat Notifications', // title
        description: 'This channel is used for chat message notifications.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidPlugin?.createNotificationChannel(urgentChannel);
      await androidPlugin?.createNotificationChannel(chatChannel);
    }

    // Initial message if app was terminated
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }

    _isInitialized = true;
    
    // 4. Get and Register Token
    await registerToken();
  }

  Future<void> registerToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        debugPrint("\n\n" + "X" * 30);
        debugPrint("FCM TOKEN: $token");
        debugPrint("X" * 30 + "\n\n");
        
        String platform = Platform.isAndroid ? "android" : "ios";
        await _repository.registerPushToken(token, platform);
      }
    } catch (e) {
      Utils.print("Error getting FCM token: $e");
    }
  }

  Future<void> removeToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _repository.removePushToken(token);
      }
    } catch (e) {
      Utils.print("Error removing FCM token: $e");
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    Utils.print('Got a message whilst in the foreground!');
    Utils.print('Message data: ${message.data}');

    if (message.notification != null) {
      Utils.print('Message also contained a notification: ${message.notification}');
      PushNotificationService.showLocalNotification(message);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {
    Utils.print('Message clicked! ${message.data}');
    // Navigate to notifications screen or specific URL
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();
    
    // Simple initialization for background use
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await localNotifications.initialize(
      settings: initializationSettings,
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'brahmakosh_urgent_notifications', // id
      'Urgent Notifications', // title
      channelDescription: 'This channel is used for important app notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotifications.show(
      id: message.hashCode,
      title: message.notification?.title ?? message.data['title'],
      body: message.notification?.body ?? message.data['body'],
      notificationDetails: platformChannelSpecifics,
      payload: message.data['url'],
    );
  }

  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    final FlutterLocalNotificationsPlugin localNotifications = FlutterLocalNotificationsPlugin();

    // Ensure settings are initialized (especially important for background/socket usage)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          try {
            final ChatNotificationService notifService = Get.find<ChatNotificationService>();
            notifService.handleNotificationTap(response.payload);
          } catch (e) {
            Utils.print('❌ Error handling notification tap: $e');
          }
        }
      },
    );

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'brahmakosh_chat_notifications', // id
      'Chat Notifications', // title
      channelDescription: 'This channel is used for chat message notifications.',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await localNotifications.show(
      id: DateTime.now().microsecondsSinceEpoch % 1000000,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }
}
