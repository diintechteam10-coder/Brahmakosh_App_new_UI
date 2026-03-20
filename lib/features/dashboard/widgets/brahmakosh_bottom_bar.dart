import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class BrahmakoshBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BrahmakoshBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final double barHeight = 64;

    return Container(
      margin: EdgeInsets.only(
        left: 15,
        right: 15,
        bottom: bottomPadding > 0 ? bottomPadding : 15,
      ),
      height: barHeight + 30, // Extra height for the floating logo
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Painter
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width, barHeight),
                painter: BottomBarPainter(),
              ),
            ),
          ),
          
          // Center Logo (Ask BI) - Positioned higher
          Positioned(
            top: -15,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 75,
                  height: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/brahmkosh_logo.jpeg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Navigation Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: barHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                   _buildNavItem(0, 'assets/icons/home_new.svg', 'Home'),
                   _buildNavItem(1, 'assets/icons/check_in_new.svg', 'Check - In'),
                   
                   // Center Spacer for Ask BI
                   const Expanded(child: SizedBox()),
                   
                   _buildNavItem(3, 'assets/icons/connect_new.svg', 'Connect'),
                   _buildNavItem(4, 'assets/icons/cart_new.svg', 'Remedies'),
                ],
              ),
            ),
          ),
          
          // Separate "Ask BI" text to sit lower than the logo
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Ask BI',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: currentIndex == 2 ? FontWeight.w600 : FontWeight.w400,
                  color: currentIndex == 2 ? AppTheme.primaryGold : Colors.white60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath, String label) {
    final isSelected = currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              colorFilter: ColorFilter.mode(
                isSelected ? AppTheme.primaryGold : Colors.grey[400]!,
                BlendMode.srcIn
              ),
              width: 20,
              height: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryGold : Colors.white60,
              ),
            ),
            const SizedBox(height: 4),
            // Selection Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 24 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomBarPainter extends CustomPainter {
  final double dipWidth;   // How wide the opening is
  final double dipDepth;   // How deep the curve goes
  final double dipRadius;  // The smoothness/tension of the curve

  BottomBarPainter({
    this.dipWidth = 40.0, 
    this.dipDepth = 28.0, 
    this.dipRadius = 15.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF2C2C2E)
      ..style = PaintingStyle.fill;

    double h = size.height;
    double w = size.width;
    double cx = w / 2;

    Path path = Path();
    
    // Start at top-left
    path.moveTo(h / 2, 0);

    // Line to the start of the "shoulder" (Left side)
    path.lineTo(cx - dipWidth - dipRadius, 0);

    // Inner Curve (Left side to Center)
    path.cubicTo(
      cx - dipWidth, 0,               // First control point
      cx - dipWidth + 5, dipDepth,    // Second control point
      cx, dipDepth,                   // Endpoint (bottom of the dip)
    );

    // Inner Curve (Center to Right side)
    path.cubicTo(
      cx + dipWidth - 5, dipDepth,    // First control point
      cx + dipWidth, 0,               // Second control point
      cx + dipWidth + dipRadius, 0,   // Endpoint
    );

    // Complete the Pill Shape
    path.lineTo(w - (h / 2), 0);
    path.arcToPoint(Offset(w, h / 2), radius: Radius.circular(h / 2));
    path.arcToPoint(Offset(w - (h / 2), h), radius: Radius.circular(h / 2));
    path.lineTo(h / 2, h);
    path.arcToPoint(Offset(0, h / 2), radius: Radius.circular(h / 2));
    path.arcToPoint(Offset(h / 2, 0), radius: Radius.circular(h / 2));
    path.close();

    canvas.drawShadow(path, Colors.black, 10, false);
    canvas.drawPath(path, paint);
    
    // Border highlight
    canvas.drawPath(
      path, 
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
    );
  }

  @override
  bool shouldRepaint(covariant BottomBarPainter oldDelegate) {
    return oldDelegate.dipWidth != dipWidth || 
           oldDelegate.dipDepth != dipDepth || 
           oldDelegate.dipRadius != dipRadius;
  }
}
