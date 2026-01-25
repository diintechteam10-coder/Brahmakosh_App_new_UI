import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LuckInFavourSection extends StatelessWidget {
  const LuckInFavourSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Luck in Favour",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCard(
                  title: "Lucky Number",
                  content: Column(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 20,
                      ), // Sparkle icon
                      Text(
                        "7",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB2EBF2), Color(0xFFE0F7FA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCard(
                  title: "Lucky Color",
                  content: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF43A047),
                          Color(0xFF66BB6A),
                        ], // Green gradient
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required Widget content,
    required Gradient gradient,
  }) {
    return Container(
      height: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          content,
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6D3A0C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
