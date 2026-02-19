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
      return const Center(child: Text("No Ashtakvarga data available"));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ashtakvarga",
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Ashtakvarga is used to determine and fine tune the prediction accuracies based on Dasha and Transit forecasts. 4 or lesser points are considered not good whereas more than 4 points are favorable.",
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFF5D4037),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _buildControls(),
          const SizedBox(height: 20),
          AnimatedCrossFade(
            firstChild: _buildChart(),
            secondChild: _buildTable(),
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

  Widget _buildControls() {
    return Row(
      children: [
        // Radio Buttons for View Mode
        Row(
          children: [
            Radio<int>(
              value: 0,
              groupValue: _viewMode,
              onChanged: (val) {
                setState(() {
                  _viewMode = val!;
                });
              },
              activeColor: const Color(0xFF00796B),
            ),
            Text("Chart", style: GoogleFonts.lora(fontSize: 16)),
            Radio<int>(
              value: 1,
              groupValue: _viewMode,
              onChanged: (val) {
                setState(() {
                  _viewMode = val!;
                });
              },
              activeColor: const Color(0xFF00796B),
            ),
            Text("Table", style: GoogleFonts.lora(fontSize: 16)),
          ],
        ),
        const Spacer(),
        // Dropdown for Planet
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPlanet,
              items: _planets.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: GoogleFonts.lora(color: const Color(0xFF5D4037)),
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedPlanet = newValue!;
                });
              },
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF5D4037)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    final planetData = widget.planetAshtak![_selectedPlanet.toLowerCase()];
    if (planetData == null || planetData.ashtakPoints == null) {
      return const SizedBox(height: 200, child: Center(child: Text("No Data")));
    }

    // Map Sign -> Total Points for the selected planet
    // Then Map House -> Points
    final Map<int, int> housePointsMap = {};
    int ascNum = _getSignNumber(widget.ascendantSign);

    // Create a map of SignName -> Total Points
    final Map<int, int> signTotalPoints = {};
    for (var entry in planetData.ashtakPoints!.entries) {
      int signNum = _getSignNumber(entry.key);
      signTotalPoints[signNum] = entry.value.total ?? 0;
    }

    for (int house = 1; house <= 12; house++) {
      int signForHouse = (ascNum + house - 2) % 12 + 1;
      housePointsMap[house] = signTotalPoints[signForHouse] ?? 0;
    }

    return NorthIndianPointsChart(
      housePoints: housePointsMap,
      ascendantSign: widget.ascendantSign,
    );
  }

  Widget _buildTable() {
    final planetData = widget.planetAshtak![_selectedPlanet.toLowerCase()];
    if (planetData == null || planetData.ashtakPoints == null) {
      return const SizedBox(height: 200, child: Center(child: Text("No Data")));
    }

    // Columns: Sign (Abbr), Sun -> Asc, Total
    // 8 factors: Sun, Moon, Mars, Mercury, Jupiter, Venus, Saturn, Ascendant
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

    // Build Rows for 12 signs in order Aries -> Pisces
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
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                _buildCell("Sign", width: 80, isHeader: true),
                ...factors.map(
                  (f) => _buildCell(
                    _formatFactorName(f),
                    width: 40,
                    isHeader: true,
                  ),
                ),
                _buildCell(
                  "Total",
                  width: 50,
                  isHeader: true,
                  bgColor: const Color(0xFFB2DFDB),
                ),
              ],
            ),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
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
                        padding: const EdgeInsets.only(left: 8),
                      ),
                      _buildCell(points.sun?.toString() ?? "0", width: 40),
                      _buildCell(points.moon?.toString() ?? "0", width: 40),
                      _buildCell(points.mars?.toString() ?? "0", width: 40),
                      _buildCell(points.mercury?.toString() ?? "0", width: 40),
                      _buildCell(points.jupiter?.toString() ?? "0", width: 40),
                      _buildCell(points.venus?.toString() ?? "0", width: 40),
                      _buildCell(points.saturn?.toString() ?? "0", width: 40),
                      _buildCell(
                        points.ascendant?.toString() ?? "0",
                        width: 40,
                      ),
                      _buildCell(
                        points.total?.toString() ?? "0",
                        width: 50,
                        isBold: true,
                        bgColor: const Color(0xFFB2DFDB).withOpacity(0.5),
                      ),
                    ],
                  ),
                  const Divider(height: 1, color: Color(0xffeeeeee)),
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
  }) {
    return Container(
      width: width,
      height: 40,
      alignment: align == TextAlign.start
          ? Alignment.centerLeft
          : Alignment.center,
      padding: padding,
      color: bgColor ?? Colors.transparent,
      child: Text(
        text,
        style: GoogleFonts.lora(
          fontSize: 13,
          fontWeight: (isHeader || isBold)
              ? FontWeight.bold
              : FontWeight.normal,
          color: const Color(0xFF424242),
        ),
        textAlign: align,
      ),
    );
  }

  String _formatFactorName(String key) {
    if (key == 'ascendant') return 'Asc';
    if (key.length <= 2) return key;
    return key.substring(0, 1).toUpperCase() + key.substring(1, 2);
  }

  String _formatSignName(String key) {
    if (key.length <= 2) return key.toUpperCase();
    if (key == "ascendant") return "Asc";
    return key[0].toUpperCase() + key.substring(1);
  }

  int _getSignNumber(String? signName) {
    if (signName == null) return 1;
    final lower = signName.toLowerCase();
    if (lower.contains('aries')) return 1;
    if (lower.contains('taurus')) return 2;
    if (lower.contains('gemini')) return 3;
    if (lower.contains('cancer')) return 4;
    if (lower.contains('leo')) return 5;
    if (lower.contains('virgo')) return 6;
    if (lower.contains('libra')) return 7;
    if (lower.contains('scorpio')) return 8;
    if (lower.contains('sagittarius')) return 9;
    if (lower.contains('capricorn')) return 10;
    if (lower.contains('aquarius')) return 11;
    if (lower.contains('pisces')) return 12;
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