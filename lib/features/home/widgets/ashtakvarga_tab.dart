import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class AshtakvargaTab extends StatelessWidget {
  final Map<String, PlanetAshtak>? planetAshtak;
  final SarvAshtak? sarvashtak;

  const AshtakvargaTab({
    super.key,
    required this.planetAshtak,
    required this.sarvashtak,
  });

  @override
  Widget build(BuildContext context) {
    if (planetAshtak == null && sarvashtak == null) {
      return Center(
        child: Text(
          "No Ashtakvarga Data Available",
          style: GoogleFonts.lora(color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sarvashtak != null) ...[
            _buildSectionTitle("Sarvashtakvarga (Totals)"),
            const SizedBox(height: 12),
            _buildSarvashtakTable(sarvashtak!),
            const SizedBox(height: 24),
          ],

          if (planetAshtak != null && planetAshtak!.isNotEmpty) ...[
            _buildSectionTitle("Bhinnashtakvarga (Planetary Details)"),
            const SizedBox(height: 12),
            ...planetAshtak!.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
                    child: Text(
                      "${entry.key} Ashtakvarga",
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                  _buildPlanetTable(entry.value),
                  const SizedBox(height: 24),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF5D4037),
      ),
    );
  }

  Widget _buildSarvashtakTable(SarvAshtak data) {
    // Data structure: Map<String, SignPoints> where key is Sign Name (Aries, Taurus...)
    // We want to show: Sign | Score
    if (data.ashtakPoints == null) return const SizedBox();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD7CCC8)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildTableHeader(["Sign", "Total Points"]),
          const Divider(height: 1, color: Color(0xFFD7CCC8)),
          ...data.ashtakPoints!.entries.map((entry) {
            return Column(
              children: [
                _buildTableRow(
                  [entry.key, entry.value.total?.toString() ?? "-"],
                  isTotal:
                      entry.value.total != null && entry.value.total! >= 28,
                ),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlanetTable(PlanetAshtak data) {
    if (data.ashtakPoints == null) return const SizedBox();

    // We want columns: Sign | Total (contributed by others to this planet in this sign)
    // The API gives specific points provided by other planets for THIS planet in each sign.
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD7CCC8)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          _buildTableHeader(["Sign", "Score"]),
          const Divider(height: 1, color: Color(0xFFD7CCC8)),
          ...data.ashtakPoints!.entries.map((entry) {
            return Column(
              children: [
                _buildTableRow(
                  [entry.key, entry.value.total?.toString() ?? "-"],
                  isTotal: entry.value.total != null && entry.value.total! >= 4,
                ),
                // 4 is average for single planet (max 8)
                const Divider(height: 1, color: Color(0xFFEEEEEE)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTableHeader(List<String> cells) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEEE8E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
      ),
      child: Row(
        children: cells
            .map(
              (e) => Expanded(
                child: Text(
                  e,
                  style: GoogleFonts.lora(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF5D4037),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> cells, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: cells
            .map(
              (e) => Expanded(
                child: Text(
                  e,
                  style: GoogleFonts.lora(
                    fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    color: isTotal
                        ? Colors.green[800]
                        : const Color(0xFF4E342E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
