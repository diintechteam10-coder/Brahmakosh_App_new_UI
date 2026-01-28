import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaharSection extends StatefulWidget {
  const PaharSection({super.key});

  @override
  State<PaharSection> createState() => _PaharSectionState();
}

class _PaharSectionState extends State<PaharSection> {
  int _selectedIndex = 0;
  final List<String> _tabs = ["Pradosh", "Aparahna", "Nishita", "Brahma"];

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    // Base width 375.0 (standard mobile).
    // Clamp scale to avoid too small or too large text on extreme devices.
    double scale = (w / 375.0).clamp(0.85, 1.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pahar",
            style: GoogleFonts.lora(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20 * scale,
                      vertical: 8 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFFDECB6)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _tabs[index],
                      style: GoogleFonts.lora(
                        fontSize: 12 * scale,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF6D3A0C)
                            : const Color(0xFF596072),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20 * scale),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/Pahar_background.jpeg'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Sunday, January 22, 2026",
                    style: GoogleFonts.lora(
                      fontSize: 14 * scale,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Pradosh Pahar ",
                                  style: GoogleFonts.playfairDisplay(
                                    fontSize: 22 * scale,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                TextSpan(
                                  text: "(Night Pahar)",
                                  style: GoogleFonts.lora(
                                    fontSize: 14 * scale,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Text(
                            "6.00 - 9.00 Pm",
                            style: GoogleFonts.lora(
                              fontSize: 16 * scale,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20 * scale),
                Text(
                  "The Moon grace the sky, encouraging reflection and letting go. A serene time for relaxation, meditating and finding peaceful closer.",
                  style: GoogleFonts.lora(
                    fontSize: 13 * scale,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 20 * scale),
                _buildInfoRow(
                  "Energy",
                  "Moderate",
                  const Color(0xFF4ADE80),
                  scale,
                ),
                SizedBox(height: 8 * scale),
                _buildInfoRow(
                  "Avoid",
                  "Negativity & Excess Emotion",
                  const Color(0xFFFF5252),
                  scale,
                ),
                SizedBox(height: 20 * scale),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16 * scale,
                    vertical: 8 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Muhurat: ",
                        style: GoogleFonts.lora(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                      Text(
                        "Supportive Window ( 6.18 - 7.02 PM )",
                        style: GoogleFonts.lora(
                          fontSize: 11 * scale,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  children: [
                    Text(
                      "Good For: ",
                      style: GoogleFonts.lora(
                        fontSize: 15 * scale,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "Auspicious endeavors",
                      style: GoogleFonts.lora(
                        fontSize: 15 * scale,
                        color: const Color(0xFFFFA726),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12 * scale),
                _buildBulletPoint("Meditation", scale),
                _buildBulletPoint("Letting Go Rituals", scale),
                _buildBulletPoint("Forgiveness", scale),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 32 * scale,
                      vertical: 12 * scale,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECB6),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      "Ask BI",
                      style: GoogleFonts.lora(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A3426),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color valueColor,
    double scale,
  ) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: GoogleFonts.lora(
            fontSize: 12 * scale,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lora(fontSize: 12 * scale, color: valueColor),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, double scale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.circle, size: 4 * scale, color: Colors.white70),
          SizedBox(width: 8 * scale),
          Text(
            text,
            style: GoogleFonts.lora(
              fontSize: 12 * scale,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
