import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:brahmakosh/core/common_imports.dart';

class FocusView extends StatelessWidget {
  const FocusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAEBD7), // Soft antique white background
      body: Stack(
        children: [
          // Background Gradient Orbs
          Positioned(
            top: -100,
            right: -100,
            child: _buildGradientOrb(AppTheme.primaryGold.withOpacity(0.3)),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildGradientOrb(Colors.purple.withOpacity(0.2)),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildFocusGrid(),
                        const SizedBox(height: 30),
                        _buildDailyInsightCard(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientOrb(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 100,
            spreadRadius: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20),
            ),
          ),
           Text(
            'Life Focus',
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          // Spacer/Placeholder for symmetry
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Align Your Energy',
          style: GoogleFonts.lora(
            fontSize: 16,
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose an area to\nenhance today',
          style: GoogleFonts.lora(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFocusGrid() {
    final focusItems = [
      _FocusItem(
        title: 'Health',
        icon: Icons.favorite_rounded,
        color: const Color(0xffFF6B6B),
        description: 'Vitality & Wellness'
      ),
      _FocusItem(
        title: 'Relations',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xffD980FA),
        description: 'Harmony & Love'
      ),
      _FocusItem(
        title: 'Career',
        icon: Icons.work_rounded,
        color: const Color(0xff4D96FF),
        description: 'Growth & Success'
      ),
      _FocusItem(
        title: 'Finance',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xff6BCB77),
        description: 'Abundance & Wealth'
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: focusItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        return _FocusCard(item: focusItems[index]);
      },
    );
  }
  
  Widget _buildDailyInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.goldGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.deepGold, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Tip',
                  style: GoogleFonts.lora(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.deepGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Meditate for 10 mins to improving focus.',
                  style: GoogleFonts.lora(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  _FocusItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}

class _FocusCard extends StatelessWidget {
  final _FocusItem item;

  const _FocusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20), // Slightly smaller radius
        border: Border.all(
          color: Colors.white.withOpacity(0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                String route = '';
                switch (item.title) {
                  case 'Health':
                    route = AppConstants.routeFocusHealth;
                    break;
                  case 'Relations':
                    route = AppConstants.routeFocusRelations;
                    break;
                  case 'Career':
                    route = AppConstants.routeFocusCareer;
                    break;
                  case 'Finance':
                    route = AppConstants.routeFocusFinance;
                    break;
                }
                if (route.isNotEmpty) {
                  Get.toNamed(route);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), // Reduced padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12), // Reduced icon padding
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: item.color.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 28, // Reduced icon size
                      ),
                    ),
                    const SizedBox(height: 12), // Reduced spacing
                    Text(
                      item.title,
                      style: GoogleFonts.lora(
                        fontSize: 16, // Reduced font size
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                     const SizedBox(height: 4), // Reduced spacing
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      maxLines: 2, // Prevent overflow
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.lora(
                        fontSize: 11, // Reduced font size
                        color: AppTheme.textSecondary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

