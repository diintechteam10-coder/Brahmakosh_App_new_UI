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

  static const Color _bgDark = Colors.black;
  static const Color _cardDark = Color(0xFF0F0F2D);
  static const Color _cardBorder = Color(0xFF1E1E4D);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFB0B0CC);
  static const Color _accentGold = Color(0xFFD4AF37);
  static const Color _sectionLine = Color(0xFF1E1E4D);

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
      backgroundColor: _bgDark,
      appBar: AppBar(
        title: Text(
          "Planet Positions",
          style: GoogleFonts.poppins(
            color: _textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _bgDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: _cardDark,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: _accentGold,
          unselectedLabelColor: _textSecondary,
          indicatorColor: _accentGold,
          dividerColor: _sectionLine,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
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
          style: GoogleFonts.poppins(fontSize: 16, color: _textSecondary),
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
              color: _cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _cardBorder),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [_accentGold, _accentGold.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      planet.name?.substring(0, 1) ?? "P",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _bgDark,
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
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                        ),
                      ),
                      Text(
                        planet.sign ?? "-",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "House ${planet.house}",
                  style: GoogleFonts.poppins(fontSize: 14, color: _textSecondary),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: _textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
