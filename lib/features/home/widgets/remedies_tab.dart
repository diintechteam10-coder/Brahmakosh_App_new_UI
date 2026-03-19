import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class RemediesTab extends StatelessWidget {
  final GemstoneSuggestion? gemstoneSuggestion;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);

  const RemediesTab({super.key, this.gemstoneSuggestion});

  @override
  Widget build(BuildContext context) {
    if (gemstoneSuggestion == null) {
      return Container(
        color: _bgDark,
        child: Center(
          child: Text(
            "No Gemstone Suggestions Available",
            style: GoogleFonts.poppins(color: _textSecondary),
          ),
        ),
      );
    }

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGemstoneCard(
              "Life Stone",
              gemstoneSuggestion!.life,
              const Color(0xFFE53935), 
              Icons.favorite,
            ),
            const SizedBox(height: 16),
            _buildGemstoneCard(
              "Benefic Stone",
              gemstoneSuggestion!.benefic,
              const Color(0xFF43A047), 
              Icons.verified,
            ),
            const SizedBox(height: 16),
            _buildGemstoneCard(
              "Lucky Stone",
              gemstoneSuggestion!.lucky,
              const Color(0xFFFDD835), 
              Icons.star,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGemstoneCard(
    String title,
    GemstoneDetail? detail,
    Color accentColor,
    IconData icon,
  ) {
    if (detail == null) return const SizedBox();

    List<Widget> detailRows = [
      _buildDetailRow("Gemstone", detail.name ?? "-", isBold: true, valueColor: _textPrimary),
      if (detail.semiGem != null && detail.semiGem!.isNotEmpty)
        _buildDetailRow("Substitute", detail.semiGem ?? "-", valueColor: _textPrimary),
      _buildDetailRow("Weight", detail.weightCaret ?? "-", valueColor: _textPrimary),
      _buildDetailRow("Wear Finger", detail.wearFinger ?? "-", valueColor: _textPrimary),
      _buildDetailRow("Metal", detail.wearMetal ?? "-", valueColor: _textPrimary),
      _buildDetailRow("Day", detail.wearDay ?? "-", valueColor: _textPrimary),
      if (detail.gemDeity != null && detail.gemDeity!.isNotEmpty)
        _buildDetailRow("Deity", detail.gemDeity ?? "-", valueColor: _textPrimary),
    ];

    List<Widget> spacedChildren = [];
    for (int i = 0; i < detailRows.length; i++) {
        spacedChildren.add(detailRows[i]);
        if (i < detailRows.length - 1) {
            spacedChildren.add(
                const Divider(
                    color: Color(0xFF1E1E4D), // Deeper violet underline
                    height: 24,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                ),
            );
        }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...spacedChildren,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: _textPrimary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: valueColor ?? _textPrimary,
          ),
        ),
      ],
    );
  }
}
