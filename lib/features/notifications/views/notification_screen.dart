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
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            final bool hasNotifications = state is NotificationLoaded && state.notifications.isNotEmpty;

            return Column(
              children: [
                // Premium Header
                _buildHeader(context, showMarkAll: hasNotifications),

                Expanded(
                  child: _buildContent(context, state),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, {required bool showMarkAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            "notifications_title".tr,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
              letterSpacing: 2.0,
            ),
          ),
          if (showMarkAll)
            GestureDetector(
              onTap: () {
                context.read<NotificationBloc>().add(MarkAllReadEvent());
              },
              child: Text(
                "mark_all".tr,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            const SizedBox(width: 40), // Balance the row
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, NotificationState state) {
    if (state is NotificationLoading) {
      return _buildNotificationShimmer();
    }

    if (state is NotificationError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                color: AppTheme.errorRed.withOpacity(0.5), size: 48),
            const SizedBox(height: 16),
            Text(state.message, style: const TextStyle(color: Colors.white70)),
            TextButton(
              onPressed: () =>
                  context.read<NotificationBloc>().add(const FetchNotifications()),
              child: Text("retry".tr,
                  style: TextStyle(color: AppTheme.primaryGold)),
            ),
          ],
        ),
      );
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
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Today Section
            if (today.isNotEmpty) ...[
              _buildSectionHeader("today".tr),
              _buildNotificationList(today, context),
            ],

            // This Week Section
            if (thisWeek.isNotEmpty) ...[
              _buildSectionHeader("this_week".tr),
              _buildNotificationList(thisWeek, context),
            ],

            // Earlier Section
            if (earlier.isNotEmpty) ...[
              _buildSectionHeader("earlier".tr),
              _buildNotificationList(earlier, context),
            ],

            if (!state.hasReachedMax)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primaryGold, strokeWidth: 2),
                  ),
                ),
              ),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withOpacity(0.05),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.05),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 60,
                    color: AppTheme.primaryGold.withOpacity(0.2),
                  ),
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 32,
                    color: AppTheme.primaryGold.withOpacity(0.8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "no_notifications_title".tr,
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "no_notifications_desc".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.4),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          TextButton.icon(
            onPressed: () {
              context.read<NotificationBloc>().add(const FetchNotifications());
            },
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: Text(
              "refresh_inbox".tr,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryGold,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.3)),
              ),
            ),
          ),
          const SizedBox(height: 100), // Push up slightly from true center
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
    return ListView.builder(
      itemCount: 8,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) => _buildShimmerItem(),
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

