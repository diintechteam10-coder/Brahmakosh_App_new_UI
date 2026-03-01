import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/colors.dart';
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
      backgroundColor: CustomColors.lightPinkColor,
      appBar: AppBar(
        title: Text(
          "Choose Sankalp",
          style: GoogleFonts.lora(
            fontSize: 20,
            color: const Color(0xff4E342E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xff5D4037),
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
      ),
      body: BlocBuilder<SankalpBloc, SankalpState>(
        builder: (context, state) {
          if (state is SankalpLoading && (state is! SankalpLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SankalpError) {
            return Center(child: Text(state.message));
          }

          List<SankalpModel> sankalps = [];
          List<UserSankalpModel> userSankalps = [];
          if (state is SankalpLoaded) {
            sankalps = state.availableSankalps;
            userSankalps = state.userSankalps;
          }

          if (sankalps.isEmpty) {
            if (state is SankalpLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text("No Sankalps Available"));
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
    );
  }

  Widget _buildSankalpItem(
    BuildContext context,
    SankalpModel sankalp,
    String? userStatus,
  ) {
    final bool isAlreadyJoined = userStatus != null;
    final bool isCompleted = userStatus == 'completed';
    final String statusLabel = isCompleted ? "Completed ✓" : "Already Joined";

    return GestureDetector(
      onTap: isAlreadyJoined
          ? () {
              Get.snackbar(
                isCompleted ? "Already Completed" : "Already Active",
                isCompleted
                    ? "You have already completed this sankalp."
                    : "This sankalp is already active in your list.",
                backgroundColor: const Color(0xffFFF3E0),
                colorText: const Color(0xff4E342E),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                borderRadius: 12,
              );
            }
          : () {
              if (sankalp.id.isEmpty) {
                Get.snackbar("Error", "Invalid Sankalp ID");
                return;
              }

              try {
                final bloc = context.read<SankalpBloc>();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: bloc,
                      child: SankalpDetailScreen(sankalp: sankalp),
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Full details not available")),
                );
              }
            },
      child: Opacity(
        opacity: isAlreadyJoined ? 0.6 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Image Area with Gradient Overlay
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      sankalp.bannerImage.isNotEmpty
                          ? sankalp.bannerImage
                          : "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=600&q=80",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.4),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${sankalp.totalDays} Days",
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xffE65100),
                          ),
                        ),
                      ),
                    ),
                    if (isAlreadyJoined)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green.withOpacity(0.9)
                                : const Color(0xffff7438).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sankalp.title,
                      style: GoogleFonts.lora(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xff4E342E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      sankalp.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xff8D6E63),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 16,
                              color: Color(0xffD4AF37),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "+${sankalp.karmaPointsPerDay} Karma / Day",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff5D4037),
                              ),
                            ),
                          ],
                        ),
                        if (!isAlreadyJoined)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xffFEDA87).withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              size: 14,
                              color: Color(0xffE65100),
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
      ),
    );
  }
}
