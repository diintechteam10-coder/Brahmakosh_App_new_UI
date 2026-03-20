import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/common_imports.dart';
import '../../../common/widgets/custom_profile_avatar.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileDetailsView extends StatelessWidget {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark Theme
      appBar: AppBar(
        title: Text(
          '',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          final profile = vm.profile;
          final user = profile?.profile;

          return vm.isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)))
              : RefreshIndicator(
                  onRefresh: vm.refreshProfile,
                  color: const Color(0xFFD4AF37),
                  backgroundColor: Colors.black,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // Top Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                              ),
                              child: CustomProfileAvatar(
                                imageUrl: profile?.profileImageUrl,
                                radius: 30.0,
                                borderWidth: 0.0,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.name ?? 'User',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                                        fontSize: 13,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // const Icon(Icons.chevron_right, color: Colors.white38, size: 24),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Personal Information Container
                      _buildSectionContainer(
                        title: "Personal Information",
                        children: [
                          _buildInfoTile(
                            icon: Icons.person_outline,
                            label: "Name",
                            value: user?.name ?? "Sushant",
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildInfoTile(
                            icon: Icons.phone_outlined,
                            label: "Mobile",
                            value: profile?.mobile ?? "+91 ****",
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),

                      // Birth Details Container
                      _buildSectionContainer(
                        title: "Birth Details",
                        children: [
                          _buildInfoTile(
                            icon: Icons.calendar_today_outlined,
                            label: "Date Of Birth",
                            value: user?.dob?.split('T').first ?? "2000 - 03 - 23",
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildInfoTile(
                            icon: Icons.access_time_outlined,
                            label: "Time Of Birth",
                            value: user?.timeOfBirth ?? "7:17 AM",
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _buildInfoTile(
                            icon: Icons.place_outlined,
                            label: "Place Of Birth",
                            value: user?.placeOfBirth ?? "Nawada, Bihar, India",
                          ),
                           const Divider(color: Colors.white10, height: 1),
                          _buildInfoTile(
                            icon: Icons.auto_awesome_outlined,
                            label: "Profession",
                            value: user?.gowthra ?? "Designer",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildSectionContainer({required String title, required List<Widget> children}) {
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
              color: const Color(0xFF141414), // Dark slightly gray background for card
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 16),
          Expanded(
             flex: 2,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
