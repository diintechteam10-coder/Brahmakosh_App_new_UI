import '../../../../core/common_imports.dart';
import '../../../../common/colors.dart';
import '../models/profile_model.dart';
import '../viewmodels/profile_viewmodel.dart';
import 'update_profile_view.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
            backgroundColor: CustomColors.lightPinkColor,
            appBar: AppBar(
              title: Text(
                'My Profile',
                style: GoogleFonts.cinzel(
                  fontSize: 20, // Adjusted font size
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              centerTitle: true,
              backgroundColor: CustomColors.lightPinkColor,
              elevation: 0,
              foregroundColor: AppTheme.textPrimary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
                color: AppTheme.textPrimary,
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    Get.to(() => const UpdateProfileView());
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: vm.refreshProfile,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      children: [
                        _heroHeader(vm.profile),
                        const SizedBox(height: 20),
                        _sectionCard(
                          title: 'Personal Information',
                          children: [
                            _infoTile(
                              Icons.person_outline,
                              'Name',
                              vm.profile?.profile?.name,
                            ),
                            // _infoTile(
                            //   Icons.email_outlined,
                            //   'Email',
                            //   vm.profile?.email,
                            // ),
                            _infoTile(
                              Icons.phone_outlined,
                              'Mobile',
                              vm.profile?.mobile,
                            ),
                            // Mobile number moved to header
                          ],
                        ),
                        _sectionCard(
                          title: 'Birth Details',
                          children: [
                            _infoTile(
                              Icons.calendar_today_outlined,
                              'Date of Birth',
                              vm.profile?.profile?.dob?.split('T').first,
                            ),
                            _infoTile(
                              Icons.access_time,
                              'Time of Birth',
                              vm.profile?.profile?.timeOfBirth,
                            ),
                            _infoTile(
                              Icons.place_outlined,
                              'Place of Birth',
                              vm.profile?.profile?.placeOfBirth,
                            ),
                            _infoTile(
                              Icons.auto_awesome_outlined,
                              'Profession',
                              vm.profile?.profile?.gowthra,
                            ),
                          ],
                        ),

                        // _sectionCard(
                        //   title: 'Account Status',
                        //   children: [
                        //     _statusTile(
                        //       'Email Verified',
                        //       vm.profile?.emailVerified,
                        //     ),
                        //     _statusTile(
                        //       'Mobile Verified',
                        //       vm.profile?.mobileVerified,
                        //     ),
                        //     _infoTile(
                        //       Icons.admin_panel_settings_outlined,
                        //       'Role',
                        //       vm.profile?.role,
                        //     ),
                        //   ],
                        // ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: CustomColors.lightPinkColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: profile?.profileImageUrl != null
                    ? NetworkImage(profile!.profileImageUrl!)
                    : null,
                child: profile?.profileImageUrl == null
                    ? Icon(Icons.person, size: 40, color: Colors.grey.shade600)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                // Make camera icon functional
                child: Consumer<ProfileViewModel>(
                  builder: (context, viewModel, child) {
                    return GestureDetector(
                      onTap: () async {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            height: 150,
                            color: Colors.white,
                            child: Column(
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.camera_alt),
                                  title: const Text("Camera"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.camera,
                                      imageQuality: 50,
                                    );
                                    if (image != null) {
                                      viewModel.uploadProfileImage(
                                        File(image.path),
                                      );
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text("Gallery"),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    final ImagePicker picker = ImagePicker();
                                    final XFile? image = await picker.pickImage(
                                      source: ImageSource.gallery,
                                      imageQuality: 50,
                                    );
                                    if (image != null) {
                                      viewModel.uploadProfileImage(
                                        File(image.path),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_outlined,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile?.profile?.name ?? '—',
                  style: GoogleFonts.cinzel(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),

                // Row(
                //   mainAxisSize: MainAxisSize.min,
                //   children: [
                //     // Icon(
                //     //   Icons.phone_outlined,
                //     //   size: 14,
                //     //   color: AppTheme.textPrimary,
                //     // ),
                //     // const SizedBox(width: 8),
                //     // Text(
                //     //   'Mobile :',
                //     //   style: GoogleFonts.inter(
                //     //     fontSize: 12,
                //     //     color: AppTheme.textSecondary,
                //     //   ),
                //     // ),
                //     const SizedBox(width: 4),
                //     Text(
                //       profile?.mobile ?? '—',
                //       style: GoogleFonts.inter(
                //         fontSize: 12,
                //         fontWeight: FontWeight.w600,
                //         color: AppTheme.textPrimary,
                //       ),
                //     ),
                //   ],
                // ),
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
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16), // Reduced card padding
      decoration: BoxDecoration(
        color: AppTheme.cardBackground, // Keep card background as requested
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cinzel(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary, // Keep text color as requested
            ),
          ),
          const SizedBox(height: 12), // Reduced vertical spacing below title
          ...children,
        ],
      ),
    );
  }

  // ================= INFO TILE =================

  Widget _infoTile(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ), // Reduced vertical padding
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppTheme.textPrimary,
          ), // Updated icon color to brown/primary
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textSecondary, // Brown color for label
              ),
            ),
          ),
          Flexible(
            child: Text(
              value?.isNotEmpty == true ? value! : '—',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary, // Darker color for value
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
      padding: const EdgeInsets.symmetric(
        vertical: 6,
      ), // Reduced vertical padding
      child: Row(
        children: [
          Icon(
            status == true ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: status == true ? Colors.green : Colors.redAccent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Flexible(
            child: Text(
              status == true ? 'Verified' : 'Not Verified',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
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
