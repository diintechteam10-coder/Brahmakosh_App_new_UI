import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/models/dosha_dasha_model.dart';

class DoshaDetailView extends StatelessWidget {
  final String title;
  final DoshaDetail doshaDetail;
  final bool isPitra;

  const DoshaDetailView({
    super.key,
    required this.title,
    required this.doshaDetail,
    this.isPitra = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF8E1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isPitra
                          ? Colors.red.shade50
                          : Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPitra
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: isPitra ? Colors.red : Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Status",
                          style: GoogleFonts.lora(
                            fontSize: 14,
                            color: const Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doshaDetail.present == true
                              ? "Present"
                              : "Not Present",
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4E342E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Description / Report
            if ((doshaDetail.manglikReport != null &&
                    doshaDetail.manglikReport!.isNotEmpty) ||
                (doshaDetail.description != null &&
                    doshaDetail.description!.isNotEmpty)) ...[
              Text(
                "Report",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D3A0C),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade100),
                ),
                child: Text(
                  // Prefer manglikReport, then description
                  doshaDetail.manglikReport ?? doshaDetail.description!,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    color: const Color(0xFF5D4037),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Detailed Analysis based on Raw Data
            if (doshaDetail.raw != null && doshaDetail.raw is Map) ...[
              _buildDetailedAnalysis(doshaDetail.raw),
            ],

            const SizedBox(height: 24),

            // Conclusion / One Liner - Handle both oneLine and conclusion fields
            if (doshaDetail.oneLine != null ||
                doshaDetail.conclusion != null) ...[
              Text(
                "Conclusion",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D3A0C),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  doshaDetail.conclusion ?? doshaDetail.oneLine!,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFFE65100),
                    height: 1.5,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysis(Map<String, dynamic> raw) {
    List<Widget> children = [];

    // --- Manglik Analysis ---
    if (raw.containsKey('manglik_present_rule')) {
      children.add(_buildSectionTitle("Manglik Analysis"));

      // Present Rules
      final rules = raw['manglik_present_rule'];
      if (rules != null && rules is Map) {
        if (rules['based_on_aspect'] != null &&
            (rules['based_on_aspect'] as List).isNotEmpty) {
          children.add(
            _buildSubSection(
              "Based on Aspect",
              (rules['based_on_aspect'] as List).cast<String>(),
            ),
          );
        }
        if (rules['based_on_house'] != null &&
            (rules['based_on_house'] as List).isNotEmpty) {
          children.add(
            _buildSubSection(
              "Based on House",
              (rules['based_on_house'] as List).cast<String>(),
            ),
          );
        }
      }

      // Cancel Rules
      if (raw['manglik_cancel_rule'] != null &&
          (raw['manglik_cancel_rule'] as List).isNotEmpty) {
        children.add(
          _buildSubSection(
            "Cancellation Rules",
            (raw['manglik_cancel_rule'] as List).cast<String>(),
          ),
        );
      }

      // Percentage
      if (raw['percentage_manglik_present'] != null) {
        children.add(const SizedBox(height: 12));
        children.add(
          _buildInfoRow(
            "Percentage Present",
            "${raw['percentage_manglik_present']}%",
          ),
        );
      }
    }

    // --- Pitra Analysis ---
    if (raw.containsKey('what_is_pitri_dosha')) {
      children.add(_buildSectionTitle("Understanding Pitra Dosha"));
      children.add(const SizedBox(height: 8));
      children.add(_buildParagraph(raw['what_is_pitri_dosha']));

      if (raw['rules_matched'] != null &&
          (raw['rules_matched'] as List).isNotEmpty) {
        children.add(
          _buildSubSection(
            "Reasons (Rules Matched)",
            (raw['rules_matched'] as List).cast<String>(),
          ),
        );
      }
    }

    // --- Kalsarpa Analysis (if extra details exist) ---
    if (raw.containsKey('type') && raw['type'] != null) {
      children.add(_buildSectionTitle("Kalsarpa Details"));
      children.add(_buildInfoRow("Type", raw['type']));
    }

    if (children.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [const SizedBox(height: 24), ...children],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.lora(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6D3A0C),
        ),
      ),
    );
  }

  Widget _buildSubSection(String title, List<String> items) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6.0),
                    child: Icon(Icons.circle, size: 6, color: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        color: Colors.brown.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontSize: 14,
          color: Colors.brown.shade800,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.brown,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lora(fontSize: 14, color: Colors.brown.shade700),
          ),
        ],
      ),
    );
  }
}
