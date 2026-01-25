import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common_imports.dart';

class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  int _currentPage = 0;
  Timer? _timer;
  final List<Map<String, String>> _signs = [
    {"label": "Your Moon Sign", "value": "Leo"},
    {"label": "Your Sun Sign", "value": "Sagittarius"},
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentPage = (_currentPage + 1) % _signs.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/brahmkosh_logo.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "BRAHMAKOSH",
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3A0C), // Dark Brown
                      ),
                    ),
                    Text(
                      "Your Spiritual operating System",
                      style: GoogleFonts.lora(
                        fontSize: 10,
                        color: const Color(0xFF874101),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 40,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF6D3A0C),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // Added space from top as requested
          Center(
            child: Container(
              height: 30,
              width:
                  MediaQuery.of(context).size.width * 0.6, // Responsive width
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                  child: RichText(
                    key: ValueKey<int>(_currentPage),
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: GoogleFonts.lora(
                        fontSize: 12,
                        color: const Color(0xFF596072),
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(text: "${_signs[_currentPage]['label']}: "),
                        TextSpan(
                          text: _signs[_currentPage]['value'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Good Morning",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Here' your daily Insights!",
            style: GoogleFonts.lora(
              fontSize: 13,
              color: const Color(0xFF596072),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Discipline gives freedom",
            style: GoogleFonts.lora(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF894A1E),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Clear rules make creative work easier.",
            style: GoogleFonts.lora(
              fontSize: 13,
              color: const Color(0xFF596072),
            ),
          ),
        ],
      ),
    );
  }
}
