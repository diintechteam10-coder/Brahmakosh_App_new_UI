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

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _sectionLine = Color(0xFF1E1E4D);

  @override
  Widget build(BuildContext context) {
    if (widget.sarvashtak.ashtakPoints == null) {
      return const SizedBox();
    }

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "SARVASHTAKVARGA",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                      letterSpacing: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _cardDark,
                    border: Border.all(color: _cardBorder),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToggleBtn(Icons.table_chart, 0),
                      _buildToggleBtn(Icons.grid_on, 1),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(height: 1, color: _sectionLine),
            const SizedBox(height: 16),
            Text(
              "Sarvashtak Varga is the composite form of Ashtak Varga. The houses that get more than 28 points in Sarvashtak Varga, the auspicious factors of those houses increase.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textSecondary,
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
            fontSize: 14,
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? _accentGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : _textSecondary,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                index == 0 ? "Table" : "Chart",
                style: GoogleFonts.poppins(
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
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(12),
          color: _cardDark,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: _cardBorder.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  _buildHeaderCell("SIGN", width: 80, align: TextAlign.start),
                  ...planetKeys.map(
                    (p) => _buildHeaderCell(_formatPlanetName(p), width: 40),
                  ),
                  _buildHeaderCell("TOTAL", isBold: true, width: 45),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            // Body
            ...data.ashtakPoints!.entries.map((entry) {
              final sign = entry.key;
              final pointsIdx = entry.value;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        _buildCell(
                          sign.toUpperCase(),
                          width: 80,
                          isHeader: true,
                          align: TextAlign.start,
                        ),
                        _buildCell(pointsIdx.sun?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.moon?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.mars?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.mercury?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.jupiter?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.venus?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.saturn?.toString() ?? "-", width: 40),
                        _buildCell(pointsIdx.ascendant?.toString() ?? "-", width: 40),
                        _buildCell(
                          pointsIdx.total?.toString() ?? "-",
                          isTotal: true,
                          highlightTotal: (pointsIdx.total ?? 0) >= 28,
                          width: 45,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: _cardBorder),
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
    if (key == "asc") return "ASC";
    return key[0].toUpperCase() + key.substring(1).toUpperCase();
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
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: isBold ? _accentGold : _textSecondary,
          fontSize: 11,
          letterSpacing: 0.5,
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
        style: GoogleFonts.poppins(
          fontWeight: isHeader || isTotal ? FontWeight.bold : FontWeight.normal,
          color: highlightTotal
              ? const Color(0xFF81C784)
              : (isHeader ? _textPrimary : _textSecondary),
          fontSize: 13,
        ),
        textAlign: align,
      ),
    );
  }

  Widget _buildSarvashtakChart(SarvAshtak data) {
    final Map<int, int> signPointsMap = {};
    for (var entry in data.ashtakPoints!.entries) {
      int signNum = _getSignNumber(entry.key);
      if (entry.value.total != null) {
        signPointsMap[signNum] = entry.value.total!;
      }
    }

    final Map<int, int> housePointsMap = {};
    int ascNum = _getSignNumber(widget.ascendantSign);

    for (int house = 1; house <= 12; house++) {
      int signForHouse = (ascNum + house - 2) % 12 + 1;
      housePointsMap[house] = signPointsMap[signForHouse] ?? 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
      ),
      child: NorthIndianPointsChart(
        housePoints: housePointsMap,
        ascendantSign: widget.ascendantSign,
        isDark: true,
      ),
    );
  }

  int _getSignNumber(String? signName) {
    if (signName == null) return 1;
    final lower = signName.toLowerCase();
    if (lower.contains('aries') || lower.contains('mesh')) return 1;
    if (lower.contains('taurus') || lower.contains('vrish')) return 2;
    if (lower.contains('gemini') || lower.contains('mithun')) return 3;
    if (lower.contains('cancer') || lower.contains('kark')) return 4;
    if (lower.contains('leo') || lower.contains('simha')) return 5;
    if (lower.contains('virgo') || lower.contains('kanya')) return 6;
    if (lower.contains('libra') || lower.contains('tula')) return 7;
    if (lower.contains('scorpio') || lower.contains('vrishchik')) return 8;
    if (lower.contains('sagittarius') || lower.contains('dhanu')) return 9;
    if (lower.contains('capricorn') || lower.contains('makar')) return 10;
    if (lower.contains('aquarius') || lower.contains('kumbh')) return 11;
    if (lower.contains('pisces') || lower.contains('meen')) return 12;
    return 1;
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
