import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/notification_bloc.dart';
import '../models/notification_model.dart';
import '../../../core/services/push_notification_service.dart';
import 'notification_detail_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Initial fetch
    context.read<NotificationBloc>().add(const FetchNotifications());
    // Print token for debugging
    PushNotificationService.instance.registerToken();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationBloc>().add(const LoadMoreNotifications());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return _buildNotificationShimmer();
          }

          if (state is NotificationError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
          }

          if (state is NotificationLoaded) {
            final allNotifications = state.notifications;
            
            if (allNotifications.isEmpty) {
              return _buildEmptyState();
            }

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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(const FetchNotifications());
              },
              color: AppTheme.primaryGold,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Premium AppBar
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
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
                            Text(
                              'NOTIFICATION',
                              style: GoogleFonts.lora(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryGold,
                                letterSpacing: 2.0,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<NotificationBloc>().add(MarkAllReadEvent());
                              },
                              child: Text(
                                'Mark all',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.w500,
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

                  if (!state.hasReachedMax)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold, strokeWidth: 2)),
                      ),
                    ),

                  // Bottom padding
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 16),
          ),
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
          ),
          child: Column(
            children: [
              for (var i = 0; i < notifications.length; i++) ...[
                _NotificationCard(
                  notification: notifications[i],
                  onTap: () {
                    if (!notifications[i].isRead) {
                      context.read<NotificationBloc>().add(MarkReadEvent(notifications[i].id));
                    }
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

  Widget _buildNotificationShimmer() {
    return Column(
      children: [
        // Fake AppBar Shimmer
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
            child: Shimmer.fromColors(
              baseColor: Colors.white.withOpacity(0.05),
              highlightColor: Colors.white.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 150,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // List Shimmers
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => _buildShimmerItem(),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 200,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

