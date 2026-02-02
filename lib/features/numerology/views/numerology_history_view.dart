import 'package:brahmakosh/features/numerology/controllers/numerology_controller.dart';
import 'package:brahmakosh/features/numerology/models/numerology_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class NumerologyHistoryView extends StatelessWidget {
  const NumerologyHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NumerologyController());

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: Text(
          "Mystical Insights",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6D3A0C)),
          );
        }

        if (controller.numerologyHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: const Color(0xFF6D3A0C).withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  "No insights found yet.",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    color: const Color(0xFF6D3A0C).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            // Determine if tablet based on width > 600
            bool isTablet = constraints.maxWidth > 600;
            int crossAxisCount = isTablet ? 2 : 1;
            // For very large screens, maybe 3 columns
            if (constraints.maxWidth > 900) crossAxisCount = 3;

            if (isTablet) {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.65, // Adjust based on card content height
                ),
                itemCount: controller.numerologyHistory.length,
                itemBuilder: (context, index) {
                  final item = controller.numerologyHistory[index];
                  return SingleChildScrollView(
                    child: _buildPremiumHistoryCard(
                      item,
                      constraints.maxWidth / crossAxisCount,
                    ),
                  );
                },
              );
            } else {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                itemCount: controller.numerologyHistory.length,
                itemBuilder: (context, index) {
                  final item = controller.numerologyHistory[index];
                  return _buildPremiumHistoryCard(item, constraints.maxWidth);
                },
              );
            }
          },
        );
      }),
    );
  }

  Widget _buildPremiumHistoryCard(
    NumerologyHistoryItem item,
    double parentWidth,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6D3A0C).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // Important for usage in ScrollView
        children: [
          // 1. Header with Name and Date
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF6D3A0C),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              image: DecorationImage(
                image: NetworkImage(
                  "https://www.transparenttextures.com/patterns/stardust.png",
                ), // Subtle texture if needed, or remove
                opacity: 0.1,
                fit: BoxFit.cover,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? "Seeker",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFDECB6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.dailyPrediction?.predictionDate ?? "Unknown Date",
                        style: GoogleFonts.lora(
                          fontSize: 12,
                          color: const Color(0xFFFDECB6).withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDECB6).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFFDECB6),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),

          // 2. Daily Prediction
          if (item.dailyPrediction != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "✨ Daily Guidance",
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: const Color(0xFF874101),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "\"${item.dailyPrediction!.prediction ?? ""}\"",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                      color: const Color(0xFF4A4A4A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLuckyBox(
                          "Lucky Color",
                          item.dailyPrediction!.luckyColor ?? "-",
                          Icons.palette_outlined,
                          const Color(0xFFE8F5E9),
                          const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildLuckyBox(
                          "Lucky Number",
                          item.dailyPrediction!.luckyNumber ?? "-",
                          Icons.confirmation_number_outlined,
                          const Color(0xFFE3F2FD),
                          const Color(0xFF1565C0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // 3. Divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: const Color(0xFF6D3A0C).withOpacity(0.1)),
          ),

          // 4. Numero Report
          if (item.numeroReport != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 20,
                        color: Color(0xFF6D3A0C),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.numeroReport!.title ?? "Numerology Report",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D3A0C),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFDECB6),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      item.numeroReport!.description ?? "",
                      style: GoogleFonts.lora(
                        fontSize: 13,
                        height: 1.6,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 5. Numero Table Grid
          if (item.numeroTable != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              color: const Color(0xFFFDECB6).withOpacity(0.3),
              child: Row(
                children: [
                  const Icon(
                    Icons.grid_view,
                    size: 20,
                    color: Color(0xFF6D3A0C),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Your Numerological Chart",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: _buildNumeroGrid(item.numeroTable!, parentWidth),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLuckyBox(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: accentColor, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: accentColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNumeroGrid(NumeroTable table, double parentWidth) {
    final items = [
      {"label": "Destiny No", "value": "${table.destinyNumber}"},
      {"label": "Radical No", "value": "${table.radicalNumber}"},
      {"label": "Name No", "value": "${table.nameNumber}"},
      {"label": "Evil No", "value": table.evilNum},
      {"label": "Fav Color", "value": table.favColor},
      {"label": "Fav Day", "value": table.favDay},
      {"label": "Fav God", "value": table.favGod},
      {"label": "Fav Mantra", "value": table.favMantra}, // Added Mantra
      {"label": "Fav Metal", "value": table.favMetal},
      {"label": "Fav Stone", "value": table.favStone},
      {"label": "Friendly No", "value": table.friendlyNum},
      {"label": "Radical Ruler", "value": table.radicalRuler},
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        // Dynamic width calculation based on parent container
        // Subtract paddings: 20 (card left) + 20 (card right) + 16 (screen left) + 16 (screen right) if full width
        // But here we use 'parentWidth' passed down efficiently.
        // We roughly want 2 columns on mobile, maybe 3 on wider cards.

        // Approximate available width inside the padding
        double availableWidth =
            parentWidth - 40; // Minus card internal padding (20*2)
        if (availableWidth < 0) availableWidth = 300; // fallback

        // On mobile (narrow), 2 columns. On wider tablet card, maybe 3.
        int columns = availableWidth > 500 ? 3 : 2;

        double itemWidth = (availableWidth - (12 * (columns - 1))) / columns;

        return Container(
          width: itemWidth,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEE5D3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['label']!,
                style: GoogleFonts.lora(
                  fontSize: 10,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['value'] ?? "-",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3E2723),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
