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
              .where((s) => s.status == 'active')
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
            floatingActionButton: Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xffff7438), Color(0xffE65100)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xffff7438).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: () {
                    final bloc = context.read<SankalpBloc>();
                    Get.to(
                      () => BlocProvider.value(
                        value: bloc,
                        child: const ChooseSankalpScreen(),
                      ),
                      transition: Transition.downToUp,
                    );
                  },
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
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
            // Decorative Illustration
            Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xffFEDA87).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffff7438).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.auto_awesome,
                    size: 80,
                    color: Color(0xffff7438),
                  ),
                  Positioned(
                    top: 40,
                    right: 30,
                    child: Icon(
                      Icons.star,
                      color: const Color(0xffFEDA87),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    bottom: 40,
                    left: 20,
                    child: Icon(
                      Icons.star_border,
                      color: const Color(0xffFEDA87),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No Active Sankalps",
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xff4E342E),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Start your journey towards mindfulness\nby choosing a sankalp that resonates with you.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
                color: const Color(0xff7D6E63),
                height: 1.5,
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
                  transition: Transition.downToUp,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xffff7438), Color(0xffE65100)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xffff7438).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Discover Sankalps",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.explore_outlined,
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

  Widget _buildSankalpCard(BuildContext context, UserSankalpModel userSankalp) {
    final completedDays = userSankalp.dailyReports
        .where((r) => r.status == 'yes')
        .length;
    double progress = userSankalp.totalDays > 0
        ? completedDays / userSankalp.totalDays
        : 0;

    final sankalp = userSankalp.sankalp;
    final bool isReportPending = _isReportPending(userSankalp);

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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
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
                        Text(
                          sankalp.title,
                          style: GoogleFonts.lora(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xff4E342E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.stars,
                              size: 14,
                              color: Color(0xffD4AF37),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "+${sankalp.karmaPointsPerDay} Karma / Day",
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withOpacity(0.1)),
                    ),
                    child: Text(
                      "$completedDays/${userSankalp.totalDays} Days",
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isReportPending)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffff7438),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "Mark Daily Progress",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Completion",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xff8D6E63),
                        ),
                      ),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xff4E342E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xffFEDA87), Color(0xffff7438)],
                            ),
                            borderRadius: BorderRadius.circular(3),
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
