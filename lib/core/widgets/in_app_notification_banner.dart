import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_notification_service.dart';
import '../theme/app_theme.dart';

/// A globally-overlaid animated banner that shows chat notifications.
///
/// Place this at the top of the widget tree (e.g. in `GetMaterialApp.builder`)
/// so it can appear over any screen.
class InAppNotificationBanner extends StatefulWidget {
  final Widget child;

  const InAppNotificationBanner({super.key, required this.child});

  @override
  State<InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<Offset> _slideAnimation;
  late final ChatNotificationService _notifService;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _notifService = Get.find<ChatNotificationService>();

    // React to show/hide changes
    ever(_notifService.showNotification, (bool show) {
      if (show) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main app content
        widget.child,

        // Notification overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SlideTransition(
            position: _slideAnimation,
            child: GestureDetector(
              onTap: () => _notifService.onNotificationTapped(),
              onVerticalDragEnd: (details) {
                // Swipe up to dismiss
                if (details.primaryVelocity != null &&
                    details.primaryVelocity! < -100) {
                  _notifService.dismissNotification();
                }
              },
              child: Obx(() {
                if (!_notifService.showNotification.value) {
                  return const SizedBox.shrink();
                }
                return SafeArea(
                  bottom: false,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF3E2723), // deep brown
                          Color(0xFF5D4037), // medium brown
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryGold.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            // Expert avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryGold,
                                  width: 2,
                                ),
                                image:
                                    _notifService
                                        .notificationImage
                                        .value
                                        .isNotEmpty
                                    ? DecorationImage(
                                        image: NetworkImage(
                                          _notifService.notificationImage.value,
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child:
                                  _notifService.notificationImage.value.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: AppTheme.primaryGold,
                                      size: 24,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),

                            // Title + body
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _notifService.notificationTitle.value,
                                    style: GoogleFonts.cinzel(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryGold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _notifService.notificationBody.value,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.white70,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Chat icon indicator
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                color: AppTheme.primaryGold,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
