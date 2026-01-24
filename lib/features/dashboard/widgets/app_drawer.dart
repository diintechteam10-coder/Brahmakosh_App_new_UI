import '../../../../core/common_imports.dart';
import '../../profile/viewmodels/profile_viewmodel.dart';
import '../../profile/views/profile_details_view.dart';
import '../viewmodels/dashboard_viewmodel.dart';
import '../../agent/lemon_agent_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundLight,
      child: Consumer<ProfileViewModel>(
        builder: (context, viewModel, child) {
          final profile = viewModel.profile;

          return Column(
            children: [
              // Drawer Header
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                decoration: BoxDecoration(gradient: AppTheme.goldGradient),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        backgroundImage: profile?.profileImageUrl != null
                            ? NetworkImage(profile!.profileImageUrl!)
                            : null,
                        child: profile?.profileImageUrl == null
                            ? const Icon(
                                Icons.person,
                                size: 35,
                                color: AppTheme.primaryGold,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile?.profile?.name ?? 'User',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            profile?.email ?? '',
                            style: GoogleFonts.lora(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Drawer Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _drawerItem(
                      icon: Icons.person_outline,
                      label: 'My Profile',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const ProfileDetailsView());
                      },
                    ),
                    _drawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'My Kosh',
                      onTap: () {
                        Navigator.pop(context);
                        // MyKosh is at index 5 in Dashboard
                        Provider.of<DashboardViewModel>(
                          context,
                          listen: false,
                        ).changeTab(5);
                      },
                    ),
                    _drawerItem(
                      icon: Icons.history,
                      label: 'Consultation History',
                      onTap: () {},
                    ),
                    _drawerItem(
                      icon: Icons.bookmark_outline,
                      label: 'Saved Reports',
                      onTap: () {},
                    ),
                    _drawerItem(
                      icon: Icons.face_unlock_outlined,
                      label: 'Avatar Agent',
                      onTap: () {
                        Navigator.pop(context);
                        Get.to(() => const AvatarAgentPage());
                      },
                    ),
                    const Divider(),
                    _drawerItem(
                      icon: Icons.settings_outlined,
                      label: 'Settings',
                      onTap: () {},
                    ),
                    _drawerItem(
                      icon: Icons.help_outline,
                      label: 'Help & Support',
                      onTap: () {},
                    ),
                    _drawerItem(
                      icon: Icons.info_outline,
                      label: 'About Us',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListTile(
                  onTap: () async {
                    await StorageService.setBool(
                      AppConstants.keyIsLoggedIn,
                      false,
                    );
                    await StorageService.remove(AppConstants.keyAuthToken);
                    await StorageService.remove(AppConstants.keyUserId);
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
                ),
              ),
              SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryGold),
      title: Text(
        label,
        style: GoogleFonts.cinzel(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}
