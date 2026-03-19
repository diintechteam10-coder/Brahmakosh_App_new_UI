import 'dart:async';
import 'package:flutter/material.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

class NeonVoiceRing extends StatefulWidget {
  final bool isListening;
  final bool isSpeaking;

  const NeonVoiceRing({
    Key? key,
    required this.isListening,
    this.isSpeaking = false,
  }) : super(key: key);

  @override
  State<NeonVoiceRing> createState() => _NeonVoiceRingState();
}

class _NeonVoiceRingState extends State<NeonVoiceRing>
    with SingleTickerProviderStateMixin {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  bool _isRecording = false;

  late AnimationController _pulseController;

  double _targetScale = 1.0;
  double _currentMicScale = 1.0;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();

    // Smooth idle breathing animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    if (widget.isListening) {
      _startListening();
    }
  }

  @override
  void didUpdateWidget(NeonVoiceRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isListening != oldWidget.isListening) {
      if (widget.isListening) {
        _startListening();
      } else {
        _stopListening();
      }
    }

    if (widget.isSpeaking != oldWidget.isSpeaking) {
      if (widget.isSpeaking) {
        // Faster pulsing when AI is speaking
        _pulseController.duration = const Duration(milliseconds: 800);
        _pulseController.repeat(reverse: true);
      } else {
        // Return to normal idle length
        _pulseController.duration = const Duration(milliseconds: 1500);
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      if (await Permission.microphone.request().isGranted) {
        _noiseSubscription = _noiseMeter?.noise.listen(
          (NoiseReading noise) {
            if (!mounted) return;
            final db = noise.meanDecibel;

            // Normalize DB to scale (typical room is ~40dB, loud voice is ~80dB)
            double normalized = (db - 40) / 40;
            normalized = normalized.clamp(0.0, 1.0);

            // Base scale 0.85, max scale 1.35
            double newTarget = 0.85 + (normalized * 0.50);
            _targetScale = newTarget;
          },
          onError: (Object error) {
            debugPrint("NeonVoiceRing - Noise meter error: $error");
            _stopListening();
          },
        );
        setState(() {
          _targetScale = 0.85;
          _isRecording = true;
        });
      }
    } catch (err) {
      debugPrint("NeonVoiceRing - Microphone access error: $err");
    }
  }

  void _stopListening() {
    _noiseSubscription?.cancel();
    _noiseSubscription = null;
    if (mounted) {
      setState(() {
        _isRecording = false;
        _targetScale = 1.0; // Reset target scale
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          // Smoothly interpolate current mic scale towards target scale
          // Adjust lerp factor for snappiness (0.15 is fairly smooth for 60fps)
          _currentMicScale += (_targetScale - _currentMicScale) * 0.15;

          double finalScale = 1.0;

          // Breathing curve
          final pulseValue = Curves.easeInOutSine.transform(
            _pulseController.value,
          );

          if (widget.isSpeaking) {
            // When AI is speaking, prominent pulsing logic
            finalScale = 1.0 + (pulseValue * 0.15); // Scale 1.0 to 1.15
          } else if (widget.isListening && _isRecording) {
            // When listening, react to mic plus a very subtle breathe so it's not totally dead on silence
            finalScale = _currentMicScale + (pulseValue * 0.02);
          } else {
            // Pure idle state (no mic, not speaking)
            finalScale = 0.95 + (pulseValue * 0.05);
          }

          // Determine visual styling based on state
          final bool isGlowStrong =
              widget.isSpeaking || (_isRecording && _targetScale > 0.95);
          final double blurRadius = widget.isSpeaking
              ? 11.25.w
              : (isGlowStrong ? 7.5.w : 3.75.w);
          final double spreadRadius = widget.isSpeaking
              ? 3.w
              : (isGlowStrong ? 2.w : 1.w);

          final mainColor = widget.isSpeaking
              ? Colors.blueAccent
              : Colors.cyanAccent;
          final coreSize = 35.w;

          return Center(
            child: Transform.scale(
              scale: finalScale,
              child: Container(
                width: coreSize,
                height: coreSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF161618), // Deep inner void
                  border: Border.all(
                    color: mainColor.withOpacity(0.9),
                    width: 2.5,
                  ),
                  boxShadow: [
                    // Outer neon glow
                    BoxShadow(
                      color: mainColor.withOpacity(
                        widget.isSpeaking ? 0.6 : 0.35,
                      ),
                      blurRadius: blurRadius,
                      spreadRadius: spreadRadius,
                    ),
                    BoxShadow(
                      color: mainColor.withOpacity(0.15),
                      blurRadius: blurRadius * 1.5,
                      spreadRadius: spreadRadius * 1.5,
                    ),
                    // Inner neon glow
                    BoxShadow(
                      color: mainColor.withOpacity(0.5),
                      blurRadius: blurRadius / 2,
                      spreadRadius: spreadRadius / 2,
                      blurStyle: BlurStyle.inner,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: coreSize * 0.8,
                    height: coreSize * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          mainColor.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
