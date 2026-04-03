import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NorthIndianChart extends StatelessWidget {
  final Map<int, List<String>> housesPlanets;
  final String? ascendantSign;

  const NorthIndianChart({
    super.key,
    required this.housesPlanets,
    this.ascendantSign,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Get Ascendant Number (1 = Aries, ..., 12 = Pisces)
    int ascNum = _getSignNumber(ascendantSign);

    // 2. Generate SVG String
    String svgString = _generateSvg(ascNum);

    // Responsive: Use full width, constrain by aspect ratio
    return AspectRatio(
      aspectRatio: 1, // Keep it square
      child: SvgPicture.string(
        svgString,
        fit: BoxFit.contain, // Ensure it scales down to fit available width
      ),
    );
  }

  int _getSignNumber(String? signName) {
    if (signName == null) return 1; // Default to Aries
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

  String _getPlanetCode(String planetName) {
    final lower = planetName.toLowerCase().trim();
    if (lower.startsWith('su')) return 'Su';
    if (lower.startsWith('mo')) return 'Mo';
    if (lower.startsWith('ma')) return 'Ma';
    if (lower.startsWith('me')) return 'Me';
    if (lower.startsWith('ju')) return 'Ju';
    if (lower.startsWith('ve')) return 'Ve';
    if (lower.startsWith('sa')) return 'Sa';
    if (lower.startsWith('ra')) return 'Ra';
    if (lower.startsWith('ke')) return 'Ke';
    return planetName.substring(0, 2);
  }

  String _generateSvg(int ascNum) {
    // Helper to get sign number for a specific house (1-based index)
    // House 1 has Sign = ascNum
    // House i has Sign = (ascNum + i - 2) % 12 + 1
    int getSignForHouse(int houseIndex) {
      return (ascNum + houseIndex - 2) % 12 + 1;
    }

    // Coordinates for House Numbers (Sign Numbers)
    // House 1-12
    final houseNumCoords = [
      {'x': 171.7, 'y': 161.8}, // H1 (Top Diamond)
      {'x': 92.5, 'y': 76.0}, // H2 (Top Left)
      {'x': 67.75, 'y': 99.1}, // H3 (Left)
      {
        'x': 147.5,
        'y': 179.95,
      }, // H4 (Center Left ... wait, based on user SVG text "9")
      {'x': 64.4, 'y': 265.75}, // H5 (Bottom Left)
      {'x': 82.6, 'y': 282.3}, // H6 (Bottom Left-Center)
      {'x': 168.4, 'y': 199.8}, // H7 (Bottom Diamond)
      {'x': 249.25, 'y': 277.3}, // H8 (Bottom Right)
      {'x': 274.0, 'y': 257.5}, // H9 (Right)
      {'x': 190.55, 'y': 179.95}, // H10 (Center Right)
      {'x': 274.0, 'y': 97.45}, // H11 (Top Right ... wait sign 4 position)
      {'x': 249.25, 'y': 76.0}, // H12 (Top Right)
    ];

    // Check against user SVG values:
    // "6" (H1) -> 171.7, 161.8. Matches index 0.
    // "7" (H2) -> 92.5, 76. Matches index 1.
    // "8" (H3) -> 67.75, 99.1. Matches index 2.
    // "9" (H4?) -> 147.5, 179.95. Matches index 3.
    // "10" (H5) -> 64.4, 265.75. Matches index 4.
    // "11" (H6) -> 82.6, 282.3. Matches index 5.
    // "12" (H7) -> 168.4, 199.8. Matches index 6.
    // "1" (H8) -> 249.25, 277.3. Matches index 7. (Sign 1 is H8 relative to Sign 6? 6+7=13->1. Correct).
    // "2" (H9) -> 274, 257.5. Matches index 8.
    // "3" (H10) -> 190.55, 179.95. Matches index 9.
    // "4" (H11) -> 274, 97.45. Matches index 10.
    // "5" (H12) -> 249.25, 76. Matches index 11.

    // Base Planet Positions (approximate starting points for rows/groups)
    // We will simple render planets in a list string for now to avoid complex collision logic,
    // or try to offset them if we can.
    // Safe Centroids for Planets (Calculated to avoid House Numbers)
    final planetZones = [
      {'x': 175.0, 'y': 95.0}, // H1 (Top Diamond) - Above center
      {'x': 92.5, 'y': 35.0}, // H2 (Top Left)
      {'x': 30.0, 'y': 92.5}, // H3 (Left)
      {'x': 92.5, 'y': 175.0}, // H4 (Left Diamond) - Centered
      {'x': 30.0, 'y': 257.5}, // H5 (Bottom Left)
      {'x': 92.5, 'y': 320.0}, // H6 (Bottom Left-Center)
      {'x': 175.0, 'y': 280.0}, // H7 (Bottom Diamond) - Below center
      {'x': 257.5, 'y': 320.0}, // H8 (Bottom Right)
      {'x': 320.0, 'y': 257.5}, // H9 (Right)
      {'x': 257.5, 'y': 175.0}, // H10 (Right Diamond) - Centered
      {'x': 320.0, 'y': 92.5}, // H11 (Top Right Side)
      {'x': 257.5, 'y': 35.0}, // H12 (Top Right)
    ];

    // Build Planet Texts
    StringBuffer planetsSvg = StringBuffer();

    // Helper to add Text
    void addPlanetText(String text, double x, double y) {
      planetsSvg.writeln(
        '<text font-size="12" x="$x" y="$y" fill="#FF5722" font-family="Poppins, sans-serif" font-weight="600" text-anchor="middle" alignment-baseline="middle">$text</text>',
      );
    }

    // Iterate 12 houses
    for (int i = 0; i < 12; i++) {
      int houseNum = i + 1;
      List<String> planets = housesPlanets[houseNum] ?? [];

      if (planets.isNotEmpty) {
        double zoneX = planetZones[i]['x']!;
        double zoneY = planetZones[i]['y']!;

        // Logic for wrapping if too many planets
        // Max 2-3 per line
        int maxPerLine = 3;
        if (i == 2 || i == 4 || i == 8 || i == 10)
          maxPerLine =
          2; // Narrower triangles (H3, H5, H9, H11) -> wait, indexes are correct?
        // H3 is index 2. H5 index 4. H9 index 8. H11 index 10.
        // These are the side triangles, very narrow horizontally.

        List<List<String>> lines = [];
        for (int p = 0; p < planets.length; p += maxPerLine) {
          int end = (p + maxPerLine < planets.length)
              ? p + maxPerLine
              : planets.length;
          lines.add(planets.sublist(p, end));
        }

        double lineHeight = 14.0;
        double startY = zoneY - ((lines.length - 1) * lineHeight / 2);

        for (int l = 0; l < lines.length; l++) {
          List<String> linePlanets = lines[l];
          // Join them with spaces for a single text element line
          // String lineStr = linePlanets.map((p) => _getPlanetCode(p)).join(" ");
          // addPlanetText(lineStr, zoneX, startY + (l * lineHeight));

          // Better: Draw individual texts centered?
          // Using text-anchor=middle on the group string works well.

          String lineStr = linePlanets.map((p) => _getPlanetCode(p)).join(" ");
          addPlanetText(lineStr, zoneX, startY + (l * lineHeight));
        }
      }
    }

    // Build Sign Number Texts
    StringBuffer signsSvg = StringBuffer();
    for (int i = 0; i < 12; i++) {
      int sign = getSignForHouse(i + 1);
      double x = houseNumCoords[i]['x']!;
      double y = houseNumCoords[i]['y']!;
      signsSvg.writeln(
        '<text font-size="15" x="$x" y="$y" fill="#E0E0E0" font-family="Poppins, sans-serif">$sign</text>',
      );
    }

    return '''
<svg width="350" height="350" viewBox="0 0 350 350" xmlns="http://www.w3.org/2000/svg">
  <g class="slice">
    <!-- Paths -->
    <path d="M10,10L175,10L92.5,92.5L10,10" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M175,10L340,10L257.5,92.5L175,10" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M92.5,92.5L10,175L10,10" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M92.5,92.5L175,175L257.5,92.5L175,10" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M257.5,92.5L340,175L340,10" stroke="#D4AF37" stroke-width="1.5" fill="none"/>

    <path d="M92.5,92.5L175,175L92.5,257.5L10,175" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M257.5,92.5L340,175L257.5,257.5L175,175" stroke="#D4AF37" stroke-width="1.5" fill="none"/>

    <path d="M92.5,257.5L10,340L10,175" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M175,175L257.5,257.5L175,340L92.5,257.5" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M340,175L340,340L257.5,257.5" stroke="#D4AF37" stroke-width="1.5" fill="none"/>

    <path d="M92.5,257.5L175,340L10,340" stroke="#D4AF37" stroke-width="1.5" fill="none"/>
    <path d="M257.5,257.5L340,340L175,340" stroke="#D4AF37" stroke-width="1.5" fill="none"/>

    <!-- House Numbers -->
    $signsSvg

    <!-- Planets -->
    $planetsSvg

  </g>
</svg>
''';
  }
}
