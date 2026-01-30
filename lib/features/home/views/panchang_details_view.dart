import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PanchangDetailsView extends StatelessWidget {
  const PanchangDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Today's Panchang",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
      ),
      body: Obx(() {
        if (homeController.isPanchangLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final panchang = homeController.panchangData;
        if (panchang == null) {
          return const Center(child: Text("Data Unavailable"));
        }

        final basic = panchang.basicPanchang;
        final advanced = panchang.advancedPanchang;
        final chaughadiya = panchang.chaughadiyaMuhurta;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info Section
              _buildSectionTitle("Basic Details"),
              _buildInfoCard([
                _buildInfoRow("Date", panchang.dateKey ?? "-"),
                _buildInfoRow("Utility", "Tithi: ${basic?.tithi ?? '-'}"),
                _buildInfoRow("Day", basic?.day ?? "-"),
                _buildInfoRow("Sunrise", basic?.sunrise ?? "-"),
                _buildInfoRow("Sunset", basic?.sunset ?? "-"),
                _buildInfoRow("Moonrise", basic?.moonrise ?? "-"),
                _buildInfoRow("Moonset", basic?.moonset ?? "-"),
              ]),

              const SizedBox(height: 20),

              // Hindu Calendar Section
              _buildSectionTitle("Hindu Calendar"),
              _buildInfoCard([
                _buildInfoRow(
                  "Vikram Samvat",
                  "${basic?.vikramSamvat ?? '-'} (${basic?.vkramSamvatName ?? '-'})",
                ),
                _buildInfoRow(
                  "Shaka Samvat",
                  "${basic?.shakaSamvat ?? '-'} (${basic?.shakaSamvatName ?? '-'})",
                ),
                _buildInfoRow(
                  "Purnimanta Month",
                  advanced?.hinduMaah?.purnimanta ?? "-",
                ),
                _buildInfoRow(
                  "Amanta Month",
                  advanced?.hinduMaah?.amanta ?? "-",
                ),
                _buildInfoRow("Paksha", basic?.paksha ?? "-"),
                _buildInfoRow("Ritu", basic?.ritu ?? "-"),
                _buildInfoRow("Ayana", basic?.ayana ?? "-"),
              ]),

              const SizedBox(height: 20),

              // Panchang Elements
              _buildSectionTitle("Five Elements (Panchang)"),
              _buildInfoCard([
                _buildInfoRow(
                  "Tithi",
                  advanced?.panchang?.tithi?.details?['tithi_name'] ??
                      basic?.tithi ??
                      "-",
                ),
                _buildInfoRow(
                  "Nakshatra",
                  advanced?.panchang?.nakshatra?.details?['nak_name'] ??
                      basic?.nakshatra ??
                      "-",
                ),
                _buildInfoRow(
                  "Yog",
                  advanced?.panchang?.yog?.details?['yog_name'] ??
                      basic?.yog ??
                      "-",
                ),
                _buildInfoRow(
                  "Karan",
                  advanced?.panchang?.karan?.details?['karan_name'] ??
                      basic?.karan ??
                      "-",
                ),
              ]),

              const SizedBox(height: 20),

              // Auspicious/Inauspicious Times
              _buildSectionTitle("Muhurat Timings"),
              _buildInfoCard([
                _buildInfoRow(
                  "Abhijit Muhurat",
                  "${advanced?.abhijitMuhurta?.start ?? '-'} - ${advanced?.abhijitMuhurta?.end ?? '-'}",
                ),
                _buildInfoRow(
                  "Rahukaal",
                  "${advanced?.rahukaal?.start ?? '-'} - ${advanced?.rahukaal?.end ?? '-'}",
                ),
                _buildInfoRow(
                  "GuliKaal",
                  "${advanced?.guliKaal?.start ?? '-'} - ${advanced?.guliKaal?.end ?? '-'}",
                ),
                _buildInfoRow(
                  "YamghantKaal",
                  "${advanced?.yamghantKaal?.start ?? '-'} - ${advanced?.yamghantKaal?.end ?? '-'}",
                ),
              ]),

              const SizedBox(height: 20),

              // Other Details
              _buildSectionTitle("Other Details"),
              _buildInfoCard([
                _buildInfoRow("Sun Sign", basic?.sunSign ?? "-"),
                _buildInfoRow("Moon Sign", basic?.moonSign ?? "-"),
                _buildInfoRow(
                  "Disha Shool",
                  "${basic?.dishaShool ?? '-'} (Remedy: ${basic?.dishaShoolRemedies ?? '-'})",
                ),
                _buildInfoRow(
                  "Nakshatra Shool",
                  "${advanced?.nakShool?.direction ?? '-'} (Remedy: ${advanced?.nakShool?.remedies ?? '-'})",
                ),
                _buildInfoRow("Moon Nivas", basic?.moonNivas ?? "-"),
              ]),

              const SizedBox(height: 20),

              if (chaughadiya != null) ...[
                _buildSectionTitle("Chaughadiya Muhurat (Day)"),
                _buildChaughadiyaList(chaughadiya.day),
                const SizedBox(height: 16),
                _buildSectionTitle("Chaughadiya Muhurat (Night)"),
                _buildChaughadiyaList(chaughadiya.night),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6D3A0C),
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.lora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF596072),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.lora(
                fontSize: 14,
                color: const Color(0xFF1F1F1F),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaughadiyaList(List<dynamic>? list) {
    if (list == null || list.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = list[index];
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.muhurta ?? "-",
                  style: GoogleFonts.lora(
                    fontWeight: FontWeight.bold,
                    color: _getChaughadiyaColor(item.muhurta),
                  ),
                ),
                Text(
                  item.time ?? "-",
                  style: GoogleFonts.lora(color: Colors.black87),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getChaughadiyaColor(String? muhurta) {
    switch (muhurta?.toLowerCase()) {
      case 'shubh':
      case 'labh':
      case 'amrit':
        return Colors.green;
      case 'udveg':
      case 'rog':
      case 'kaal':
        return Colors.red;
      case 'char':
        return Colors.blue;
      default:
        return Colors.black;
    }
  }
}
