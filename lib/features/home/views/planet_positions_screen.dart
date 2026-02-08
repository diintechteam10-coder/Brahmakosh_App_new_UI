import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/features/home/views/planet_detail_screen.dart';

class PlanetPositionsScreen extends StatefulWidget {
  final List<Planets> planets;
  final List<Planets> planetsExtended;

  const PlanetPositionsScreen({
    super.key,
    required this.planets,
    required this.planetsExtended,
  });

  @override
  State<PlanetPositionsScreen> createState() => _PlanetPositionsScreenState();
}

class _PlanetPositionsScreenState extends State<PlanetPositionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF5),
      appBar: AppBar(
        title: Text(
          "Planet Positions",
          style: GoogleFonts.lora(
            color: const Color(0xFF6D3A0C),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFFFBF5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF6D3A0C)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF6D3A0C),
          unselectedLabelColor: const Color(0xFFAFAFAF),
          indicatorColor: const Color(0xFF6D3A0C),
          labelStyle: GoogleFonts.lora(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Planets"),
            Tab(text: "Planets Extended"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlanetList(widget.planets),
          _buildPlanetList(widget.planetsExtended),
        ],
      ),
    );
  }

  Widget _buildPlanetList(List<Planets> planets) {
    if (planets.isEmpty) {
      return Center(
        child: Text(
          "No Data Available",
          style: GoogleFonts.lora(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: planets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final planet = planets[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanetDetailScreen(planet: planet),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      planet.name?.substring(0, 1) ?? "P",
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet.name ?? "-",
                        style: GoogleFonts.lora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6D3A0C),
                        ),
                      ),
                      Text(
                        planet.sign ?? "-",
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: const Color(0xFF5A6BB2),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "House ${planet.house}",
                  style: GoogleFonts.lora(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
