import 'package:brahmakosh/core/common_imports.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PanchangView extends StatelessWidget {
  const PanchangView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 24),
                      _buildSunMoonSection(),
                      const SizedBox(height: 24),
                      _buildPanchangGrid(),
                      const SizedBox(height: 24),
                      _buildAuspiciousSection(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
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

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF3C052), Color(0xFFD48F37)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thursday, 12 Oct 2023',
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Shukla Paksha Trayodashi',
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
                '06:21 AM',
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
                '06:45 PM',
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

  Widget _buildSunMoonSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSunMoonItem(Icons.wb_sunny_outlined, "Sunrise", "06:21 AM", Colors.orange),
          _buildSunMoonItem(Icons.wb_twilight, "Sunset", "05:58 PM", Colors.deepOrange),
          _buildSunMoonItem(Icons.nights_stay_outlined, "Moon rise", "06:45 PM", Colors.blueAccent),
          _buildSunMoonItem(Icons.bedtime_outlined, "Moon set", "07:12 AM", Colors.indigoAccent),
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

  Widget _buildPanchangGrid() {
    final items = [
      {'label': 'NAKSHATRA', 'value': 'Purva Phalguni', 'time': 'Until 08:34 PM'},
      {'label': 'YOG', 'value': 'Shukla', 'time': 'Until 10:12 AM'},
      {'label': 'KARAN', 'value': 'Kaulava', 'time': 'Until 11:45 PM'},
      {'label': 'RASHI', 'value': 'Simha (Leo)', 'time': 'Full Day'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Panchang Details', const Color(0xFFF3C052)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildSmallCard(
              items[index]['label']!,
              items[index]['value']!,
              items[index]['time']!,
            );
          },
        ),
      ],
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
            style: GoogleFonts.lora(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFF3C052),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
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

  Widget _buildAuspiciousSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Inauspicious Timings', Colors.redAccent),
        const SizedBox(height: 16),
        _buildTimingRow('Rahu Kaal', '01:30 PM - 03:00 PM', Icons.error_outline, Colors.redAccent),
        const SizedBox(height: 12),
        _buildTimingRow('Yamghant Kaal', '06:00 AM - 07:30 AM', Icons.access_time, Colors.orangeAccent),
        const SizedBox(height: 24),
        _buildSectionHeader('Best Time Today', Colors.greenAccent),
        const SizedBox(height: 16),
        _buildBestTimeTile('Abhijit Muhurta', '11:44 AM - 12:29 PM'),
      ],
    );
  }

  Widget _buildBestTimeTile(String title, String time) {
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
                  title,
                  style: GoogleFonts.lora(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildTimingRow(String title, String time, IconData icon, Color color) {
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
}
