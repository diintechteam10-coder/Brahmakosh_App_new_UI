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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomHeader(),
            Expanded(
              child: Obx(() {
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
                      _buildDateCard(basic, advanced),
                      _buildSunMoonRow(advanced),
                      _buildTabBar(),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          Text(
            "Panchang",
            style: GoogleFonts.lora(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(BasicPanchang? basic, AdvancedPanchang? advanced) {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, dd MMM yyyy').format(now);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3C052), Color(0xFFD48F37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(
          image: AssetImage('assets/images/shubh_muhurat_bg.png'), // Using existing asset if available, or just gradient
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formattedDate,
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            basic?.tithi ?? "Tithi Unavailable",
            style: GoogleFonts.lora(
              fontSize: 16,
              color: const Color(0xFF333333),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.wb_sunny, color: Colors.orange, size: 22),
              const SizedBox(width: 8),
              Text(
                _formatTimeString(advanced?.sunrise),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(width: 24),
              const Icon(Icons.nights_stay, color: Colors.indigo, size: 22),
              const SizedBox(width: 8),
              Text(
                _formatTimeString(advanced?.moonrise),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
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
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunMoonItem(Icons.wb_sunny_outlined, "Sunrise", _formatTimeString(advanced?.sunrise), Colors.orange),
          _buildSunMoonItem(Icons.wb_twilight, "Sunset", _formatTimeString(advanced?.sunset), Colors.deepOrange),
          _buildSunMoonItem(Icons.nights_stay_outlined, "Moon rise", _formatTimeString(advanced?.moonrise), Colors.blueAccent),
          _buildSunMoonItem(Icons.bedtime_outlined, "Moon set", _formatTimeString(advanced?.moonset), Colors.indigoAccent),
        ],
      ),
    );
  }

  Widget _buildSunMoonItem(IconData icon, String label, String time, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.lora(fontSize: 9, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 35,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3C052), width: 1)),
      ),
      child: TabBar(
        isScrollable: true,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        tabAlignment: TabAlignment.start,
        indicator: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          color: Color(0xFFF3C052),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: const Color(0xFFF3C052),
        labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 13),
        unselectedLabelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: [
          _buildTabItem("Over View"),
          _buildTabItem("Panchang"),
          _buildTabItem("Muhurta"),
          _buildTabItem("Chaughadiya"),
        ],
      ),
    );
  }

  Widget _buildTabItem(String text) {
    return Tab(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          border: const Border(
            top: BorderSide(color: Color(0xFFF3C052), width: 1),
            left: BorderSide(color: Color(0xFFF3C052), width: 1),
            right: BorderSide(color: Color(0xFFF3C052), width: 1),
          ),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }

  Widget _buildOverviewTab(BasicPanchang? basic, AdvancedPanchang? advanced, DailyNakshatraPrediction? dailyNakshatra) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Daily Panchang", const Color(0xFFF3C052)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _buildSmallCard("TITHI", basic?.tithi ?? "-", "Until ${_formatEndTime(advanced?.panchang?.tithi?.endTime)}"),
              _buildSmallCard("NAKSHATRA", basic?.nakshatra ?? "-", "Until ${_formatEndTime(advanced?.panchang?.nakshatra?.endTime)}"),
              _buildSmallCard("YOG", basic?.yog ?? "-", "Until ${_formatEndTime(advanced?.panchang?.yog?.endTime)}"),
              _buildSmallCard("KARAN", basic?.karan ?? "-", "Until ${_formatEndTime(advanced?.panchang?.karan?.endTime)}"),
            ],
          ),
          _buildSectionHeader("Inauspicious Timings", Colors.redAccent),
          _buildInauspiciousCard("Rahu Kaal", "${_formatTimeString(advanced?.rahukaal?.start)} - ${_formatTimeString(advanced?.rahukaal?.end)}", icon: Icons.error_outline, color: Colors.redAccent),
          const SizedBox(height: 12),
          _buildInauspiciousCard("Guli Kaal", "${_formatTimeString(advanced?.guliKaal?.start)} - ${_formatTimeString(advanced?.guliKaal?.end)}", icon: Icons.access_time, color: Colors.orangeAccent),
          const SizedBox(height: 12),
          _buildInauspiciousCard("Yamghant Kaal", "${_formatTimeString(advanced?.yamghantKaal?.start)} - ${_formatTimeString(advanced?.yamghantKaal?.end)}", icon: Icons.access_time, color: Colors.orangeAccent),
          _buildSectionHeader("Inauspicious Timings", Colors.greenAccent),
          _buildBestTimeTile(advanced),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 18,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.lora(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(String title, String value, String time) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lora(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFFF3C052)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lora(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInauspiciousCard(String title, String time, {required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  "Avoid new beginnings",
                  style: GoogleFonts.lora(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBestTimeTile(AdvancedPanchang? advanced) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E4D3B).withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E4D3B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF1E4D3B), shape: BoxShape.circle),
            child: const Icon(Icons.shield_outlined, color: Colors.greenAccent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "BEST TIME TODAY",
                  style: GoogleFonts.lora(color: const Color(0xFFF3C052), fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Abhijit Muhurta",
                  style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Highly auspicious for all activities",
                  style: GoogleFonts.lora(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${_formatTimeString(advanced?.abhijitMuhurta?.start)} - ${_formatTimeString(advanced?.abhijitMuhurta?.end)}",
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatTimeString(String? time) {
    if (time == null || time.isEmpty || time == "-" || time == "--:--") return "--:--";
    try {
      String cleanTime = time.trim();
      if (cleanTime.contains('AM') || cleanTime.contains('PM')) return cleanTime;
      
      final parts = cleanTime.split(':');
      if (parts.length < 2) return cleanTime;
      
      final hour = int.parse(parts[0].trim());
      final minute = int.parse(parts[1].trim());
      
      final dt = DateTime(2000, 1, 1, hour % 24, minute);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return time;
    }
  }

  String _formatEndTime(EndTime? time) {
    if (time == null || time.hour == null || time.minute == null) return "--:--";
    final dt = DateTime(2000, 1, 1, time.hour!, time.minute!);
    return DateFormat('hh:mm a').format(dt);
  }

  Widget _buildPanchangTab(BasicPanchang? basic, AdvancedPanchang? advanced) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildDetailCard(
          "Tithi",
          basic?.tithi ?? "-",
          "Ends At: ${_formatEndTime(advanced?.panchang?.tithi?.endTime)}",
          "Deity: Moon",
          "Special: Poorna",
          Colors.orange.withOpacity(0.1),
        ),
        _buildDetailCard(
          "Nakshatra",
          basic?.nakshatra ?? "-",
          "Ends At: ${_formatEndTime(advanced?.panchang?.nakshatra?.endTime)}",
          null,
          null,
          null,
        ),
        _buildDetailCard(
          "Yog",
          basic?.yog ?? "-",
          "Ends At: ${_formatEndTime(advanced?.panchang?.yog?.endTime)}",
          null,
          null,
          null,
        ),
        _buildDetailCard(
          "Karan",
          basic?.karan ?? "-",
          "Ends At: ${_formatEndTime(advanced?.panchang?.karan?.endTime)}",
          null,
          null,
          null,
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    String title,
    String value,
    String subValue,
    String? extra1,
    String? extra2,
    Color? iconBg,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg ?? Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.star_outline, color: Color(0xFFF3C052), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      "$value • $subValue",
                      style: GoogleFonts.lora(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (extra1 != null || extra2 != null) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.white10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (extra1 != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Text(extra1, style: GoogleFonts.lora(color: Colors.white70, fontSize: 13)),
                  ),
                if (extra2 != null)
                  Text(
                    extra2,
                    style: GoogleFonts.lora(
                      color: const Color(0xFFF3C052),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
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
    Color statusColor;
    if (isAuspicious) {
      statusColor = Colors.green;
    } else if (isAmber) {
      statusColor = Colors.amber;
    } else if (isReview) {
      statusColor = Colors.blueGrey;
    } else {
      statusColor = Colors.red;
    }

    // Convert time range if needed
    String formattedTime = time;
    if (time.contains(" - ")) {
      final parts = time.split(" - ");
      if (parts.length == 2) {
        formattedTime = "${_formatTimeString(parts[0])} - ${_formatTimeString(parts[1])}";
      }
    }

    return _buildDetailCard(
      title,
      "", // Value is included in title or description
      "Time: $formattedTime",
      description,
      isAuspicious ? "Status: Auspicious" : "Status: Inauspicious",
      statusColor.withOpacity(0.1),
    );
  }


  Widget _buildChaughadiyaTab(ChaughadiyaMuhurta? chaughadiya) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A).withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10, width: 0.5),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: const Color(0xFFF3C052),
                borderRadius: BorderRadius.circular(20),
              ),
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey[400],
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: EdgeInsets.zero,
              labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
              unselectedLabelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
              tabs: const [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wb_sunny_rounded, size: 18),
                      SizedBox(width: 6),
                      Text("DAY TIMINGS"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.nights_stay_rounded, size: 18),
                      SizedBox(width: 6),
                      Text("NIGHT TIMINGS"),
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
    if (list == null || list.isEmpty) return const Center(child: Text("No Data", style: TextStyle(color: Colors.white)));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final isGood = ['shubh', 'labh', 'amrit'].contains(item.muhurta?.toLowerCase());
        final isBad = ['udveg', 'rog', 'kaal'].contains(item.muhurta?.toLowerCase());

        Color statusColor = isGood ? Colors.green : (isBad ? Colors.red : Colors.amber);
        String statusText = isGood ? "Highly Auspicious" : (isBad ? "Avoid all works" : "Neutral results");

        // Format time range
        String formattedTime = item.time ?? "-";
        if (formattedTime.contains(" - ")) {
          final parts = formattedTime.split(" - ");
          if (parts.length == 2) {
            formattedTime = "${_formatTimeString(parts[0])} - ${_formatTimeString(parts[1])}";
          }
        }

        return _buildDetailCard(
          item.muhurta ?? "-",
          "",
          "Time: $formattedTime",
          statusText,
          isGood ? "Status: GOOD" : (isBad ? "Status: BAD" : "Status: AVG"),
          statusColor.withOpacity(0.1),
        );
      },
    );
  }


}
