import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/dosha_detail_screen.dart';
import 'package:brahmakosh/features/home/widgets/north_indian_chart.dart';

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

class BirthChartTab extends StatefulWidget {
  final BirthChart birthChart;
  final BirthExtendedChart? birthExtendedChart;
  final AstroDetails? astroDetails;

  const BirthChartTab({
    super.key,
    required this.birthChart,
    this.birthExtendedChart,
    this.astroDetails,
  });

  @override
  State<BirthChartTab> createState() => _BirthChartTabState();
}

class _BirthChartTabState extends State<BirthChartTab> {
  // 0 = Lagna Chart (D1), 1 = Navamsa Chart (D9)
  int _selectedChartindex = 0;

  @override
  Widget build(BuildContext context) {
    // 1. Prepare Data based on selection
    Map<int, List<String>> currentHouses = {};
    if (_selectedChartindex == 0) {
      currentHouses = _getHousesFromBirthChart(widget.birthChart);
    } else {
      currentHouses = _getHousesFromExtendedChart(widget.birthExtendedChart);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          // Toggle Buttons
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleBtn("Birth Chart", 0),
                _buildToggleBtn("Birth Extended Chart", 1),
              ],
            ),
          ),
          const SizedBox(height: 20),

          NorthIndianChart(
            housesPlanets: currentHouses,
            ascendantSign: widget.astroDetails?.ascendant,
          ),

          const SizedBox(height: 24),
          Text(
            "Planet Notations",
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _LegendItem(code: "Su", name: "Sun"),
              _LegendItem(code: "Mo", name: "Moon"),
              _LegendItem(code: "Ma", name: "Mars"),
              _LegendItem(code: "Me", name: "Mercury"),
              _LegendItem(code: "Ju", name: "Jupiter"),
              _LegendItem(code: "Ve", name: "Venus"),
              _LegendItem(code: "Sa", name: "Saturn"),
              _LegendItem(code: "Ra", name: "Rahu"),
              _LegendItem(code: "Ke", name: "Ketu"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, int index) {
    bool isSelected = _selectedChartindex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChartindex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Map<int, List<String>> _getHousesFromBirthChart(BirthChart chart) {
    return {
      1: chart.houses?.house1 ?? [],
      2: chart.houses?.house2 ?? [],
      3: chart.houses?.house3 ?? [],
      4: chart.houses?.house4 ?? [],
      5: chart.houses?.house5 ?? [],
      6: chart.houses?.house6 ?? [],
      7: chart.houses?.house7 ?? [],
      8: chart.houses?.house8 ?? [],
      9: chart.houses?.house9 ?? [],
      10: chart.houses?.house10 ?? [],
      11: chart.houses?.house11 ?? [],
      12: chart.houses?.house12 ?? [],
    };
  }

  Map<int, List<String>> _getHousesFromExtendedChart(
    BirthExtendedChart? chart,
  ) {
    if (chart == null) return {};
    return {
      1: chart.houses?.house1 ?? [],
      2: chart.houses?.house2 ?? [],
      3: chart.houses?.house3 ?? [],
      4: chart.houses?.house4 ?? [],
      5: chart.houses?.house5 ?? [],
      6: chart.houses?.house6 ?? [],
      7: chart.houses?.house7 ?? [],
      8: chart.houses?.house8 ?? [],
      9: chart.houses?.house9 ?? [],
      10: chart.houses?.house10 ?? [],
      11: chart.houses?.house11 ?? [],
      12: chart.houses?.house12 ?? [],
    };
  }
}

class DoshasTab extends StatelessWidget {
  final Doshas doshas;

  const DoshasTab({super.key, required this.doshas});

  @override
  Widget build(BuildContext context) {
    debugPrint("DOSHAS_TAB_DEBUG: manglik != null: ${doshas.manglik != null}");
    debugPrint(
      "DOSHAS_TAB_DEBUG: kalsarpa != null: ${doshas.kalsarpa != null}",
    );
    debugPrint(
      "DOSHAS_TAB_DEBUG: sadeSatiCurrent != null: ${doshas.sadeSatiCurrent != null}",
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          _buildDoshaCard(
            context,
            "Manglik Dosha",
            doshas.manglik?.present ?? false,
            doshas.manglik?.raw?.manglikReport ?? doshas.manglik?.description,
            "manglik",
            doshas.manglik?.raw,
          ),
          _buildDoshaCard(
            context,
            "Kalsarpa Dosha",
            doshas.kalsarpa?.present ?? false,
            doshas.kalsarpa?.raw?.oneLine ?? doshas.kalsarpa?.description,
            "kalsarpa",
            doshas.kalsarpa?.raw,
          ),
          _buildDoshaCard(
            context,
            "Sade Sati",
            doshas.sadeSatiCurrent?.present ?? false,
            doshas.sadeSatiCurrent?.raw?.isUndergoingSadhesati ??
                doshas.sadeSatiCurrent?.status,
            "sadesati",
            doshas.sadeSatiCurrent?.raw,
          ),
          if (doshas.sadeSatiLife?.raw != null &&
              doshas.sadeSatiLife!.raw!.isNotEmpty)
            _buildDoshaCard(
              context,
              "Sade Sati Life Cycles",
              doshas.sadeSatiLife?.present ?? false,
              "View Life Cycles",
              "sadesati_life",
              doshas.sadeSatiLife?.raw,
            ),
          _buildDoshaCard(
            context,
            "Pitra Dosha",
            doshas.pitra?.present ?? false,
            doshas.pitra?.raw?.conclusion ?? doshas.pitra?.description,
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
    debugPrint(
      "DASHAS_TAB_DEBUG: currentYogini != null: ${dashas.currentYogini != null}",
    );
    debugPrint(
      "DASHAS_TAB_DEBUG: currentChardasha != null: ${dashas.currentChardasha != null}",
    );
    debugPrint(
      "DASHAS_TAB_DEBUG: majorChardasha != null: ${dashas.majorChardasha != null}",
    );

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
            const SizedBox(height: 24),
          ],

          if (dashas.vimshottariDasha != null) ...[
            Text(
              "Vimshottari Dasha",
              style: GoogleFonts.lora(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashas.vimshottariDasha!.length,
              itemBuilder: (context, index) {
                final dasha = dashas.vimshottariDasha![index];
                return _buildDashaCard(
                  dasha.planet ?? "",
                  "${dasha.start} - ${dasha.end}",
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

class _LegendItem extends StatelessWidget {
  final String code;
  final String name;

  const _LegendItem({super.key, required this.code, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "$code: ",
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF5722), // Orange for code
          ),
        ),
        Text(
          name,
          style: GoogleFonts.lora(
            color: const Color(0xFF5D4037), // Brown for name
          ),
        ),
      ],
    );
  }
}
