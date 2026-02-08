import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/astrology_details_screen.dart'; // For styles if needed, or just copy

class DoshaDetailScreen extends StatelessWidget {
  final String title;
  final String doshaType; // "manglik", "kalsarpa", "sadesati", "pitra"
  final dynamic data; // The raw object for that dosha

  const DoshaDetailScreen({
    super.key,
    required this.title,
    required this.doshaType,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (doshaType) {
      case 'manglik':
        return _buildManglikContent(data as RawManglik?);
      case 'kalsarpa':
        return _buildKalsarpaContent(data as RawKalsarpa?);
      case 'sadesati':
        // Sade Sati usually has current status and potentially a life chart
        // Here we handle if we passed the specific sub-object or a wrapper
        if (data is SadeSatiCurrent) {
          return _buildSadeSatiCurrentContent((data as SadeSatiCurrent).raw);
        } else if (data is List<RawSadeSati>) {
          return _buildSadeSatiLifeContent(data as List<RawSadeSati>);
        } else if (data is Map<String, dynamic>) {
          // Handle if we passed a map with both current and life,
          // but for now let's assume we pass the relevant object
          return const Text("Complex Sade Sati Data");
        }
        return const Text("No Details Available");
      case 'pitra':
        return _buildPitraContent(data as RawPitra?);
      default:
        return const Center(child: Text("Details not available"));
    }
  }

  Widget _buildManglikContent(RawManglik? manglik) {
    if (manglik == null) return const Text("No Data");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Status"),
        _buildInfoCard(
          "Manglik Status: ${manglik.manglikStatus ?? 'N/A'}",
          manglik.manglikReport ?? "",
        ),
        if (manglik.percentageManglikPresent != null)
          _buildInfoCard(
            "Intensity",
            "Percentage: ${manglik.percentageManglikPresent}%\nAfter Cancellation: ${manglik.percentageManglikAfterCancellation}%",
          ),
        if (manglik.manglikPresentRule?.basedOnAspect != null &&
            manglik.manglikPresentRule!.basedOnAspect!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Reasons (Aspect)"),
          ...manglik.manglikPresentRule!.basedOnAspect!.map(
            (e) => _buildBulletPoint(e),
          ),
        ],
        if (manglik.manglikPresentRule?.basedOnHouse != null &&
            manglik.manglikPresentRule!.basedOnHouse!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Reasons (House)"),
          ...manglik.manglikPresentRule!.basedOnHouse!.map(
            (e) => _buildBulletPoint(e),
          ),
        ],
        if (manglik.manglikCancelRule != null &&
            manglik.manglikCancelRule!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Cancellation Rules"),
          ...manglik.manglikCancelRule!.map((e) => _buildBulletPoint(e)),
        ],
      ],
    );
  }

  Widget _buildKalsarpaContent(RawKalsarpa? kalsarpa) {
    if (kalsarpa == null) return const Text("No Data");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Analysis"),
        _buildInfoCard(
          kalsarpa.present == true ? "Present" : "Not Present",
          kalsarpa.oneLine ?? "No description available",
        ),
      ],
    );
  }

  Widget _buildSadeSatiCurrentContent(RawSadeSatiCurrent? current) {
    if (current == null) return const Text("No Data");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Current Status"),
        _buildInfoCard(
          "Undergoing Sade Sati?",
          current.isUndergoingSadhesati ?? "-",
        ),
        _buildInfoCard("Moon Sign", current.moonSign ?? "-"),
        _buildInfoCard("Saturn Sign", current.saturnSign ?? "-"),
        if (current.whatIsSadhesati != null)
          _buildInfoCard("What is Sade Sati?", current.whatIsSadhesati!),
      ],
    );
  }

  Widget _buildSadeSatiLifeContent(List<RawSadeSati> life) {
    if (life.isEmpty) return const Text("No Life Cycles Data");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Sade Sati Life Cycles"),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: life.length,
          separatorBuilder: (c, i) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = life[index];
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${item.type?.replaceAll('_', ' ')}",
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Date: ${item.date}",
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${item.summary}",
                    style: GoogleFonts.lora(fontSize: 13),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPitraContent(RawPitra? pitra) {
    if (pitra == null) return const Text("No Data");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Overview"),
        _buildInfoCard("Conclusion", pitra.conclusion ?? "-"),

        if (pitra.whatIsPitriDosha != null) ...[
          const SizedBox(height: 16),
          _buildInfoCard("What is Pitra Dosha?", pitra.whatIsPitriDosha!),
        ],

        if (pitra.rulesMatched != null && pitra.rulesMatched!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Rules Matched"),
          ...pitra.rulesMatched!.map((e) => _buildBulletPoint(e)),
        ],
        if (pitra.effects != null && pitra.effects!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Effects"),
          ...pitra.effects!.map((e) => _buildBulletPoint(e)),
        ],
        if (pitra.remedies != null && pitra.remedies!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSectionTitle("Remedies"),
          ...pitra.remedies!.map((e) => _buildBulletPoint(e)),
        ],
      ],
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
          color: const Color(0xFF5D4037),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFEBE9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.lora(
              fontSize: 15,
              color: const Color(0xFF3E2723),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF8D6E63)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: const Color(0xFF4E342E),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
