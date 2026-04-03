import '../../../../core/common_imports.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../controllers/astrology_controller.dart';

class AstrologySettingsView extends StatelessWidget {
  const AstrologySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final AstrologyController controller = Get.find<AstrologyController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDF8F0),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGold,
        elevation: 0,
        centerTitle: false,
        title: Text(
          "settings_title".tr,
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CREDITS (Wallet) ---
            _buildPremiumWallet(context, controller),
            const SizedBox(height: 32),

            Text(
              "account_support_title".tr,
              style: GoogleFonts.lora(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 16),

            // --- GRID FOR History, Profile, FAQs ---
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildActionTile(
                  Icons.history_rounded,
                  "history_title".tr,
                  "history_subtitle".tr,
                  const Color(0xFF6366F1),
                  () => controller.openHistory(),
                ),
                _buildActionTile(
                  Icons.person_outline_rounded,
                  "profile_title".tr,
                  "profile_subtitle".tr,
                  const Color(0xFF10B981),
                  () => controller.openUserProfile(),
                ),
                _buildActionTile(
                  Icons.help_outline_rounded,
                  "faqs_title".tr,
                  "faqs_subtitle".tr,
                  const Color(0xFFF59E0B),
                  () => controller.openFAQs(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumWallet(BuildContext context, AstrologyController controller) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE2B45C).withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background accents
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7E6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "total_credits".tr,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Consumer<ProfileViewModel>(
                          builder: (context, profileVM, child) {
                            final credits = profileVM.profile?.credits ?? 0;
                            return Text(
                              "\u20B9 ${credits.toStringAsFixed(2)}",
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                color: const Color(0xFF1A1A1A),
                                fontWeight: FontWeight.w800,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFFE2B45C),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => controller.showRechargeBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A), // Sleek black
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 5,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "recharge_wallet".tr,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    Color accentColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

