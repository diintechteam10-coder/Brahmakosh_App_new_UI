import 'package:brahmakosh/core/common_imports.dart';
import 'package:video_player/video_player.dart';
import 'package:sizer/sizer.dart';

import 'ai_rashmi_view_model.dart';
import 'deity_selection_service.dart';

class RashmiVoicePage extends StatefulWidget {
  const RashmiVoicePage({super.key});

  @override
  State<RashmiVoicePage> createState() => _RashmiVoicePageState();
}

class _RashmiVoicePageState extends State<RashmiVoicePage> {
  late VideoPlayerController _vicontroller;
  final DeitySelectionService _deityService = DeitySelectionService();

  @override
  void initState() {
    super.initState();
    // Get video path based on selected deity
    final videoPath = _deityService.getVideoPath();
    if (videoPath != null) {
      if (videoPath.startsWith('http')) {
        _vicontroller = VideoPlayerController.network(videoPath);
      } else {
        _vicontroller = VideoPlayerController.asset(videoPath);
      }

      _vicontroller.initialize().then((_) {
        if (mounted) {
          _vicontroller.setLooping(false);
          _vicontroller.setVolume(1.0);
          _vicontroller.seekTo(Duration.zero);
          _vicontroller.play();
          setState(() {});
        }
      }).catchError((error) {
        print('Video initialization error: $error');
      });
    } else {
      // Initialize with something even if null path to avoid LateInitializationError later
      _vicontroller = VideoPlayerController.asset('assets/images/bi_bg.mp4');
      _vicontroller.initialize().then((_) {
         if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _vicontroller.pause();
    _vicontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiRashmiController>(
      builder: (vm) {
        return Scaffold(
          body: Stack(
            children: [
              // Video Background
              Positioned.fill(
                child: _vicontroller.value.isInitialized
                    ? FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: _vicontroller.value.size.width,
                          height: _vicontroller.value.size.height,
                          child: VideoPlayer(_vicontroller),
                        ),
                      )
                    : Container(color: Colors.black),
              ),

              // Dark overlay
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.25)),
              ),

              // Main Content
              SafeArea(
                child: Column(
                  children: [
                    // Top Bar with Back Button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1.w),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                          const Spacer(),
                          Text(
                            _deityService.selectedDeityName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48), // Balance the back button
                        ],
                      ),
                    ),
                    SizedBox(height: 2.5.h),

                    // Status Indicators
                    if (vm.isInitializing)
                      LinearProgressIndicator(minHeight: 0.25.h),

                    if (vm.isRecording)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        color: Colors.green.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 3.w,
                              height: 3.w,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Listening... Tap to stop',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.isProcessingVoice)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        color: Colors.blue.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 4.w,
                              height: 4.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.blue,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Processing...',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.isPlayingAudio)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 1.h),
                        color: Colors.orange.withOpacity(0.1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.volume_up,
                              color: Colors.orange,
                              size: 4.w,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Speaking... Tap mic to interrupt',
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                                fontSize: 10.5.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (vm.error != null)
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.h,
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 1.25.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.red.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 5.w,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                vm.error!,
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                  fontSize: 9.75.sp,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.close,
                                color: Colors.red.shade700,
                                size: 4.5.w,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                vm.clearError();
                              },
                            ),
                          ],
                        ),
                      ),

                    const Spacer(),

                    // Voice Recording Button
                    GestureDetector(
                      onTap: vm.isPlayingAudio
                          // Agent is speaking → tap to interrupt
                          ? () async {
                              await vm.interruptAgent();
                            }
                          : (vm.isProcessingVoice && !vm.isRecording) ||
                                  vm.isSending
                              ? null
                              : () async {
                                  if (vm.isRecording) {
                                    await vm.stopVoiceRecording();
                                  } else {
                                    await vm.startVoiceRecording();
                                  }
                                },
                      onLongPress: vm.isPlayingAudio ||
                              (vm.isProcessingVoice && !vm.isRecording) ||
                              vm.isSending
                          ? null
                          : () async {
                              await vm.startVoiceRecording();
                            },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 30.w,
                        height: 30.w,
                        decoration: BoxDecoration(
                          color: vm.isPlayingAudio
                              ? Colors.orange
                              : vm.isRecording
                                  ? Colors.green
                                  : (vm.isProcessingVoice || vm.isSending
                                      ? Colors.white24
                                      : Colors.blueAccent),
                          shape: BoxShape.circle,
                          boxShadow: [
                            if (vm.isRecording)
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            if (vm.isPlayingAudio)
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.5),
                                blurRadius: 24,
                                spreadRadius: 6,
                              ),
                          ],
                        ),
                        child: vm.isPlayingAudio
                            // Show mic icon when agent is speaking (tap to interrupt)
                            ? Icon(
                                Icons.mic,
                                color: Colors.white,
                                size: 12.5.w,
                              )
                            : vm.isProcessingVoice && !vm.isRecording
                                ? Padding(
                                    padding: EdgeInsets.all(7.5.w),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 3,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    vm.isRecording ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                    size: 12.5.w,
                                  ),
                      ),
                    ),
                    SizedBox(height: 2.5.h),

                    // Instruction Text
                    Text(
                      vm.isPlayingAudio
                          ? 'Tap to interrupt'
                          : vm.isRecording
                              ? 'Streaming to AI... Tap to stop'
                              : 'Tap to start listening',
                      style: TextStyle(
                        color: vm.isPlayingAudio
                            ? Colors.orange.withOpacity(0.9)
                            : Colors.white70,
                        fontSize: 10.5.sp,
                        fontWeight: vm.isPlayingAudio
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),

                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
