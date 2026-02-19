import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NorthIndianPointsChart extends StatelessWidget {
  /// Map of House Number (1-12) -> Points (Int)
  /// Note: This map should key by HOUSE number, not SIGN number.
  /// The logic to map Sign -> House should be done before passing data here,
  /// or we can pass the sign points and ascendant and do it here.
  /// Let's stick to the pattern: We pass a Map of int to int where Key is
  /// House Number (1-12).
  final Map<int, int> housePoints;
  final String? ascendantSign;

  const NorthIndianPointsChart({
    super.key,
    required this.housePoints,
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
      child: SvgPicture.string(svgString, fit: BoxFit.contain),
    );
  }

  int _getSignNumber(String? signName) {
    if (signName == null) {
      return 1;
    } // Default to Aries
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

  String _generateSvg(int ascNum) {
    // Helper to get sign number for a specific house (1-based index)
    int getSignForHouse(int houseIndex) {
      return (ascNum + houseIndex - 2) % 12 + 1;
    }

    // Coordinates for House Numbers (Sign Numbers) - same as NorthIndianChart
    final houseNumCoords = [
      {'x': 171.7, 'y': 161.8}, // H1
      {'x': 92.5, 'y': 76.0}, // H2
      {'x': 67.75, 'y': 99.1}, // H3
      {'x': 147.5, 'y': 179.95}, // H4
      {'x': 64.4, 'y': 265.75}, // H5
      {'x': 82.6, 'y': 282.3}, // H6
      {'x': 168.4, 'y': 199.8}, // H7
      {'x': 249.25, 'y': 277.3}, // H8
      {'x': 274.0, 'y': 257.5}, // H9
      {'x': 190.55, 'y': 179.95}, // H10
      {'x': 274.0, 'y': 97.45}, // H11
      {'x': 249.25, 'y': 76.0}, // H12
    ];

    // Center Points for displaying the score (large number)
    // Adjusted to be in the visual center of each rhomboid/triangle
    final centerPoints = [
      {'x': 175.0, 'y': 85.0}, // H1 (Top Diamond)
      {'x': 85.0, 'y': 40.0}, // H2 (Top Left)
      {'x': 40.0, 'y': 85.0}, // H3 (Left)
      {'x': 90.0, 'y': 175.0}, // H4 (Left Diamond)
      {'x': 40.0, 'y': 265.0}, // H5 (Bottom Left)
      {'x': 85.0, 'y': 310.0}, // H6 (Bottom Left-Center)
      {'x': 175.0, 'y': 265.0}, // H7 (Bottom Diamond)
      {'x': 265.0, 'y': 310.0}, // H8 (Bottom Right)
      {'x': 310.0, 'y': 265.0}, // H9 (Right)
      {'x': 260.0, 'y': 175.0}, // H10 (Right Diamond)
      {'x': 310.0, 'y': 85.0}, // H11 (Top Right Side)
      {'x': 265.0, 'y': 40.0}, // H12 (Top Right)
    ];

    // Build Sign Number Texts
    StringBuffer signsSvg = StringBuffer();
    for (int i = 0; i < 12; i++) {
      int sign = getSignForHouse(i + 1);
      double x = houseNumCoords[i]['x']!;
      double y = houseNumCoords[i]['y']!;
      signsSvg.writeln(
        '<text font-size="14" x="$x" y="$y" fill="#5D4037" text-anchor="middle" alignment-baseline="middle">$sign</text>',
      );
    }

    // Build Points Texts
    StringBuffer pointsSvg = StringBuffer();
    for (int i = 0; i < 12; i++) {
      int houseNum = i + 1;
      int points = housePoints[houseNum] ?? 0;
      double x = centerPoints[i]['x']!;
      double y = centerPoints[i]['y']!;

      // Color logic: High points (>28) green, Low (<25) red, Avg orange?
      // Standard Sarvashtak: 28 is average.
      String color = "#4E342E"; // Default brown
      if (points >= 30) {
        color = "#2E7D32"; // Green
      } else if (points < 25) {
        color = "#C62828"; // Red
      }

      pointsSvg.writeln(
        '<text font-size="24" font-weight="bold" x="$x" y="$y" fill="$color" text-anchor="middle" alignment-baseline="middle">$points</text>',
      );
    }

    return '''
<svg width="350" height="350" viewBox="0 0 350 350" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur in="SourceAlpha" stdDeviation="2" />
      <feOffset dx="0" dy="1" />
      <feComponentTransfer>
        <feFuncA type="linear" slope="0.2" />
      </feComponentTransfer>
      <feMerge>
        <feMergeNode />
        <feMergeNode in="SourceGraphic" />
      </feMerge>
    </filter>
  </defs>
  <g class="slice">
    <!-- Paths -->
    <path d="M10,10L175,10L92.5,92.5L10,10" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M175,10L340,10L257.5,92.5L175,10" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M92.5,92.5L10,175L10,10" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M92.5,92.5L175,175L257.5,92.5L175,10" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M257.5,92.5L340,175L340,10" stroke="#D4A373" stroke-width="2" fill="none"/>

    <path d="M92.5,92.5L175,175L92.5,257.5L10,175" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M257.5,92.5L340,175L257.5,257.5L175,175" stroke="#D4A373" stroke-width="2" fill="none"/>

    <path d="M92.5,257.5L10,340L10,175" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M175,175L257.5,257.5L175,340L92.5,257.5" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M340,175L340,340L257.5,257.5" stroke="#D4A373" stroke-width="2" fill="none"/>

    <path d="M92.5,257.5L175,340L10,340" stroke="#D4A373" stroke-width="2" fill="none"/>
    <path d="M257.5,257.5L340,340L175,340" stroke="#D4A373" stroke-width="2" fill="none"/>

    <!-- House/Sign Numbers -->
    <g font-family="Georgia, serif">
      $signsSvg
    </g>

    <!-- Points -->
    <g font-family="Georgia, serif">
      $pointsSvg
    </g>

  </g>
</svg>
''';
  }
}
