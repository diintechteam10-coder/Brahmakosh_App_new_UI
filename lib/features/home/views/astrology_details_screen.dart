import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';
import 'package:brahmakosh/features/home/views/planet_positions_screen.dart';
import 'package:brahmakosh/features/home/widgets/astrology_tabs.dart';

class AstrologyDetailsScreen extends StatefulWidget {
  const AstrologyDetailsScreen({super.key});

  @override
  State<AstrologyDetailsScreen> createState() => _AstrologyDetailsScreenState();
}

class _AstrologyDetailsScreenState extends State<AstrologyDetailsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  UserCompleteDetailsModel? _data;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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

    /* // Temporarily bypass cache for debugging
    final cachedData = StorageService.getString('astrology_data_$userId');
    if (cachedData != null) {
      try {
        final jsonMap = jsonDecode(cachedData);
        final data = UserCompleteDetailsModel.fromJson(jsonMap);
        if (mounted) {
          setState(() {
            _data = data;
            _isLoading = false;
          });
        }
        return;
      } catch (e) {
        debugPrint("Error parsing cached astrology data: $e");
      }
    }
    */

    // Fetch from API if not cached or error parsing
    final data = await getUserCompleteDetails(this, userId);

    if (data != null) {
      // Cache the data
      // Note: Assuming getUserCompleteDetails returns the model directly.
      // If we want to cache the raw JSON, we might need to adjust the service or serialize the model back to JSON.
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
    debugPrint("ASTROLOGY_DEBUG: _data != null: ${_data != null}");
    debugPrint("ASTROLOGY_DEBUG: _data.data != null: ${_data?.data != null}");
    debugPrint(
      "ASTROLOGY_DEBUG: _data.data.astrology != null: ${_data?.data?.astrology != null}",
    );
    debugPrint(
      "ASTROLOGY_DEBUG: _data.data.doshas != null: ${_data?.data?.doshas != null}",
    );
    debugPrint(
      "ASTROLOGY_DEBUG: _data.data.dashas != null: ${_data?.data?.dashas != null}",
    );

    final astro = _data?.data?.astrology;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6D3A0C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Astrology Details",
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6D3A0C),
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6D3A0C)),
            )
          : astro == null
          ? Center(child: Text("No Data", style: GoogleFonts.lora()))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: _buildSummaryCard(astro),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD4A373).withOpacity(0.3),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFF6D3A0C),
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: const Color(0xFFD4A373),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    isScrollable: false,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                    padding: EdgeInsets.zero,
                    labelStyle: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: "Basic Info"),
                      Tab(text: "Planets"),
                      Tab(text: "Birth Chart"),
                      Tab(text: "Doshas"),
                      Tab(text: "Dashas"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      BasicInfoTab(
                        astroDetails: astro.astroDetails ?? AstroDetails(),
                      ),
                      PlanetsTab(
                        planets: astro.planets ?? [],
                        onViewAllTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlanetPositionsScreen(
                                planets: astro.planets ?? [],
                                planetsExtended: astro.planetsExtended ?? [],
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
                      DoshasTab(doshas: _data?.data?.doshas ?? Doshas()),
                      DashasTab(dashas: _data?.data?.dashas ?? Dashas()),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryCard(Astrology astro) {
    final astroDetails = astro.astroDetails;
    final birthDetails = astro.birthDetails;
    // Attempt to get name from data, default to "Personal Horoscope" if null
    final userName = _data?.data?.user?.profile?.name ?? "User";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D9), // Light pastel orange/beige
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF0D9), Color(0xFFFFE0B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            userName,
            style: GoogleFonts.lora(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5D4037),
            ),
          ),
          Text(
            "Personal Horoscope",
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFF8D6E63),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.nightlight_round,
                  title: "Moon Sign",
                  value: astroDetails?.sign ?? "-",
                  color: const Color(0xFF5E35B1), // Deep Purple
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.star, // Placeholder for Virgo-like symbol
                  title:
                      "Sun Sign", // Assuming Virgo refers to Sun/Ascendant or just another sign data
                  value:
                      astroDetails?.ascendant ??
                      "-", // Using Ascendant as secondary important sign
                  color: const Color(0xFF546E7A), // Blue Grey
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.auto_awesome,
                  title: "Nakshatra",
                  value: astroDetails?.nakshatra ?? "-",
                  color: const Color(0xFFFFB74D), // Orange
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryItem(
                  icon: Icons.public,
                  title: "Ruling Planet",
                  value:
                      astroDetails?.signLord ??
                      "-", // Usually sign lord is considered ruling
                  color: const Color(0xFFE57373), // Red
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Color(0xFF8D6E63),
              ),
              const SizedBox(width: 6),
              Text(
                "${birthDetails?.day} ${_getMonthName(birthDetails?.month)} ${birthDetails?.year}, ${birthDetails?.hour}:${birthDetails?.minute}",
                style: GoogleFonts.lora(
                  fontSize: 12,
                  color: const Color(0xFF8D6E63),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFF8D6E63)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Lat: ${birthDetails?.latitude}, Lon: ${birthDetails?.longitude}",
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: const Color(0xFF8D6E63),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lora(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int? month) {
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
    if (month != null && month >= 1 && month <= 12) {
      return months[month - 1];
    }
    return "";
  }
}
