import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/home/views/planet_positions_screen.dart';
import 'package:brahmakosh/features/home/widgets/astrology_tabs.dart';
import 'package:brahmakosh/features/home/widgets/ashtakvarga_tab.dart';
import 'package:brahmakosh/features/home/widgets/remedies_tab.dart';

import '../widgets/sarvashtak_tab.dart';

class AstrologyDetailsScreen extends StatefulWidget {
  const AstrologyDetailsScreen({super.key});

  @override
  State<AstrologyDetailsScreen> createState() => _AstrologyDetailsScreenState();
}

class DetailsScreenColors {
  static const Color bgDark = Colors.black;
  static const Color cardDark = Color(0xFF1A1A3E);
  static const Color cardBorder = Color(0xFF2A2A5A);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0CC);
  static const Color textMuted = Color(0xFF7A7A9E);
  static const Color accentGold = Color(0xFFD4A373);
  static const Color tabSelected = Colors.white;
  static const Color tabUnselected = Color(0xFF7A7A9E);
  static const Color sectionLine = Color(0xFF2A2A5A);
}

class _AstrologyDetailsScreenState extends State<AstrologyDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  UserCompleteDetailsModel? _data;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final userId = StorageService.getString(AppConstants.keyUserId);
    if (userId == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    final data = await getUserCompleteDetails(this, userId);

    if (data != null) {
      try {
        StorageService.setString(
          'astrology_data_$userId',
          jsonEncode(data.toJson()),
        );
      } catch (e) {
        debugPrint("Error caching astrology data: $e");
      }
    }

    if (mounted) {
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final astro = _data?.data?.astrology;

    return Scaffold(
      backgroundColor: DetailsScreenColors.bgDark,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: DetailsScreenColors.accentGold,
              ),
            )
          : astro == null
              ? Center(
                  child: Text(
                    "No Data",
                    style: GoogleFonts.lora(
                      color: DetailsScreenColors.textPrimary,
                    ),
                  ),
                )
              : Column(
                  children: [
                    _buildHeader(astro),
                    _buildTabBar(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          BasicInfoTab(
                            astroDetails:
                                astro.astroDetails ?? AstroDetails(),
                            ghatChakra: astro.ghatChakra,
                            ayanamsha: astro.ayanamsha,
                          ),
                          PlanetsTab(
                            planets: astro.planets ?? [],
                            onViewAllTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PlanetPositionsScreen(
                                    planets: astro.planets ?? [],
                                    planetsExtended:
                                        astro.planetsExtended ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                          BirthChartTab(
                            birthChart: astro.birthChart!,
                            birthExtendedChart: astro.birthExtendedChart,
                            astroDetails: astro.astroDetails,
                          ),
                          BhavChalitTab(
                            bhavMadhya:
                                astro.bhavMadhya ?? BhavMadhya(),
                          ),
                          DoshasTab(
                            doshas: _data?.data?.doshas ?? Doshas(),
                            sadhesatiLifeDetails:
                                astro.sadhesatiLifeDetails,
                            pitraDoshaReport: astro.pitraDoshaReport,
                          ),
                          DashasTab(dashas: _getEffectiveDashas()),
                          SarvashtakTab(
                            sarvashtak:
                                astro.sarvashtak ?? SarvAshtak(),
                            ascendantSign:
                                astro.astroDetails?.ascendant,
                          ),
                          AshtakvargaTab(
                            planetAshtak: astro.planetAshtak,
                            ascendantSign:
                                astro.astroDetails?.ascendant,
                          ),
                          RemediesTab(
                            gemstoneSuggestion:
                                astro.gemstoneSuggestion,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHeader(Astrology astro) {
    final astroDetails = astro.astroDetails;
    final userName = _data?.data?.user?.profile?.name ?? "User";

    return SafeArea(
      bottom: false,
      // top: false,
      child: Stack(
        children: [
          // Background zodiac decoration
          Positioned(
            top: -6,
            right: -100,
            child: Opacity(
              opacity: 0.4,
              child: SvgPicture.asset(
                'assets/icons/Top zodaic sign.svg',
                width: 130,
                height: 130,
                // colorFilter: const ColorFilter.mode(
                //   Colors.white,
                //   BlendMode.srcIn,
                // ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: DetailsScreenColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: DetailsScreenColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Personal Horoscope",
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: DetailsScreenColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Info chips - Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              iconAsset: 'assets/icons/moon.png',
                              title: "Moon Sign",
                              value: astroDetails?.sign ?? "-",
                              gradientColors: const [
                                Color(0xFF2D1B69),
                                Color(0xFF1A1145),
                              ],
                              borderColor: const Color(0xFF4A3399),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInfoChip(
                              iconAsset: 'assets/icons/sun.png',
                              title: "Sun Sign",
                              value: astroDetails?.ascendant ?? "-",
                              gradientColors: const [
                                Color(0xFF2D1B69),
                                Color(0xFF1A1145),
                              ],
                              borderColor: const Color(0xFF4A3399),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Info chips - Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip(
                              iconAsset: 'assets/icons/star.png',
                              title: "Nakshatra",
                              value: astroDetails?.nakshatra ?? "-",
                              gradientColors: const [
                                Color(0xFF2D1B69),
                                Color(0xFF1A1145),
                              ],
                              borderColor: const Color(0xFF4A3399),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInfoChip(
                              iconAsset: 'assets/icons/planet.png',
  
                              title: "Ruling Planet",
                              value: astroDetails?.signLord ?? "-",
                              gradientColors: const [
                                Color(0xFF2D1B69),
                                Color(0xFF1A1145),
                              ],
                              borderColor: const Color(0xFF4A3399),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required String iconAsset,
    required String title,
    required String value,
    required List<Color> gradientColors,
    required Color borderColor,
  }) {
    return SizedBox(
      height: 66,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withOpacity(0.5), width: 1),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: Image.asset(
                iconAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 10,
                      color: DetailsScreenColors.textMuted,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: DetailsScreenColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildTabBar() {
  final List<String> tabTitles = [
    "BASIC INFO", "PLANETS", "BIRTH CHART", "BHAV CHALIT",
    "DOSHAS", "DASHAS", "SARVASHTAK", "ASHTAKVARGA", "REMEDIES"
  ];

  return Container(
    // This is the main bottom line
    decoration: const BoxDecoration(
      border: Border(
        bottom: BorderSide(
          color: Color(0xFF6B4EFF),
          width: 1.5,
        ),
      ),
    ),
    child: TabBar(
      tabAlignment: TabAlignment.start,
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF8A8A8D),
      indicatorSize: TabBarIndicatorSize.label,
      // We set the indicator to transparent because we are 
      // drawing the "active" look inside the AnimatedBuilder
      indicator: const BoxDecoration(), 
      dividerColor: Colors.transparent,
      isScrollable: true,
      
      // CRITICAL: Remove extra padding that causes the "gap"
      labelPadding: EdgeInsets.zero, 
      padding: const EdgeInsets.symmetric(horizontal: 16),
      
      tabs: tabTitles.asMap().entries.map((entry) {
        final title = entry.value;
        final index = entry.key;
        return Tab(
          height: 30, // Increased slightly to match the UI feel
          child: AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              // Use indexIsChanging to handle the animation state correctly
              final isSelected = _tabController.index == index;
              
              return Container(
                margin: const EdgeInsets.only(right: 8), // Gap between tabs
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6B4EFF) : Colors.transparent,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  border: Border.all(
                    color: const Color(0xFF6B4EFF),
                    width: 1.5,
                  ),
                ),
                // This offset moves the tab down by 1.5px to overlap 
                // the parent container's bottom border
                transform: Matrix4.translationValues(0, 1.5, 0),
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    ),
  );
}


  Dashas _getEffectiveDashas() {
    final topLevelDashas = _data?.data?.dashas;
    final astro = _data?.data?.astrology;

    return Dashas(
      currentYogini:
          topLevelDashas?.currentYogini ?? astro?.astrologyCurrentYoginiDasha,
      currentChardasha:
          topLevelDashas?.currentChardasha ?? astro?.astrologyCurrentChardasha,
      majorChardasha:
          topLevelDashas?.majorChardasha ?? astro?.astrologyMajorChardasha,
      vimshottariDasha:
          topLevelDashas?.vimshottariDasha ??
          astro?.majorVdasha
              ?.map(
                (v) => VimshottariDasha(
                  planet: v.planet,
                  start: v.start,
                  end: v.end,
                ),
              )
              .toList(),
      currentVdasha: topLevelDashas?.currentVdasha ?? astro?.currentVdasha,
      currentVdashaAll:
          topLevelDashas?.currentVdashaAll ?? astro?.currentVdashaAll,
    );
  }
}
