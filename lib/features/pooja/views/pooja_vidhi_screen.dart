import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/app_snackbar.dart';

import '../models/pooja_model.dart';
import 'package:brahmakosh/core/localization/translate_helper.dart';

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
  
  // Translated Data
  String? _translatedMuhurat;
  String? _translatedInstructions;
  String? _translatedPoojaName;
  List<PujaVidhi> _translatedSteps = [];
  List<SamagriList> _translatedSamagri = [];
  List<Mantras> _translatedMantras = [];

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
    
    // Initialize translated data with original values
    _translatedMuhurat = widget.pooja.muhurat;
    _translatedInstructions = widget.pooja.specialInstructions;
    _translatedPoojaName = widget.pooja.pujaName;
    _translatedSteps = List.from(widget.pooja.pujaVidhi ?? []);
    _translatedSamagri = List.from(widget.pooja.samagriList ?? []);
    _translatedMantras = List.from(widget.pooja.mantras ?? []);

    _translateDynamicData();
  }

  Future<void> _translateDynamicData() async {
    final currentLang = Get.locale?.languageCode ?? 'en';
    if (currentLang == 'en') return;

    final Set<String> toTranslate = {};

    if (widget.pooja.pujaName != null) toTranslate.add(widget.pooja.pujaName!);
    if (widget.pooja.muhurat != null) toTranslate.add(widget.pooja.muhurat!);
    if (widget.pooja.specialInstructions != null) toTranslate.add(widget.pooja.specialInstructions!);

    for (var step in widget.pooja.pujaVidhi ?? []) {
      if (step.title != null) toTranslate.add(step.title!);
      if (step.description != null) toTranslate.add(step.description!);
    }

    for (var item in widget.pooja.samagriList ?? []) {
      if (item.itemName != null) toTranslate.add(item.itemName!);
    }

    for (var mantra in widget.pooja.mantras ?? []) {
      if (mantra.meaning != null) toTranslate.add(mantra.meaning!);
    }

    if (toTranslate.isEmpty) return;

    final list = toTranslate.toList();
    final results = await TranslateHelper.translateList(list);
    final translationMap = Map.fromIterables(list, results);

    if (mounted) {
      setState(() {
        if (widget.pooja.pujaName != null) {
          _translatedPoojaName = translationMap[widget.pooja.pujaName];
        }
        if (widget.pooja.muhurat != null) {
          _translatedMuhurat = translationMap[widget.pooja.muhurat];
        }
        if (widget.pooja.specialInstructions != null) {
          _translatedInstructions = translationMap[widget.pooja.specialInstructions];
        }

        // Steps
        _translatedSteps = (widget.pooja.pujaVidhi ?? []).map((step) {
          return PujaVidhi(
            stepNumber: step.stepNumber,
            title: step.title != null ? translationMap[step.title] : step.title,
            description: step.description != null ? translationMap[step.description] : step.description,
          );
        }).toList();

        // Samagri
        _translatedSamagri = (widget.pooja.samagriList ?? []).map((item) {
          return SamagriList(
            itemName: item.itemName != null ? translationMap[item.itemName] : item.itemName,
            quantity: item.quantity,
          );
        }).toList();

        // Mantras
        _translatedMantras = (widget.pooja.mantras ?? []).map((mantra) {
          return Mantras(
            mantraText: mantra.mantraText,
            meaning: mantra.meaning != null ? translationMap[mantra.meaning] : mantra.meaning,
          );
        }).toList();
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playPause() async {
    if (widget.pooja.audioUrl == null || widget.pooja.audioUrl!.isEmpty) {
 AppSnackBar.showError(
        "error".tr,
        "audio_not_available".tr,
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
        "error".tr,
        "audio_play_error".trParams({'error': e.toString()}),
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
          "vidhi".tr,
          style: GoogleFonts.lora(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 18,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Auspicious Muhurat Header
            if (widget.pooja.muhurat != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "auspicious_muhurat_label".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Expanded(
                        child: Text(
                        _translatedMuhurat!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Puja Vidhi Steps
            _sectionHeader("puja_vidhi_title".tr),
            const SizedBox(height: 16),
            if (widget.pooja.pujaVidhi != null)
              ..._buildVidhiContent(),

            const SizedBox(height: 24),

            // Required Samagri
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("required_samagri".tr),
                  const SizedBox(height: 16),
                    ..._translatedSamagri.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFFD4AF37),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "${item.itemName ?? ''} ${item.quantity != null ? '(${item.quantity})' : ''}",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.6),
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

            // Main Audio Player (Redesigned Design 3 Large Gold Card)
            if (_translatedMantras.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
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
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "mantra_cap".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _translatedPoojaName ?? "Mantra",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                            Text(
                              _translatedMantras[0].mantraText ?? "",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.notoSans(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.4,
                              ),
                            ),
                            if (_translatedMantras[0].meaning != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                "\"${_translatedMantras[0].meaning!}\"",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.9),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPlayerAction(Icons.replay_10, _seekBackward),
                        const SizedBox(width: 24),
                        GestureDetector(
                          onTap: _playPause,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: _isLoading
                                ? const Center(child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                                : Icon(
                                    _isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.black,
                                    size: 30,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildPlayerAction(Icons.forward_10, _seekForward),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Guidelines (Do's & Don'ts Layout)
            _sectionHeader("puja_guidelines".tr),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildGuidelineCard("dos".tr, true)),
                const SizedBox(width: 12),
                Expanded(child: _buildGuidelineCard("donts".tr, false)),
              ],
            ),

            const SizedBox(height: 24),

            // Guidelines
            if (widget.pooja.specialInstructions != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader("special_instructions".tr),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131313),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Text(
                        _translatedInstructions!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.7),
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
        Container(
          width: 2,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildVidhiContent() {
    List<Widget> content = [];
    final steps = _translatedSteps;
    
    for (int i = 0; i < steps.length; i++) {
      content.add(_buildStepCard(steps[i]));
      
      // Inject Mantra To Chant Card after step 2 (index 1) if available
      if (i == 1 && _translatedMantras.isNotEmpty) {
        content.add(_buildMantraToChantCard(_translatedMantras[0]));
      }
    }
    return content;
  }

  Widget _buildStepCard(PujaVidhi step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step.stepNumber?.toString().padLeft(2, '0') ?? "01",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFD4AF37).withOpacity(0.6),
                ),
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  step.description ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(28),
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
              const Icon(Icons.music_note, color: Colors.white, size: 14),
              const SizedBox(width: 8),
              Text(
                "mantra_to_chant".tr,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            mantra.mantraText ?? "",
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineCard(String title, bool isDo) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                size: 18,
                color: isDo ? const Color(0xFF81C784) : const Color(0xFFE57373),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isDo ? const Color(0xFF81C784) : const Color(0xFFE57373),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isDo ? "dos_list".tr : "donts_list".tr,
            style: GoogleFonts.poppins(
              fontSize: 12,
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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}

