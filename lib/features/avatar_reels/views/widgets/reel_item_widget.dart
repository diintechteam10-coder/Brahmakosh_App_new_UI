import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/common/models/brahm_reel.dart';
import 'package:brahmakosh/features/avatar_reels/controllers/avatar_reels_controller.dart';

class ReelItemWidget extends StatefulWidget {
  final ReelItem reel;
  final int index;

  const ReelItemWidget({super.key, required this.reel, required this.index});

  @override
  State<ReelItemWidget> createState() => _ReelItemWidgetState();
}

class _ReelItemWidgetState extends State<ReelItemWidget> {
  late VideoPlayerController _controller;
  final AvatarReelsController controller = Get.find<AvatarReelsController>();

  @override
  void initState() {
    super.initState();
    _initVideo();

    // Listen to mute state changes
    ever(controller.isMuted, (bool muted) {
      _controller.setVolume(muted ? 0 : 1);
    });
  }

  void _initVideo() {
    if (widget.reel.videoUrl == null || widget.reel.videoUrl!.isEmpty) return;
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl!))
          ..initialize().then((_) {
            setState(() {});
            _controller.setLooping(true);
            _controller.setVolume(controller.isMuted.value ? 0 : 1);
            _controller.play();
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Video Player
        GestureDetector(
          onTap: () {
            if (_controller.value.isPlaying) {
              _controller.pause();
            } else {
              _controller.play();
            }
          },
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        ),

        // Bottom Details (Name & Description)
        Positioned(
          left: 16,
          bottom: 40,
          right: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.reel.name ?? "Avatar Name",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),

        // Right Side Actions
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              Obx(
                () => _ActionButton(
                  icon: controller.likedReels[widget.index] == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: controller.likedReels[widget.index] == true
                      ? Colors.red
                      : Colors.white,
                  label: (widget.reel.likes ?? 0).toString(),
                  onTap: () => controller.toggleLike(widget.index),
                ),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.share,
                label: (widget.reel.shares ?? 0).toString(),
                onTap: () => controller.shareReel(widget.index),
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.remove_red_eye,
                label: (widget.reel.views ?? 0).toString(),
                onTap: () {}, // Views are read-only
              ),
              const SizedBox(height: 20),
              _ActionButton(
                icon: Icons.download_for_offline,
                label: "Save",
                onTap: () => controller.downloadReel(widget.index),
              ),
            ],
          ),
        ),

        // Mute Button Overlay
        Positioned(
          top: 60,
          right: 20,
          child: Obx(
            () => IconButton(
              icon: Icon(
                controller.isMuted.value ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 30,
              ),
              onPressed: controller.toggleMute,
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 60,
          left: 10,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, color: color, size: 35),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
