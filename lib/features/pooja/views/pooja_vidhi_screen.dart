import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import '../../../core/utils/app_snackbar.dart';

import '../models/pooja_model.dart';

class PoojaVidhiScreen extends StatefulWidget {
  final PoojaModel pooja;
  const PoojaVidhiScreen({super.key, required this.pooja});

  @override
  State<PoojaVidhiScreen> createState() => _PoojaVidhiScreenState();
}

class _PoojaVidhiScreenState extends State<PoojaVidhiScreen> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Listen to state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) {
        setState(() {
          _duration = newDuration;
        });
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) {
        setState(() {
          _position = newPosition;
        });
      }
    });

    // Automatically prepare audio if url is present?
    // Maybe better to wait for user to click play to load data efficiently.
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (widget.pooja.audioUrl == null || widget.pooja.audioUrl!.isEmpty) {
      AppSnackBar.showError(
        "Error",
        "Audio not available for this pooja",
      );
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position == Duration.zero) {
          setState(() {
            _isLoading = true;
          });
          await _audioPlayer.play(UrlSource(widget.pooja.audioUrl!));
          setState(() {
            _isLoading = false;
          });
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      AppSnackBar.showError(
        "Error",
        "Could not play audio: $e",
      );
    }
  }

  Future<void> _seekForward() async {
    final newPosition = _position + const Duration(seconds: 10);
    if (newPosition < _duration) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(_duration); // Go to end
    }
  }

  Future<void> _seekBackward() async {
    final newPosition = _position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      await _audioPlayer.seek(newPosition);
    } else {
      await _audioPlayer.seek(Duration.zero); // Go to start
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Vidhi",
          style: GoogleFonts.lora(
            fontSize: 16.sp,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(1.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 14.sp,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auspicious Muhurat Header
            if (widget.pooja.muhurat != null)
              Center(
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: const Color(0xFF1B5E20),
                    strokeWidth: 1.2,
                    dash: 4,
                    gap: 3,
                    borderRadius: 12,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.2.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withOpacity(0.02),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 0.3.h),
                          child: Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: "Auspicious Muhurat: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                TextSpan(
                                  text: widget.pooja.muhurat!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            SizedBox(height: 3.h),

            // Puja Vidhi Steps
            _sectionHeader("Puja Vidhi"),
            SizedBox(height: 1.5.h),
            if (widget.pooja.pujaVidhi != null && widget.pooja.pujaVidhi!.isNotEmpty)
              ..._buildVidhiContent()
            else ...[
              SizedBox(height: 1.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Detailed Vidhi steps for this ritual will be available soon.",
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.4),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            SizedBox(height: 2.h),

            // Required Samagri
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Required Samagri"),
                  SizedBox(height: 2.h),
                  if (widget.pooja.samagriList != null && widget.pooja.samagriList!.isNotEmpty)
                    ...widget.pooja.samagriList!.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Container(
                              width: 1.5.w,
                              height: 1.5.w,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Text(
                                "${item.itemName ?? ''} ${item.quantity != null ? '(${item.quantity})' : ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 11.sp,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Text(
                        "No specific samagri list provided for this ritual.",
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          color: Colors.white.withOpacity(0.4),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Main Audio Player (Redesigned Design 3 Large Gold Card)
            if (widget.pooja.mantras != null && widget.pooja.mantras!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B3E11), Color(0xFF91631B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "MANTRA",
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      widget.pooja.pujaName ?? "Mantra",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.5.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.pooja.mantras![0].mantraText ?? "",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                          if (widget.pooja.mantras![0].meaning != null) ...[
                            SizedBox(height: 1.5.h),
                            Text(
                              "\"${widget.pooja.mantras![0].meaning!}\"",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPlayerAction(Icons.replay_10, _seekBackward),
                        SizedBox(width: 6.w),
                        GestureDetector(
                          onTap: _playPause,
                          child: Container(
                            width: 14.w,
                            height: 14.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.sp))
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 24.sp,
                                  ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        _buildPlayerAction(Icons.forward_10, _seekForward),
                      ],
                    ),
                  ],
                ),
              ),

            SizedBox(height: 3.h),

            // Guidelines (Do's & Don'ts Layout)
            _sectionHeader("Puja Guidelines"),
            SizedBox(height: 1.5.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGuidelineCard("Do's", true)),
                SizedBox(width: 3.w),
                Expanded(child: _buildGuidelineCard("Don'ts", false)),
              ],
            ),

            SizedBox(height: 3.h),

            // Guidelines
            if (widget.pooja.specialInstructions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Special Instructions"),
                  SizedBox(height: 1.5.h),
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                      widget.pooja.specialInstructions!,
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.white.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 0.5.w,
          height: 2.h,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.5.w),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVidhiContent() {
    List<Widget> content = [];
    final steps = widget.pooja.pujaVidhi ?? [];
    
    for (int i = 0; i < steps.length; i++) {
      content.add(_buildStepCard(steps[i]));
      
      // Inject Mantra To Chant Card after step 2 (index 1) if available
      if (i == 1 && widget.pooja.mantras != null && widget.pooja.mantras!.isNotEmpty) {
        content.add(_buildMantraToChantCard(widget.pooja.mantras![0]));
      }
    }
    return content;
  }

  Widget _buildStepCard(PujaVidhi step) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step.stepNumber?.toString().padLeft(2, '0') ?? "01",
                style: GoogleFonts.lora(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  step.description ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.5),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMantraToChantCard(Mantras mantra) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B4513), Color(0xFFD4AF37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, color: Colors.white, size: 12.sp),
              SizedBox(width: 2.w),
              Text(
                "MANTRA TO CHANT",
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Text(
            mantra.mantraText ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.lora(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard(String title, bool isDo) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDo ? const Color(0xFFE8F5E9).withOpacity(0.15) : const Color(0xFFFFEBEE).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDo ? Icons.check_circle : Icons.cancel,
                size: 14.sp,
                color: isDo ? const Color(0xFF81C784) : const Color(0xFFE57373),
              ),
              SizedBox(width: 2.w),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDo ? const Color(0xFF81C784) : const Color(0xFFE57373),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.2.h),
          Text(
            isDo ? "• Face East/North\n• Wear clean clothes\n• Maintain Silence" : "• Don't rush steps\n• No leather items\n• Avoid Interruptions",
            style: GoogleFonts.poppins(
              fontSize: 10.sp,
              color: isDo ? const Color(0xFF2E7D32).withOpacity(0.9) : const Color(0xFFC62828).withOpacity(0.9),
              height: 1.8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerAction(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18.sp),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.green,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.dash = 5.0,
    this.borderRadius = 12.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final Path path = Path()
      ..addRRect(RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(borderRadius)));

    final Path dashedPath = Path();
    for (var pathMetric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < pathMetric.length) {
        dashedPath.addPath(
          pathMetric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

