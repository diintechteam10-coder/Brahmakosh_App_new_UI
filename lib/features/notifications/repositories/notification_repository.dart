import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../../../common/api_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  /// Fetch paginated notifications
  Future<NotificationResponse> getNotifications({int limit = 20, int skip = 0}) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.get(
        Uri.parse("${ApiUrls.notifications}?limit=$limit&skip=$skip"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationResponse.fromJson(data);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }

  /// Mark single notification as read
  Future<bool> markAsRead(String id) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.put(
        Uri.parse("${ApiUrls.notifications}/$id/read"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.put(
        Uri.parse(ApiUrls.markAllRead),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get total unread notifications count
  Future<int> getUnreadCount() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.get(
        Uri.parse(ApiUrls.notificationUnreadCount),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("NOTIFICATION_REPOSITORY: Unread count response: $data");
        // Ensure we parse the 'data' field which contains the count
        final count = data['data'] ?? 0;
        debugPrint("NOTIFICATION_REPOSITORY: Parsed count: $count");
        return count;
      }
      debugPrint("NOTIFICATION_REPOSITORY: Error response: ${response.statusCode} - ${response.body}");
      return 0;
    } catch (e) {
      debugPrint("NOTIFICATION_REPOSITORY: Exception: $e");
      return 0;
    }
  }

  /// Register or update FCM token
  Future<bool> registerPushToken(String fcmToken, String platform) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.put(
        Uri.parse(ApiUrls.pushToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "fcmToken": fcmToken,
          "platform": platform,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Remove FCM token on logout
  Future<bool> removePushToken(String fcmToken) async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.delete(
        Uri.parse(ApiUrls.pushToken),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "fcmToken": fcmToken,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
