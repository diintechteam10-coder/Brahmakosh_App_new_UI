import 'package:flutter/material.dart';

class DeitySelectionWidget extends StatelessWidget {
  final VoidCallback onSelectKrishna;
  final VoidCallback onSelectRashmi;

  const DeitySelectionWidget({
    super.key,
    required this.onSelectKrishna,
    required this.onSelectRashmi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF18151B), // Dark theme background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive layout: Row for wide screens, Column for very narrow (though Row usually fits on mobile for 2 items)
          // Actually, design shows a Row.
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDeityCard(
                context,
                "Ask Krishna",
                "assets/images/Small_krishna.png",
                onSelectKrishna,
              ),
              const SizedBox(width: 16),
              _buildDeityCard(
                context,
                "Ask Rashmi",
                "assets/images/Small_rashmi.png",
                onSelectRashmi,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeityCard(
    BuildContext context,
    String title,
    String imagePath,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          // Fixed aspect ratio or height to look like a card
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF100E13), // Darker card background
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFFF1C453),
                      );
                    },
                  ),
                ),
              ),
              // Text
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
