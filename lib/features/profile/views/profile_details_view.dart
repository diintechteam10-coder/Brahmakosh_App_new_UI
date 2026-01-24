import '../../../../core/common_imports.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileDetailsView extends StatelessWidget {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ProfileViewModel();
        WidgetsBinding.instance.addPostFrameCallback((_) => vm.fetchProfile());
        return vm;
      },
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppTheme.backgroundLight,
            appBar: AppBar(
              title: const Text('My Profile'),
              centerTitle: true,
              backgroundColor: Colors.white,
              elevation: 0,
              foregroundColor: AppTheme.textPrimary,
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: vm.refreshProfile,
                    child: ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        _heroHeader(vm.profile),
                        const SizedBox(height: 20),
                        _sectionCard(
                          title: 'Personal Information',
                          children: [
                            _infoTile(
                              Icons.person,
                              'Name',
                              vm.profile?.profile?.name,
                            ),
                            _infoTile(Icons.email, 'Email', vm.profile?.email),
                            _infoTile(
                              Icons.phone,
                              'Mobile',
                              vm.profile?.mobile,
                            ),
                          ],
                        ),
                        _sectionCard(
                          title: 'Birth Details',
                          children: [
                            _infoTile(
                              Icons.cake,
                              'Date of Birth',
                              vm.profile?.profile?.dob,
                            ),
                            _infoTile(
                              Icons.schedule,
                              'Time of Birth',
                              vm.profile?.profile?.timeOfBirth,
                            ),
                            _infoTile(
                              Icons.place,
                              'Place of Birth',
                              vm.profile?.profile?.placeOfBirth,
                            ),
                            _infoTile(
                              Icons.auto_awesome,
                              'Gowthra',
                              vm.profile?.profile?.gowthra,
                            ),
                          ],
                        ),
                        _sectionCard(
                          title: 'Account Status',
                          children: [
                            _statusTile(
                              'Email Verified',
                              vm.profile?.emailVerified,
                            ),
                            _statusTile(
                              'Mobile Verified',
                              vm.profile?.mobileVerified,
                            ),
                            _infoTile(
                              Icons.admin_panel_settings,
                              'Role',
                              vm.profile?.role,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }

  // ================= HEADER =================

  Widget _heroHeader(ProfileModel? profile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppTheme.backgroundLight,
            backgroundImage: profile?.profileImageUrl != null
                ? NetworkImage(profile!.profileImageUrl!)
                : null,
            child: profile?.profileImageUrl == null
                ? Icon(Icons.person, size: 32, color: AppTheme.textSecondary)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.profile?.name ?? '—',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION CARD =================

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ================= INFO TILE =================

  Widget _infoTile(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryGold),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value?.isNotEmpty == true ? value! : '—',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS TILE =================

  Widget _statusTile(String label, bool? status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            status == true ? Icons.check_circle : Icons.cancel,
            size: 18,
            color: status == true ? Colors.green : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              status == true ? 'Verified' : 'Not Verified',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
