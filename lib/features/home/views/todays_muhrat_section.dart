import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodaysMuhratSection extends StatelessWidget {
  const TodaysMuhratSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Muhrat",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF6E7),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildSunMoonCard(
                        title1: "Sunrise",
                        time1: "7:10 AM",
                        title2: "Sunset",
                        time2: "7:10 AM",
                        isSun: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSunMoonCard(
                        title1: "Moonrise",
                        time1: "9:51 AM",
                        title2: "Moonset",
                        time2: "10:21 PM",
                        isSun: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        Icons.calendar_today_outlined,
                        "Hindu Month",
                        "Magha",
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.wb_sunny_outlined,
                        "Ritu",
                        "Shishira Ritu ( Winter)",
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.explore_outlined,
                        "Direction",
                        "West",
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.nightlight_round,
                        "Tithi",
                        "Panchami - 22:45:39",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeBox(
                        "Abhijit Muhurat",
                        "12:12 - 12:54",
                        const Color(0xFFEDF7EE),
                        const Color(0xFF274C2A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeBox(
                        "Dushta Muhurat",
                        "09:24 - 10:06",
                        const Color(0xFFFEF0EF),
                        const Color(0xFF6C261E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "View Today's Panchang",
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF3B3B3B),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF3B3B3B),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSunMoonCard({
    required String title1,
    required String time1,
    required String title2,
    required String time2,
    required bool isSun,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSun ? const Color(0xFFFDECB6) : const Color(0xFF414792),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title1,
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      color: isSun ? const Color(0xFF6D3A0C) : Colors.white70,
                    ),
                  ),
                  Text(
                    time1,
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSun ? const Color(0xFF6D3A0C) : Colors.white,
                    ),
                  ),
                ],
              ),
              Icon(
                isSun ? Icons.wb_sunny : Icons.nightlight_round,
                color: isSun ? Colors.orange : Colors.white,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title2,
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      color: isSun ? const Color(0xFF6D3A0C) : Colors.white70,
                    ),
                  ),
                  Text(
                    time2,
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSun ? const Color(0xFF6D3A0C) : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF596072)),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 12, color: const Color(0xFF596072)),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.lora(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeBox(
    String title,
    String time,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 11,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            time,
            style: GoogleFonts.lora(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
