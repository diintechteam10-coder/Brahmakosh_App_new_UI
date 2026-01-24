import 'package:flutter/material.dart';

class PremiumBottomSection extends StatelessWidget {
  const PremiumBottomSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Explore",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              Expanded(
                child: _PremiumCard(
                  title: "Testimonials",
                  description: "Read what our happy users say",
                  icon: Icons.chat_bubble_outline,
                  gradientColors: [Color(0xFFf7971e), Color(0xFFffd200)],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PremiumCard(
                  title: "Founder Message",
                  description: "Hear from our founder directly",
                  icon: Icons.person_outline,
                  gradientColors: [Color(0xFF36d1dc), Color(0xFF5b86e5)],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _PremiumCard(
                  title: "Branding",
                  description: "Our vision & identity",
                  icon: Icons.auto_awesome,
                  gradientColors: [Color(0xFFf953c6), Color(0xFFb91d73)],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PremiumCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const _PremiumCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: gradientColors.last.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors.reversed.toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors.last.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          // Optional button
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Learn More",
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
