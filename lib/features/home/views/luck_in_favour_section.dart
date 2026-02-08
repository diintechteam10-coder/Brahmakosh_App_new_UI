import 'package:brahmakosh/features/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LuckInFavourSection extends StatelessWidget {
  const LuckInFavourSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController homeController = Get.find<HomeController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Luck in Favour",
            style: GoogleFonts.lora(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF6D3A0C),
            ),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final prediction =
                homeController.panchangData?.numeroDailyPrediction;

            // Default to '--' and empty/grey if API response is null or loading
            final luckyNumber = prediction?.luckyNumber ?? '';
            final luckyColor = prediction?.luckyColor ?? '';

            return Row(
              children: [
                Expanded(
                  child: _buildCard(
                    title: "Lucky Number",
                    frontImagePath: 'assets/images/yourLuckyNumber_card.png',
                    backImagePath:
                        'assets/images/YourLuckyNumberVisible_card.png',
                    backContent: Text(
                      luckyNumber,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 64, // Larger font as per example
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6D3A0C), // Dark brown/gold
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCard(
                    title: "Lucky Color",
                    frontImagePath: 'assets/images/yourLuckyColor_card.png',
                    backImagePath:
                        'assets/images/yourLuckyColorVisible_card.png',
                    backContent: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _parseColor(luckyColor).withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: _parseColor(luckyColor).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'pink':
        return Colors.pink;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'white':
        return Colors.white;
      case 'black':
        return Colors.black;
      case 'brown':
        return Colors.brown;
      case 'cyan':
        return Colors.cyan;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      default:
        return Colors.green; // Default fallback
    }
  }

  Widget _buildCard({
    required String title,
    required String frontImagePath,
    required String backImagePath,
    required Widget backContent,
  }) {
    return _FlipCard(
      front: _buildFrontCard(frontImagePath),
      back: _buildBackCard(title, backImagePath, backContent),
    );
  }

  Widget _buildFrontCard(String imagePath) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
          height: 300,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildBackCard(String title, String imagePath, Widget content) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.fill)),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 40.0,
                ), // Adjust for text position
                child: content,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  final Widget front;
  final Widget back;

  const _FlipCard({required this.front, required this.back});

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      _isFront = !_isFront;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.14159;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: _animation.value < 0.5
                ? widget.front
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: widget.back,
                  ),
          );
        },
      ),
    );
  }
}
