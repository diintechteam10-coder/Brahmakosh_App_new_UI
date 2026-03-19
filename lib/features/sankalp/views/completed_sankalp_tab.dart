import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_progress_screen.dart';

class CompletedSankalpTab extends StatelessWidget {
  const CompletedSankalpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SankalpBloc, SankalpState>(
      listener: (context, state) {
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;

        if (state is SankalpOperationSuccess) {
          _showSuccessDialog(context, state.message);
        } else if (state is SankalpError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<SankalpBloc, SankalpState>(
        builder: (context, state) {
          if (state is SankalpLoading && state is! SankalpLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SankalpError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          List<UserSankalpModel> completedSankalps = [];
          if (state is SankalpLoaded) {
            completedSankalps =
                state.userSankalps
                    .where((s) => s.status == 'completed')
                    .toList();
          }

          if (completedSankalps.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SankalpBloc>().add(FetchUserSankalps());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: _buildEmptyState(context),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<SankalpBloc>().add(FetchUserSankalps());
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: completedSankalps.length,
                itemBuilder: (context, index) {
                  final userSankalp = completedSankalps[index];
                  return _buildCompletedCard(context, userSankalp);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 24),
          Text(
            "No Completed Sankalps",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Complete your active sankalps to see them here.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedCard(BuildContext context, UserSankalpModel userSankalp) {
    final sankalp = userSankalp.sankalp;
    return GestureDetector(
      onTap: () {
        final bloc = context.read<SankalpBloc>();
        Get.to(
          () => BlocProvider.value(
            value: bloc,
            child: SankalpProgressScreen(sankalpId: userSankalp.id),
          ),
          transition: Transition.rightToLeft,
        )?.then((_) {
          bloc.add(FetchUserSankalps());
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E).withOpacity(0.8),
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
                      color: const Color(0xFF1A3326),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.2)),
                    ),
                    child: Text(
                      "SUCCESS",
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4CAF50),
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
                    "${userSankalp.totalDays} Days Daily ${sankalp.description.split('\n').first}",
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
                            "${userSankalp.totalDays * sankalp.karmaPointsPerDay} Karma Earned",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFD4AF37), Color(0xFFFFD700)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              "View Details",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 14, color: Colors.black),
                          ],
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

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              Text(
                "Great Job!",
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffff7438),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: const Text("Keep Going"),
              ),
            ],
          ),
        );
      },
    );
  }
}

