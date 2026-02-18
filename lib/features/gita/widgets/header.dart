import 'package:flutter/material.dart';

class GitaHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String backgroundImage;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final VoidCallback? onContinue;
  final String continueSubtitle;
  final double height;

  const GitaHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.backgroundImage,
    required this.onBack,
    required this.onMenu,
    this.onContinue,

    this.continueSubtitle = '',
    this.height = 220,
  });

  Widget _roundIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Top Image
        Stack(
          children: [
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/geeta_background.png"),
                  fit: BoxFit.cover,
                ),
                // borderRadius: const BorderRadius.only(
                //   bottomLeft: Radius.circular(20),
                //   bottomRight: Radius.circular(20),
                // ),
              ),
            ),

            /// Back
            Positioned(
              top: 30,
              left: 12,
              child: _roundIcon(
                Icons.arrow_back_ios_new_outlined,
                onBack,
              ),
            ),

            /// Menu
            Positioned(
              top: 30,
              right: 12,
              child: _roundIcon(Icons.menu, onMenu),
            ),
          ],
        ),


        /// Title + Continue
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Left text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Color(0xFF8B4513),fontWeight: FontWeight.bold),

                    ),
                  ],
                ),
              ),

              /// Continue card
                GestureDetector(
                  onTap: onContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9F2D),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Continue',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          continueSubtitle,
                          style: TextStyle(
                              color: Color(0xFF8B4513),
                              fontSize: 11,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
