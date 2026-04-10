import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'dart:io';
import '../../../core/services/payment_service.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../astrology/views/credit_history_view.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'subscription_plans_view.dart';

class RechargePlansView extends StatefulWidget {
  const RechargePlansView({super.key});

  @override
  State<RechargePlansView> createState() => _RechargePlansViewState();
}

class _RechargePlansViewState extends State<RechargePlansView> {
  int _selectedPlanIndex = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _plans = [];
  final IAPService _iapService = IAPService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    if (Platform.isIOS) {
      await _iapService.initialize();
      _loadIAPPlans();
    } else {
      _fetchPlans();
    }
  }

  void _loadIAPPlans() {
    if (mounted) {
      setState(() {
        _plans = _iapService.products.map((ProductDetails p) {
          // Parse credits from ID (e.g., com.brahmakosh.coins.100 -> 100)
          final parts = p.id.split('.');
          final credits = parts.isNotEmpty ? parts.last : "0";
          
          return {
            "credits": credits,
            "price": p.price,
            "originalPrice": p.price,
            "productDetails": p,
          };
        }).toList();
        _isLoading = false;
      });
    }
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
          _buildSubscriptionBanner(),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGold,
                    ),
                  )
                : _plans.isEmpty 
                    ? _buildEmptyState()
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final gridWidth = constraints.maxWidth - 40;
                          final cardWidth = (gridWidth - 20) / 2;
                          final double safeRatio =
                              (cardWidth / (constraints.maxHeight / 2.1))
                                  .clamp(0.75, 1.0);
                          return GridView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 20,
                              mainAxisSpacing: 16,
                              childAspectRatio: safeRatio,
                            ),
                            itemCount: _plans.length,
                            itemBuilder: (context, index) {
                              final plan = _plans[index];
                              final isSelected = _selectedPlanIndex == index;
                              return _buildPlanCard(plan, index, isSelected);
                            },
                          );
                        },
                      ),
          ),
          if (_plans.isNotEmpty) _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 60.sp,
            color: AppTheme.primaryGold.withOpacity(0.5),
          ),
          SizedBox(height: 2.h),
          Text(
            Platform.isIOS ? "No products available" : "No plans available",
            style: GoogleFonts.lora(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            Platform.isIOS 
              ? "We couldn't fetch products from the App Store."
              : "Please check back later.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    return GestureDetector(
      onTap: () => Get.to(() => const SubscriptionPlansView()),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryGold.withOpacity(0.15),
              const Color(0xFFD4AF37).withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGold.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: AppTheme.primaryGold, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Upgrade to Pro",
                    style: GoogleFonts.lora(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Get unlimited talks, chats and 1-on-1 guidance.",
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppTheme.primaryGold, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      Map<String, dynamic> plan, int index, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20),
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
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryGold.withOpacity(0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.monetization_on,
                        size: 6.w,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "${plan['credits']}",
                        style: GoogleFonts.lora(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      "Credits",
                      style: GoogleFonts.lora(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white54,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.primaryGold.withOpacity(0.3),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          Platform.isIOS ? "${plan['price']}" : "₹ ${plan['price']}",
                          style: GoogleFonts.lora(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 1.1.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryGold
                    : Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
              ),
              child: Text(
                isSelected ? "SELECTED" : "SELECT",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 9.sp,
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
          onTap: () async {
            if (_plans.isEmpty) return;
            final selectedPlan = _plans[_selectedPlanIndex];

            if (Platform.isIOS) {
              final product = selectedPlan["productDetails"] as ProductDetails;
              await _iapService.buyProduct(product);
            } else {
              // Existing Stripe payment logic
              final success = await PaymentService.startPayment(
                planAmount: int.tryParse(selectedPlan["price"].toString()),
              );

              if (success) {
                _showCreditRequestPopup();
              } else {
                AppSnackBar.showError("Error", "Payment failed");
              }
            }
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
                  Platform.isIOS ? "Buy with Apple Pay" : "Proceed to Payment",
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
