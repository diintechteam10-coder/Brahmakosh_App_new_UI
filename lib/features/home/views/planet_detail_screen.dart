import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class PlanetDetailScreen extends StatelessWidget {
  final Planets planet;

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);

  const PlanetDetailScreen({super.key, required this.planet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      appBar: AppBar(
        backgroundColor: _bgDark,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _cardDark,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          planet.name ?? "Planet Details",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanetHeader(),
            const SizedBox(height: 24),
            _buildInfoSection("Basic Info", [
              _buildInfoRow(
                "Sign",
                planet.sign ?? "-",
                "House",
                "${planet.house}",
              ),
              _buildInfoRow("Sign Lord", planet.signLord ?? "-", "", ""),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection("Nakshatra Info", [
              _buildInfoRow(
                "Nakshatra",
                planet.nakshatra ?? "-",
                "Lord",
                planet.nakshatraLord ?? "-",
              ),
              _buildInfoRow("Pada", "${planet.nakshatraPad}", "", ""),
            ]),
            const SizedBox(height: 16),
            _buildInfoSection("Technical Info", [
              _buildInfoRow(
                "Degree",
                "${planet.normDegree?.toStringAsFixed(2)}°",
                "Retrograde",
                planet.isRetro == "true" ? "Yes" : "No",
              ),
              _buildInfoRow(
                "Speed",
                "${planet.speed?.toStringAsFixed(2)}",
                "Awastha",
                planet.planetAwastha ?? "-",
              ),
            ]),
            const SizedBox(height: 16),
            if (planet.isPlanetSet == true)
              _buildInfoSection("Status", [
                _buildInfoRow("Combust (Set)", "Yes", "", ""),
              ]),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetHeader() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFCC80).withOpacity(0.1),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFCC80).withOpacity(0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          // Planet Image Placeholder
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [_accentGold, _accentGold.withOpacity(0.7)], // Adjusted Gold Gradient
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45, // Darker shadow
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                planet.name?.substring(0, 1) ?? "P",
                style: GoogleFonts.poppins(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: _bgDark, // Dark text on gold
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            child: Column(
              children: [
                Text(
                  planet.name ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentGold,
                  ),
                ),
                Text(
                  planet.sign ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            child: Column(
              children: [
                Text(
                  planet.sign ?? "",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _accentGold,
                  ),
                ),
                Text(
                  "House ${planet.house}",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: _textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _accentGold,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  "$label1: ",
                  style: GoogleFonts.poppins(color: _textSecondary),
                ),
                Expanded(
                  child: Text(
                    value1,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (label2.isNotEmpty)
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "$label2: ",
                    style: GoogleFonts.poppins(color: _textSecondary),
                  ),
                  Text(
                    value2,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  if (label2 == "House" ||
                      label2 == "Lord" ||
                      label2 == "Jupiter")
                    const Icon(
                      Icons.keyboard_arrow_right,
                      size: 16,
                      color: Color(0xFFB0B0CC), // _textSecondary
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
