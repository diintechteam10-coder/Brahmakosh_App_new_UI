import 'package:brahmakosh/features/avatar_reels/controllers/avatar_reels_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';

class AvatarStudioCard extends StatelessWidget {
  AvatarStudioCard({super.key});

  final AvatarReelsController _reelsController =
      Get.isRegistered<AvatarReelsController>()
      ? Get.find<AvatarReelsController>()
      : Get.put(AvatarReelsController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.deepGold),
                  const SizedBox(width: 8),
                  Text(
                    "Brahm Avatar",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔹 AVATAR VIDEO CARDS
            Obx(() {
              if (_reelsController.isLoading.value &&
                  _reelsController.reels.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                    ),
                  ),
                );
              }

              if (_reelsController.reels.isEmpty) {
                return const SizedBox.shrink();
              }

              // Show first 3 reels
              final displayReels = _reelsController.reels.take(3).toList();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: displayReels.asMap().entries.map((entry) {
                    final index = entry.key;
                    final reel = entry.value;
                    return _VideoAvatarCard(
                      videoPath: reel.videoUrl ?? "",
                      index: index,
                    );
                  }).toList(),
                ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// 🔹 SINGLE VIDEO CARD (Video-player style)
class _VideoAvatarCard extends StatefulWidget {
  final String videoPath;
  final int index;
  const _VideoAvatarCard({required this.videoPath, required this.index});

  @override
  State<_VideoAvatarCard> createState() => _VideoAvatarCardState();
}

class _VideoAvatarCardState extends State<_VideoAvatarCard> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoPath.isEmpty) return;

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoPath))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller.setLooping(true);
          _controller.setVolume(0); // Muted by default for preview
          _controller.play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final AvatarReelsController controller = Get.find<AvatarReelsController>();
        print("AvatarStudioCard: Tapping reel at index ${widget.index}");
        controller.currentIndex.value = widget.index;
        Get.toNamed(AppConstants.routeAvatarReels);
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.25,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.3),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_isInitialized)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),
            // Play icon overlay
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
