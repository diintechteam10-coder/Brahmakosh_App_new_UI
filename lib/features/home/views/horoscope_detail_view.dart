import 'package:brahmakosh/core/common_imports.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class HoroscopeDetailViewColors {
  static const Color bgDark = Colors.black;
  static const Color cardDark = Color(0xFF111111);
  static const Color accentGold = Color(0xFFD4AF37);
  static const Color textMuted = Color(0xFF7A7A9E);
}

class HoroscopeDetailView extends StatefulWidget {
  const HoroscopeDetailView({super.key});

  @override
  State<HoroscopeDetailView> createState() => _HoroscopeDetailViewState();
}

class _HoroscopeDetailViewState extends State<HoroscopeDetailView> {
  final HomeController _homeController = Get.find<HomeController>();
  final RxString _activeTimeframe = "daily".obs;
  final RxString _activeCategory = "personal_life".obs;

  final ScrollController _categoryController = ScrollController();
  final List<GlobalKey> _categoryKeys = List.generate(6, (index) => GlobalKey());

  final List<Map<String, dynamic>> _aspects = [
    {"title": "personal_life", "icon": Icons.person, "color": Color(0xFFD4AF37)},
    {"title": "profession", "icon": Icons.business_center, "color": Color(0xFF42A5F5)}, // Reference "Career"
    {"title": "health", "icon": Icons.monitor_heart, "color": Color(0xFF66BB6A)},
    {"title": "emotions", "icon": Icons.favorite, "color": Color(0xFFF06292)}, // Reference "Love"
    {"title": "travel", "icon": Icons.explore, "color": Color(0xFFFF7043)},
    {"title": "luck", "icon": Icons.auto_awesome, "color": Color(0xFF9575CD)},
  ];

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  void _centerCategory(int index) {
    if (index >= 0 && index < _categoryKeys.length && _categoryKeys[index].currentContext != null) {
      Scrollable.ensureVisible(
        _categoryKeys[index].currentContext!,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HoroscopeDetailViewColors.bgDark,
      body: Obx(() {
        if (_homeController.isHoroscopeLoading) {
          return const Center(child: CircularProgressIndicator(color: HoroscopeDetailViewColors.accentGold));
        }

        final daily = _homeController.dailyHoroscope;
        final monthly = _homeController.monthlyHoroscope;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildReferenceHeader(daily?.sunSign ?? _homeController.userSign, daily, monthly),
              const SizedBox(height: 24),
              _buildTimeframeRow(),
              const SizedBox(height: 16),
              if (_activeTimeframe.value == "daily") _buildAspectTiles(),
              const SizedBox(height: 16),
              _buildPredictionCard(daily, monthly),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReferenceHeader(String sign, dynamic daily, dynamic monthly) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.only(top: 8),
        child: Stack(
          children: [
            // LARGE ZODIAC ILLUSTRATION ON RIGHT - Positioned to bleed and prevent overflow
            Positioned(
              top: 0,
              right: -30,
              child: Opacity(
                opacity: 0.6,
                child: SvgPicture.asset(
                  'assets/icons/Top zodaic sign.svg',
                  width: 160,
                  height: 160,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(HoroscopeDetailViewColors.accentGold, BlendMode.srcIn),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Color(0xFF111111), shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sign.toUpperCase(),
                        style: GoogleFonts.lora(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: HoroscopeDetailViewColors.accentGold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "personal_horoscope".tr,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, color: Colors.white54, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            _activeTimeframe.value == "monthly"
                                ? (monthly?.predictionMonth ?? "")
                                : (daily?.predictionDate ?? DateTime.now().toString().split(' ')[0]),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10), // Padding to clear the image height if necessary
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeframeRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HoroscopeDetailViewColors.accentGold, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: ["daily", "monthly"].map((mode) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _activeTimeframe.value = mode,
                child: Obx(() {
                  final isActive = _activeTimeframe.value == mode;
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [Color(0xFFF7D15A), Color(0xFFD4AF37)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null,
                      color: isActive ? null : Colors.transparent,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      border: isActive
                          ? null
                          : Border.all(color: HoroscopeDetailViewColors.accentGold.withOpacity(0.4)),
                    ),
                    child: Center(
                      child: Text(
                        mode.tr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isActive ? Colors.black : HoroscopeDetailViewColors.accentGold.withOpacity(0.8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAspectTiles() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        controller: _categoryController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _aspects.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final aspect = _aspects[index];
          return Obx(() {
            final isActive = _activeCategory.value == aspect["title"];
            return GestureDetector(
              key: _categoryKeys[index],
              onTap: () {
                _activeCategory.value = aspect["title"];
                _centerCategory(index);
              },
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: (aspect["color"] as Color).withOpacity(isActive ? 0.3 : 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (aspect["color"] as Color).withOpacity(isActive ? 1.0 : 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(aspect["icon"] as IconData, color: aspect["color"] as Color, size: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    (aspect["title"] as String).tr,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildPredictionCard(dynamic daily, dynamic monthly) {
    String title = _activeCategory.value;
    String content = "";

    if (_activeTimeframe.value == "monthly") {
      title = monthly?.predictionMonth?.toUpperCase() ?? "monthly_report".tr;
      content = monthly?.prediction?.join("\n\n") ?? "gathering_trends".tr;
    } else {
      // DAILY
      switch (_activeCategory.value) {
        case "personal_life":
          content = daily?.prediction?.personalLife ?? "";
          break;
        case "emotions":
          content = daily?.prediction?.emotions ?? "";
          break;
        case "profession":
          content = daily?.prediction?.profession ?? "";
          break;
        case "health":
          content = daily?.prediction?.health ?? "";
          break;
        case "travel":
          content = daily?.prediction?.travel ?? "";
          break;
        case "luck":
          content = daily?.prediction?.luck ?? "";
          break;
        default:
          content = "calculating_alignment".tr;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF222222)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.tr,
              style: GoogleFonts.lora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Text(
              content.isEmpty ? "preparing_insights".tr : content,
              style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13.sp, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
