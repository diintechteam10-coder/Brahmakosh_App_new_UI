import 'package:brahmakosh/features/wallet/views/recharge_plans_view.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import '../../../../core/common_imports.dart';
import '../../../common/utils.dart';
import '../../../common/widgets/profile_image_view.dart';
import '../../../common/widgets/custom_profile_avatar.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'profile_details_view.dart';
import 'update_profile_view.dart';
import 'package:brahmakosh/common/api_urls.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../support/views/help_support_view.dart';
import '../../support/views/about_us_view.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../astrology/views/credit_history_view.dart';
import '../../redeem/views/redeem_list_view.dart';
import '../../../common/widgets/custom_popups.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme explicitly
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final profile = viewModel.profile;
          final user = profile?.profile;

          final imageUrl = ApiUrls.getFormattedImageUrl(
            profile?.profileImageUrl,
          );

          return RefreshIndicator(
            onRefresh: viewModel.refreshProfile,
            color: const Color(0xFFD4AF37),
            backgroundColor: Colors.black,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                // Top header section with Avatar, Name, Email/Phone, and Edit Button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (imageUrl != null && imageUrl.isNotEmpty) {
                                _showProfileOptions(
                                  context,
                                  imageUrl,
                                  viewModel,
                                );
                              } else {
                                _showImageSourceSheet(context, viewModel);
                              }
                            },
                            child: Hero(
                              tag: 'profile_pic_home',
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: CustomProfileAvatar(
                                  imageUrl: profile?.profileImageUrl,
                                  radius: 40.0,
                                  borderWidth: 0.0,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () =>
                                  _showImageSourceSheet(context, viewModel),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'User',
                              style: GoogleFonts.lora(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (profile?.email.isNotEmpty == true)
                              Text(
                                profile!.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            const SizedBox(height: 2),
                            if (profile?.mobile?.isNotEmpty == true)
                              Text(
                                profile!.mobile!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Edit Button
                      GestureDetector(
                        onTap: () => Get.to(() => const UpdateProfileView()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.edit,
                                size: 14,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Preferences Section
                _buildSectionContainer(
                  title: "Preferences",
                  children: [
                    _buildListTile(
                      icon: Icons.person_outline,
                      title: "My Profile",
                      onTap: () => Get.to(() => const ProfileDetailsView()),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.translate,
                            color: Colors.white70,
                            size: 24,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Change Language",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.dialog(
                              const ComingSoonPopup(feature: "Language Change"),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildLangToggle("En", true),
                                  _buildLangToggle("Hi", false),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Wallets Row
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      // Karma Wallet
                      Expanded(
                        child: _buildWalletCard(
                          title: "Karma Wallet",
                          value: "${profile?.karmaPoints ?? 56}",
                          subtitle: "Your Karma Points",
                          buttonLabel: "Redeem",
                          isKarma: true,
                          onTap: () => Get.to(() => const RedeemListView()),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Credit Wallet
                      Expanded(
                        child: _buildWalletCard(
                          title: "Credit Wallet",
                          value: "${profile?.credits ?? 1000}",
                          subtitle: "Your Credit Points",
                          buttonLabel: "Add Credit",
                          isKarma: false,
                          onTap: () => Get.to(() => const RechargePlansView()),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Others Section
                _buildSectionContainer(
                  title: "Others",
                  children: [
                    if (!Platform.isIOS) ...[
                      _buildListTile(
                        icon: Icons.account_balance_wallet_outlined,
                        title: "My Kosh",
                        onTap: () {
                          // ProfileView is pushed from NewHomeView via Navigator.push.
                          // We safely pop and return the desired tab index back to NewHomeView.
                          Get.back(result: 5);
                        },
                      ),
                      const Divider(color: Colors.white10, height: 1),
                    ],
                    if (!Platform.isIOS)
                      _buildListTile(
                        icon: Icons.shopping_cart_outlined,
                        title: "Orders",
                        onTap: () => Utils.showToast('Coming soon'),
                      ),
                    const Divider(color: Colors.white10, height: 1),
                    if (!Platform.isIOS)
                      _buildListTile(
                        icon: Icons.receipt_long_outlined,
                        title: "Credit History",
                        onTap: () => Get.to(() => const CreditHistoryView()),
                      ),
                    const Divider(color: Colors.white10, height: 1),
                    if (!Platform.isIOS)
                      _buildListTile(
                        icon: Icons.settings_outlined,
                        title: "Settings",
                        onTap: () => Utils.showToast('Coming soon'),
                      ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildListTile(
                      icon: Icons.help_outline,
                      title: "Help & Support",
                      onTap: () => Get.to(() => const HelpSupportView()),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildListTile(
                      icon: Icons.info_outline,
                      title: "About Us",
                      onTap: () => Get.to(() => const AboutUsView()),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    _buildListTile(
                      icon: Icons.delete_outline,
                      title: "Delete Account",
                      onTap: () {
                        Get.dialog(
                          ActionConfirmationPopup(
                            title: "Delete Account",
                            description: "Are you sure you want to delete your account?\nThis action will permanently remove your data from Brahmakosh.",
                            confirmLabel: "Delete",
                            onConfirm: () => _launchDeleteAccountEmail(
                              context,
                              profile?.email ?? '',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Logout Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () {
                        Get.dialog(
                          ActionConfirmationPopup(
                            title: "Logout",
                            description: "Are you sure you want to logout from Brahmakosh?",
                            confirmLabel: "Logout",
                            onConfirm: _logout,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4800), // Solid Orange
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.logout,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Logout",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(
                0xFF141414,
              ), // Dark slightly gray background for card
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // Helper Method to build the cards
  Widget _buildWalletCard({
    required String title,
    required String value,
    required String subtitle,
    required String buttonLabel,
    required bool isKarma,
    String? imageAsset,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Adjusted height to match image aspect ratio
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isKarma
                ? [
                    const Color(0xFFE2A03D),
                    const Color(0xFFBF7A23),
                  ] // Golden gradient
                : [
                    const Color(0xFF4B5BEA),
                    const Color(0xFF2E3EB1),
                  ], // Blue gradient
          ),
        ),
        child: Stack(
          children: [
            // Background Pattern (Faded circles/lines)
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                isKarma ? Icons.blur_circular : Icons.track_changes,
                size: 150,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Foreground Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lora(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isKarma ? const Color(0xFF2C1E0D) : Colors.white,
                    ),
                  ),
                  // const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isKarma
                              ? const Color(0xFF2C1E0D)
                              : Colors.white,
                        ),
                      ),
                      if (isKarma) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.stars,
                          color: const Color(0xFF2C1E0D),
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: isKarma
                          ? const Color(0xFF2C1E0D).withOpacity(0.8)
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            // Piggy Bank Image for Karma Wallet
            if (isKarma && imageAsset != null)
              Positioned(
                right: -5,
                bottom: -5,
                child: Image.asset(imageAsset, height: 95),
              ),

            // Bottom Right Button
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isKarma
                      ? const Color(0xFFE87A24)
                      : const Color(0xFF00893F),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  buttonLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: Colors.white70, size: 24),
      title: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white38,
        size: 24,
      ),
    );
  }

  Widget _buildLangToggle(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFFFCA28)
            : Colors.transparent, // Gold selected
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.black : Colors.white54,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    // 1. Notify backend to remove push token (Requires current token)
    try {
      await PushNotificationService.instance.removeToken();
    } catch (e) {
      debugPrint("Error removing push token: $e");
    }

    // 2. Clear all authentication data including token
    await StorageService.setBool(AppConstants.keyIsLoggedIn, false);
    await StorageService.remove(AppConstants.keyAuthToken);
    await StorageService.remove(AppConstants.keyUserId);
    await StorageService.remove(AppConstants.keyUserEmail);
    await StorageService.remove(AppConstants.keyUserPhone);
    print("✅ Logout: All tokens and user data cleared");
    Get.offAllNamed(AppConstants.routeLogin);
  }

  Future<void> _launchDeleteAccountEmail(
    BuildContext context,
    String? currentEmail,
  ) async {
    const String recipient = 'contact@brahmakosh.com';
    final String subject =
        'Account Deletion Request - ${currentEmail ?? "User"}';
    final String body =
        'Hello Brahmakosh Team,\n\nI would like to request the deletion of my account associated with this email address ($currentEmail).\n\nReason (Optional):\n\nThank you.\n';

    final Uri emailLaunchUri = Uri.parse(
      'mailto:$recipient?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      final bool launched = await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not open Mail app. Please email contact@brahmakosh.com directly.',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Could not launch email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open Mail app. Please email contact@brahmakosh.com directly.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showProfileOptions(
    BuildContext context,
    String imageUrl,
    ProfileViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141414), // Dark Theme
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD4AF37),
                radius: 20,
                child: Icon(Icons.person, color: Colors.black, size: 20),
              ),
              title: Text(
                'View Profile Picture',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Get.to(
                  () => ProfileImageView(
                    imageUrl: imageUrl,
                    heroTag: 'profile_pic_home',
                  ),
                  transition: Transition.fadeIn,
                );
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFD4AF37),
                radius: 20,
                child: Icon(Icons.edit, color: Colors.black, size: 20),
              ),
              title: Text(
                'Edit Profile Picture',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showImageSourceSheet(context, viewModel);
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showImageSourceSheet(BuildContext context, ProfileViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141414), // Dark Theme
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white70),
              title: Text(
                "Camera",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 50,
                );
                if (image != null) {
                  viewModel.uploadProfileImage(File(image.path));
                }
              },
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.photo, color: Colors.white70),
              title: Text(
                "Gallery",
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 50,
                );
                if (image != null) {
                  viewModel.uploadProfileImage(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
