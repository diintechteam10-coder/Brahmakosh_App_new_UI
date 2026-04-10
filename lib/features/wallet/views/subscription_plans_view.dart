import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView> {
  int _selectedPlanIndex = 0;
  bool _isYearly = false;

  final List<Map<String, dynamic>> _subscriptions = [
    {
      "name": "Jigyashu",
      "type": "FREEMIUM",
      "basePrice": 0,
      "icon": Icons.spa_outlined,
      "features": [
        "100 Credits",
        "Krishna talk 5 minute",
        "Ask Rashmi 10 questions",
        "Expert chat 5 questions",
      ],
      "color": Colors.white70,
    },
    {
      "name": "Seeker",
      "type": "PREMIUM",
      "basePrice": 499,
      "icon": Icons.self_improvement,
      "features": [
        "500 Credits",
        "Krishna talk 30 minute",
        "Ask Rashmi 50 questions",
        "Expert chat 20 questions",
      ],
      "color": const Color(0xFFFF9800), // Vibrant Saffron
      "recommended": false,
    },
    {
      "name": "Sadhak",
      "type": "PREMIUM",
      "basePrice": 999,
      "icon": Icons.workspace_premium,
      "features": [
        "1000 Credits",
        "Krishna talk 60 minute",
        "Ask Rashmi 100 questions",
        "Expert chat 50 questions",
        "Priority Support",
      ],
      "color": AppTheme.primaryGold, // Classy Gold
      "recommended": true,
    },
    {
      "name": "Brahmakosh Pro",
      "type": "ELITE",
      "basePrice": 2499,
      "icon": Icons.diamond_outlined,
      "features": [
        "Unlimited Credits",
        "Krishna talk unlimited",
        "Ask Rashmi unlimited",
        "Expert chat unlimited",
        "1-on-1 Spiritual Guidance",
      ],
      "color": const Color(0xFFB388FF), // Royal Purple
      "recommended": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Subscriptions",
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 1.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              "Choose your path to Spiritual Enlightenment",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13.sp,
                color: Colors.white70,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          _buildBillingToggle(),
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
              physics: const BouncingScrollPhysics(),
              itemCount: _subscriptions.length,
              itemBuilder: (context, index) {
                final sub = _subscriptions[index];
                final isSelected = _selectedPlanIndex == index;
                return _buildSubscriptionCard(sub, index, isSelected);
              },
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildBillingToggle() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: !_isYearly ? AppTheme.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Monthly",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: !_isYearly ? Colors.black : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isYearly = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: _isYearly ? AppTheme.primaryGold : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Yearly",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: _isYearly ? Colors.black : Colors.white54,
                      ),
                    ),
                    SizedBox(width: 1.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.2.h),
                      decoration: BoxDecoration(
                        color: _isYearly ? Colors.black : AppTheme.primaryGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "SAVE 17%",
                        style: GoogleFonts.poppins(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                          color: _isYearly ? AppTheme.primaryGold : AppTheme.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(
      Map<String, dynamic> sub, int index, bool isSelected) {
    final bool isRecommended = sub["recommended"] ?? false;
    final int basePrice = sub["basePrice"] ?? 0;
    
    // Dynamic price calculation
    final String displayPrice = basePrice == 0
        ? "Free"
        : _isYearly
            ? "₹${basePrice * 10}"
            : "₹$basePrice";
            
    final String displayDuration = basePrice == 0
        ? "Forever"
        : _isYearly
            ? "/year"
            : "/month";

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 2.5.h),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? sub["color"].withOpacity(0.1)
                    : const Color(0xFF141414),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? sub["color"] : Colors.white10,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: sub["color"].withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        )
                      ]
                    : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: sub["color"].withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          sub["icon"],
                          color: sub["color"],
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub["type"],
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: sub["color"],
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              sub["name"],
                              style: GoogleFonts.lora(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            displayPrice,
                            style: GoogleFonts.lora(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? sub["color"] : Colors.white,
                            ),
                          ),
                          Text(
                            displayDuration,
                            style: GoogleFonts.poppins(
                              fontSize: 10.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Divider(color: Colors.white10, height: 1),
                  SizedBox(height: 2.h),
                  ...List.generate(
                    (sub["features"] as List).length,
                    (fIndex) => Padding(
                      padding: EdgeInsets.only(bottom: 1.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: sub["color"],
                            size: 16.sp,
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Text(
                              sub["features"][fIndex],
                              style: GoogleFonts.poppins(
                                fontSize: 11.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isRecommended)
              Positioned(
                top: -12,
                right: 20,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: sub["color"],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: sub["color"].withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Text(
                    "RECOMMENDED",
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomAction() {
    final sub = _subscriptions[_selectedPlanIndex];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h).copyWith(
        bottom: Platform.isIOS ? 4.h : 3.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGold.withOpacity(0.1),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 6.5.h,
        child: ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Selected plan: ${sub['name']}"),
                backgroundColor: sub["color"],
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: sub["color"],
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 10,
            shadowColor: sub["color"].withOpacity(0.3),
          ),
          child: Text(
            sub["basePrice"] == 0 ? "Start Free Plan" : "Subscribe Now",
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
