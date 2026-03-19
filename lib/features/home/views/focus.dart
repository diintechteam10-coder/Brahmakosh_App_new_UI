import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/constants/app_constants.dart';
import 'package:get/get.dart';

class FocusInfoCard extends StatelessWidget {
  const FocusInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.favorite_rounded, 'Health', const Color(0xffFF6B6B)),
      (Icons.favorite_border_rounded, 'Relations', const Color(0xffD980FA)),
      (Icons.work_rounded, 'Career', const Color(0xff4D96FF)),
      (
        Icons.account_balance_wallet_rounded,
        'Finance',
        const Color(0xff6BCB77),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
         onTap: () {
           // Navigate to FocusView
           Get.toNamed(AppConstants.routeFocus);
         },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.05),
                blurRadius: 30,
                offset: const Offset(0, -5),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Focus Area',
                        style: GoogleFonts.lora(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Align your luck in your favour',
                        style: GoogleFonts.lora(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.auto_awesome,
                      color: AppTheme.primaryGold,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...items.map((item) {
                final (icon, label, color) = item;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _PremiumFocusTile(
                    icon: icon,
                    label: label,
                    color: color,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFocusTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _PremiumFocusTile({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  State<_PremiumFocusTile> createState() => _PremiumFocusTileState();
}

class _PremiumFocusTileState extends State<_PremiumFocusTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  void _toggle() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          // Usign a 3D flip effect
          final angle = _controller.value * math.pi;
          final isBack = angle > math.pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateX(angle),
            child: Container(
              height: 72, // Premium height
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: isBack
                      ? [
                          widget.color.withOpacity(0.15),
                          widget.color.withOpacity(0.05),
                        ]
                      : [Colors.grey.shade50, Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isBack
                        ? widget.color.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(
                  color: isBack
                      ? widget.color.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Transform(
                alignment: Alignment.center,
                // Fix text orientation on back flip
                transform: isBack
                    ? Matrix4.rotationX(math.pi)
                    : Matrix4.identity(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // Premium Icon Container
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          isBack ? Icons.auto_awesome_outlined : widget.icon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isBack ? "Insights Unlocked" : widget.label,
                              style: GoogleFonts.lora(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isBack
                                  ? "Tap to hide details"
                                  : "Tap to view insights",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isBack
                                    ? widget.color.withOpacity(0.8)
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action Indicator
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isBack
                              ? Colors.white.withOpacity(0.5)
                              : Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isBack
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_right_rounded,
                          color: isBack ? widget.color : Colors.grey.shade400,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
