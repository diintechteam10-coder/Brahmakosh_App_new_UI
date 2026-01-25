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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pahar",
            style: GoogleFonts.lora(
              fontSize: 18,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
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
                        fontSize: 12,
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
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00396B), Color(0xFF1F1F1F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
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
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(height: 1, width: 30, color: Colors.amber),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          "Current Phase",
                          style: GoogleFonts.lora(
                            fontSize: 10,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      Container(height: 1, width: 30, color: Colors.amber),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pradosh Pahar (Night Pahar)",
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "6:00 - 9:00 PM",
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.nightlight_round,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  "The Moon grace the sky, encouraging reflection and letting go. A serene time for relaxation, meditating and finding peaceful closure.",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoRow("Energy", "Moderate", Colors.greenAccent),
                const SizedBox(height: 8),
                _buildInfoRow(
                  "Avoid",
                  "Negativity & Excess Emotion",
                  Colors.redAccent,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    "Muhurat: Shubh/Amrit (06:00 - 09:00 PM)",
                    style: GoogleFonts.lora(fontSize: 10, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Good For: Auspicious endeavors",
                  style: GoogleFonts.lora(fontSize: 12, color: Colors.amber),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint("Meditation"),
                _buildBulletPoint("Letting Go Rituals"),
                _buildBulletPoint("Forgiveness"),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECB6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Ask BI",
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3A0C),
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

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          "$label : ",
          style: GoogleFonts.lora(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(value, style: GoogleFonts.lora(fontSize: 12, color: valueColor)),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 4, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.lora(fontSize: 12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
