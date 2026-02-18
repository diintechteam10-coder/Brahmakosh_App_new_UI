import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class RemediesTab extends StatelessWidget {
  final GemstoneSuggestion? gemstoneSuggestion;

  const RemediesTab({super.key, this.gemstoneSuggestion});

  @override
  Widget build(BuildContext context) {
    if (gemstoneSuggestion == null) {
      return Center(
        child: Text(
          "No Gemstone Suggestions Available",
          style: GoogleFonts.lora(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGemstoneCard(
            "Life Stone",
            gemstoneSuggestion!.life,
            const Color(0xFFE53935), // RedAccent
            Icons.favorite,
          ),
          const SizedBox(height: 16),
          _buildGemstoneCard(
            "Benefic Stone",
            gemstoneSuggestion!.benefic,
            const Color(0xFF43A047), // Green
            Icons.verified,
          ),
          const SizedBox(height: 16),
          _buildGemstoneCard(
            "Lucky Stone",
            gemstoneSuggestion!.lucky,
            const Color(0xFFFDD835), // Yellow
            Icons.star,
          ),
        ],
      ),
    );
  }

  Widget _buildGemstoneCard(
    String title,
    GemstoneDetail? detail,
    Color color,
    IconData icon,
  ) {
    if (detail == null) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow("Gemstone", detail.name ?? "-", isBold: true),
          if (detail.semiGem != null && detail.semiGem!.isNotEmpty)
            _buildDetailRow("Substitute", detail.semiGem ?? "-"),
          _buildDetailRow("Weight", detail.weightCaret ?? "-"),
          _buildDetailRow("Wear Finger", detail.wearFinger ?? "-"),
          _buildDetailRow("Metal", detail.wearMetal ?? "-"),
          _buildDetailRow("Day", detail.wearDay ?? "-"),
          if (detail.gemDeity != null && detail.gemDeity!.isNotEmpty)
            _buildDetailRow("Deity", detail.gemDeity ?? "-"),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: const Color(0xFF3E2723),
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
