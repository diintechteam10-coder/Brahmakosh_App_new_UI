import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CheckInView extends StatelessWidget {
  const CheckInView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFDF8), Color(0xffFFF2D9), Color(0xffFFE4B5)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: Color(0xff7B4A12),
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, color: Color(0xff7B4A12)),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                /// 🔱 App Title
                Text(
                  'BRAHMAKOSH',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: const Color(0xff7B4A12),
                  ),
                ),

                const SizedBox(height: 4),

                /// #AreYouSpiritual
                Text(
                  '#AreYouSpiritual',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff7B4A12),
                  ),
                ),

                const SizedBox(height: 18),

                /// Subtitle
                Text(
                  'Take a moment for yourself',
                  style: GoogleFonts.lora(fontSize: 16, color: Colors.black87),
                ),

                const SizedBox(height: 6),

                Text(
                  'CHECK-IN OPTIONS',
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff7B4A12),
                  ),
                ),

                const SizedBox(height: 24),

                /// 🧘 Cards Grid
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, // 🔥 More side padding for smaller cards
                  ),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20, // 🔥 More horizontal gap
                    mainAxisSpacing: 20, // 🔥 More vertical gap
                    childAspectRatio: 1.1, // 🔥 More squared/smaller
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _card(
                        lottiePath: 'assets/lotties/Meditating.json',
                        title: 'MEDITATE',
                        onTap: () {
                          print("Selected Mood: Happy");

                          Get.toNamed(AppConstants.routeMeditate);
                        },
                      ),
                      _card(
                        image: 'assets/images/pray.png',
                        title: 'PRAY',
                        onTap: () {
                          print("Selected Mood: Happy");

                          Get.toNamed(AppConstants.routeMeditate);
                        },
                      ),
                      _card(
                        image: 'assets/images/chant.png',
                        title: 'CHANT',
                        onTap: () {
                          Get.toNamed(AppConstants.routeMantraChanting);
                        },
                      ),
                      _card(
                        image: 'assets/images/silence.png',
                        title: 'SILENCE',
                        onTap: () {
                          print("Selected Mood: Happy");

                          Get.toNamed(AppConstants.routeMeditate);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                /// ⭐ Karma
                Text('😊 😊 😊', style: const TextStyle(fontSize: 18)),

                const SizedBox(height: 4),

                Text(
                  'Earn Karma points',
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff7B4A12),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'With Each Check-In',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'No Pressure Any One Is Enough',
                  style: GoogleFonts.lora(fontSize: 13, color: Colors.black54),
                ),

                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// ✅ Left – 100
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '100',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),

                      /// 🪙 Right – Coins
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on,
                            size: 18,
                            color: Color(0xffC9A24D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '1,452',
                            style: GoogleFonts.lora(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({
    String? image,
    String? lottiePath,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xff7B4A12).withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              blurRadius: 4,
              color: const Color(0xff7B4A12).withOpacity(0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (lottiePath != null)
              Lottie.asset(lottiePath, height: 50) // Reduced height
            else if (image != null)
              Image.asset(image, height: 40), // Reduced height
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cinzel(
                fontSize: 11, // Slightly smaller text
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: const Color(0xff5D3A1A), // Softer brown
              ),
            ),
          ],
        ),
      ),
    );
  }
}
