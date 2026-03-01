import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/features/home/models/panchang_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PanchangDetailsView extends StatelessWidget {
  const PanchangDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6), // Light orange background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Panchang",
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

        return DefaultTabController(
          length: 4,
          child: Column(
            children: [
              _buildHeaderCard(basic, advanced),
              _buildSunMoonRow(advanced),
              TabBar(
                labelColor: const Color(0xFFE65100),
                unselectedLabelColor: const Color(0xFF6D3A0C).withOpacity(0.6),
                indicatorColor: const Color(0xFFE65100),
                labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold),
                isScrollable: false,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                tabs: const [
                  Tab(text: "Over View"),
                  Tab(text: "Panchang"),
                  Tab(text: "Muhurta"),
                  Tab(text: "Chaughadiya"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildOverviewTab(basic, advanced, dailyNakshatra),
                    _buildPanchangTab(basic, advanced),
                    _buildMuhuratTab(advanced),
                    _buildChaughadiyaTab(chaughadiya),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeaderCard(BasicPanchang? basic, AdvancedPanchang? advanced) {
    // Format Date: Thursday, 05 Feb 2026
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(now);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1), // Light yellow/cream
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            basic?.tithi ?? "Tithi Unavailable",
            style: GoogleFonts.lora(
              fontSize: 16,
              color: const Color(0xFF8D6E63),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.wb_sunny_outlined,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                advanced?.sunrise ?? "--:--",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 24),
              const Icon(
                Icons.nights_stay_outlined,
                color: Colors.indigo,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                advanced?.moonrise ?? "--:--",
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSunMoonRow(AdvancedPanchang? advanced) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunMoonItem(
            Icons.wb_sunny_outlined,
            "Sunrise",
            advanced?.sunrise ?? "-",
            Colors.orange,
          ),
          _buildSunMoonItem(
            Icons.wb_twilight,
            "Sunset",
            advanced?.sunset ?? "-",
            Colors.deepOrange,
          ),
          _buildSunMoonItem(
            Icons.nights_stay_outlined,
            "Moon rise",
            advanced?.moonrise ?? "-",
            Colors.indigo,
          ),
          _buildSunMoonItem(
            Icons.bedtime_outlined,
            "Moon set",
            advanced?.moonset ?? "-",
            Colors.blueGrey,
          ),
        ],
      ),
    );
  }

  Widget _buildSunMoonItem(
    IconData icon,
    String label,
    String time,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 12, color: const Color(0xFF6D3A0C)),
        ),
        Text(
          time,
          style: GoogleFonts.lora(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F1F1F),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(
    BasicPanchang? basic,
    AdvancedPanchang? advanced,
    DailyNakshatraPrediction? dailyNakshatra,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
            _buildInfoRow("Amanta Month", advanced?.hinduMaah?.amanta ?? "-"),
            _buildInfoRow("Paksha", advanced?.paksha ?? "-"),
            _buildInfoRow("Ritu", advanced?.ritu ?? "-"),
            _buildInfoRow("Ayana", advanced?.ayana ?? "-"),
          ]),
          const SizedBox(height: 20),
          _buildSectionTitle("Daily Panchang"),
          Row(
            children: [
              Expanded(
                child: _buildSmallCard(
                  "TITHI",
                  basic?.tithi ?? "-",
                  "Until ${advanced?.panchang?.tithi?.endTime?.hour}:${advanced?.panchang?.tithi?.endTime?.minute} ",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallCard(
                  "NAKSHATRA",
                  basic?.nakshatra ?? "-",
                  "Until ${advanced?.panchang?.nakshatra?.endTime?.hour}:${advanced?.panchang?.nakshatra?.endTime?.minute}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSmallCard(
                  "YOG",
                  basic?.yog ?? "-",
                  "Until ${advanced?.panchang?.yog?.endTime?.hour}:${advanced?.panchang?.yog?.endTime?.minute}",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallCard(
                  "KARAN",
                  basic?.karan ?? "-",
                  "Until ${advanced?.panchang?.karan?.endTime?.hour}:${advanced?.panchang?.karan?.endTime?.minute}",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Inauspicious Timings"),
          _buildInauspiciousCard(
            "Rahu Kaal",
            "${advanced?.rahukaal?.start} - ${advanced?.rahukaal?.end}",
          ),
          const SizedBox(height: 12),
          _buildInauspiciousCard(
            "Guli Kaal",
            "${advanced?.guliKaal?.start} - ${advanced?.guliKaal?.end}",
            icon: Icons.access_time,
          ),
          const SizedBox(height: 12),
          _buildInauspiciousCard(
            "Yamghant Kaal",
            "${advanced?.yamghantKaal?.start} - ${advanced?.yamghantKaal?.end}",
            icon: Icons.access_time,
          ),
          const SizedBox(height: 20),
          _buildSectionTitle("Abhijit Muhurta"),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E6B56),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.white, size: 30),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BEST TIME TODAY",
                        style: GoogleFonts.lora(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Abhijit Muhurta",
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Highly auspicious for all activities",
                        style: GoogleFonts.lora(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${advanced?.abhijitMuhurta?.start} - ${advanced?.abhijitMuhurta?.end}",
                  style: GoogleFonts.lora(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPanchangTab(BasicPanchang? basic, AdvancedPanchang? advanced) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildExpansionCard(
          "Tithi",
          basic?.tithi ?? "-",
          "Ends At: ${advanced?.panchang?.tithi?.endTime?.hour}:${advanced?.panchang?.tithi?.endTime?.minute}",
          "Deity: Moon",
          "Special: Poorna",
          Colors.orange.shade100,
        ), // Placeholder data for now
        _buildExpansionCard(
          "Nakshatra",
          basic?.nakshatra ?? "-",
          "Ends At: ${advanced?.panchang?.nakshatra?.endTime?.hour}:${advanced?.panchang?.nakshatra?.endTime?.minute}",
          null,
          null,
          null,
        ),
        _buildExpansionCard(
          "Yog",
          basic?.yog ?? "-",
          "Ends At: ${advanced?.panchang?.yog?.endTime?.hour}:${advanced?.panchang?.yog?.endTime?.minute}",
          null,
          null,
          null,
        ),
        _buildExpansionCard(
          "Karan",
          basic?.karan ?? "-",
          "Ends At: ${advanced?.panchang?.karan?.endTime?.hour}:${advanced?.panchang?.karan?.endTime?.minute}",
          null,
          null,
          null,
        ),
      ],
    );
  }

  Widget _buildExpansionCard(
    String title,
    String value,
    String subValue,
    String? extra1,
    String? extra2,
    Color? iconBg,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        collapsedBackgroundColor: Colors.white,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg ?? Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.star_outline,
            color: const Color(0xFFE65100),
          ), // dynamic icon needed
        ),
        title: Text(
          title,
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        subtitle: Text(
          "$value • $subValue",
          style: GoogleFonts.lora(color: Colors.grey.shade600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (extra1 != null) Text(extra1, style: GoogleFonts.lora()),
                if (extra2 != null) Text(extra2, style: GoogleFonts.lora()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuhuratTab(AdvancedPanchang? advanced) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildMuhuratCard(
          "Abhijit Muhurta",
          "${advanced?.abhijitMuhurta?.start} - ${advanced?.abhijitMuhurta?.end}",
          "Highly auspicious for all activities",
          true,
        ),
        _buildMuhuratCard(
          "Rahu Kaal",
          "${advanced?.rahukaal?.start} - ${advanced?.rahukaal?.end}",
          "Considered harmful for starting new project.",
          false,
        ),
        _buildMuhuratCard(
          "Guli Kaal",
          "${advanced?.guliKaal?.start} - ${advanced?.guliKaal?.end}",
          "Known as the period of Gulika.",
          false,
          isAmber: true,
        ), // Amber for Guli
        _buildMuhuratCard(
          "Yamghant Kaal",
          "${advanced?.yamghantKaal?.start} - ${advanced?.yamghantKaal?.end}",
          "Avoid beginning important life events.",
          false,
          isReview: true,
        ), // Grey/Review for Yamghant
      ],
    );
  }

  Widget _buildMuhuratCard(
    String title,
    String time,
    String description,
    bool isAuspicious, {
    bool isAmber = false,
    bool isReview = false,
  }) {
    Color cardColor = Colors.white;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isAuspicious) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = "AUSPICIOUS";
    } else if (isAmber) {
      statusColor = Colors.amber;
      statusIcon = Icons.hourglass_full;
      statusText = "INAUSPICIOUS";
    } else if (isReview) {
      statusColor = Colors.blueGrey;
      statusIcon = Icons.warning;
      statusText = "INAUSPICIOUS";
    } else {
      statusColor = Colors.red;
      statusIcon = Icons.block;
      statusText = "INAUSPICIOUS";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusText,
                style: GoogleFonts.lora(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Icon(statusIcon, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                time,
                style: GoogleFonts.lora(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaughadiyaTab(ChaughadiyaMuhurta? chaughadiya) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              labelColor: const Color(0xFFE65100),
              unselectedLabelColor: Colors.grey,
              isScrollable: false,
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.wb_sunny_outlined),
                      SizedBox(width: 8),
                      Text("Day Timings"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.nights_stay_outlined),
                      SizedBox(width: 8),
                      Text("Night Timings"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildChaughadiyaList(chaughadiya?.day),
                _buildChaughadiyaList(chaughadiya?.night),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaughadiyaList(List<MuhurtaItem>? list) {
    if (list == null || list.isEmpty)
      return const Center(child: Text("No Data"));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isGood = [
          'shubh',
          'labh',
          'amrit',
        ].contains(item.muhurta?.toLowerCase());
        final isBad = [
          'udveg',
          'rog',
          'kaal',
        ].contains(item.muhurta?.toLowerCase());
        final isAvg = ['char'].contains(item.muhurta?.toLowerCase());

        Color statusColor = isGood
            ? Colors.green
            : (isBad ? Colors.red : Colors.amber);
        String statusText = isGood ? "GOOD" : (isBad ? "BAD" : "AVG");

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border(left: BorderSide(color: statusColor, width: 4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "FROM",
                      style: GoogleFonts.lora(
                        fontSize: 10,
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.time ?? "-", // Provide safe default
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.muhurta ?? "-",
                          style: GoogleFonts.lora(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F1F1F),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isGood
                          ? "Highly Auspicious"
                          : (isBad
                                ? "Avoid all works"
                                : "Neutral results"), // Placeholder text based on status
                      style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Text(
                statusText,
                style: GoogleFonts.lora(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
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
        color: const Color(0xFFFDF8F0), // Slight beige/paper bg
        borderRadius: BorderRadius.circular(12),
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
                color: const Color(0xFF8D6E63),
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
                color: const Color(0xFF4E342E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String title, String value, String subValue) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE65100),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subValue,
            style: GoogleFonts.lora(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInauspiciousCard(
    String title,
    String time, {
    IconData icon = Icons.warning_amber_rounded,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.red.shade900),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lora(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                "Avoid new beginnings",
                style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          Text(
            time,
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
