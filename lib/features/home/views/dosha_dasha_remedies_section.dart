import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/features/home/views/dosha_details_view.dart';
import 'package:brahmakosh/features/home/views/dasha_timeline_view.dart';
import 'package:brahmakosh/features/home/models/dosha_dasha_model.dart'; // Added for DoshaDetail type
import 'package:brahmakosh/features/home/views/remedies_details_view.dart'; // Added for Remedies Detail View

class DoshaDashaRemediesSection extends StatefulWidget {
  const DoshaDashaRemediesSection({super.key});

  @override
  State<DoshaDashaRemediesSection> createState() =>
      _DoshaDashaRemediesSectionState();
}

class _DoshaDashaRemediesSectionState extends State<DoshaDashaRemediesSection> {
  int _selectedIndex = 1; // Default to 'Dasha' as shown in the design
  final List<String> _tabs = ["Dosha", "Dasha", "Remedies"];
  final HomeController _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double scale = (w / 375.0).clamp(0.85, 1.3);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dosha, Dasha & Remedies",
            style: GoogleFonts.lora(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xff4E342E),
            ),
          ),
          const SizedBox(height: 16),
          // Custom Tab Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24 * scale,
                          vertical: 8 * scale,
                        ),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: const Color(0xFFFFE0B2), // Selected bg
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                  bottom: BorderSide(
                                    color: const Color(
                                      0xFFFFA726,
                                    ), // Orange line
                                    width: 3 * scale,
                                  ),
                                ),
                              )
                            : null,
                        child: Text(
                          _tabs[index],
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4E342E),
                            decoration: isSelected
                                ? TextDecoration.underline
                                : TextDecoration.none,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Transform.translate(
                          offset: const Offset(0, 0),
                          child: CustomPaint(
                            size: const Size(12, 8),
                            painter: TrianglePainter(color: Color(0xFFFFA726)),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Content Area
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Obx(() {
              if (_homeController.isDoshaDashaLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return _buildContent(scale);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(double scale) {
    switch (_selectedIndex) {
      case 0:
        return _buildDoshaTab(scale);
      case 1:
        return _buildDashaTab(scale);
      case 2:
        return _buildRemediesTab(scale);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDashaTab(double scale) {
    print("Dasha Tab Building");
    final data = _homeController.doshaDashaData?.data?.dashas;
    print("Dasha Data: $data");
    if (data == null) {
      return Center(
        child: Text("No Dasha Data Available", style: GoogleFonts.lora()),
      );
    }

    final yogini = data.currentYogini;
    final chardasha = data.currentChardasha;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2), // Light orange bg
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20 * scale,
                height: 20 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.8),
                ),
                child: SvgPicture.asset("assets/images/dashadot.svg"),
              ),
              SizedBox(width: 8 * scale),
              Text(
                "Dasha",
                style: GoogleFonts.lora(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12 * scale,
              vertical: 4 * scale,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 8 * scale, color: Colors.orange),
                SizedBox(width: 4 * scale),
                Text(
                  "Yogini Dasha",
                  style: GoogleFonts.poppins(
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff4E342E),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16 * scale),
          // Current Major Dasha
          if (yogini?.majorDasha != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CURRENT MAJOR DASHA",
                      style: GoogleFonts.lora(
                        fontSize: 10 * scale,
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${yogini!.majorDasha!.dashaName ?? ""}  ",
                            style: GoogleFonts.lora(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4E342E),
                            ),
                          ),
                          TextSpan(
                            text:
                                "${_formatDate(yogini.majorDasha!.startDate)} - ${_formatDate(yogini.majorDasha!.endDate)}",
                            style: GoogleFonts.lora(
                              fontSize: 12 * scale,
                              color: const Color(0xFF6D4C41),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 2 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Text(
                    "ACTIVE",
                    style: GoogleFonts.lora(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 12 * scale),
          Row(
            children: [
              if (yogini?.subDasha != null)
                Expanded(
                  child: _buildDashaCard(
                    "SUB DASHA",
                    yogini!.subDasha!.dashaName ?? "",
                    "Till ${_formatDate(yogini.subDasha!.endDate)}",
                    scale,
                  ),
                ),
              SizedBox(width: 12 * scale),
              if (yogini?.subSubDasha != null)
                Expanded(
                  child: _buildDashaCard(
                    "SUB-SUB DASHA",
                    yogini!.subSubDasha!.dashaName ?? "",
                    "Till ${_formatDate(yogini.subSubDasha!.endDate)}",
                    scale,
                  ),
                ),
            ],
          ),
          SizedBox(height: 20 * scale),

          // Char Dasha
          if (chardasha?.majorDasha != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CHAR DASHA",
                      style: GoogleFonts.lora(
                        fontSize: 10 * scale,
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4 * scale),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "${chardasha!.majorDasha!.signName ?? ""}  ",
                            style: GoogleFonts.lora(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4E342E),
                            ),
                          ),
                          TextSpan(
                            text:
                                "${_formatYear(chardasha.majorDasha!.startDate)} - ${_formatYear(chardasha.majorDasha!.endDate)}",
                            style: GoogleFonts.lora(
                              fontSize: 12 * scale,
                              color: const Color(0xFF6D4C41),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8 * scale,
                    vertical: 2 * scale,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Text(
                    "ACTIVE",
                    style: GoogleFonts.lora(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Row(
              children: [
                if (chardasha.subDasha != null)
                  Expanded(
                    child: _buildDashaCard(
                      "SUB DASHA",
                      chardasha.subDasha!.dashaName ?? "",
                      "Till ${_formatDate(chardasha.subDasha!.endDate)}",
                      scale,
                    ),
                  ),
                SizedBox(width: 12 * scale),
                if (chardasha.subSubDasha != null)
                  Expanded(
                    child: _buildDashaCard(
                      "SUB-SUB DASHA",
                      chardasha.subSubDasha!.dashaName ?? "",
                      "Till ${_formatDate(chardasha.subSubDasha!.endDate)}",
                      scale,
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 20 * scale),
          Center(
            child: GestureDetector(
              onTap: () {
                Get.to(() => const DashaTimelineView());
              },
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 24 * scale,
                  vertical: 10 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFEF6C00)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View Full Dasha Timeline",
                      style: GoogleFonts.lora(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8 * scale),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 16 * scale,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return "";
    // Assuming date format from API is DD/MM/YYYY or similar that needs parsing
    // If it's standard ISO or DD MMM YYYY, we can just return or format
    // For now, returning as is or implementing simple formatter if needed
    // Example: "12 Feb 2029"
    return dateStr;
  }

  String _formatYear(String? dateStr) {
    if (dateStr == null) return "";
    // Extract year if full date
    // simple logic
    if (dateStr.contains("-")) return dateStr.split("-").last;
    if (dateStr.contains(" ")) return dateStr.split(" ").last;
    return dateStr;
  }

  Widget _buildDashaCard(String title, String name, String date, double scale) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 9 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFA1887F),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            name,
            style: GoogleFonts.lora(
              fontSize: 14 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4E342E),
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            date,
            style: GoogleFonts.lora(
              fontSize: 11 * scale,
              color: const Color(0xFF8D6E63),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaTab(double scale) {
    print("Dosha Tab Building");
    final data = _homeController.doshaDashaData?.data?.doshas;
    print("Dosha Data: $data");
    if (data == null) {
      return Center(
        child: Text("No Dosha Data Available", style: GoogleFonts.lora()),
      );
    }
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2), // Light orange bg
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon(Icons.warning_amber_rounded, size: 18 * scale, color: const Color(0xFFD32F2F)),
              Container(
                width: 20 * scale,
                height: 20 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.8),
                ),
                child: SvgPicture.asset("assets/images/doshadot.svg"),
              ),
              SizedBox(width: 8 * scale),
              Text(
                "Dosha",
                style: GoogleFonts.lora(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF3E2723),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          if (data.manglik != null)
            _buildDoshaItem(
              "Manglik Dosha",
              data.manglik!,
              scale,
              isActive: data.manglik!.present == true,
              customDescription: data.manglik!.manglikReport,
            ),
          SizedBox(height: 12 * scale),
          if (data.kalsarpa != null)
            _buildDoshaItem(
              "Kaal Sarpa Dosha",
              data.kalsarpa!,
              scale,
              isActive: data.kalsarpa!.present == true,
              customDescription:
                  (data.kalsarpa!.present == false &&
                      (data.kalsarpa!.oneLine == null ||
                          data.kalsarpa!.oneLine!.isEmpty))
                  ? "Kalsarpa dosha is not detected in your horoscope."
                  : data.kalsarpa!.oneLine,
            ),
          SizedBox(height: 12 * scale),
          if (data.pitra != null)
            _buildDoshaItem(
              "Pitra Dosha",
              data.pitra!,
              scale,
              isPitra: true,
              isActive: data.pitra!.present == true,
              customDescription: data.pitra!.conclusion,
            ),
        ],
      ),
    );
  }

  Widget _buildDoshaItem(
    String title,
    DoshaDetail detail,
    double scale, {
    bool isActive = true,
    bool isPitra = false,
    String? customDescription,
  }) {
    // Determine colors based on type/active
    Color bgColor = const Color(0xFFFFF3E0);
    Color statusColor = const Color(0xFFE65100);
    String statusText = detail.present == true ? "YES" : "NO";

    if (isActive && !isPitra) {
      // Active Manglik / Kalsarpa
      if (title.contains("Kaal")) {
        bgColor = const Color(0xFFE8F5E9);
        statusColor = const Color(0xFF2E7D32);
      } else {
        bgColor = const Color(0xFFFFF3E0);
        statusColor = const Color(0xFFE65100);
      }
    } else if (isPitra) {
      bgColor = const Color(0xFFFFEBEE);
      statusColor = const Color(0xFFC62828);
    } else {
      // Not present/active
      bgColor = Colors.grey.shade100;
      statusColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: isPitra
                      ? const Color(0xFFFF8A80)
                      : isActive
                      ? const Color(0xFFFFE0B2)
                      : const Color(0xFFA5D6A7).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPitra || isActive)
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      Container(
                        width: 6 * scale,
                        height: 6 * scale,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    SizedBox(width: 6 * scale),
                    Text(
                      title,
                      style: GoogleFonts.lora(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: GoogleFonts.lora(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 8 * scale),
          Text(
            customDescription ?? detail.description ?? "",
            style: GoogleFonts.poppins(
              fontSize: 12 * scale,
              color: const Color(0xff5D4037),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8 * scale),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Get.to(
                  () => DoshaDetailView(
                    title: title,
                    doshaDetail: detail,
                    isPitra: isPitra,
                  ),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View Details",
                    style: GoogleFonts.poppins(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFE65100),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16 * scale,
                    color: const Color(0xFFE65100),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemediesTab(double scale) {
    if (_homeController.isRemediesLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E88E5)),
      );
    }

    final remedies = _homeController.remediesData?.data?.remedies;
    if (remedies == null) {
      return Container(
        padding: EdgeInsets.all(24 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFFE3F2FD),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(
            "No Remedies Data Available",
            style: GoogleFonts.lora(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1565C0),
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0B2), // Light Blue bg for Remedies Tab
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20 * scale,
                height: 20 * scale,
                padding: EdgeInsets.all(2 * scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.8),
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  size: 16 * scale,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 8 * scale),
              Text(
                "Remedies",
                style: GoogleFonts.lora(
                  fontSize: 16 * scale,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D47A1),
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          // 1. Gemstones Card
          if (remedies.gemstone != null)
            _buildRemedyCard(
              title: "Gemstones",
              icon: Icons.diamond_outlined,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (remedies.gemstone!.life != null)
                    _buildGemstoneRow(
                      "LIFE",
                      remedies.gemstone!.life!.name,
                      scale,
                    ),
                  if (remedies.gemstone!.benefic != null)
                    _buildGemstoneRow(
                      "BENEFIC",
                      remedies.gemstone!.benefic!.name,
                      scale,
                    ),
                  if (remedies.gemstone!.lucky != null)
                    _buildGemstoneRow(
                      "LUCKY",
                      remedies.gemstone!.lucky!.name,
                      scale,
                    ),
                ],
              ),
              scale: scale,
              themeColor: Colors.blue,
              bgColor: const Color(0xFFE3F2FD),
              borderColor: const Color(0xFF90CAF9),
              onTap: () => Get.to(
                () => GemstoneDetailView(gemstones: remedies.gemstone!),
              ),
            ),

          SizedBox(height: 12 * scale),

          // 2. Rudraksha Card
          if (remedies.rudraksha != null)
            _buildRemedyCard(
              title: "Rudraksha",
              icon: Icons.spa_outlined,
              content: Text(
                remedies.rudraksha!.recommend ?? "Recommended for you.",
                style: GoogleFonts.poppins(
                  fontSize: 12 * scale,
                  color: const Color(0xff4E342E),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              scale: scale,
              themeColor: Colors.brown,
              bgColor: const Color(0xFFEFEBE9),
              borderColor: const Color(0xFFBCAAA4),
              onTap: () => Get.to(
                () => RudrakshaDetailView(rudraksha: remedies.rudraksha!),
              ),
            ),

          SizedBox(height: 12 * scale),

          // 3. Puja Card
          if (remedies.puja != null)
            _buildRemedyCard(
              title: "Puja Suggestions",
              icon: Icons.self_improvement,
              content: Text(
                remedies.puja!.summary ??
                    "Puja recommendations based on your chart.",
                style: GoogleFonts.poppins(
                  fontSize: 12 * scale,
                  color: const Color(0xffff7438),
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              scale: scale,
              themeColor: Colors.orange,
              bgColor: const Color(0xFFFFF8E1),
              borderColor: const Color(0xFFFFCC80),
              onTap: () => Get.to(() => PujaDetailView(puja: remedies.puja!)),
            ),
        ],
      ),
    );
  }

  Widget _buildGemstoneRow(String label, String? name, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.0 * scale),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "$label: ",
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1565C0),
              ),
            ),
            TextSpan(
              text: name ?? "N/A",
              style: GoogleFonts.poppins(
                fontSize: 12 * scale,
                color: const Color(0xff4E342E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemedyCard({
    required String title,
    required IconData icon,
    required Widget content,
    required double scale,
    required Color themeColor,
    required Color bgColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(12 * scale),
      decoration: BoxDecoration(
        color: bgColor, // Use the passed bgColor (light pastel)
        borderRadius: BorderRadius.circular(16),

        // Removed BoxShadow to match Dosha Item style
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10 * scale,
                  vertical: 4 * scale,
                ),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(
                    0.5,
                  ), // Slightly transparent white
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 14 * scale, color: themeColor),
                    SizedBox(width: 6 * scale),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 11 * scale,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4E342E),
                      ),
                    ),
                  ],
                ),
              ),
              // Status or other indicators could go here
            ],
          ),
          SizedBox(height: 8 * scale),
          content,
          SizedBox(height: 8 * scale),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "View Details",
                    style: GoogleFonts.poppins(
                      fontSize: 11 * scale,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 16 * scale,
                    color: themeColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
