import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_progress_screen.dart';
import 'choose_sankalp_screen.dart';

class CompletedSankalpTab extends StatelessWidget {
  const CompletedSankalpTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SankalpBloc, SankalpState>(
      builder: (context, state) {
        if (state is SankalpLoading && state is! SankalpLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is SankalpError) {
          return Center(child: Text(state.message));
        }

        List<UserSankalpModel> completedSankalps = [];
        if (state is SankalpLoaded) {
          completedSankalps = state.userSankalps
              .where(
                (s) =>
                    s.status == 'completed' ||
                    (s.status == 'active' && s.currentDay >= s.totalDays),
              )
              .toList();
        }

        if (completedSankalps.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Art
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: 180,
                          width: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xffff7438),
                              width: 1,
                            ),
                          ),
                        ),
                        Container(
                          height: 130,
                          width: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xffff7438).withOpacity(0.5),
                              width: 1,
                            ),
                            color: const Color(0xffFEDA87).withOpacity(0.2),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xffff7438),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "No Sankalp completed yet",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Your journey is just beginning.Complete your first\nSankalp to see your spiritual record here.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xff4D4D4D),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      final bloc = context.read<SankalpBloc>();
                      Get.to(
                        () => BlocProvider.value(
                          value: bloc,
                          child: const ChooseSankalpScreen(),
                        ),
                        transition: Transition.upToDown,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffff7438),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Choose Sankalp",
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: completedSankalps.length,
          itemBuilder: (context, index) {
            final userSankalp = completedSankalps[index];
            return _buildCompletedCard(context, userSankalp);
          },
        );
      },
    );
  }

  Widget _buildCompletedCard(
    BuildContext context,
    UserSankalpModel userSankalp,
  ) {
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
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(
                    sankalp.bannerImage.isNotEmpty
                        ? sankalp.bannerImage
                        : "https://images.unsplash.com/photo-1604881991720-f91add269bed?ixlib=rb-4.0.3&auto=format&fit=crop&w=150&q=80",
                  ),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          sankalp.title,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4E342E),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Text(
                          "SUCCESS",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${userSankalp.totalDays} Days Completed",
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xff4E342E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: 14,
                        color: Color(0xffD4AF37),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${userSankalp.totalDays * sankalp.karmaPointsPerDay} Karma Points Earned",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff8D6E63),
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
