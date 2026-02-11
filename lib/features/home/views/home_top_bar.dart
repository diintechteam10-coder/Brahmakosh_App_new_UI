import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common_imports.dart';
import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:brahmakosh/common/models/user_complete_details_model.dart';

class HomeTopBar extends StatefulWidget {
  const HomeTopBar({super.key});

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}
enum DayPhase { morning, afternoon, night }

class _HomeTopBarState extends State<HomeTopBar> with TickerProviderStateMixin {
  DayPhase _currentPhase = DayPhase.morning;
  Timer? _dayPhaseTimer;

  int _currentPage = 0;
  Timer? _timer;
  List<Map<String, String>> _signs = [
    {"label": "Your Moon Sign", "value": "Loading..."},
    {"label": "Your Ascendant", "value": "Loading..."},
  ];
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
   // _startDayPhaseWatcher();
    _startDayPhaseRotation();


    // Initial update if data exists
    final controller = Get.find<HomeController>();
    if (controller.userCompleteDetails != null) {
      _updateSigns(controller.userCompleteDetails);
    }

    // Listen for changes
    _worker = ever(controller.userCompleteDetailsRx, (data) {
      _updateSigns(data);
    });
  }
  String get _backgroundImage {
    switch (_currentPhase) {
      case DayPhase.morning:
        return 'assets/images/morning_background2.png';
      case DayPhase.afternoon:
        return 'assets/images/top_background.png';
      case DayPhase.night:
        return 'assets/images/night_image(3).png';
    }
  }
  // DayPhase _getDayPhaseFromTime() {
  //   final hour = DateTime.now().hour;
  //
  //   if (hour >= 5 && hour < 12) {
  //     return DayPhase.morning;
  //   } else if (hour >= 12 && hour < 18) {
  //     return DayPhase.afternoon;
  //   } else {
  //     return DayPhase.night;
  //   }
  // }

  String get _greetingText {
    switch (_currentPhase) {
      case DayPhase.morning:
        return 'Good Morning';
      case DayPhase.afternoon:
        return 'Good Afternoon';
      case DayPhase.night:
        return 'Good Night';
    }
  }

  void _startDayPhaseRotation() {
    _dayPhaseTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted) return;

      setState(() {
        if (_currentPhase == DayPhase.morning) {
          _currentPhase = DayPhase.afternoon;
        } else if (_currentPhase == DayPhase.afternoon) {
          _currentPhase = DayPhase.night;
        } else {
          _currentPhase = DayPhase.morning;
        }
      });
    });
  }
  // void _startDayPhaseWatcher() {
  //   // Set initial phase
  //   _currentPhase = _getDayPhaseFromTime();
  //
  //   _dayPhaseTimer = Timer.periodic(const Duration(minutes: 1), (_) {
  //     if (!mounted) return;
  //
  //     final newPhase = _getDayPhaseFromTime();
  //     if (newPhase != _currentPhase) {
  //       setState(() {
  //         _currentPhase = newPhase;
  //       });
  //     }
  //   });
  // }



  void _updateSigns(UserCompleteDetailsModel? data) {
    if (mounted && data?.data?.astrology?.astroDetails != null) {
      final astro = data!.data!.astrology!.astroDetails!;
      setState(() {
        _signs = [
          {"label": "Your Sign", "value": astro.sign ?? "-"},
          {"label": "Your Sign Lord", "value": astro.signLord ?? "-"},
          {"label": "Your Ascendant", "value": astro.ascendant ?? "-"},
          {"label": "Your Ascendant Lord", "value": astro.ascendantLord ?? "-"},
        ];
      });
    }
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
    _dayPhaseTimer?.cancel();
    _worker.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration:  BoxDecoration(
        image: DecorationImage(
          image: AssetImage(_backgroundImage),
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
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
                          image: AssetImage(
                            'assets/images/brahmkosh_logo.jpeg',
                          ),
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
                          "Your Spritual operating System",
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
                      MediaQuery.of(context).size.width *
                      0.6, // Responsive width
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
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
                            TextSpan(
                              text: "${_signs[_currentPage]['label']}: ",
                            ),
                            TextSpan(
                              text: _signs[_currentPage]['value'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
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
                _greetingText,
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
              // Text(
              //   "Discipline gives freedom",
              //   style: GoogleFonts.lora(
              //     fontSize: 16,
              //     fontWeight: FontWeight.bold,
              //     color: const Color(0xFF894A1E),
              //   ),
              // ),
              // const SizedBox(height: 4),
              // Text(
              //   "Clear rules make creative work easier.",
              //   style: GoogleFonts.lora(
              //     fontSize: 13,
              //     color: const Color(0xFF596072),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
