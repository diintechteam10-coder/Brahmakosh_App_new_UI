import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:google_fonts/google_fonts.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import 'sankalp_progress_screen.dart';
import 'choose_sankalp_screen.dart';

class MySankalpTab extends StatelessWidget {
  const MySankalpTab({super.key});

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

        List<UserSankalpModel> activeSankalps = [];
        if (state is SankalpLoaded) {
          activeSankalps = state.userSankalps
              .where((s) => s.status == 'active' && s.currentDay < s.totalDays)
              .toList();
        }

        if (activeSankalps.isEmpty) {
          if (state is SankalpLoading) {
            return const Center(child: CircularProgressIndicator());
          }
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
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<SankalpBloc>().add(FetchUserSankalps());
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: activeSankalps.length,
                itemBuilder: (context, index) {
                  final userSankalp = activeSankalps[index];
                  return _buildSankalpCard(context, userSankalp);
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xffff7438),
              onPressed: () {
                final bloc = context.read<SankalpBloc>();
                Get.to(
                  () => BlocProvider.value(
                    value: bloc,
                    child: const ChooseSankalpScreen(),
                  ),
                  transition: Transition.downToUp,
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                  Positioned(
                    right: 15,
                    top: 40,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffFEDA87).withOpacity(0.5),
                      ),
                      child: const Icon(
                        Icons.star,
                        size: 16,
                        color: Color(0xffff7438),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: 60,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffFEDA87).withOpacity(0.5),
                      ),
                      child: const Icon(
                        Icons.local_florist,
                        size: 16,
                        color: Color(0xffff7438),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "You don't have any \n",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2D2D), // Dark text
                    ),
                  ),
                  TextSpan(
                    text: "Sankalp",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xffff7438), // Orange highlight
                    ),
                  ),
                  TextSpan(
                    text: " yet",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff2D2D2D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Choose a sankalp to begin your journey\ntowards a more mindful life.",
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
            const SizedBox(height: 16),
            Text(
              "YOUR SPIRITUAL PATH AWAITS",
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSankalpCard(BuildContext context, UserSankalpModel userSankalp) {
    // Calculate progress
    double progress = userSankalp.totalDays > 0
        ? userSankalp.currentDay / userSankalp.totalDays
        : 0;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                              "${userSankalp.currentDay}/${userSankalp.totalDays} Days",
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
                        sankalp.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: const Color(0xff8D6E63),
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
                            "+${sankalp.karmaPointsPerDay} Karma",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff4E342E),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Daily Check-in Button if pending
            if (_isReportPending(userSankalp))
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showCheckInDialog(context, userSankalp),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffff7438),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      "Mark Daily Progress",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            // Progress Bar
            Row(
              children: [
                Text(
                  "Completion Progress",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff4E342E),
                  ),
                ),
                const Spacer(),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffff7438),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xffff7438),
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isReportPending(UserSankalpModel userSankalp) {
    if (userSankalp.dailyReports.isEmpty) return true;

    // Find today's report based on currentDay
    // currentDay is 1-based.
    final currentDay = userSankalp.currentDay;
    if (currentDay > userSankalp.dailyReports.length) return false;

    // Check if the report for currentDay exists and status is 'not_reported'
    final todayReport = userSankalp.dailyReports.firstWhere(
      (report) => report.day == currentDay,
      orElse: () => DailyReport(day: currentDay, status: 'reported'),
    );

    return todayReport.status == 'not_reported';
  }

  void _showCheckInDialog(BuildContext context, UserSankalpModel userSankalp) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Daily Check-in",
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              color: const Color(0xff5D4037),
            ),
          ),
          content: Text(
            "Did you complete your '${userSankalp.sankalp.title}' today?",
            style: GoogleFonts.inter(color: const Color(0xff5D4037)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SankalpBloc>().add(
                  ReportDailyStatus(
                    userSankalpId: userSankalp.id,
                    status: "no",
                  ),
                );
              },
              child: Text(
                "No",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<SankalpBloc>().add(
                  ReportDailyStatus(
                    userSankalpId: userSankalp.id,
                    status: "yes",
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffff7438),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                "Yes, Completed",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
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
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff5D4037),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
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
