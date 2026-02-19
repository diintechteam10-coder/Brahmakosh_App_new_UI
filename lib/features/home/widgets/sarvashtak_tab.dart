import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/widgets/north_indian_points_chart.dart';

class SarvashtakTab extends StatefulWidget {
  final SarvAshtak sarvashtak;
  final String? ascendantSign;

  const SarvashtakTab({
    super.key,
    required this.sarvashtak,
    this.ascendantSign,
  });

  @override
  State<SarvashtakTab> createState() => _SarvashtakTabState();
}

class _SarvashtakTabState extends State<SarvashtakTab> {
  // 0 = Table, 1 = Kundali (Chart)
  int _viewMode = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.sarvashtak.ashtakPoints == null) {
      return const SizedBox();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sarvashtakvarga",
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D4037),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 152, 0, 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildToggleBtn(Icons.table_chart, 0),
                    _buildToggleBtn(
                      Icons.grid_on,
                      1,
                    ), // Using grid icon for Chart
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Sarvashtak Varga is the composite form of Ashtak Varga. The houses that get more than 28 points in Sarvashtak Varga, the auspicious factors of those houses increase. Its result is considered in the auspicious and inauspicious results of the houses.",
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFF5D4037),
              height: 1.6,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24),
          AnimatedCrossFade(
            firstChild: _buildSarvashtakTable(widget.sarvashtak),
            secondChild: _buildSarvashtakChart(widget.sarvashtak),
            crossFadeState: _viewMode == 0
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Planet Notations",
              style: GoogleFonts.lora(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
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
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(IconData icon, int index) {
    bool isSelected = _viewMode == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _viewMode = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD4A373) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4A373).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF6D3A0C),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                index == 0 ? "Table" : "Chart",
                style: GoogleFonts.lora(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSarvashtakTable(SarvAshtak data) {
    // Collect all planets + ascendant keys
    // We'll standardise the order as per user request (image):
    // Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Ascendant, Total
    // Note: The API returns keys in lowercase usually.
    final List<String> planetKeys = [
      "su",
      "mo",
      "ma",
      "me",
      "ju",
      "ve",
      "sa",
      "asc",
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD7CCC8)),
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEEE8E8),
                borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  _buildHeaderCell("Sign", width: 80, align: TextAlign.start),
                  ...planetKeys.map(
                    (p) => _buildHeaderCell(_formatPlanetName(p), width: 40),
                  ),
                  _buildHeaderCell("Total", isBold: true, width: 40),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFD7CCC8)),
            // Body
            ...data.ashtakPoints!.entries.map((entry) {
              final sign = entry.key;
              final pointsIdx = entry.value;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        _buildCell(
                          sign,
                          width: 80,
                          isHeader: true,
                          align: TextAlign.start,
                        ),
                        _buildCell(pointsIdx.sun?.toString() ?? "-", width: 40),
                        _buildCell(
                          pointsIdx.moon?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.mars?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.mercury?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.jupiter?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.venus?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.saturn?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.ascendant?.toString() ?? "-",
                          width: 40,
                        ),
                        _buildCell(
                          pointsIdx.total?.toString() ?? "-",
                          isTotal: true,
                          highlightTotal: (pointsIdx.total ?? 0) >= 28,
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatPlanetName(String key) {
    if (key.length <= 2) return key.toUpperCase();
    if (key == "ascendant") return "Asc";
    return key[0].toUpperCase() + key.substring(1);
    // Or return icons/hindi names if preferred, but user image showed Hindi/English names
    // Let's stick to simple abbreviations if space is tight, or icons?
    // User image shows text. Let's return text.
    // Ideally user image has: Mesh, 5, 5, 2, ...
    // Columns in image are not labeled with planet names but they correspond to planets.
    // Wait, the image provided `sarvashtak` table in user request is:
    // Sign | Sun | Moon | ... | Total
    // User provided JSON snippet: "aries": { "sun": 4, ... }
    // So columns should be planets.
  }

  Widget _buildHeaderCell(
    String text, {
    double width = 50,
    bool isBold = false,
    TextAlign align = TextAlign.center,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontWeight: FontWeight.bold,
          color: isBold ? Colors.black : const Color(0xFF5D4037),
          fontSize: 14,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildCell(
    String text, {
    double width = 50,
    bool isHeader = false,
    bool isTotal = false,
    bool highlightTotal = false,
    TextAlign align = TextAlign.center,
  }) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
          color: highlightTotal
              ? Colors.green[800]
              : (isHeader ? Colors.black : const Color(0xFF4E342E)),
          fontSize: 14,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildSarvashtakChart(SarvAshtak data) {
    // Convert Map<String, SignPoints> to Map<int, int> (HouseNum -> Points)
    // We assume data keys are sign names.
    // Logic:
    // 1. Map Sign Name -> Sign Number (1-12)
    // 2. Map Sign Number -> House Number (based on Ascendant)
    // Actually, NorthIndianPointsChart takes House -> Points.
    // Wait, NorthIndianPointsChart takes House -> Points.
    // And it internally calculates the Sign Number for each House to display the Sign Number.
    // So if we pass House 1 = 30 points, it will display 30 in top diamond.
    // What points should go to House 1? The points for the Sign that is in House 1.
    // Ascendant Sign is in House 1.
    // So we need to map:
    //  - Find points for Ascendant Sign -> House 1
    //  - Find points for (Ascendant + 1) -> House 2
    //  ...

    // Step 1: Parse Data into Map<int, int> (Sign Number -> Points)
    final Map<int, int> signPointsMap = {};
    for (var entry in data.ashtakPoints!.entries) {
      int signNum = _getSignNumber(entry.key);
      if (entry.value.total != null) {
        signPointsMap[signNum] = entry.value.total!;
      }
    }

    // Step 2: Create Map<int, int> (House Number -> Points)
    final Map<int, int> housePointsMap = {};
    int ascNum = _getSignNumber(widget.ascendantSign);

    for (int house = 1; house <= 12; house++) {
      // Logic: House 1 has sign ascNum.
      // House i has sign (ascNum + i - 2) % 12 + 1
      int signForHouse = (ascNum + house - 2) % 12 + 1;
      housePointsMap[house] = signPointsMap[signForHouse] ?? 0;
    }

    return NorthIndianPointsChart(
      housePoints: housePointsMap,
      ascendantSign: widget.ascendantSign,
    );
  }

  int _getSignNumber(String? signName) {
    if (signName == null) {
      return 1;
    }
    final lower = signName.toLowerCase();
    if (lower.contains('aries') || lower.contains('mesh')) {
      return 1;
    }
    if (lower.contains('taurus') || lower.contains('vrish')) {
      return 2;
    }
    if (lower.contains('gemini') || lower.contains('mithun')) {
      return 3;
    }
    if (lower.contains('cancer') || lower.contains('kark')) {
      return 4;
    }
    if (lower.contains('leo') || lower.contains('simha')) {
      return 5;
    }
    if (lower.contains('virgo') || lower.contains('kanya')) {
      return 6;
    }
    if (lower.contains('libra') || lower.contains('tula')) {
      return 7;
    }
    if (lower.contains('scorpio') || lower.contains('vrishchik')) {
      return 8;
    }
    if (lower.contains('sagittarius') || lower.contains('dhanu')) {
      return 9;
    }
    if (lower.contains('capricorn') || lower.contains('makar')) {
      return 10;
    }
    if (lower.contains('aquarius') || lower.contains('kumbh')) {
      return 11;
    }
    if (lower.contains('pisces') || lower.contains('meen')) {
      return 12;
    }
    return 1;
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
