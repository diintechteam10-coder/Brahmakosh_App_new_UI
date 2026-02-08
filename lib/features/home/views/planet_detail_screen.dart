import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class PlanetDetailScreen extends StatelessWidget {
  final Planets planet;

  const PlanetDetailScreen({super.key, required this.planet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          planet.name ?? "Planet Details",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
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
              color: const Color(0xFFFFCC80).withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFCC80).withOpacity(0.4),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFFF9A825), Color(0xFFFBC02D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                planet.name?.substring(0, 1) ?? "P",
                style: GoogleFonts.lora(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6D3A0C),
                  ),
                ),
                Text(
                  planet.sign ?? "",
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6D3A0C),
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
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6D3A0C),
                  ),
                ),
                Text(
                  "${planet.house}",
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    color: const Color(0xFF6D3A0C),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6D3A0C),
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
                  style: GoogleFonts.lora(color: Colors.grey[600]),
                ),
                Expanded(
                  child: Text(
                    value1,
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
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
                    style: GoogleFonts.lora(color: Colors.grey[600]),
                  ),
                  Text(
                    value2,
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  if (label2 == "House" ||
                      label2 == "Lord" ||
                      label2 == "Jupiter")
                    const Icon(
                      Icons.keyboard_arrow_right,
                      size: 16,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
