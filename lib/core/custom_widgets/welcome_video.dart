import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CircularVideoAvatar extends StatefulWidget {
  final String videoAsset;
  final double size;
  final Color glowColor;
  final double borderWidth;
  final bool loop;

  const CircularVideoAvatar({
    super.key,
    required this.videoAsset,
    this.size = 180,
    this.glowColor = Colors.amber,
    this.borderWidth = 3,
    this.loop = true,
  });

  @override
  State<CircularVideoAvatar> createState() => _CircularVideoAvatarState();
}

class _CircularVideoAvatarState extends State<CircularVideoAvatar> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(widget.videoAsset);
    await _controller!.initialize();

    if (!mounted) return;

    _controller!
      ..setLooping(widget.loop)
      ..play();

    setState(() {});
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double outerSize = widget.size + 20;

    return Center(
      child: Container(
        width: outerSize,
        height: outerSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              widget.glowColor.withOpacity(0.6),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.glowColor,
                width: widget.borderWidth,
              ),
            ),
            child: ClipOval(
              child: _controller != null &&
                      _controller!.value.isInitialized
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    )
                  : Center(
                      child: CircularProgressIndicator(
                        color: widget.glowColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
