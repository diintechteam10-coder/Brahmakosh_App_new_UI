import 'package:brahmakosh/core/common_imports.dart';

class MeditateScreen extends StatefulWidget {
  const MeditateScreen({super.key});

  @override
  State<MeditateScreen> createState() => _MeditateScreenState();
}

class _MeditateScreenState extends State<MeditateScreen> {
  String _selectedMood = "Happy";
  double _selectedDuration = 7.0;
  String _selectedGuide = "Rashmi";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DF),
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
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back_ios, size: 16),
                          SizedBox(width: 4),
                          Text("Back", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_vert),
                  ],
                ),

                const SizedBox(height: 25),

                /// 🧘 Title
                Center(
                  child: Column(
                    children: const [
                      Text(
                        "Mediate",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "How are you feeling today?",
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 18),
                          SizedBox(width: 8),
                          Text(
                            "Select Duration",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
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
                                            trackHeight: 6,
                                            activeTrackColor: Colors.orange,
                                            inactiveTrackColor: Colors.orange
                                                .withOpacity(0.3),
                                            thumbColor: Colors.orange,
                                            overlayColor: Colors.orange
                                                .withOpacity(0.2),
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
                              const Positioned(
                                left: 0,
                                top: 68,
                                child: Text(
                                  "3 Min",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              const Positioned(
                                right: 0,
                                top: 68,
                                child: Text(
                                  "9 Min",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                Center(
                  child: Column(
                    children: [
                      const Text(
                        "Summary",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${_selectedMood == 'Happy'
                            ? '😊'
                            : _selectedMood == 'Stressed'
                            ? '😔'
                            : '😐'} "
                        "$_selectedMood  •  👧 $_selectedGuide  •  ⏱ ${_selectedDuration.round()} Mins",
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "⭐ Finish to earn +10 karma Points",
                        style: TextStyle(color: Colors.orange),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                /// ▶ Start Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Get.toNamed(AppConstants.routeMeditationStart);
                    },
                    child: const Text(
                      "Start",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Footer
                const Center(
                  child: Text(
                    "You can stop anytime",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.orange.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 38)),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.orange : Colors.black,
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
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6),
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
            color: Colors.orange,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$duration Min",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const CircleAvatar(radius: 4, backgroundColor: Colors.orange),
      ],
    );
  }
}
