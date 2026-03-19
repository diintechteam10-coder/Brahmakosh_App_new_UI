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
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundIcon(
                Icons.arrow_back_ios_new_outlined,
                onBack,
              ),
              _roundIcon(Icons.menu, onMenu),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF1C453), // Gold text
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              // Continue Card
              if (onContinue != null)
                GestureDetector(
                  onTap: onContinue,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1C453), // Gold button
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          continueSubtitle,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: WavyDivider(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class WavyDivider extends StatelessWidget {
  const WavyDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 12,
      width: double.infinity,
      child: CustomPaint(
        painter: WavyPainter(),
      ),
    );
  }
}

class WavyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    var path = Path();
    double waveWidth = 10.0;
    double waveHeight = 4.5;

    path.moveTo(0, size.height / 2);

    for (double i = 0; i < size.width; i += waveWidth) {
      path.quadraticBezierTo(
          i + waveWidth / 4, size.height / 2 - waveHeight,
          i + waveWidth / 2, size.height / 2);
      path.quadraticBezierTo(
          i + waveWidth * 3 / 4, size.height / 2 + waveHeight,
          i + waveWidth, size.height / 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
