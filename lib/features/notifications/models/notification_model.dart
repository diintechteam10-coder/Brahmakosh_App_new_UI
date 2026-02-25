import 'package:flutter/material.dart';

enum NotificationCategory {
  dailyAstrology,
  offer,
  surveyFeedback,
  newLaunchFeature,
  missedActivity,
  spiritualCheckIn,
  criticalAlert,
  remedies,
  aiIntuition,
  specialOccasion,
  rewards,
  emotionalCompanion,
  paymentRequest,
  appUpdate,
}

class NotificationCategoryInfo {
  final String label;
  final IconData icon;
  final Color color;

  const NotificationCategoryInfo({
    required this.label,
    required this.icon,
    required this.color,
  });

  static NotificationCategoryInfo getInfo(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.dailyAstrology:
        return const NotificationCategoryInfo(
          label: 'Daily Astrology',
          icon: Icons.auto_awesome,
          color: Color(0xFFD4AF37),
        );
      case NotificationCategory.offer:
        return const NotificationCategoryInfo(
          label: 'BrahmaBazaar Offers',
          icon: Icons.local_offer,
          color: Color(0xFFFFD700),
        );
      case NotificationCategory.surveyFeedback:
        return const NotificationCategoryInfo(
          label: 'Survey & Feedback',
          icon: Icons.poll,
          color: Color(0xFF2E7D32),
        );
      case NotificationCategory.newLaunchFeature:
        return const NotificationCategoryInfo(
          label: 'New Launch',
          icon: Icons.rocket_launch,
          color: Color(0xFF4169E1),
        );
      case NotificationCategory.missedActivity:
        return const NotificationCategoryInfo(
          label: 'Missed Activity',
          icon: Icons.access_time_rounded,
          color: Color(0xFFFF8C00),
        );
      case NotificationCategory.spiritualCheckIn:
        return const NotificationCategoryInfo(
          label: 'Spiritual Check-In',
          icon: Icons.self_improvement,
          color: Color(0xFF8208BF),
        );
      case NotificationCategory.criticalAlert:
        return const NotificationCategoryInfo(
          label: 'Critical Alert',
          icon: Icons.warning_amber_rounded,
          color: Color(0xFFDC143C),
        );
      case NotificationCategory.remedies:
        return const NotificationCategoryInfo(
          label: 'Remedies',
          icon: Icons.spa,
          color: Color(0xFF00897B),
        );
      case NotificationCategory.aiIntuition:
        return const NotificationCategoryInfo(
          label: 'AI Intuition',
          icon: Icons.psychology,
          color: Color(0xFF4B0082),
        );
      case NotificationCategory.specialOccasion:
        return const NotificationCategoryInfo(
          label: 'Special Occasion',
          icon: Icons.cake,
          color: Color(0xFFE91E63),
        );
      case NotificationCategory.rewards:
        return const NotificationCategoryInfo(
          label: 'Rewards',
          icon: Icons.card_giftcard,
          color: Color(0xFFFCA016),
        );
      case NotificationCategory.emotionalCompanion:
        return const NotificationCategoryInfo(
          label: 'Companion',
          icon: Icons.favorite,
          color: Color(0xFFE57373),
        );
      case NotificationCategory.paymentRequest:
        return const NotificationCategoryInfo(
          label: 'Payments',
          icon: Icons.payment,
          color: Color(0xFF607D8B),
        );
      case NotificationCategory.appUpdate:
        return const NotificationCategoryInfo(
          label: 'App Update',
          icon: Icons.system_update,
          color: Color(0xFF455A64),
        );
    }
  }
}

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? description;
  final DateTime createdAt;
  final bool isRead;
  final NotificationCategory category;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.description,
    required this.createdAt,
    required this.isRead,
    required this.category,
  });

  NotificationCategoryInfo get categoryInfo =>
      NotificationCategoryInfo.getInfo(category);

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Content',
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      category: NotificationCategory.dailyAstrology,
    );
  }
}

class NotificationResponse {
  final bool success;
  final List<NotificationModel> data;
  final int unreadCount;
  final int total;

  NotificationResponse({
    required this.success,
    required this.data,
    required this.unreadCount,
    required this.total,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (e) => NotificationModel.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      unreadCount: json['unreadCount'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
