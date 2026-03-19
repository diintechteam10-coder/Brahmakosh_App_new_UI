import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/dosha_detail_screen.dart';
import 'package:brahmakosh/features/home/widgets/north_indian_chart.dart';
import 'package:brahmakosh/features/home/views/all_dashas_screen.dart';

class PlanetsTab extends StatelessWidget {
  final List<Planets> planets;
  final VoidCallback onViewAllTap;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _accentGold = Color(0xFFD4AF37);

  const PlanetsTab({
    super.key,
    required this.planets,
    required this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Column(
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: planets.take(5).length,
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
      ),
    );
  }

  Widget _buildPlanetItem(Planets planet) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4A3E92), // Lighter violet gradient start
            const Color(0xFF332766), // Darker violet gradient end
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF5E4EA6).withOpacity(0.5), width: 1.5), // Inner light border impression
        boxShadow: [
          // Inner shadow illusion via a dark drop shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accentGold, _accentGold.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                planet.name?.substring(0, 1) ?? "P",
                style: GoogleFonts.poppins(
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                Text(
                  planet.sign ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 16, // Increased sign font size
                    fontWeight: FontWeight.w700, // Made sign bolder like reference
                    color: _textPrimary, // Changed to white
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "House ${planet.house}",
                style: GoogleFonts.poppins(fontSize: 14, color: _textPrimary), // Changed to white
              ),
              const SizedBox(height: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: _textPrimary), // Changed to white and moved below
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xff614FFE),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _cardBorder, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "View All Planets",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BasicInfoTab extends StatelessWidget {
  final AstroDetails astroDetails;
  final GhatChakra? ghatChakra;
  final List<AyanamshaEntry>? ayanamsha;

  // Dark theme colors
  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _sectionLine = Color(0xFF1E1E4D);

  const BasicInfoTab({
    super.key,
    required this.astroDetails,
    this.ghatChakra,
    this.ayanamsha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoSection("BASIC DETAILS", [
              _buildInfoRow("Ascendant", astroDetails.ascendant ?? "-"),
              _buildInfoRow("Sign", astroDetails.sign ?? "-"),
              _buildInfoRow("Sign Lord", astroDetails.signLord ?? "-"),
              _buildInfoRow("Nakshatra Lord", astroDetails.nakshatraLord ?? "-"),
              _buildInfoRow("Charan", astroDetails.charan.toString()),
              _buildInfoRow("Yog", astroDetails.yog ?? "-"),
              _buildInfoRow("Karan", astroDetails.karan ?? "-"),
              _buildInfoRow("Tithi", astroDetails.tithi ?? "-"),
            ]),

            if (ghatChakra != null) ...[
              const SizedBox(height: 24),
              _buildInfoSection("PANCHANG / GHAT CHAKRA", [
                if (ghatChakra!.month != null)
                  _buildInfoRow("Month", ghatChakra!.month!),
                if (ghatChakra!.tithi != null)
                  _buildInfoRow("Tithi", ghatChakra!.tithi!),
                if (ghatChakra!.day != null)
                  _buildInfoRow("Day", ghatChakra!.day!),
                if (ghatChakra!.nakshatra != null)
                  _buildInfoRow("Nakshatra", ghatChakra!.nakshatra!),
                if (ghatChakra!.yog != null)
                  _buildInfoRow("Yog", ghatChakra!.yog!),
                if (ghatChakra!.karan != null)
                  _buildInfoRow("Karan", ghatChakra!.karan!),
                if (ghatChakra!.pahar != null)
                  _buildInfoRow("Pahar", ghatChakra!.pahar!),
                if (ghatChakra!.moon != null)
                  _buildInfoRow("Moon", ghatChakra!.moon!),
              ]),
            ],

            if (ayanamsha != null && ayanamsha!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildInfoSection("AYANAMSHA", [
                ...ayanamsha!.map(
                  (e) => _buildInfoRow(
                    e.type?.replaceAll('_', ' ') ?? "Type",
                    e.formatted ?? "${e.degree?.toStringAsFixed(2)}°",
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          Divider(
            color: _sectionLine,
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
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: _textPrimary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          ...spacedChildren,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            color: _textPrimary,
          ),
        ),
      ],
    );
  }
}

class BhavChalitTab extends StatelessWidget {
  final BhavMadhya bhavMadhya;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF332A5B); // Darker tone of violet for the table body
  static const Color _cardBorder = Color(0xFF433989); // Distinct outline
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFE2DFEE); // Lighter text secondary
  static const Color _tableHeader = Color(0xFF614FFE); // Match the exact header tone from screenshot

  const BhavChalitTab({super.key, required this.bhavMadhya});

  @override
  Widget build(BuildContext context) {
    final Map<int, BhavMadhyaHouse> madhyaMap = {};
    if (bhavMadhya.bhavMadhya != null) {
      for (var item in bhavMadhya.bhavMadhya!) {
        if (item.house != null) madhyaMap[item.house!] = item;
      }
    }

    final Map<int, BhavSandhiHouse> sandhiMap = {};
    if (bhavMadhya.bhavSandhi != null) {
      for (var item in bhavMadhya.bhavSandhi!) {
        if (item.house != null) sandhiMap[item.house!] = item;
      }
    }

    final List<int> houses = List.generate(12, (index) => index + 1);

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: _cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _cardBorder, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(_tableHeader),
                  columnSpacing: 10,
                  dataRowMinHeight: 60,
                  dataRowMaxHeight: 80,
                  border: TableBorder.all(
                    color: _cardBorder,
                    width: 1,
                  ),
                  columns: [
                    DataColumn(
                      label: Center(
                        child: Text(
                          "House",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Center(
                        child: Text(
                          "Bhav\nMadhya",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Center(
                        child: Text(
                          "Bhav\nSandhi",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                  rows: houses.map((houseId) {
                    final madhya = madhyaMap[houseId];
                    final sandhi = sandhiMap[houseId];

                    return DataRow(
                      cells: [
                        DataCell(
                          Center(
                            child: Text(
                              "Bhav\n$houseId",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: _textPrimary,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: _buildCellContent(
                              sign: madhya?.sign,
                              degree: madhya?.normDegree ?? madhya?.degree,
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: _buildCellContent(
                              sign: sandhi?.sign,
                              degree: sandhi?.normDegree ?? sandhi?.degree,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCellContent({String? sign, double? degree}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          sign ?? "-",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _toDMS(degree),
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: _textSecondary),
        ),
      ],
    );
  }

  String _toDMS(double? decimalDegree) {
    if (decimalDegree == null) return "-";
    int d = decimalDegree.toInt();
    double mPart = (decimalDegree - d) * 60;
    int m = mPart.toInt();
    double sPart = (mPart - m) * 60;
    int s = sPart.round();
    return "$d°$m'${s}\"";
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
  int _selectedChartindex = 0;

  static const Color _bgDark = Colors.black;
  static const Color _textPrimary = Colors.white;

  @override
  Widget build(BuildContext context) {
    Map<int, List<String>> currentHouses = {};
    if (_selectedChartindex == 0) {
      currentHouses = _getHousesFromBirthChart(widget.birthChart);
    } else {
      currentHouses = _getHousesFromExtendedChart(widget.birthExtendedChart);
    }

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1F1D36), // Dark background for the toggle container
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildToggleBtn("Birth Chart", 0),
                  _buildToggleBtn("Extended Chart", 1),
                ],
              ),
            ),
            const SizedBox(height: 8),
            NorthIndianChart(
              housesPlanets: currentHouses,
              ascendantSign: widget.astroDetails?.ascendant,
            ),
            
             const SizedBox(height: 24),
            _buildSectionHeader("PLANET NOTATIONS"),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
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
      ),
    );
  }

 Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: const Color(0xFF1E1E4D),
        ),
      ],
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B4EFF) : Colors.transparent, // Match the bright purple
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label.toUpperCase(), // Text is uppercase in reference
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isSelected ? Colors.white : _textPrimary.withOpacity(0.5),
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
  final List<SadhesatiLifeDetail>? sadhesatiLifeDetails;
  final PitraDoshaReport? pitraDoshaReport;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);

  const DoshasTab({
    super.key,
    required this.doshas,
    this.sadhesatiLifeDetails,
    this.pitraDoshaReport,
  });

  @override
  Widget build(BuildContext context) {
    final hasSadeSatiLife =
        (doshas.sadeSatiLife?.raw != null &&
            doshas.sadeSatiLife!.raw!.isNotEmpty) ||
        (sadhesatiLifeDetails != null && sadhesatiLifeDetails!.isNotEmpty);

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            if (hasSadeSatiLife)
              _buildDoshaCard(
                context,
                "Sade Sati Life Cycles",
                doshas.sadeSatiLife?.present ?? false,
                "View Life Cycles",
                "sadesati_life",
                sadhesatiLifeDetails ??
                    doshas.sadeSatiLife?.raw
                        ?.map(
                          (e) => SadhesatiLifeDetail(
                            moonSign: e.moonSign,
                            saturnSign: e.saturnSign,
                            isSaturnRetrograde: e.isSaturnRetrograde,
                            type: e.type,
                            millisecond: e.millisecond,
                            date: e.date,
                            summary: e.summary,
                          ),
                        )
                        .toList(),
              ),
            _buildDoshaCard(
              context,
              "Pitra Dosha",
              pitraDoshaReport?.isPitriDoshaPresent ??
                  (doshas.pitra?.present ?? false),
              pitraDoshaReport?.conclusion ??
                  (doshas.pitra?.raw?.conclusion ?? doshas.pitra?.description),
              "pitra",
              pitraDoshaReport ?? doshas.pitra?.raw,
            ),
          ],
        ),
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
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _cardBorder,
            width: 1,
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
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPresent ? _accentGold.withOpacity(0.1) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isPresent ? Border.all(color: _accentGold.withOpacity(0.5)) : null,
                      ),
                      child: Text(
                        isPresent ? "PRESENT" : "NOT PRESENT",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isPresent ? _accentGold : _textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Colors.white54,
                    ),
                  ],
                ),
              ],
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
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

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _textMuted = Color(0xFF7A7A9E);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _sectionLine = Color(0xFF1E1E4D);

  const DashasTab({super.key, required this.dashas});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dashas.currentVdasha != null) ...[
              _buildSectionHeader("CURRENT VIMSHOTTARI DASHA"),
              const SizedBox(height: 12),
              _buildCurrentHierarchyCard(
                majorTitle: "Major",
                majorName: dashas.currentVdasha!.major?.planet,
                majorDate:
                    "${dashas.currentVdasha!.major?.start} - ${dashas.currentVdasha!.major?.end}",
                subTitle: "Minor",
                subName: dashas.currentVdasha!.minor?.planet,
                subDate:
                    "${dashas.currentVdasha!.minor?.start} - ${dashas.currentVdasha!.minor?.end}",
                subSubTitle: "Sub-Minor",
                subSubName: dashas.currentVdasha!.subMinor?.planet,
                subSubDate:
                    "${dashas.currentVdasha!.subMinor?.start} - ${dashas.currentVdasha!.subMinor?.end}",
              ),
              const SizedBox(height: 24),
            ],
            if (dashas.currentYogini != null) ...[
              _buildSectionHeader("CURRENT YOGINI DASHA"),
              const SizedBox(height: 12),
              _buildCurrentHierarchyCard(
                majorTitle: "Major",
                majorName: dashas.currentYogini!.majorDasha?.dashaName,
                majorDate:
                    "${dashas.currentYogini!.majorDasha?.startDate} - ${dashas.currentYogini!.majorDasha?.endDate}",
                subTitle: "Sub",
                subName: dashas.currentYogini!.subDasha?.dashaName,
                subDate:
                    "${dashas.currentYogini!.subDasha?.startDate} - ${dashas.currentYogini!.subDasha?.endDate}",
                subSubTitle: "Sub-Sub",
                subSubName: dashas.currentYogini!.subSubDasha?.dashaName,
                subSubDate:
                    "${dashas.currentYogini!.subSubDasha?.startDate} - ${dashas.currentYogini!.subSubDasha?.endDate}",
              ),
              const SizedBox(height: 24),
            ],
            if (dashas.currentChardasha != null) ...[
              _buildSectionHeader("CURRENT CHARDASHA"),
              if (dashas.currentChardasha!.dashaDate != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    "${dashas.currentChardasha!.dashaDate}",
                    style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
                  ),
                ),
              const SizedBox(height: 8),
              _buildCurrentHierarchyCard(
                majorTitle: "Major",
                majorName: dashas.currentChardasha!.majorDasha?.signName,
                majorDate:
                    "${dashas.currentChardasha!.majorDasha?.startDate} - ${dashas.currentChardasha!.majorDasha?.endDate}",
                subTitle: "Sub",
                subName: dashas.currentChardasha!.subDasha?.signName,
                subDate:
                    "${dashas.currentChardasha!.subDasha?.startDate} - ${dashas.currentChardasha!.subDasha?.endDate}",
                subSubTitle: "Sub-Sub",
                subSubName: dashas.currentChardasha!.subSubDasha?.signName,
                subSubDate:
                    "${dashas.currentChardasha!.subSubDasha?.startDate} - ${dashas.currentChardasha!.subSubDasha?.endDate}",
              ),
              const SizedBox(height: 24),
            ],
            _buildViewAllButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AllDashasScreen(dashas: dashas),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder, width: 1),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "View All Dashas",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _accentGold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward,
                size: 20,
                color: _accentGold,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 1,
          color: _sectionLine,
        ),
      ],
    );
  }

  Widget _buildCurrentHierarchyCard({
    String? majorTitle,
    String? majorName,
    String? majorDate,
    String? subTitle,
    String? subName,
    String? subDate,
    String? subSubTitle,
    String? subSubName,
    String? subSubDate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder, width: 1),
      ),
      child: Column(
        children: [
          if (majorName != null)
            _buildHierarchyRow(
              level: 0,
              label: majorTitle ?? "Major",
              value: majorName,
              date: majorDate,
              isLast: subName == null,
            ),
          if (subName != null)
            _buildHierarchyRow(
              level: 1,
              label: subTitle ?? "Sub",
              value: subName,
              date: subDate,
              isLast: subSubName == null,
            ),
          if (subSubName != null)
            _buildHierarchyRow(
              level: 2,
              label: subSubTitle ?? "Sub-Sub",
              value: subSubName,
              date: subSubDate,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildHierarchyRow({
    required int level,
    required String label,
    required String value,
    String? date,
    required bool isLast,
  }) {
    final double indent = level * 24.0;
    final Color dotColor = level == 0
        ? _accentGold
        : (level == 1 ? _textSecondary : _textMuted);

    final formattedDate = _formatDateRange(date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: _cardDark, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: _cardBorder,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: indent, bottom: isLast ? 0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _textMuted,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            value,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (formattedDate != null) ...[
                    const SizedBox(height: 6),
                    formattedDate,
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _formatDateRange(String? dateStr, {bool compact = false}) {
    if (dateStr == null || dateStr.isEmpty) return null;

    try {
      final parts = dateStr.split(" - ");
      if (parts.length != 2) {
        return Text(
          dateStr,
          style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
        );
      }

      final startStr = parts[0].trim();
      final endStr = parts[1].trim();

      DateTime start;
      DateTime end;
      DateFormat outFormat;

      try {
        final formatWithTime = DateFormat("d-M-yyyy H:m");
        start = formatWithTime.parse(startStr);
        end = formatWithTime.parse(endStr);
        outFormat = DateFormat("d MMM yyyy, h:mm a");
      } catch (_) {
        final formatDateOnly = DateFormat("d-M-yyyy");
        start = formatDateOnly.parse(startStr);
        end = formatDateOnly.parse(endStr);
        outFormat = DateFormat("d MMM yyyy");
      }

      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${outFormat.format(start)} -",
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: _textMuted,
              ),
            ),
            Text(
              outFormat.format(end),
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _accentGold,
              ),
            ),
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateChip("Start", outFormat.format(start)),
          const SizedBox(height: 4),
          _buildDateChip("End", outFormat.format(end)),
        ],
      );
    } catch (e) {
      return Text(
        dateStr,
        style: GoogleFonts.poppins(fontSize: 12, color: _textSecondary),
      );
    }
  }

  Widget _buildDateChip(String label, String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: _textMuted,
            ),
          ),
          Text(
            date,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _accentGold,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF1E1E4D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$code: ",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFD4AF37),
              fontSize: 12,
            ),
          ),
          Text(
            name,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
