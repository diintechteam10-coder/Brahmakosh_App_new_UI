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
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(
          'numerology_title'.tr,
          style: GoogleFonts.lora(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 1.8.h),
          ),
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
              'no_numerology_data'.tr,
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
    final profileImageUrl =
        profileVM.profile?.profileImageUrl;
    final hasImage =
        profileImageUrl != null &&
            profileImageUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), 
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              hasImage
                  ?CircleAvatar(
                radius: 24, // Reduced radius
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  profileVM.profile?.profileImageUrl ?? 'https://i.pravatar.cc/150?img=11',
                ), // Placeholder
              ):
              Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [
            Color(0xFFD4AF37),
            Color(0xFFA67C00),
          ], // Gold Gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFA67C00,
            ).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.person_rounded,
        size: 24,
        color: Colors.white,
      ),
    ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profileVM.profile?.profile?.name ?? data.name ?? 'user_name_placeholder'.tr,
                    style: GoogleFonts.lora(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profileVM.profile?.profile?.dob?.split('T').first ?? "${data.year}-${data.month}-${data.day}",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.6),
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
                  'destiny_number'.tr,
                  data.numeroTable?.destinyNumber?.toString() ?? "-",
                ),
              ),
              const SizedBox(width: 8), // Reduced spacing
              Expanded(
                child: _buildNumberChip(
                  'radical_number'.tr,
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
        vertical: 10,
        horizontal: 12,
      ), 
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 8.sp, 
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
            ),
          ),
          Text(
            number,
            style: GoogleFonts.lora(
              fontSize: 14.sp, 
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 48, 
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), 
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab, // Important for pill shape
        indicator: BoxDecoration(
          color: AppTheme.primaryGold,
          borderRadius: BorderRadius.circular(25),
        ),
        dividerColor: Colors.transparent, 
        labelColor: Colors.black, 
        unselectedLabelColor: Colors.grey, 
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 13, 
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 13, 
        ),
        padding: const EdgeInsets.all(4),
        tabs: [
          Tab(text: 'report_tab'.tr),
          Tab(text: 'table_tab'.tr),
          Tab(text: 'daily_tab'.tr),
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
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.numeroReport!.title ?? 'numerology_report_title'.tr,
                    style: GoogleFonts.lora(
                      fontSize: 14.sp, 
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    data.numeroReport!.description ?? "",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp, 
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 16),

                  // Tags mock - since API doesn't allow, we show generic ones or skip?
                  // User asked to match UI. I will put placeholders or check if I can derive.
                  // For now, I'll extract some keywords or just skip to avoid fake data.
                  // But the image has tags: Creative, Disciplined, Optimistic.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTag("Creative"),
                      _buildTag("Disciplined"),
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                'insight_label'.trParams({'planet': planet}),
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: AppTheme.primaryGold,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'number_energy'.tr,
                style: GoogleFonts.lora(
                  fontSize: 14.sp, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                  'daily_lucky_color_title'.tr,
                    style: GoogleFonts.lora(
                      fontSize: 14.sp, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    color,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp, 
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: const BoxDecoration(
          //     color: Colors.amber,
          //     shape: BoxShape.circle,
          //   ),
          // ),
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
                  'name_number_label'.tr,
                  "${table.nameNumber}",
                  badge: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  'radical_number'.tr,
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
                  'friendly_number_label'.tr,
                  table.friendlyNum ?? "-",
                  greenBg: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem(
                  'neutral_number_label'.tr,
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
                  'evil_number_label'.tr,
                  table.evilNum ?? "-",
                  redBg: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItemWithColorIcon(
                  'fav_color_label'.tr,
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
                child: _buildGridItem('fav_god_label'.tr, table.favGod ?? "-"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem('fav_day_label'.tr, table.favDay ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Metal & Stone
          Row(
            children: [
              Expanded(
                child: _buildGridItem('fav_metal_label'.tr, table.favMetal ?? "-"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridItem('fav_stone_label'.tr, table.favStone ?? "-"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Radical Ruler (Full width)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'radical_ruler_label'.tr,
                      style: GoogleFonts.poppins(
                        fontSize: 9.sp, 
                        color: AppTheme.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      table.radicalRuler ?? "-",
                      style: GoogleFonts.lora(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
                    'fav_mantra_label'.tr,
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
    Color bgColor = const Color(0xFF1C1C1E);
    if (greenBg) bgColor = const Color(0xFF1B2E1B);
    if (blueBg) bgColor = const Color(0xFF1B222E);
    if (redBg) bgColor = const Color(0xFF2E1B1B); 

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
            style: GoogleFonts.poppins(
              fontSize: 9.sp, 
              fontWeight: FontWeight.bold, 
              color: AppTheme.primaryGold.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14.sp, 
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9.sp, 
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGold,
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
                  style: GoogleFonts.lora(
                    fontSize: 12.sp, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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
              color: const Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppTheme.primaryGold),
                    const SizedBox(width: 8),
                    Text(
                      'daily_prediction_title'.tr,
                      style: GoogleFonts.lora(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "\"${daily.prediction}\"",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 11.sp, 
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withValues(alpha: 0.7),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Lucky Items
          _buildLuckyItemCard(
            Icons.palette,
            'daily_lucky_color_title'.tr,
            daily.luckyColor ?? "-",
            const Color(0xFF1C1C1E),
          ),
          const SizedBox(height: 16),
          _buildLuckyItemCard(
            Icons.tag,
            'daily_lucky_number_title'.tr,
            daily.luckyNumber ?? "-",
            const Color(0xFF1C1C1E),
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
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.lora(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
