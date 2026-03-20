import 'package:brahmakosh/core/common_imports.dart';
import 'package:google_fonts/google_fonts.dart';

class MeditateScreen extends StatefulWidget {
  const MeditateScreen({super.key});

  @override
  State<MeditateScreen> createState() => _MeditateScreenState();
}

class _MeditateScreenState extends State<MeditateScreen> {
  String _selectedMood = "Happy";
  double _selectedDuration = 7.0;
  final String _selectedGuide = "Rashmi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme Background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔙 Top Bar
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert, color: Colors.white),
                  ],
                ),

                const SizedBox(height: 25),

                /// 🧘 Title
                Center(
                  child: Column(
                    children: [
                      Text(
                        "MEDITATE",
                        style: GoogleFonts.lora(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD4AF37), // Primary Gold
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "How are you feeling today?",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 😀 Mood Selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _moodItem(
                      "😔",
                      "Stressed",
                      onTap: () => setState(() => _selectedMood = "Stressed"),
                    ),
                    _moodItem(
                      "😊",
                      "Happy",
                      onTap: () => setState(() => _selectedMood = "Happy"),
                    ),
                    _moodItem(
                      "😐",
                      "Neutral",
                      onTap: () => setState(() => _selectedMood = "Neutral"),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                /// ⏱ Duration Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414), // Dark Grey Background
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time_filled_rounded,
                              color: Color(0xFFD4AF37), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "Select Duration",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// Slider
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const double sidePad = 40;
                          final availableWidth =
                              constraints.maxWidth - (sidePad * 2);
                          final relativePos = (_selectedDuration - 3) / 6;
                          final leftPos =
                              sidePad + (relativePos * availableWidth) - 25;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 60),
                                  Row(
                                    children: [
                                      _greyBar(),
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 4,
                                            activeTrackColor: const Color(0xFFD4AF37),
                                            inactiveTrackColor: const Color(0xFFD4AF37)
                                                .withValues(alpha: 0.2),
                                            thumbColor: const Color(0xFFD4AF37),
                                            overlayColor: const Color(0xFFD4AF37)
                                                .withValues(alpha: 0.2),
                                            thumbShape:
                                                const RoundSliderThumbShape(
                                              enabledThumbRadius: 8,
                                            ),
                                          ),
                                          child: Slider(
                                            value: _selectedDuration,
                                            min: 3,
                                            max: 9,
                                            divisions: 6,
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedDuration = value;
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      _greyBar(),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                left: leftPos,
                                top: 0,
                                child: _SelectedTime(
                                  duration: _selectedDuration.round(),
                                ),
                              ),
                              Positioned(
                                left: 0,
                                top: 68,
                                child: Text(
                                  "3 Min",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 0,
                                top: 68,
                                child: Text(
                                  "9 Min",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white38,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// 📊 Summary
                Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "Summary",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${_selectedMood == 'Happy' ? '😊' : _selectedMood == 'Stressed' ? '😔' : '😐'} "
                        "$_selectedMood  •  👧 $_selectedGuide  •  ⏱ ${_selectedDuration.round()} Mins",
                        style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Color(0xFFD4AF37), size: 16),
                          const SizedBox(width: 6),
                          Text(
                            "Finish to earn ",
                            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                          ),
                          Text(
                            "+10 ",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                          Text(
                            "karma Points",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// ▶ Start Button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFB8860B)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Get.toNamed(AppConstants.routeMeditationStart, arguments: {
                        'duration': _selectedDuration,
                        'mood': _selectedMood,
                      });
                    },
                    child: Text(
                      "START",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Footer
                Center(
                  child: Text(
                    "You can stop anytime",
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white38),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 😀 Mood Item
  Widget _moodItem(String emoji, String text, {required VoidCallback onTap}) {
    final isSelected = _selectedMood == text;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4AF37).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white10,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _greyBar() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

/// ⏱ Selected Time Bubble
class _SelectedTime extends StatelessWidget {
  final int duration;
  const _SelectedTime({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD4AF37),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            "$duration Min",
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const CircleAvatar(
          radius: 3,
          backgroundColor: Color(0xFFD4AF37),
        ),
      ],
    );
  }
}
