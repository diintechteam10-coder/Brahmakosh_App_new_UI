import 'package:brahmakosh/features/updates/controller/status_controller.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WhatsAppStatusWidget extends StatelessWidget {
  const WhatsAppStatusWidget({super.key});

  // 8 Prahar names
  static const List<String> praharNames = [
    'Brahma Prahar',
    'Usha Prahar',
    'Pratah Prahar',
    'Madhyahna Prahar',
    'Aparahna Prahar',
    'Sayah Prahar',
    'Sandhya Prahar',
    'Nishitha Prahar',
  ];

  @override
  Widget build(BuildContext context) {
    final StatusController controller = Get.put(StatusController());
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: controller.totalStatus,
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () {
              controller.onTapStatus(index);
              _showStoryBottomSheet(context, controller, index);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGold,
                        AppTheme.chakraOrange,
                        AppTheme.chakraRed,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: Get.width * 0.08,
                      backgroundColor: AppTheme.lightGold.withOpacity(0.5),
                      child: Icon(
                        Icons.person,
                        color: AppTheme.primaryGold.withOpacity(0.8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  praharNames[index],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showStoryBottomSheet(
    BuildContext context,
    StatusController controller,
    int initialIndex,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => DraggableStorySheet(
        controller: controller,
        initialIndex: initialIndex,
      ),
    );
  }
}

class DraggableStorySheet extends StatefulWidget {
  final StatusController controller;
  final int initialIndex;

  const DraggableStorySheet({
    super.key,
    required this.controller,
    required this.initialIndex,
  });

  @override
  State<DraggableStorySheet> createState() => _DraggableStorySheetState();
}

class _DraggableStorySheetState extends State<DraggableStorySheet> {
  late PageController _pageController;
  final ValueNotifier<double> _sheetSizeNotifier = ValueNotifier<double>(0.75);
  bool _isCurrentlyFullScreen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.initialIndex,

      viewportFraction: 0.88,
    );
    widget.controller.currentIndex.value = widget.initialIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sheetSizeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            // Update the notifier which will trigger ValueListenableBuilder rebuild
            _sheetSizeNotifier.value = notification.extent;

            final isFull = notification.extent >= 0.98;
            if (isFull != _isCurrentlyFullScreen) {
              setState(() {
                _isCurrentlyFullScreen = isFull;
                final currentPage = widget.controller.currentIndex.value;
                // We keep the old controller until the next frame to avoid disposal issues during build
                final oldController = _pageController;
                _pageController = PageController(
                  initialPage: currentPage,
                  viewportFraction: isFull ? 1.0 : 0.88,
                );
                // Dispose the old controller after the current frame
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  oldController.dispose();
                });
              });
            }
            return true;
          },
          child: ValueListenableBuilder<double>(
            valueListenable: _sheetSizeNotifier,
            builder: (context, size, _) {
              // Full screen when size is very close to 1.0 (0.98 threshold)
              final isFullScreen = size >= 0.98;

              return Container(
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Column(
                  children: [
                    // Horizontal scrollable content - each story is separate
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        physics: isFullScreen
                            ? const NeverScrollableScrollPhysics()
                            : const PageScrollPhysics(),
                        onPageChanged: (index) {
                          widget.controller.currentIndex.value = index;
                        },
                        itemCount: widget.controller.totalStatus,
                        itemBuilder: (context, index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.symmetric(
                              horizontal: isFullScreen ? 0.0 : 12.0,
                              vertical: isFullScreen ? 0.0 : 8.0,
                            ),
                            child: _StoryContent(
                              praharName:
                                  WhatsAppStatusWidget.praharNames[index],
                              index: index,
                              scrollController: scrollController,
                              isFullScreen: isFullScreen,
                            ),
                          );
                        },
                      ),
                    ),
                    // Page indicators
                    Obx(
                      () => Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isFullScreen ? 8 : 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.controller.totalStatus,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width:
                                  widget.controller.currentIndex.value == index
                                  ? 24
                                  : 8,
                              height: 6,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color:
                                    widget.controller.currentIndex.value ==
                                        index
                                    ? AppTheme.primaryGold
                                    : AppTheme.textSecondary.withOpacity(0.2),
                                boxShadow:
                                    widget.controller.currentIndex.value ==
                                        index
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryGold
                                              .withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : [],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryContent extends StatelessWidget {
  final String praharName;
  final int index;
  final ScrollController scrollController;
  final bool isFullScreen;

  const _StoryContent({
    required this.praharName,
    required this.index,
    required this.scrollController,
    required this.isFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    // Each story is a separate card container
    // Disable scroll when full screen, enable when not full screen
    final content = Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: isFullScreen ? 0 : 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: isFullScreen
            ? const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.zero,
                bottomRight: Radius.zero,
              )
            : const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
        border: isFullScreen
            ? null
            : Border.all(
                color: AppTheme.primaryGold.withOpacity(0.3),
                width: 1.5,
              ),
        boxShadow: isFullScreen
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: isFullScreen
          ? SizedBox.expand(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Story header with animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) => Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      ),
                      child: Text(
                        praharName,
                        style: AppTheme.lightTheme.textTheme.headlineLarge
                            ?.copyWith(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Story image/content area with shadow and gradient
                    Container(
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Center(
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 80,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Story ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Pure Essence of Time',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Story description with entry animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween(begin: 0.0, end: 1.0),
                      builder: (context, value, child) =>
                          Opacity(opacity: value, child: child),
                      child: Text(
                        'Experience the divine energy of $praharName. This segment of time carries unique vibrations that influence our physical and mental well-being.',
                        style: AppTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(
                              color: AppTheme.textSecondary,
                              height: 1.6,
                            ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Detailed Info Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryGold.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.info_outline,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auspicious Timing',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Learn more about the best practices for this period.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  praharName,
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.auto_awesome,
                            size: 40,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Story ${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            praharName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Divine essence of $praharName. Discover the spiritual significance of this sacred time.',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_filled,
                        color: AppTheme.primaryGold,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Tap to expand details',
                        style: TextStyle(
                          color: AppTheme.primaryGold.withOpacity(0.8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );

    if (isFullScreen) {
      // When full screen, return content directly to take full height
      return content;
    } else {
      // When not full screen, wrap in scrollable
      return SingleChildScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        child: content,
      );
    }
  }
}
