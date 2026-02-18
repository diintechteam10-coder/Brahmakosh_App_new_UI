import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/astrology_details_screen.dart';

class DoshaDetailScreen extends StatelessWidget {
  final String title;
  final String doshaType;
  final dynamic data;

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
        return _buildSadeSatiCurrentContent(data as RawSadeSatiCurrent?);
      case 'sadesati_life':
        return _buildSadeSatiLifeContent(data as List<RawSadeSati>? ?? []);
      case 'pitra':
        return _buildPitraContent(data as RawPitra?);
      default:
        return Center(
          child: Text(
            "Details for $title not available",
            style: GoogleFonts.lora(),
          ),
        );
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
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: life.length,
          itemBuilder: (context, index) {
            final item = life[index];
            return _buildTimelineItem(
              context,
              item,
              index == 0,
              index == life.length - 1,
            );
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    RawSadeSati item,
    bool isFirst,
    bool isLast,
  ) {
    final phaseColor = _getPhaseColor(item.type);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line and Dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Upper Line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isFirst
                        ? Colors.transparent
                        : const Color(0xFFD7CCC8),
                  ),
                ),
                // Dot
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: phaseColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(
                        0xFFFFFBF5,
                      ), // Background color for gap
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: phaseColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                // Lower Line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : const Color(0xFFD7CCC8),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: phaseColor.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: phaseColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            (item.type?.replaceAll('_', ' ') ?? "Cycle")
                                .toUpperCase(),
                            style: GoogleFonts.lora(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: phaseColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Date: ${item.date}",
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${item.summary}",
                      style: GoogleFonts.lora(
                        fontSize: 14,
                        color: const Color(0xFF4E342E),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor(String? type) {
    if (type == null) return const Color(0xFF6D3A0C);
    final lowerType = type.toLowerCase();
    if (lowerType.contains('rising')) {
      return const Color(0xFFE65100); // Warm Orange for Rising
    } else if (lowerType.contains('peak')) {
      return const Color(0xFFB71C1C); // Deep Red for Peak
    } else if (lowerType.contains('setting')) {
      return const Color(0xFF2E7D32); // Green for Setting/Cooling
    }
    return const Color(0xFF6D3A0C); // Default Brown
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
