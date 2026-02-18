import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/models/dosha_dasha_model.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';

class DashaTimelineView extends StatelessWidget {
  const DashaTimelineView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    // Access data safely
    final dashas = controller.doshaDashaData?.data?.dashas;
    final chardasha = dashas?.currentChardasha;
    final currentYogini = dashas?.currentYogini;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0), // Slightly warmer background
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF3E0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Dasha Timeline",
          style: GoogleFonts.playfairDisplay(
            // Premium Font
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
        centerTitle: true,
      ),
      body: dashas == null
          ? const Center(child: Text("No Dasha Data Available"))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Yogini Dasha", Icons.auto_awesome),
                        const SizedBox(height: 24),
                        if (currentYogini != null)
                          _buildYoginiTimeline(currentYogini),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("Char Dasha", Icons.stars),
                        const SizedBox(height: 24),
                        if (chardasha != null)
                          _buildCharDashaTimeline(
                            chardasha,
                            dashas.majorChardasha,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCCBC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFD84315), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF3E2723),
          ),
        ),
      ],
    );
  }

  Widget _buildYoginiTimeline(CurrentYogini yogini) {
    return Column(
      children: [
        if (yogini.majorDasha != null)
          _buildTimelineItem(
            level: "MAJOR",
            name: yogini.majorDasha!.dashaName ?? "",
            startDate: yogini.majorDasha!.startDate,
            endDate: yogini.majorDasha!.endDate,
            isLast: false,
            themeColor: const Color(0xFFBF360C), // Deep Red-Orange
          ),
        if (yogini.subDasha != null)
          _buildTimelineItem(
            level: "SUB",
            name: yogini.subDasha!.dashaName ?? "",
            startDate: yogini.subDasha!.startDate,
            endDate: yogini.subDasha!.endDate,
            isLast: false,
            themeColor: const Color(0xFFF57C00), // Orange
          ),
        if (yogini.subSubDasha != null)
          _buildTimelineItem(
            level: "SUB-SUB",
            name: yogini.subSubDasha!.dashaName ?? "",
            startDate: yogini.subSubDasha!.startDate,
            endDate: yogini.subSubDasha!.endDate,
            isLast: true,
            themeColor: const Color(0xFFFFA000), // Amber
          ),
      ],
    );
  }

  Widget _buildCharDashaTimeline(
    CurrentChardasha current,
    List<MajorChardasha>? majorList,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Active
        if (current.majorDasha != null)
          _buildTimelineItem(
            level: "MAJOR",
            name: current.majorDasha!.signName ?? "",
            startDate: current.majorDasha!.startDate,
            endDate: current.majorDasha!.endDate,
            isLast: false,
            themeColor: const Color(0xFF4527A0), // Deep Purple
          ),
        if (current.subDasha != null)
          _buildTimelineItem(
            level: "SUB",
            name: current.subDasha!.dashaName ?? "",
            startDate: current.subDasha!.startDate,
            endDate: current.subDasha!.endDate,
            isLast: false,
            themeColor: const Color(0xFF7E57C2), // Purple
          ),
        if (current.subSubDasha != null)
          _buildTimelineItem(
            level: "SUB-SUB",
            name: current.subSubDasha!.dashaName ?? "",
            startDate: current.subSubDasha!.startDate,
            endDate: current.subSubDasha!.endDate,
            isLast: true,
            themeColor: const Color(0xFF9575CD), // Light Purple
          ),

        const SizedBox(height: 32),
        // Major List if available
        if (majorList != null && majorList.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              "Full Cycle Timeline",
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF5D4037),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: majorList.length,
            itemBuilder: (context, index) {
              final item = majorList[index];
              final isLastItem = index == majorList.length - 1;
              return _buildTimelineItem(
                level: "",
                name: item.signName ?? "",
                startDate: item.startDate,
                endDate: item.endDate,
                isLast: isLastItem,
                themeColor: const Color(0xFF6D4C41), // Brown
                compact: true,
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineItem({
    required String level,
    required String name,
    String? startDate,
    String? endDate,
    required bool isLast,
    required Color themeColor,
    bool compact = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line & Dot
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: themeColor, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          themeColor.withOpacity(0.5),
                          themeColor.withOpacity(0.1),
                        ],
                      ),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 2),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (level.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        level,
                        style: GoogleFonts.lato(
                          // Lora or Lato
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: compact ? 16 : 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildDateChip(
                        "Start",
                        _formatDate(startDate),
                        Icons.event_available,
                        themeColor,
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDateChip(
                        "End ",
                        _formatDate(endDate),
                        Icons.event_busy,
                        Colors.grey.shade700,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip(String label, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            date,
            style: GoogleFonts.lato(
              fontSize: 13,
              color: const Color(0xFF424242),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";

    // Attempt to parse "d-M-yyyy H:m" e.g., "24-1-2024 3:18"
    // Also handle "d-M-yyyy" e.g., "12-3-2003"
    try {
      final parts = dateStr.split(' ');
      final dateParts = parts[0].split('-'); // [24, 1, 2024]

      if (dateParts.length == 3) {
        final day = int.parse(dateParts[0]);
        final month = int.parse(dateParts[1]);
        final year = int.parse(dateParts[2]);

        TimeOfDay? time;
        if (parts.length > 1) {
          final timeParts = parts[1].split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            time = TimeOfDay(hour: hour, minute: minute);
          }
        }

        // Month names
        const months = [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
          "Oct",
          "Nov",
          "Dec",
        ];

        String formattedDate = "$day ${months[month - 1]} $year";

        if (time != null) {
          final hourOfPeriod = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
          final period = time.period == DayPeriod.am ? "AM" : "PM";
          final minuteStr = time.minute.toString().padLeft(2, '0');
          return "$formattedDate, $hourOfPeriod:$minuteStr $period";
        }

        return formattedDate;
      }
    } catch (e) {
      // Fallback
    }
    return dateStr;
  }
}
