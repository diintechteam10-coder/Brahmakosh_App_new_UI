import 'package:flutter/material.dart';
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
  final List<String> _tabs = ["Health", "Profession", "Career", "Relationship"];

  @override
  Widget build(BuildContext context) {
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
                      color: isSelected
                          ? const Color(0xFFFDECB6)
                          : Colors.transparent,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.1),
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
                  "Anxiety can be the cause of some health related problems today. You tend to worry too much. Boost your immunity and mental strength with yoga and meditation.",
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
          ),
        ],
      ),
    );
  }
}
