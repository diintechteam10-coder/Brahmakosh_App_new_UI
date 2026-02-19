import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors.dart';
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
      Get.snackbar(
        "Error",
        "Audio not available for this pooja",
        snackPosition: SnackPosition.BOTTOM,
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
      Get.snackbar(
        "Error",
        "Could not play audio: $e",
        snackPosition: SnackPosition.BOTTOM,
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
      backgroundColor: CustomColors.lightPinkColor,
      appBar: AppBar(
        title: Text(
          "Vidhi",
          style: GoogleFonts.playfairDisplay(
            color: const Color(0xff5D4037),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff5D4037),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auspicious Muhurat Header
            if (widget.pooja.muhurat != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xffA5D6A7),
                    style: BorderStyle.none,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Color(0xff2E7D32),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Auspicious Muhurat: ${widget.pooja.muhurat}",
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff1B5E20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Puja Vidhi Steps
            _sectionHeader("Puja Vidhi"),
            const SizedBox(height: 12),
            if (widget.pooja.pujaVidhi != null)
              ...widget.pooja.pujaVidhi!.map((step) => _buildStepCard(step)),

            const SizedBox(height: 24),

            // Required Samagri
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Required Samagri"),
                  const SizedBox(height: 12),
                  if (widget.pooja.samagriList != null)
                    ...widget.pooja.samagriList!.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xffff9800),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${item.itemName ?? ''} ${item.quantity != null ? '(${item.quantity})' : ''}",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xff5D4037),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Mantra Card (Showing first mantra if available)
            if (widget.pooja.mantras != null &&
                widget.pooja.mantras!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffFF9800),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "MANTRA",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            widget.pooja.mantras![0].mantraText ?? "",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.notoSans(
                              // Using NotoSans for Hindi/Sanskrit
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (widget.pooja.mantras![0].meaning != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              widget.pooja.mantras![0].meaning!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Audio controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _seekBackward,
                          icon: const Icon(
                            Icons.replay_10,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: _playPause,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: CircularProgressIndicator(
                                      color: Color(0xffFF9800),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: const Color(0xffFF9800),
                                    size: 30,
                                  ),
                          ),
                        ),
                        IconButton(
                          onPressed: _seekForward,
                          icon: const Icon(
                            Icons.forward_10,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // Guidelines
            if (widget.pooja.specialInstructions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("Special Instructions"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffE8F5E9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      widget.pooja.specialInstructions!,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xff1B5E20),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Row(
      children: [
        Container(width: 3, height: 18, color: const Color(0xffff9800)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xff4E342E),
          ),
        ),
      ],
    );
  }

  Widget _buildStepCard(PujaVidhi step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xffff9800),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${step.stepNumber ?? 0}",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4E342E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      step.description ?? "",
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xff5D4037),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
