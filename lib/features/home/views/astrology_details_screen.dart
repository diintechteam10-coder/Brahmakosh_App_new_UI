import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:brahmakosh/core/services/storage_service.dart';

class AstrologyDetailsScreen extends StatefulWidget {
  const AstrologyDetailsScreen({super.key});

  @override
  State<AstrologyDetailsScreen> createState() => _AstrologyDetailsScreenState();
}

class _AstrologyDetailsScreenState extends State<AstrologyDetailsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  UserCompleteDetailsModel? _data;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final userId = StorageService.getString(AppConstants.keyUserId);
    if (userId != null) {
      final data = await getUserCompleteDetails(this, userId);
      if (mounted) {
        setState(() {
          _data = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6D3A0C)),
            )
          : _data?.data?.astrology == null
          ? Center(
              child: Text(
                "No Data Available",
                style: GoogleFonts.lora(color: const Color(0xFF6D3A0C)),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Birth Details"),
                  _buildBirthDetails(_data!.data!.astrology!.birthDetails!),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Astro Details"),
                  _buildAstroDetails(_data!.data!.astrology!.astroDetails!),
                  const SizedBox(height: 24),
                  _buildSectionTitle("Planetary Positions"),
                  _buildPlanetsList(_data!.data!.astrology!.planets!),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF874101),
        ),
      ),
    );
  }

  Widget _buildBirthDetails(BirthDetails details) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _buildDetailRow(
            "Date of Birth",
            "${details.day}-${details.month}-${details.year}",
          ),
          _buildDetailRow("Time of Birth", "${details.hour}:${details.minute}"),
          _buildDetailRow(
            "Location",
            "Lat: ${details.latitude}, Lon: ${details.longitude}",
          ),
          _buildDetailRow("Sunrise", "${details.sunrise}"),
          _buildDetailRow("Sunset", "${details.sunset}"),
        ],
      ),
    );
  }

  Widget _buildAstroDetails(AstroDetails details) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildInfoCard("Ascendant", details.ascendant ?? "-"),
        _buildInfoCard("Sign", details.sign ?? "-"),
        _buildInfoCard("Nakshatra", details.nakshatra ?? "-"),
        _buildInfoCard("Yog", details.yog ?? "-"),
        _buildInfoCard("Karan", details.karan ?? "-"),
        _buildInfoCard("Tithi", details.tithi ?? "-"),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDECB6).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDECB6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 12,
              color: const Color(0xFF874101).withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetsList(List<Planets> planets) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: planets.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final planet = planets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEE5D5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECB6),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    planet.name?.substring(0, 2) ?? "Pl",
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF874101),
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
                      "${planet.sign} (${planet.signLord})",
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: const Color(0xFF596072),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${planet.normDegree?.toStringAsFixed(2)}°",
                    style: GoogleFonts.lora(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  Text(
                    "House: ${planet.house}",
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      color: const Color(0xFF596072),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 14,
              color: const Color(0xFF596072),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lora(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6D3A0C),
            ),
          ),
        ],
      ),
    );
  }
}
