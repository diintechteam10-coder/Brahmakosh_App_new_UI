import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/dummy_notifications.dart';
import '../models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allNotifications = DummyNotifications.getAll();
    final unreadCount = DummyNotifications.getUnreadCount();

    // Group notifications by time
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(const Duration(days: 7));

    final today = allNotifications
        .where((n) => n.createdAt.isAfter(todayStart))
        .toList();
    final thisWeek = allNotifications
        .where(
          (n) =>
              n.createdAt.isAfter(weekStart) &&
              n.createdAt.isBefore(todayStart),
        )
        .toList();
    final earlier = allNotifications
        .where((n) => n.createdAt.isBefore(weekStart))
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.homeBackground,
      body: CustomScrollView(
        slivers: [
          // Custom AppBar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Notifications',
                      style: GoogleFonts.lora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3E2723),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: GoogleFonts.lora(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Today Section
          if (today.isNotEmpty) ...[
            _buildSectionHeader('Today'),
            _buildNotificationList(today, context),
          ],

          // This Week Section
          if (thisWeek.isNotEmpty) ...[
            _buildSectionHeader('This Week'),
            _buildNotificationList(thisWeek, context),
          ],

          // Earlier Section
          if (earlier.isNotEmpty) ...[
            _buildSectionHeader('Earlier'),
            _buildNotificationList(earlier, context),
          ],

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        child: Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF8D6E63),
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationModel> notifications,
    BuildContext context,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          return _NotificationCard(
            notification: notifications[index],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(
                    notification: notifications[index],
                  ),
                ),
              );
            },
          );
        }, childCount: notifications.length),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final info = notification.categoryInfo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: notification.isRead
              ? null
              : Border.all(color: info.color.withValues(alpha: 0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: notification.isRead
                  ? Colors.black.withValues(alpha: 0.04)
                  : info.color.withValues(alpha: 0.1),
              blurRadius: notification.isRead ? 6 : 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: info.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(info.icon, color: info.color, size: 24),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: GoogleFonts.lora(
                      fontSize: 14.5,
                      fontWeight: notification.isRead
                          ? FontWeight.w500
                          : FontWeight.w700,
                      color: const Color(0xFF3E2723),
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.lora(
                      fontSize: 12.5,
                      color: const Color(0xFF8D6E63),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: info.color.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          info.label,
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: info.color,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatTime(notification.createdAt),
                        style: GoogleFonts.lora(
                          fontSize: 11,
                          color: const Color(0xFFBCAAA4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead)
              Padding(
                padding: const EdgeInsets.only(left: 8, top: 4),
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Yesterday';
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

