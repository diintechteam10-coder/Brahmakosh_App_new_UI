import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../common/api_urls.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/storage_service.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  Future<NotificationResponse> getNotifications() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
      final response = await http.get(
        Uri.parse(ApiUrls.notifications),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return NotificationResponse.fromJson(data);
      } else {
        throw Exception('Failed to load notifications');
      }
    } catch (e) {
      throw Exception('Error fetching notifications: $e');
    }
  }
}
