import '../../../../core/common_imports.dart';
import '../../../../common/utils.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'profile_details_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ProfileViewModel();
        // Fetch profile data when viewmodel is created
        WidgetsBinding.instance.addPostFrameCallback((_) {
          viewModel.fetchProfile();
        });
        return viewModel;
      },
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final profile = viewModel.profile;
          final isLoading = viewModel.isLoading;
          final errorMessage = viewModel.errorMessage;

          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            extendBodyBehindAppBar: true,
            body: RefreshIndicator(
              onRefresh: viewModel.refreshProfile,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Header with Golden Gradient
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: AppTheme.goldGradient,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                        ),
                      ),

                      Positioned(
                        top: 70,
                        left: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => Get.to(() => const ProfileDetailsView()),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Profile Image
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Colors.white,
                                  backgroundImage:
                                      profile?.profileImageUrl != null
                                      ? NetworkImage(profile!.profileImageUrl!)
                                      : null,
                                  child: profile?.profileImageUrl == null
                                      ? Icon(
                                          Icons.person,
                                          size: 50,
                                          color: AppTheme.primaryGold,
                                        )
                                      : null,
                                ),
                              ),

                              const SizedBox(height: 12),
                              Text(
                                profile?.profile?.name ??
                                    profile?.email ??
                                    'Loading...',
                                style: GoogleFonts.playfairDisplay(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),

                              const SizedBox(height: 4),
                              Text(
                                profile?.mobile != null
                                    ? '${profile?.mobile}'
                                    : 'No phone number',
                                style: GoogleFonts.lora(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Menu Card
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _menuItem(
                          Icons.person_outline,
                          'My Profile',
                          onTap: () => Get.to(() => const ProfileDetailsView()),
                        ),
                        _menuItem(Icons.history, 'Consultation History'),
                        _menuItem(Icons.card_giftcard_rounded, 'Rewards'),
                        _menuItem(Icons.bookmark_outline, 'Saved Reports'),
                        _menuItem(
                          Icons.notifications_outlined,
                          'Notifications',
                          badge: '7',
                        ),
                        _menuItem(
                          Icons.settings_outlined,
                          'Settings',
                          onTap: () => Utils.showToast('Coming soon'),
                        ),
                        _menuItem(
                          Icons.help_outline,
                          'Help & Support',
                          onTap: () {
                            launchUrl(Uri.parse('https://www.brahmakosh.com/privacy-policy'));
                          },
                        ),
                        _menuItem(
                          Icons.info_outline,
                          'About Us',
                          onTap: () => Utils.showToast('Coming soon'),
                        ),
                        _logoutItem(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title, {
    String? badge,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppTheme.primaryGold),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: GoogleFonts.cinzel(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Icon(Icons.chevron_right, color: AppTheme.textSecondary),
    );
  }

  Widget _logoutItem() {
    return ListTile(
      onTap: () async {
        // Clear all authentication data including token
        await StorageService.setBool(AppConstants.keyIsLoggedIn, false);
        await StorageService.remove(AppConstants.keyAuthToken);
        await StorageService.remove(AppConstants.keyUserId);
        await StorageService.remove(AppConstants.keyUserEmail);
        await StorageService.remove(AppConstants.keyUserPhone);
        print("✅ Logout: All tokens and user data cleared");
        Get.offAllNamed(AppConstants.routeLogin);
      },
      leading: const Icon(Icons.logout, color: Colors.red),
      title: Text(
        'Logout',
        style: GoogleFonts.cinzel(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Colors.red,
        ),
      ),
    );
  }
}
