import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/dosha_detail_screen.dart';

class PlanetsTab extends StatelessWidget {
  final List<Planets> planets;
  final VoidCallback onViewAllTap;

  const PlanetsTab({
    super.key,
    required this.planets,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 16),
      child: Column(
        children: [
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: planets.take(5).length, // Show only first few
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final planet = planets[index];
              return _buildPlanetItem(planet);
            },
          ),
          const SizedBox(height: 16),
          _buildViewAllButton(context),
        ],
      ),
    );
  }

  Widget _buildPlanetItem(Planets planet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF9A825), Color(0xFFFBC02D)], // Gold gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                planet.name?.substring(0, 1) ?? "P",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planet.name ?? "Planet",
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF4A4A4A),
                  ),
                ),
                Text(
                  planet.sign ?? "",
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF5A6BB2), // Blueish tint for sign
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              Text(
                "House ${planet.house}",
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return InkWell(
      onTap: onViewAllTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFDECB6).withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "View All Planets",
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6D3A0C),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: Color(0xFF6D3A0C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BirthChartTab extends StatelessWidget {
  final BirthChart birthChart;
  final BirthExtendedChart? birthExtendedChart;

  const BirthChartTab({
    super.key,
    required this.birthChart,
    this.birthExtendedChart,
  });

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for the chart. A real chart drawing would be complex.
    // For now, we will list the houses as a grid or list.
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 12,
      itemBuilder: (context, index) {
        int houseNum = index + 1;
        List<String> planets = [];

        switch (houseNum) {
          case 1:
            planets = birthChart.houses?.house1 ?? [];
            break;
          case 2:
            planets = birthChart.houses?.house2 ?? [];
            break;
          case 3:
            planets = birthChart.houses?.house3 ?? [];
            break;
          case 4:
            planets = birthChart.houses?.house4 ?? [];
            break;
          case 5:
            planets = birthChart.houses?.house5 ?? [];
            break;
          case 6:
            planets = birthChart.houses?.house6 ?? [];
            break;
          case 7:
            planets = birthChart.houses?.house7 ?? [];
            break;
          case 8:
            planets = birthChart.houses?.house8 ?? [];
            break;
          case 9:
            planets = birthChart.houses?.house9 ?? [];
            break;
          case 10:
            planets = birthChart.houses?.house10 ?? [];
            break;
          case 11:
            planets = birthChart.houses?.house11 ?? [];
            break;
          case 12:
            planets = birthChart.houses?.house12 ?? [];
            break;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              "House $houseNum",
              style: GoogleFonts.lora(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              planets.isEmpty ? "Empty" : planets.join(", "),
              style: GoogleFonts.lora(),
            ),
            trailing: Text(
              "Sign: -",
            ), // Sign info not directly available in simple structure, need logic
          ),
        );
      },
    );
  }
}

class DoshasTab extends StatelessWidget {
  final Doshas doshas;

  const DoshasTab({super.key, required this.doshas});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildDoshaCard(
            context,
            "Manglik Dosha",
            doshas.manglik?.present ?? false,
            doshas.manglik?.description,
            "manglik",
            doshas.manglik?.raw,
          ),
          _buildDoshaCard(
            context,
            "Kalsarpa Dosha",
            doshas.kalsarpa?.present ?? false,
            doshas.kalsarpa?.description,
            "kalsarpa",
            doshas.kalsarpa?.raw,
          ),
          _buildDoshaCard(
            context,
            "Sade Sati",
            doshas.sadeSatiCurrent?.present ?? false,
            doshas.sadeSatiCurrent?.status,
            "sadesati",
            doshas.sadeSatiCurrent,
          ),
          // Optionally add Sade Sati Life if needed separately, or expect user to navigate via Sade Sati
          if (doshas.sadeSatiLife?.raw != null &&
              doshas.sadeSatiLife!.raw!.isNotEmpty)
            _buildDoshaCard(
              context,
              "Sade Sati Life Cycles",
              doshas.sadeSatiLife?.present ?? false,
              "View Life Cycles",
              "sadesati",
              doshas.sadeSatiLife?.raw,
            ),

          _buildDoshaCard(
            context,
            "Pitra Dosha",
            doshas.pitra?.present ?? false,
            doshas.pitra?.description,
            "pitra",
            doshas.pitra?.raw,
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaCard(
    BuildContext context,
    String title,
    bool isPresent,
    String? description,
    String doshaType,
    dynamic rawData,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoshaDetailScreen(
              title: title,
              doshaType: doshaType,
              data: rawData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPresent
                ? Colors.red.withOpacity(0.3)
                : Colors.green.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isPresent ? Colors.red[700] : Colors.green[700],
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      isPresent
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: isPresent ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashasTab extends StatelessWidget {
  final Dashas dashas;

  const DashasTab({super.key, required this.dashas});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dashas.currentYogini != null) ...[
            Text(
              "Current Yogini Dasha",
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildDashaCard(
              "Major: ${dashas.currentYogini!.majorDasha?.dashaName}",
              "${dashas.currentYogini!.majorDasha?.startDate} - ${dashas.currentYogini!.majorDasha?.endDate}",
            ),
            _buildDashaCard(
              "Sub: ${dashas.currentYogini!.subDasha?.dashaName}",
              "${dashas.currentYogini!.subDasha?.startDate} - ${dashas.currentYogini!.subDasha?.endDate}",
            ),
            _buildDashaCard(
              "Sub-Sub: ${dashas.currentYogini!.subSubDasha?.dashaName}",
              "${dashas.currentYogini!.subSubDasha?.startDate} - ${dashas.currentYogini!.subSubDasha?.endDate}",
            ),
            const SizedBox(height: 24),
          ],

          if (dashas.currentChardasha != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Current Chardasha",
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (dashas.currentChardasha!.dashaDate != null)
                  Text(
                    "${dashas.currentChardasha!.dashaDate}",
                    style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),

            const SizedBox(height: 8),
            if (dashas.currentChardasha!.majorDasha != null)
              _buildDashaCard(
                "Major: ${dashas.currentChardasha!.majorDasha?.signName}",
                "${dashas.currentChardasha!.majorDasha?.startDate} - ${dashas.currentChardasha!.majorDasha?.endDate}",
              ),
            if (dashas.currentChardasha!.subDasha != null)
              _buildDashaCard(
                "Sub: ${dashas.currentChardasha!.subDasha?.signName}",
                "${dashas.currentChardasha!.subDasha?.startDate} - ${dashas.currentChardasha!.subDasha?.endDate}",
              ),
            if (dashas.currentChardasha!.subSubDasha != null)
              _buildDashaCard(
                "Sub-Sub: ${dashas.currentChardasha!.subSubDasha?.signName}",
                "${dashas.currentChardasha!.subSubDasha?.startDate} - ${dashas.currentChardasha!.subSubDasha?.endDate}",
              ),
            const SizedBox(height: 24),
          ],

          if (dashas.majorChardasha != null) ...[
            Text(
              "Major Chardasha",
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashas.majorChardasha!.length,
              itemBuilder: (context, index) {
                final dasha = dashas.majorChardasha![index];
                return _buildDashaCard(
                  dasha.signName ?? "",
                  "${dasha.startDate} - ${dasha.endDate}",
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDashaCard(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          Text(
            subtitle,
            style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class BasicInfoTab extends StatelessWidget {
  final AstroDetails astroDetails;

  const BasicInfoTab({super.key, required this.astroDetails});

  @override
  Widget build(BuildContext context) {
    // Map of display name to property value
    final Map<String, String?> details = {
      "Ascendant": astroDetails.ascendant,
      "Ascendant Lord": astroDetails.ascendantLord,
      "Sign": astroDetails.sign,
      "Sign Lord": astroDetails.signLord,
      "Nakshatra": astroDetails.nakshatra,
      "Nakshatra Lord": astroDetails.nakshatraLord,
      "Charan": astroDetails.charan,
      "Varna": astroDetails.varna,
      "Vashya": astroDetails.vashya,
      "Yoni": astroDetails.yoni,
      "Gan": astroDetails.gan,
      "Nadi": astroDetails.nadi,
      "Tithi": astroDetails.tithi,
      "Yog": astroDetails.yog,
      "Karan": astroDetails.karan,
      "Yunja": astroDetails.yunja,
      "Tatva": astroDetails.tatva,
      "Name Alphabet": astroDetails.nameAlphabet,
      "Paya": astroDetails.paya,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: details.entries.map((entry) {
          return _buildDetailRow(entry.key, entry.value ?? "-");
        }).toList(),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lora(fontSize: 14, color: Colors.grey[700]),
          ),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}
