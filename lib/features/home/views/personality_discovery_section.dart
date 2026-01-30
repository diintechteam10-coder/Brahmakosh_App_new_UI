import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalityDiscoverySection extends StatefulWidget {
  const PersonalityDiscoverySection({super.key});

  @override
  State<PersonalityDiscoverySection> createState() =>
      _PersonalityDiscoverySectionState();
}

class _PersonalityDiscoverySectionState
    extends State<PersonalityDiscoverySection> {
  int _selectedIndex = 0;
  final List<String> _tabs = [
    "Health",
    "Emotions",
    "Profession",
    "Luck",
    "Personal Life",
    "Travel",
  ];

  final Map<String, List<Color>> _tabColors = {
    "Health": [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)], // Green
    "Emotions": [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)], // Blue
    "Profession": [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)], // Purple
    "Luck": [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)], // Amber
    "Personal Life": [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)], // Pink
    "Travel": [const Color(0xFFFFF3E0), const Color(0xFFFFCC80)], // Orange
  };

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Personality & Self-Discovery",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_tabs.length, (index) {
                final isSelected = _selectedIndex == index;
                // Use the first color of the gradient for the selected tab background
                // or a default selection color if logic differs
                final selectedColor = _tabColors[_tabs[index]]![0];

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? selectedColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      _tabs[index],
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF6D3A0C)
                            : const Color(0xFF596072),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final panchang = homeController.panchangData;
            final prediction = panchang?.dailyNakshatraPrediction?.prediction;
            String content = "Loading...";

            if (prediction != null) {
              switch (_tabs[_selectedIndex]) {
                case "Health":
                  content = prediction.health ?? "No data";
                  break;
                case "Emotions":
                  content = prediction.emotions ?? "No data";
                  break;
                case "Profession":
                  content = prediction.profession ?? "No data";
                  break;
                case "Luck":
                  content = prediction.luck ?? "No data";
                  break;
                case "Personal Life":
                  content = prediction.personalLife ?? "No data";
                  break;
                case "Travel":
                  content = prediction.travel ?? "No data";
                  break;
              }
            } else if (!homeController.isPanchangLoading && panchang == null) {
              content = "Data unavailable";
            }

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _tabColors[_tabs[_selectedIndex]]!,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: _tabColors[_tabs[_selectedIndex]]![0].withOpacity(
                      0.5,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _tabs[_selectedIndex],
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6D3A0C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 1,
                    width: 60,
                    color: const Color(0xFF6D3A0C).withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    content,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: const Color(0xFF6D3A0C),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
