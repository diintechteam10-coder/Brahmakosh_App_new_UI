import 'package:flutter/material.dart';
import 'package:brahmakosh/core/common_imports.dart';
import 'dart:io';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/iap_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class SubscriptionPlansView extends StatefulWidget {
  const SubscriptionPlansView({super.key});

  @override
  State<SubscriptionPlansView> createState() => _SubscriptionPlansViewState();
}

class _SubscriptionPlansViewState extends State<SubscriptionPlansView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPlanIndex = 2;
  bool _isYearly = false;
  bool _isIAPLoading = true;
  bool _isRestoring = false;
  final IAPService _iapService = IAPService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _isYearly = _tabController.index == 1;
        });
      }
    });
    if (Platform.isIOS) {
      _iapService.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isIAPLoading = false;
          });
        }
      });
    } else {
      _isIAPLoading = false;
    }
  }

  Future<void> _refreshProducts() async {
    if (Platform.isIOS) {
      setState(() => _isIAPLoading = true);
      await _iapService.fetchProducts();
      if (mounted) {
        setState(() => _isIAPLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _subscriptions = [
    {
      "name_key": "plan_explorer",
      "type_key": "type_freemium",
      "basePrice": 0,
      "icon": Icons.spa_outlined,
      "features": [
        {
          "key": "feature_credits",
          "params": {"count": "100"},
        },
        {
          "key": "feature_krishna_talk",
          "params": {"count": "5"},
        },
        {
          "key": "feature_rashmi_questions",
          "params": {"count": "10"},
        },
        {
          "key": "feature_expert_chat",
          "params": {"count": "5"},
        },
      ],
      "color": Colors.white70,
      "iosProductId": null,
    },
    {
      "name_key": "plan_seeker",
      "type_key": "type_premium",
      "basePrice": 499,
      "icon": Icons.self_improvement,
      "features": [
        {
          "key": "feature_credits",
          "params": {"count": "500"},
        },
        {
          "key": "feature_krishna_talk",
          "params": {"count": "30"},
        },
        {
          "key": "feature_rashmi_questions",
          "params": {"count": "50"},
        },
        {
          "key": "feature_expert_chat",
          "params": {"count": "20"},
        },
      ],
      "color": const Color(0xFFFF9800), // Vibrant Saffron
      "recommended": false,
      "iosProductIdMonthly": "com.brahmakoshseeker.499",
      "iosProductIdYearly": "com.brahmakoshseeker.yearly",
    },
    {
      "name_key": "plan_sadhak",
      "type_key": "type_premium",
      "basePrice": 999,
      "icon": Icons.workspace_premium,
      "features": [
        {
          "key": "feature_credits",
          "params": {"count": "1000"},
        },
        {
          "key": "feature_krishna_talk",
          "params": {"count": "60"},
        },
        {
          "key": "feature_rashmi_questions",
          "params": {"count": "100"},
        },
        {
          "key": "feature_expert_chat",
          "params": {"count": "50"},
        },
        {"key": "feature_priority_support"},
      ],
      "color": AppTheme.primaryGold, // Classy Gold
      "recommended": true,
      "iosProductIdMonthly": "com.brahmakoshsadhak.999",
      "iosProductIdYearly": "com.brahmakoshsadhak.yearly",
    },
    {
      "name_key": "plan_pro",
      "type_key": "type_elite",
      "basePrice": 2499,
      "icon": Icons.diamond_outlined,
      "features": [
        {
          "key": "feature_credits",
          "params": {"count": "Unlimited"},
        },
        {"key": "feature_krishna_unlimited"},
        {"key": "feature_rashmi_unlimited"},
        {"key": "feature_expert_unlimited"},
        {"key": "feature_one_on_one_guidance"},
      ],
      "color": const Color(0xFFB388FF), // Royal Purple
      "recommended": false,
      "iosProductIdMonthly": "com.brahmakosh.pro.monthly",
      "iosProductIdYearly": "com.brahmakoshplus.yearly",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
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
          "wallet_subscription".tr,
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
              "choose_spiritual_path".tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ),
          
          SizedBox(height: 3.h),
          _buildBillingTabs(),
          SizedBox(height: 2.h),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlanList(isYearly: false),
                _buildPlanList(isYearly: true),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: _buildBottomAction(),
        ),
      ),
    );
  }

  Widget _buildBillingTabs() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: AppTheme.primaryGold,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white54,
        labelStyle: GoogleFonts.poppins(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
        tabs: [
          Tab(text: "monthly".tr),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("yearly".tr),
                SizedBox(width: 1.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.2.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "save_percent".trParams({"percent": "17"}),
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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

  Widget _buildPlanList({required bool isYearly}) {
    return RefreshIndicator(
      onRefresh: _refreshProducts,
      color: AppTheme.primaryGold,
      backgroundColor: const Color(0xFF141414),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: _subscriptions.length,
        itemBuilder: (context, index) {
          final sub = _subscriptions[index];
          final isSelected = _selectedPlanIndex == index;
          return _buildSubscriptionCard(
            sub,
            index,
            isSelected,
            isYearly: isYearly,
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(
    Map<String, dynamic> sub,
    int index,
    bool isSelected, {
    bool isYearly = false,
  }) {
    final bool isRecommended = sub["recommended"] ?? false;
    final int basePrice = sub["basePrice"] ?? 0;

    // Dynamic price calculation
    String displayPrice = "";
    if (Platform.isIOS && basePrice != 0) {
      final String? productId = isYearly
          ? sub["iosProductIdYearly"]
          : sub["iosProductIdMonthly"];

      // Look for the product in the fetched list
      ProductDetails? product;
      try {
        product = _iapService.products.firstWhere((p) => p.id == productId);
      } catch (_) {
        product = null;
      }

      if (product != null) {
        displayPrice = product.price;
      } else {
        // Show placeholders if still loading
        displayPrice = _isIAPLoading
            ? "..."
            : (isYearly ? "₹${basePrice * 10}" : "₹$basePrice");
      }
    } else {
      displayPrice = basePrice == 0
          ? "free".tr
          : isYearly
          ? "₹${basePrice * 10}"
          : "₹$basePrice";
    }

    final String displayDuration = basePrice == 0
        ? "forever".tr
        : _isYearly
        ? "per_year".tr
        : "per_month".tr;

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
                        ),
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
                              (sub["type_key"] as String).tr,
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: sub["color"],
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              (sub["name_key"] as String).tr,
                              style: GoogleFonts.lora(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
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
                              fontSize: 16.sp,
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
                              _getLocalizedFeature(sub["features"][fIndex]),
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 3.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: sub["color"],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: sub["color"].withOpacity(0.5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "recommended_cap".tr,
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

  String _getLocalizedFeature(Map<String, dynamic> feature) {
    if (feature.containsKey('params')) {
      return (feature['key'] as String).trParams(
        (feature['params'] as Map<String, String>),
      );
    }
    return (feature['key'] as String).tr;
  }

  Widget _buildBottomAction() {
    final sub = _subscriptions[_selectedPlanIndex];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        border: Border(
          top: BorderSide(color: AppTheme.primaryGold.withOpacity(0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subscribe / Start Free Plan Button
          SizedBox(
            width: double.infinity,
            height: 6.5.h,
            child: ElevatedButton(
              onPressed: () async {
                if (Platform.isIOS && sub["basePrice"] != 0) {
                  final String? productId = _isYearly
                      ? sub["iosProductIdYearly"]
                      : sub["iosProductIdMonthly"];

                  debugPrint("Subscription button pressed for ID: $productId");
                  if (productId != null) {
                    ProductDetails? product;
                    try {
                      product = _iapService.products.firstWhere(
                        (p) => p.id == productId,
                      );
                      await _iapService.buySubscription(product);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Subscription product not found. Please try again later.",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "selected_plan_msg".trParams({
                          "name": (sub['name_key'] as String).tr,
                        }),
                      ),
                      backgroundColor: sub["color"],
                    ),
                  );
                }
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
                sub["basePrice"] == 0
                    ? "start_free_plan".tr
                    : "subscribe_now".tr,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // Compact Footer for iOS Compliance
          if (Platform.isIOS) ...[
            SizedBox(height: 1.5.h),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 4.5.h,
                  child: OutlinedButton(
                    onPressed: _isRestoring ? null : _handleRestorePurchases,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.primaryGold.withOpacity(0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isRestoring
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryGold,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "restoring_purchases".tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 9.sp,
                                  color: AppTheme.primaryGold.withOpacity(0.8),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "restore_purchases".tr,
                            style: GoogleFonts.poppins(
                              fontSize: 9.sp,
                              color: AppTheme.primaryGold.withOpacity(0.8),
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 1.5.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFooterLink(
                      "subscription_info".tr,
                      _showSubscriptionInfo,
                    ),
                    _buildFooterDivider(),
                    _buildFooterLink(
                      "privacy_policy".tr,
                      () => _launchUrl(
                        'https://www.brahmakosh.com/privacy-policy',
                      ),
                    ),
                    _buildFooterDivider(),
                    _buildFooterLink(
                      "terms_of_use".tr,
                      () => _launchUrl(
                        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 1.h),
          ],
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 8.5.sp,
          color: AppTheme.primaryGold.withOpacity(0.8),
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildFooterDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Text(
        "|",
        style: GoogleFonts.poppins(fontSize: 8.5.sp, color: Colors.white24),
      ),
    );
  }

  void _showSubscriptionInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                "wallet_subscription".tr,
                style: GoogleFonts.lora(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              _buildInfoText("auto_renewal_info".tr),
              _buildInfoText("billing_info".tr),
              _buildInfoText("management_info".tr),
              _buildInfoText("credits_account_info".tr),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGold,
                  foregroundColor: Colors.black,
                  minimumSize: Size(double.infinity, 5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "got_it".tr,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoText(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 9.5.sp,
          color: Colors.white70,
          height: 1.5,
        ),
      ),
    );
  }

  Future<void> _handleRestorePurchases() async {
    setState(() => _isRestoring = true);
    await _iapService.restorePurchases();
    if (mounted) {
      setState(() => _isRestoring = false);
      final restored = _iapService.restoreStatus.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored == true
                ? "restore_purchases_success".tr
                : "restore_purchases_failed".tr,
          ),
          backgroundColor: restored == true ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
