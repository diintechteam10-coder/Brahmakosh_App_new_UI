import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'dart:io';
import '../../../core/services/payment_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../astrology/views/credit_history_view.dart';

class RechargePlansView extends StatefulWidget {
  const RechargePlansView({super.key});

  @override
  State<RechargePlansView> createState() => _RechargePlansViewState();
}

class _RechargePlansViewState extends State<RechargePlansView> {
  int _selectedPlanIndex = 0;

  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    try {
      final plans = await PaymentService.getPlans();
      if (mounted) {
        setState(() {
          _plans = List<Map<String, dynamic>>.from(plans.map((p) => {
                "credits": p["credits"],
                "price": p["amount"],
                "originalPrice": p["amount"],
              }));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching plans: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showCreditRequestPopup() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: const Color(0xFF141414),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppTheme.primaryGold.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.primaryGold,
                  size: 30.sp,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "Request Sent",
                style: GoogleFonts.lora(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                "Your add credit request has been sent successfully. Credits will be added to your wallet shortly.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                height: 5.5.h,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Okay",
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
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
            "Recharge Plans",
            style: GoogleFonts.lora(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 80,
                color: AppTheme.primaryGold.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                "Coming Soon",
                style: GoogleFonts.lora(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "We are bringing recharge plans to iOS soon!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      );
    }
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
          "Recharge Plans",
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.receipt_long, color: AppTheme.primaryGold),
            tooltip: "Credit History",
            onPressed: () {
              Get.to(() => const CreditHistoryView());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.72,
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryGold
                : AppTheme.primaryGold.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primaryGold.withOpacity(0.15)
                  : Colors.black.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryGold.withOpacity(0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.monetization_on,
                      size: 28,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "${plan['credits']}",
                    style: GoogleFonts.lora(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Credits",
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primaryGold.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      "₹ ${plan['price']}",
                      style: GoogleFonts.lora(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGold
                    : Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(22),
                ),
              ),
              child: Text(
                isSelected ? "SELECTED" : "SELECT",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: isSelected ? Colors.black : Colors.white54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryGold.withOpacity(0.15),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        child: InkWell(
          onTap: () {
            if (_plans.isEmpty) return;
            // final selectedPlan = _plans[_selectedPlanIndex];
            //
            // final success = await PaymentService.startPayment(
            //   planAmount: selectedPlan["price"],
            // );
            //
            // if (success) {
            //   _showCreditRequestPopup();
            // } else {
            //   Get.snackbar("Error", "Payment failed");
            // }
            _showCreditRequestPopup();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGold.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Colors.black,
                ),
                const SizedBox(width: 12),
                Text(
                  "Proceed to Payment",
                  style: GoogleFonts.lora(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
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
