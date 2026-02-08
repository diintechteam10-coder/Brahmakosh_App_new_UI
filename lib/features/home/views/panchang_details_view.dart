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
        final dailyNakshatra = panchang.dailyNakshatraPrediction;
        final numeroPrediction = panchang.numeroDailyPrediction;

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
                _buildInfoRow("Sunrise", advanced?.sunrise ?? "-"),
                _buildInfoRow("Sunset", advanced?.sunset ?? "-"),
                _buildInfoRow("Moonrise", advanced?.moonrise ?? "-"),
                _buildInfoRow("Moonset", advanced?.moonset ?? "-"),
              ]),

              const SizedBox(height: 20),

              // Hindu Calendar Section
              _buildSectionTitle("Hindu Calendar"),
              _buildInfoCard([
                _buildInfoRow(
                  "Vikram Samvat",
                  "${advanced?.vikramSamvat ?? '-'} (${advanced?.vkramSamvatName ?? '-'})",
                ),
                _buildInfoRow(
                  "Shaka Samvat",
                  "${advanced?.shakaSamvat ?? '-'} (${advanced?.shakaSamvatName ?? '-'})",
                ),
                _buildInfoRow(
                  "Purnimanta Month",
                  advanced?.hinduMaah?.purnimanta ?? "-",
                ),
                _buildInfoRow(
                  "Amanta Month",
                  advanced?.hinduMaah?.amanta ?? "-",
                ),
                _buildInfoRow("Paksha", advanced?.paksha ?? "-"),
                _buildInfoRow("Ritu", advanced?.ritu ?? "-"),
                _buildInfoRow("Ayana", advanced?.ayana ?? "-"),
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
                _buildInfoRow("Sun Sign", advanced?.sunSign ?? "-"),
                _buildInfoRow("Moon Sign", advanced?.moonSign ?? "-"),
                _buildInfoRow(
                  "Disha Shool",
                  "${advanced?.dishaShool ?? '-'} (Remedy: ${advanced?.dishaShoolRemedies ?? '-'})",
                ),
                _buildInfoRow(
                  "Nakshatra Shool",
                  "${advanced?.nakShool?.direction ?? '-'} (Remedy: ${advanced?.nakShool?.remedies ?? '-'})",
                ),
                _buildInfoRow("Moon Nivas", advanced?.moonNivas ?? "-"),
              ]),

              const SizedBox(height: 20),

              if (dailyNakshatra != null) ...[
                _buildSectionTitle("Daily Nakshatra Prediction"),
                _buildInfoCard([
                  _buildInfoRow(
                    "Birth Moon Sign",
                    dailyNakshatra.birthMoonSign ?? "-",
                  ),
                  _buildInfoRow(
                    "Birth Moon Nakshatra",
                    dailyNakshatra.birthMoonNakshatra ?? "-",
                  ),
                  if (dailyNakshatra.prediction != null) ...[
                    _buildInfoRow(
                      "Health",
                      dailyNakshatra.prediction?.health ?? "-",
                    ),
                    _buildInfoRow(
                      "Emotions",
                      dailyNakshatra.prediction?.emotions ?? "-",
                    ),
                    _buildInfoRow(
                      "Profession",
                      dailyNakshatra.prediction?.profession ?? "-",
                    ),
                    _buildInfoRow(
                      "Luck",
                      dailyNakshatra.prediction?.luck ?? "-",
                    ),
                    _buildInfoRow(
                      "Personal Life",
                      dailyNakshatra.prediction?.personalLife ?? "-",
                    ),
                    _buildInfoRow(
                      "Travel",
                      dailyNakshatra.prediction?.travel ?? "-",
                    ),
                  ],
                  _buildInfoRow("Mood", dailyNakshatra.mood ?? "-"),
                  _buildInfoRow(
                    "Lucky Colors",
                    dailyNakshatra.luckyColor?.join(", ") ?? "-",
                  ),
                  _buildInfoRow(
                    "Lucky Numbers",
                    dailyNakshatra.luckyNumber?.join(", ") ?? "-",
                  ),
                  _buildInfoRow("Lucky Time", dailyNakshatra.luckyTime ?? "-"),
                ]),
                const SizedBox(height: 20),
              ],

              if (numeroPrediction != null) ...[
                _buildSectionTitle("Numerology Prediction"),
                _buildInfoCard([
                  _buildInfoRow(
                    "Prediction",
                    numeroPrediction.prediction ?? "-",
                  ),
                  _buildInfoRow(
                    "Lucky Color",
                    numeroPrediction.luckyColor ?? "-",
                  ),
                  _buildInfoRow(
                    "Lucky Number",
                    numeroPrediction.luckyNumber ?? "-",
                  ),
                ]),
                const SizedBox(height: 20),
              ],

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
