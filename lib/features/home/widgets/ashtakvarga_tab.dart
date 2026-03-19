import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/widgets/north_indian_points_chart.dart';

class AshtakvargaTab extends StatefulWidget {
  final Map<String, PlanetAshtak>? planetAshtak;
  final String? ascendantSign;

  const AshtakvargaTab({
    super.key,
    required this.planetAshtak,
    this.ascendantSign,
  });

  @override
  State<AshtakvargaTab> createState() => _AshtakvargaTabState();
}

class _AshtakvargaTabState extends State<AshtakvargaTab> {
  String _selectedPlanet = 'Sun';
  int _viewMode = 0; // 0 = Chart, 1 = Table

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _sectionLine = Color(0xFF1E1E4D);

  final List<String> _planets = [
    'Sun',
    'Moon',
    'Mars',
    'Mercury',
    'Jupiter',
    'Venus',
    'Saturn',
  ];

  @override
  Widget build(BuildContext context) {
    if (widget.planetAshtak == null) {
      return Container(
        color: _bgDark,
        child: Center(
          child: Text(
            "No Ashtakvarga data available",
            style: GoogleFonts.poppins(color: _textSecondary),
          ),
        ),
      );
    }

    return Container(
      color: _bgDark,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("ASHTAKVARGA"),
            const SizedBox(height: 16),
            Text(
              "Ashtakvarga determines and fine-tunes prediction accuracies based on Dasha and Transit forecasts. 4 or fewer points are considered unfavorable, while more than 4 points are auspicious.",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: _textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 24),
            _buildControls(),
            const SizedBox(height: 24),
            AnimatedCrossFade(
              firstChild: _buildChart(),
              secondChild: _buildTable(),
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
            fontSize: 18,
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

  Widget _buildControls() {
    return Column(
      children: [
        Row(
          children: [
            // View Mode Toggle
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
                  _buildToggleBtn(Icons.grid_on, 0, "Chart"),
                  _buildToggleBtn(Icons.table_chart, 1, "Table"),
                ],
              ),
            ),
            const Spacer(),
            // Planet Selection
            _buildPlanetDropdown(),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleBtn(IconData icon, int index, String label) {
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
                label,
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

  Widget _buildPlanetDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cardBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedPlanet,
          dropdownColor: _cardDark,
          items: _planets.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: GoogleFonts.poppins(
                  color: value == _selectedPlanet ? _accentGold : _textPrimary,
                  fontWeight: value == _selectedPlanet ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedPlanet = newValue!;
            });
          },
          icon: const Icon(Icons.arrow_drop_down, color: _accentGold),
        ),
      ),
    );
  }

  Widget _buildChart() {
    final planetData = widget.planetAshtak![_selectedPlanet.toLowerCase()];
    if (planetData == null || planetData.ashtakPoints == null) {
      return Container(
        height: 300,
        alignment: Alignment.center,
        child: Text("No Data", style: GoogleFonts.poppins(color: _textSecondary)),
      );
    }

    final Map<int, int> housePointsMap = {};
    int ascNum = _getSignNumber(widget.ascendantSign);

    final Map<int, int> signTotalPoints = {};
    for (var entry in planetData.ashtakPoints!.entries) {
      int signNum = _getSignNumber(entry.key);
      signTotalPoints[signNum] = entry.value.total ?? 0;
    }

    for (int house = 1; house <= 12; house++) {
      int signForHouse = (ascNum + house - 2) % 12 + 1;
      housePointsMap[house] = signTotalPoints[signForHouse] ?? 0;
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

  Widget _buildTable() {
    final planetData = widget.planetAshtak![_selectedPlanet.toLowerCase()];
    if (planetData == null || planetData.ashtakPoints == null) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text("No Data", style: GoogleFonts.poppins(color: _textSecondary)),
      );
    }

    final List<String> factors = [
      'sun',
      'moon',
      'mars',
      'mercury',
      'jupiter',
      'venus',
      'saturn',
      'ascendant',
    ];

    final List<String> signOrder = [
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces',
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
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              decoration: BoxDecoration(
                color: _cardBorder.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              ),
              child: Row(
                children: [
                  _buildCell("SIGN", width: 80, isHeader: true, align: TextAlign.start, padding: const EdgeInsets.only(left: 12)),
                  ...factors.map(
                    (f) => _buildCell(
                      _formatFactorName(f),
                      width: 42,
                      isHeader: true,
                    ),
                  ),
                  _buildCell(
                    "TOTAL",
                    width: 55,
                    isHeader: true,
                    isBold: true,
                    textColor: _accentGold,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _cardBorder),
            // Body rows
            ...signOrder.map((signKey) {
              final points = planetData.ashtakPoints![signKey];
              if (points == null) return const SizedBox();
              return Column(
                children: [
                  Row(
                    children: [
                      _buildCell(
                        _formatSignName(signKey),
                        width: 80,
                        isHeader: true,
                        align: TextAlign.start,
                        padding: const EdgeInsets.only(left: 12),
                      ),
                      _buildCell(points.sun?.toString() ?? "0", width: 42),
                      _buildCell(points.moon?.toString() ?? "0", width: 42),
                      _buildCell(points.mars?.toString() ?? "0", width: 42),
                      _buildCell(points.mercury?.toString() ?? "0", width: 42),
                      _buildCell(points.jupiter?.toString() ?? "0", width: 42),
                      _buildCell(points.venus?.toString() ?? "0", width: 42),
                      _buildCell(points.saturn?.toString() ?? "0", width: 42),
                      _buildCell(points.ascendant?.toString() ?? "0", width: 42),
                      _buildCell(
                        points.total?.toString() ?? "0",
                        width: 55,
                        isBold: true,
                        textColor: (points.total ?? 0) >= 28 ? const Color(0xFF81C784) : _textPrimary,
                        bgColor: _cardBorder.withOpacity(0.1),
                      ),
                    ],
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

  Widget _buildCell(
    String text, {
    double width = 40,
    bool isHeader = false,
    bool isBold = false,
    TextAlign align = TextAlign.center,
    EdgeInsets? padding,
    Color? bgColor,
    Color? textColor,
  }) {
    return Container(
      width: width,
      height: 48,
      alignment: align == TextAlign.start ? Alignment.centerLeft : Alignment.center,
      padding: padding,
      color: bgColor ?? Colors.transparent,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: isHeader ? 11 : 13,
          fontWeight: (isHeader || isBold) ? FontWeight.bold : FontWeight.normal,
          color: textColor ?? (isHeader ? _textSecondary : _textPrimary),
          letterSpacing: isHeader ? 0.5 : 0,
        ),
        textAlign: align,
      ),
    );
  }

  String _formatFactorName(String key) {
    if (key == 'ascendant') return 'ASC';
    if (key.length <= 2) return key.toUpperCase();
    return key.substring(0, 1).toUpperCase() + key.substring(1, 2).toUpperCase();
  }

  String _formatSignName(String key) {
    if (key.length <= 2) return key.toUpperCase();
    if (key == "ascendant") return "ASC";
    return key[0].toUpperCase() + key.substring(1).toUpperCase();
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
