import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/models/remedies_model.dart';
import 'package:brahmakosh/common/api_urls.dart';

class GemstoneDetailView extends StatefulWidget {
  final Gemstones gemstones;
  const GemstoneDetailView({super.key, required this.gemstones});

  @override
  State<GemstoneDetailView> createState() => _GemstoneDetailViewState();
}

class _GemstoneDetailViewState extends State<GemstoneDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // Old Lace / Beige bg
      appBar: AppBar(
        title: Text(
          "Gemstone Details",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6D3A0C),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD4A373),
          labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Life"),
            Tab(text: "Benefic"),
            Tab(text: "Lucky"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGemstonePage(widget.gemstones.life),
          _buildGemstonePage(widget.gemstones.benefic),
          _buildGemstonePage(widget.gemstones.lucky),
        ],
      ),
    );
  }

  Widget _buildGemstonePage(GemstoneDetail? detail) {
    if (detail == null) {
      return const Center(child: Text("No details available"));
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A373).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: const Color(0xFFFDECB6).withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              detail.name ?? "Gemstone",
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF6D3A0C),
              ),
            ),
            const SizedBox(height: 8),
            if (detail.semiGem != null && detail.semiGem!.isNotEmpty)
              Text(
                "Sub-Gem: ${detail.semiGem}",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const Divider(height: 32),
            _buildDetailRow("Wear Finger", detail.wearFinger),
            _buildDetailRow("Weight (Carat)", detail.weightCaret),
            _buildDetailRow("Metal", detail.wearMetal),
            _buildDetailRow("Wear Day", detail.wearDay),
            _buildDetailRow("Deity", detail.gemDeity),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF8D6E63),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lora(
                fontSize: 16,
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

class RudrakshaDetailView extends StatelessWidget {
  final Rudraksha rudraksha;
  const RudrakshaDetailView({super.key, required this.rudraksha});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: Text(
          "Rudraksha Details",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Image Placeholder (or real image if url is valid/handled)
            // Assuming local mapping or network image based on user setup.
            // Using a placeholder icon for now as base_url handling for images might vary.
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFD7CCC8),
                borderRadius: BorderRadius.circular(20),
                image: rudraksha.imgUrl != null
                    ? DecorationImage(
                        image: NetworkImage(
                          "${ApiUrls.baseUrl}${rudraksha.imgUrl}",
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: rudraksha.imgUrl == null
                  ? const Icon(Icons.spa, size: 80, color: Color(0xFF8D6E63))
                  : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD4A373).withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFFFDECB6).withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rudraksha.name ?? "Rudraksha",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Recommendation",
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8D6E63),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rudraksha.recommend ?? "Recommended for you.",
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: const Color(0xFF5D4037),
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Divider(height: 32),
                  Text(
                    "Details & Benefits",
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF8D6E63),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    rudraksha.detail ?? "No additional details.",
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: const Color(0xFF5D4037),
                      height: 1.6,
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

class PujaDetailView extends StatelessWidget {
  final Puja puja;
  const PujaDetailView({super.key, required this.puja});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6),
      appBar: AppBar(
        title: Text(
          "Puja Suggestions",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: const Color(0xFFFDF5E6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A373).withOpacity(0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFFDECB6).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Summary",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4A373),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                puja.summary ?? "No summary available.",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  color: const Color(0xFF5D4037),
                  height: 1.5,
                ),
              ),
              if (puja.suggestions != null && puja.suggestions!.isNotEmpty) ...[
                const Divider(height: 32),
                Text(
                  "Suggested Pujas",
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4A373),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: puja.suggestions!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              puja.suggestions![index].toString(),
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                color: const Color(0xFF3E2723),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
