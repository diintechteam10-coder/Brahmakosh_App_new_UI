import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/common_imports.dart';

class CustomBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNavBar> createState() => _CustomBottomNavBarState();
}

class _CustomBottomNavBarState extends State<CustomBottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Rotation animation for center button
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _rotationAnimation = Tween<double>(begin: 0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Pulse animation for center button when selected
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isRashmiSelected = widget.currentIndex == 2;

    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SizedBox(
      height:
          110 +
          bottomPadding, // Increased height to include the floating button and bottom padding
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Bottom Navigation Background & Items
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 70 + bottomPadding,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4 + bottomPadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildNavItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      index: 0,
                    ),
                    _buildNavItem(
                      icon: Icons.search_rounded,
                      svgPath: 'assets/images/checked.png',
                      label: 'Check-In',
                      index: 1,
                    ),
                    const SizedBox(width: 70),
                    _buildNavItem(
                      icon: Icons.self_improvement_rounded,
                      label: 'Connect',
                      index: 3,
                    ),
                    _buildNavItem(
                      icon: Icons.card_giftcard_rounded,
                      label: 'Remedies',
                      index: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Center Floating Button
          Positioned(
            top: 0,
            child: GestureDetector(
              onTap: () => widget.onTap(2),
              behavior: HitTestBehavior.opaque, // Ensure taps are caught
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _rotationAnimation,
                      _pulseAnimation,
                    ]),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isRashmiSelected ? _pulseAnimation.value : 1.0,
                        child: Transform.rotate(
                          angle: isRashmiSelected
                              ? _rotationAnimation.value
                              : 0,
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isRashmiSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primaryGold,
                                        AppTheme.darkGold,
                                        AppTheme.deepGold,
                                      ],
                                    )
                                  : const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.lightGold,
                                        AppTheme.primaryGold,
                                      ],
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withOpacity(
                                    isRashmiSelected ? 0.7 : 0.4,
                                  ),
                                  blurRadius: isRashmiSelected ? 20 : 15,
                                  offset: const Offset(0, 6),
                                  spreadRadius: isRashmiSelected ? 3 : 2,
                                ),
                                if (isRashmiSelected)
                                  BoxShadow(
                                    color: AppTheme.primaryGold.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 0),
                                    spreadRadius: 5,
                                  ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ring
                                if (isRashmiSelected)
                                  Container(
                                    width: 70,
                                    height: 70,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppTheme.primaryGold.withOpacity(
                                          0.3,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                // Icon
                                ClipOval(
                                  child: SizedBox(
                                    width: 70,
                                    height: 70,
                                    child: Image.asset(
                                      'assets/images/brahmkosh_logo.jpeg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ask BI',
                    style: GoogleFonts.cinzel(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isRashmiSelected
                          ? AppTheme.primaryGold
                          : AppTheme.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    String? svgPath,
    required String label,
    required int index,
  }) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => widget.onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          svgPath != null
              ? Image.asset(
                  svgPath,

                  height: isSelected ? 24 : 22,
                  width: isSelected ? 24 : 22,
                )
              : Icon(
                  icon,
                  color: isSelected
                      ? AppTheme.primaryGold
                      : AppTheme.textSecondary,
                  size: isSelected ? 24 : 22,
                ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.cinzel(
              fontSize: isSelected ? 11 : 10,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? AppTheme.primaryGold : AppTheme.textSecondary,
              letterSpacing: 0.3,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
