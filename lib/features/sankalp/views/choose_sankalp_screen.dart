import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_detail_screen.dart';

class ChooseSankalpScreen extends StatefulWidget {
  const ChooseSankalpScreen({super.key});

  @override
  State<ChooseSankalpScreen> createState() => _ChooseSankalpScreenState();
}

class _ChooseSankalpScreenState extends State<ChooseSankalpScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SankalpBloc>().add(FetchAvailableSankalps());
    context.read<SankalpBloc>().add(FetchUserSankalps());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "choose_sankalp".tr,
          style: GoogleFonts.poppins(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                'assets/icons/sankalpbg.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          BlocBuilder<SankalpBloc, SankalpState>(
            builder: (context, state) {
              if (state is SankalpLoading && (state is! SankalpLoaded)) {
                return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
              }

              if (state is SankalpError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.white)));
              }

              List<SankalpModel> sankalps = [];
              List<UserSankalpModel> userSankalps = [];
              if (state is SankalpLoaded) {
                sankalps = state.availableSankalps;
                userSankalps = state.userSankalps;
              }

              if (sankalps.isEmpty) {
                if (state is SankalpLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                }
                return Center(child: Text("no_sankalps_available".tr, style: const TextStyle(color: Colors.white70)));
              }

              // Build a set of sankalp IDs that the user has already joined/completed
              final joinedSankalpIds = <String, String>{};
              for (final us in userSankalps) {
                joinedSankalpIds[us.sankalp.id] = us.status;
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: sankalps.length,
                itemBuilder: (context, index) {
                  final sankalp = sankalps[index];
                  final userStatus = joinedSankalpIds[sankalp.id];
                  return _buildSankalpItem(context, sankalp, userStatus);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isNavigating = false;

  void _handleNavigation(BuildContext context, SankalpModel sankalp) async {
    if (_isNavigating) return;
    
    debugPrint("ChooseSankalpScreen: Starting navigation to detail for ${sankalp.id}");
    setState(() => _isNavigating = true);

    try {
      final bloc = context.read<SankalpBloc>();
      debugPrint("ChooseSankalpScreen: Bloc obtained, pushing route via Navigator");
      
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: bloc,
            child: SankalpDetailScreen(sankalp: sankalp),
          ),
          settings: const RouteSettings(name: 'SankalpDetail'),
        ),
      );
      debugPrint("ChooseSankalpScreen: Navigator.push returned");
    } catch (e) {
      debugPrint("ChooseSankalpScreen: Navigation FAILED: $e");
    } finally {
      if (mounted) setState(() => _isNavigating = false);
    }
  }

  Widget _buildSankalpItem(
    BuildContext context,
    SankalpModel sankalp,
    String? userStatus,
  ) {
    final bool isAlreadyJoined = userStatus != null;
    final bool isCompleted = userStatus == 'completed';
    final String statusLabel = isCompleted ? "completed_done".tr : "already_joined".tr;

    return InkWell(
      onTap: () {
        if (isAlreadyJoined) {
          Get.snackbar(
            isCompleted ? "already_completed".tr : "already_active".tr,
            isCompleted
                ? "already_completed_desc".tr
                : "already_active_desc".tr,
            backgroundColor: const Color(0xFF1C1C1E),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            margin: const EdgeInsets.all(16),
            borderRadius: 12,
          );
        } else {
          _handleNavigation(context, sankalp);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      sankalp.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isAlreadyJoined 
                        ? (isCompleted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1))
                        : const Color(0xFF1A3326),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isAlreadyJoined 
                          ? (isCompleted ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2))
                          : Colors.green.withOpacity(0.2)
                      ),
                    ),
                    child: Text(
                      isAlreadyJoined ? statusLabel : "${sankalp.totalDays}${"day_suffix".tr}",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isAlreadyJoined 
                          ? (isCompleted ? Colors.green : Colors.orange)
                          : const Color(0xFF4CAF50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    sankalp.bannerImage.isNotEmpty
                        ? sankalp.bannerImage
                        : "https://images.unsplash.com/photo-1604881991720-f91add269bed",
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sankalp.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/brahmkosh_logo.jpeg',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => const Icon(Icons.stars, color: Color(0xFFD4AF37), size: 18),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "+${sankalp.karmaPointsPerDay}${"karma_per_day".tr}",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                      if (!isAlreadyJoined)
                        IgnorePointer(
                          child: Container(
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                                minimumSize: const Size(80, 32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                "begin".tr,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
