import 'package:brahmakosh/core/common_imports.dart';
import '../../../../core/theme/app_theme.dart';
import '../data/dummy_notifications.dart';
import '../models/notification_model.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final allNotifications = DummyNotifications.getAll();

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
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: [
          // Premium AppBar
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'NOTIFICATION',
                      style: GoogleFonts.lora(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                        letterSpacing: 2.0,
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
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationModel> notifications,
    BuildContext context,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF151517),
            // borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (var i = 0; i < notifications.length; i++) ...[
                _NotificationCard(
                  notification: notifications[i],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NotificationDetailScreen(
                          notification: notifications[i],
                        ),
                      ),
                    );
                  },
                ),
                if (i < notifications.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Divider(
                      color: Colors.white.withOpacity(0.06),
                      height: 1,
                    ),
                  ),
              ],
            ],
          ),
        ),
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Category Icon - Rounded Square with darker background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getDisplayIcon(notification.category), 
                color: _getIconColor(notification.category), 
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                       if (!notification.isRead) ...[
              const SizedBox(width: 12),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withOpacity(0.4),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
            ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.4),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
           
          
          ],
        ),
      ),
    );
  }

  IconData _getDisplayIcon(NotificationCategory category) {
    // Attempt to match the reference image icons if possible
    // Reference has Star, Heart, Moon
    switch (category) {
      case NotificationCategory.dailyAstrology:
        return Icons.star_rounded;
      case NotificationCategory.emotionalCompanion:
        return Icons.favorite_rounded;
      case NotificationCategory.spiritualCheckIn:
        return Icons.nightlight_round;
      default:
        return NotificationCategoryInfo.getInfo(category).icon;
    }
  }

  Color _getIconColor(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.dailyAstrology:
        return const Color(0xFFFFD700);
      case NotificationCategory.emotionalCompanion:
        return Colors.red;
      case NotificationCategory.spiritualCheckIn:
        return const Color(0xFF7E57C2);
      default:
        return NotificationCategoryInfo.getInfo(category).color;
    }
  }
}

