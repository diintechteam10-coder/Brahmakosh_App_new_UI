import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/common_imports.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../common/models/astrologist_model.dart';
import '../controllers/voice_call_controller.dart';

class VoiceCallView extends StatefulWidget {
  final Astrologist expert;

  const VoiceCallView({Key? key, required this.expert}) : super(key: key);

  @override
  State<VoiceCallView> createState() => _VoiceCallViewState();
}

class _VoiceCallViewState extends State<VoiceCallView> {
  late final VoiceCallController controller;
  // We need an RTCVideoRenderer to play the remote audio stream
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  bool _rendererInitialized = false;

  @override
  void initState() {
    super.initState();
    controller = Get.put(VoiceCallController(expert: widget.expert));
    _initRenderers();
  }

  Future<void> _initRenderers() async {
    await _remoteRenderer.initialize();
    setState(() {
      _rendererInitialized = true;
    });

    // Listen to changes in the controller's remote stream to attach it
    // Using a worker to reactively assign the stream if GetX state was used,
    // but since we don't have an Rx for the stream, we just poll or check when connected.
    // A better approach is listening to the connected state.
    ever(controller.isConnected, (bool connected) {
      if (connected && controller.getRemoteStream() != null) {
        _remoteRenderer.srcObject = controller.getRemoteStream();
      }
    });
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    Get.delete<VoiceCallController>();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back button from killing the call without proper end
        // Provide a confirmation or just end the call
        if (!controller.isEnded.value) {
          controller.endCall();
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E), // Dark background for calls
        body: SafeArea(
          child: Stack(
            children: [
              // Hidden RTCVideoRenderer purely for audio playback
              if (_rendererInitialized)
                SizedBox(
                  width: 0,
                  height: 0,
                  child: RTCVideoView(_remoteRenderer),
                ),

              // Recording Indicator (Top Right)
              Obx(
                () => controller.isRecording.value
                    ? Positioned(
                        top: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.redAccent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Recording...",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),

                  // Call Header & Avatar
                  Column(
                    children: [
                      Text(
                        "Voice Consultation",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Avatar
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryGold.withOpacity(0.5),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGold.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                          image: widget.expert.image.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.expert.image),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: widget.expert.image.isEmpty
                            ? const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white54,
                              )
                            : null,
                      ),

                      const SizedBox(height: 24),

                      Text(
                        widget.expert.name,
                        style: GoogleFonts.lora(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Dynamic Status/Timer
                      Obx(() {
                        if (controller.isEnded.value) {
                          return Text(
                            "Call Ended",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.redAccent,
                            ),
                          );
                        } else if (controller.isConnecting.value) {
                          return Text(
                            "Connecting...",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: AppTheme.primaryGold,
                            ),
                          );
                        } else if (controller.isRinging.value) {
                          return Text(
                            "Ringing...",
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          );
                        } else {
                          return Text(
                            _formatDuration(controller.duration.value),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          );
                        }
                      }),
                    ],
                  ),

                  // Bottom Controls
                  Container(
                    padding: const EdgeInsets.only(bottom: 60, top: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute/Unmute
                        Obx(
                          () => _buildControlButton(
                            icon: controller.isMuted.value
                                ? Icons.mic_off
                                : Icons.mic,
                            color: controller.isMuted.value
                                ? Colors.white
                                : Colors.white24,
                            iconColor: controller.isMuted.value
                                ? Colors.black87
                                : Colors.white,
                            label: controller.isMuted.value ? "Unmute" : "Mute",
                            onTap: () => controller.toggleMute(),
                          ),
                        ),

                        // End Call
                        _buildControlButton(
                          icon: Icons.call_end,
                          color: Colors.redAccent,
                          iconColor: Colors.white,
                          label: "End",
                          size: 72,
                          iconSize: 36,
                          onTap: () {
                            controller.endCall();
                          },
                        ),

                        // Volume / Speaker
                        Obx(
                          () => _buildControlButton(
                            icon: controller.isSpeakerOn.value
                                ? Icons.volume_up
                                : Icons.volume_down,
                            color: controller.isSpeakerOn.value
                                ? Colors.white
                                : Colors.white24,
                            iconColor: controller.isSpeakerOn.value
                                ? Colors.black87
                                : Colors.white,
                            label: controller.isSpeakerOn.value
                                ? "Speaker On"
                                : "Speaker",
                            onTap: () => controller.toggleSpeaker(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    double size = 60,
    double iconSize = 28,
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
        ),
      ],
    );
  }
}

