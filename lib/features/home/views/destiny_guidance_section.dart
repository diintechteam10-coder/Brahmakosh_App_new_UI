import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/features/home/views/astrology_details_screen.dart';
import 'package:brahmakosh/features/numerology/views/numerology_history_view.dart';

class DestinyGuidanceSection extends StatelessWidget {
  const DestinyGuidanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Destiny and Life Guidance",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildCard(
                context,
                title: "Astrology",
                subtitle: "Planetary movements\ninfluencing your day.",
                icon: "assets/images/Astrology_image.png",
                color: const Color(0xFFFFDFB6),
                buttonText: "View Astrology",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AstrologyDetailsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              _buildCard(
                context,
                title: "Numerology",
                subtitle: "Numbers reveal\nlife patterns & more.",
                icon: "assets/images/Numerology_Image.png",
                color: const Color(0xFFFFDFB6),
                buttonText: "View Numerology",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NumerologyHistoryView(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String icon,
    required Color color,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Container(
            //   width: 50,
            //   height: 50,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: Colors.white.withOpacity(0.5),
            //     border: Border.all(color: Colors.white, width: 2),
            //   ),
            //   child: Icon(icon, size: 28, color: const Color(0xFF874101)),
            // ),
            Image.asset(icon,fit: BoxFit.cover,),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF874101),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFFFFC67A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      buttonText,
                      style: GoogleFonts.lora(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6D3A0C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
