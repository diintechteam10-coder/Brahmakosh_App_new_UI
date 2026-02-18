import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import '../../astrology/views/credit_history_view.dart';

class RechargePlansView extends StatefulWidget {
  const RechargePlansView({super.key});

  @override
  State<RechargePlansView> createState() => _RechargePlansViewState();
}

class _RechargePlansViewState extends State<RechargePlansView> {
  int _selectedPlanIndex = 0;

  final List<Map<String, dynamic>> _plans = [
    {
      "credits": 500,
      "price": 499,
      "originalPrice": 599, // Optional: for strike-through if needed later
    },
    {"credits": 1000, "price": 899, "originalPrice": 1199},
    {"credits": 2000, "price": 1899, "originalPrice": 2399},
    {"credits": 5000, "price": 4599, "originalPrice": 5999},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA), // Light grey background
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFFC107), // Amber
                Color(0xFFFF9800), // Orange
                Color(0xFFFF5722), // Deep Orange
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Recharge Plans",
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: Colors.white),
            tooltip: "Credit History",
            onPressed: () {
              Get.to(() => const CreditHistoryView());
            },
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Adjust based on content
              ),
              itemCount: _plans.length,
              itemBuilder: (context, index) {
                final plan = _plans[index];
                final isSelected = _selectedPlanIndex == index;
                return _buildPlanCard(plan, index, isSelected);
              },
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan, int index, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlanIndex = index;
        });
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xff4CAF50), width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Content
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon Stack with glow
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1), // Light amber bg
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.monetization_on, // Or custom coin asset
                          size: 32,
                          color: Color(0xFFFFC107),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${plan['credits']}",
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF9800),
                        ),
                      ),
                      Text(
                        "Credits",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 235, 238),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "₹ ${plan['price']}",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFD32F2F),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom Selection Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xff4CAF50)
                        : const Color(0xFFF5F5F5),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ), // slightly less to fit inside border
                  ),
                  alignment: Alignment.center,
                  child: isSelected
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Selected",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          "Select",
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff4CAF50),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () {
            // Integrate payment gateway here
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFC107),
                  Color(0xFFFF9800),
                  Color(0xFFFF5722),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9800).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payment, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  "Proceed to Payment",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
