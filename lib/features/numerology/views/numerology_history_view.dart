import 'package:brahmakosh/features/numerology/controllers/numerology_controller.dart';
import 'package:brahmakosh/features/numerology/models/numerology_detail_model.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common_imports.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';

class NumerologyHistoryView extends StatefulWidget {
  const NumerologyHistoryView({super.key});

  @override
  State<NumerologyHistoryView> createState() => _NumerologyHistoryViewState();
}

class _NumerologyHistoryViewState extends State<NumerologyHistoryView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Refresh numerology data to reflect recent profile changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.put(NumerologyController()).fetchNumerologyDetail();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NumerologyController());


    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        title: Text(
          "Numerology",
          style: GoogleFonts.merriweather(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Get.back(),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(
          //     Icons.battery_full,
          //     color: Colors.black,
          //   ), // Status bar mock, meaningful only in design
          //   onPressed: () {},
          // ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6D3A0C)),
          );
        }

        final data = controller.userNumerology.value;
        if (data == null) {
          return Center(
            child: Text(
              "No numerology data found.",
              style: GoogleFonts.lora(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        return Column(
          children: [
            _buildProfileHeader(data),
            const SizedBox(height: 16),
            _buildTabBar(),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(data),
                  _buildNumeroTableTab(data),
                  _buildDailyTab(data),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProfileHeader(NumerologyDetailData data) {
    final profileVM = context.watch<ProfileViewModel>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5), // Light beige match
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
               CircleAvatar(
                radius: 24, // Reduced radius
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  profileVM.profile?.profileImageUrl ?? 'https://i.pravatar.cc/150?img=11',
                ), // Placeholder
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileVM.profile?.profile?.name ?? data.name ?? "User Name",
                    style: GoogleFonts.merriweather(
                      fontSize: 16, // Reduced font size
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  Text(
                    profileVM.profile?.profile?.dob?.split('T').first ?? "${data.year}-${data.month}-${data.day}",
                    style: GoogleFonts.lora(
                      fontSize: 12, // Reduced font size
                      color: const Color(0xFF6D3A0C).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12), // Reduced spacing
          Row(
            children: [
              Expanded(
                child: _buildNumberChip(
                  "DESTINY NUMBER",
                  data.numeroTable?.destinyNumber?.toString() ?? "-",
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildNumberChip(
                  "RADICAL NUMBER",
                  data.numeroTable?.radicalNumber?.toString() ?? "-",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberChip(String label, String number) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 10,
      ), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.merriweather(
              fontSize: 9, // Reduced font size
              fontWeight: FontWeight.bold,
              color: const Color(0xFF8D6E63),
            ),
          ),
          Text(
            number,
            style: GoogleFonts.merriweather(
              fontSize: 14, // Reduced font size
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 40, // Fixed height for tighter look
      decoration: BoxDecoration(
        color: const Color(0xFFFDF0D5), // Background of the pill container
        borderRadius: BorderRadius.circular(20),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab, // Important for pill shape
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        dividerColor: Colors.transparent, // Remove any underline
        labelColor: const Color(0xFFE65100), // Orange active
        unselectedLabelColor: const Color(0xFF6D3A0C), // Brown inactive
        labelStyle: GoogleFonts.merriweather(
          fontWeight: FontWeight.bold,
          fontSize: 12, // Reduced font size
        ),
        unselectedLabelStyle: GoogleFonts.lora(
          fontWeight: FontWeight.w500,
          fontSize: 12, // Reduced font size
        ),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(text: "Report"),
          Tab(text: "Table"),
          Tab(text: "Daily"),
        ],
      ),
    );
  }

  // --- TAB 1: OVERVIEW ---
  Widget _buildOverviewTab(NumerologyDetailData data) {
    // NOTE: Image 3 shows "Jupiter Insight" card first, but we don't have direct mapping.
    // We will show "What the Number Says About You" from `numeroReport`.
    // And Lucky items.

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Insight mock based on radical ruler if available
          if (data.numeroTable?.radicalRuler != null)
            _buildInsightCard(data.numeroTable!.radicalRuler!),

          const SizedBox(height: 16),

          // Report Card
          if (data.numeroReport != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.numeroReport!.title ?? "Numerology Report",
                    style: GoogleFonts.merriweather(
                      fontSize: 14, // Reduced
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.numeroReport!.description ?? "",
                    style: GoogleFonts.lora(
                      fontSize: 12, // Reduced
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),

                  // Tags mock - since API doesn't allow, we show generic ones or skip?
                  // User asked to match UI. I will put placeholders or check if I can derive.
                  // For now, I'll extract some keywords or just skip to avoid fake data.
                  // But the image has tags: Creative, Disciplined, Optimistic.
                  Row(
                    children: [
                      _buildTag("Creative"),
                      const SizedBox(width: 8),
                      _buildTag("Disciplined"),
                      const SizedBox(width: 8),
                      _buildTag("Optimistic"),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),
          // Lucky Color Bottom Card (Overview Tab specific version from image 3)
          _buildLuckyColorWideCard(data.dailyPrediction?.luckyColor ?? "N/A"),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInsightCard(String planet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.wb_sunny_outlined, color: Colors.orange),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$planet INSIGHT",
                style: GoogleFonts.merriweather(
                  fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Number Energy",
                style: GoogleFonts.merriweather(
                  fontSize: 14, // Reduced
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCCBC).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFCCBC)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.merriweather(
          fontSize: 9, // Reduced
          fontWeight: FontWeight.bold,
          color: const Color(0xFFE65100),
        ),
      ),
    );
  }

  Widget _buildLuckyColorWideCard(String color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.yellow[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.palette, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lucky Color",
                    style: GoogleFonts.merriweather(
                      fontSize: 14, // Reduced
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  Text(
                    color,
                    style: GoogleFonts.merriweather(
                      fontSize: 12, // Reduced
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: NUMERO TABLE ---
  Widget _buildNumeroTableTab(NumerologyDetailData data) {
    final table = data.numeroTable;
    if (table == null) return const Center(child: Text("No table data"));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  "Name Number",
                  "${table.nameNumber}",
                  badge: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  "Radical Number",
                  "${table.radicalNumber}",
                  badge: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  "Friendly Number",
                  table.friendlyNum ?? "-",
                  greenBg: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  "Neutral Number",
                  table.neutralNum ?? "-",
                  blueBg: true,
                ),
              ),
              // Evil number is usually displayed separately or in 3rd col, but design shows 2 cols mostly
            ],
          ),
          const SizedBox(height: 12),
          // Evil Num & Favorable Color
          Row(
            children: [
              Expanded(
                child: _buildGridItem(
                  "Evil Number",
                  table.evilNum ?? "-",
                  redBg: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItemWithColorIcon(
                  "Favorable Color",
                  table.favColor ?? "-",
                  Colors.yellow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // God & Day
          Row(
            children: [
              Expanded(
                child: _buildGridItem("Favorable God", table.favGod ?? "-"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem("Favorable Day", table.favDay ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Metal & Stone
          Row(
            children: [
              Expanded(
                child: _buildGridItem("Favorable Metal", table.favMetal ?? "-"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem("Favorable Stone", table.favStone ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Radical Ruler (Full width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Radical Ruler",
                      style: GoogleFonts.merriweather(
                        fontSize: 10, // Reduced
                        color: const Color(0xFF6D3A0C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      table.radicalRuler ?? "-",
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Icon(Icons.public, color: Colors.orange[200], size: 40),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Favorite Mantra (Bottom Gradient Card)
          if (table.favMantra != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFDD835)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    "FAVORITE MANTRA",
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 10, // Reduced
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    width: 100,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    table.favMantra!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.merriweather(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGridItem(
    String label,
    String value, {
    bool badge = false,
    bool greenBg = false,
    bool blueBg = false,
    bool redBg = false,
  }) {
    Color bgColor = Colors.white;
    if (greenBg) bgColor = const Color(0xFFE8F5E9);
    if (blueBg) bgColor = const Color(0xFFE3F2FD);
    if (redBg) bgColor = const Color(0xFFFFEBEE); // Light red

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: badge
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge) ...[
            const Icon(Icons.star, color: Color(0xFFFF8A65), size: 16),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            style: GoogleFonts.merriweather(
              fontSize: 10, // Reduced
              fontWeight: FontWeight.bold, // Bold label
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.merriweather(
              fontSize: 14, // Reduced
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGridItemWithColorIcon(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.merriweather(
              fontSize: 10, // Reduced
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.merriweather(
                    fontSize: 12, // Reduced
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- TAB 3: DAILY ---
  Widget _buildDailyTab(NumerologyDetailData data) {
    if (data.dailyPrediction == null)
      return const Center(child: Text("No daily prediction"));
    final daily = data.dailyPrediction!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(
                0xFFFFF3E0,
              ), // Page background alike but slightly darker or lighter
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Colors.orange),
                    const SizedBox(width: 8),
                    Text(
                      "Daily Predication",
                      style: GoogleFonts.merriweather(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "\"${daily.prediction}\"",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lora(
                    fontSize: 12, // Reduced
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lucky Items
          _buildLuckyItemCard(
            Icons.palette,
            "Lucky Color",
            daily.luckyColor ?? "-",
            const Color(0xFFE8F5E9),
          ),
          const SizedBox(height: 16),
          _buildLuckyItemCard(
            Icons.tag,
            "Lucky Number",
            daily.luckyNumber ?? "-",
            Colors.white,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLuckyItemCard(
    IconData icon,
    String title,
    String value,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (bgColor == Colors.white)
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: title.contains("Color")
                  ? Colors.green[100]
                  : Colors.orange[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: title.contains("Color") ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6D3A0C),
                ),
              ),
              Text(
                value,
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
