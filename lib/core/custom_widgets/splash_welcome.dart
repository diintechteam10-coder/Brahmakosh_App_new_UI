import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WelcomeVideo extends StatefulWidget {
  final String videoAsset;
  final bool loop;
  final BoxFit fit;

  const WelcomeVideo({
    super.key,
    required this.videoAsset,
    this.loop = true,
    this.fit = BoxFit.cover,
  });

  @override
  State<WelcomeVideo> createState() => _WelcomeVideoState();
}

class _WelcomeVideoState extends State<WelcomeVideo> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoAsset)
      ..initialize().then((_) {
        if (!mounted) return;
        _controller
          ..setLooping(widget.loop)
          ..play();
        setState(() {});
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
      return const SizedBox.expand(
        child: ColoredBox(color: Colors.black),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    );
  }
}
