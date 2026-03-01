import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../common/colors.dart';
import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import '../models/sankalp_progress_model.dart';
import '../../notifications/views/notification_screen.dart';

class SankalpProgressScreen extends StatefulWidget {
  final String sankalpId; // This is the UserSankalpModel ID
  const SankalpProgressScreen({super.key, required this.sankalpId});

  @override
  State<SankalpProgressScreen> createState() => _SankalpProgressScreenState();
}

class _SankalpProgressScreenState extends State<SankalpProgressScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SankalpBloc>().add(FetchSankalpProgress(widget.sankalpId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomColors.lightPinkColor,
      appBar: AppBar(
        title: Text(
          "Progress",
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: Color(0xff5D4037),
                size: 20,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<SankalpBloc, SankalpState>(
        listener: (context, state) {
          if (state is SankalpOperationSuccess) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Message",
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(state.message, style: GoogleFonts.inter()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: GoogleFonts.inter(color: const Color(0xff5D4037)),
                    ),
                  ),
                ],
              ),
            );
            // Refresh progress after successful report
            context.read<SankalpBloc>().add(
              FetchSankalpProgress(widget.sankalpId),
            );
          } else if (state is SankalpError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                  "Information",
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(state.message, style: GoogleFonts.inter()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "OK",
                      style: GoogleFonts.inter(color: const Color(0xff5D4037)),
                    ),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SankalpLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          UserSankalpModel? userSankalp;
          ProgressStats? progressStats;

          if (state is SankalpProgressLoaded) {
            userSankalp = state.progressData.userSankalp;
            progressStats = state.progressData.progress;
          } else if (state is SankalpLoaded) {
            // Fallback to local data if available (though unlikely if we force fetch)
            try {
              userSankalp = state.userSankalps.firstWhere(
                (s) => s.id == widget.sankalpId,
              );
            } catch (_) {}
          }

          if (userSankalp == null) {
            return const Center(child: Text("Loading Sankalp details..."));
          }

          final sankalp = userSankalp.sankalp;
          final totalDays = progressStats?.totalDays ?? userSankalp.totalDays;

          // Use progress stats if available, otherwise fallback to local calculation
          final completedDays =
              progressStats?.yesCount ?? userSankalp.currentDay;
          // Note: API 'currentDay' might be different from 'yesCount'.
          // The user request shows "progress": { "yesCount": 1, "currentDay": 2 ... }
          // We should use 'yesCount' for completed days visualization if that's what we want,
          // OR use 'currentDay' - 1?
          // The UI shows "Day X OF Y".
          // Let's use `currentDay` from progress for "Day X" text, and `yesCount` / `totalDays` for progress bar?
          // Actually, `progressPercentage` is directly available.

          final double progressPercentage = progressStats != null
              ? progressStats.progressPercentage.toDouble()
              : (completedDays / totalDays) * 100;

          final isSankalpCompleted = userSankalp.status == 'completed';
          final rawCurrentDay =
              progressStats?.currentDay ?? userSankalp.currentDay;
          final currentDayDisplay = rawCurrentDay > totalDays
              ? totalDays
              : rawCurrentDay;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              sankalp.title,
                              style: GoogleFonts.lora(
                                fontSize: 22,
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
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                if (isSankalpCompleted)
                                  const Icon(
                                    Icons.check_circle,
                                    size: 14,
                                    color: Colors.green,
                                  )
                                else
                                  const Icon(
                                    Icons.check_circle_outline,
                                    size: 14,
                                    color: Colors.green,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  "Day $currentDayDisplay OF $totalDays",
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sankalp.description,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: const Color(0xff8D6E63),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Overall Progress",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xff4E342E),
                            ),
                          ),
                          Text(
                            "${progressPercentage.toInt()}%",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffff7438),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progressPercentage / 100,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xffFEDA87),
                                    Color(0xffff7438),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xffFEDA87,
                                    ).withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 10,
                            backgroundColor: Color(0xffD4AF37),
                            child: Icon(
                              Icons.star,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${sankalp.karmaPointsPerDay} Karma Points Per Day",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xff5D4037),
                            ),
                          ),
                        ],
                      ),
                      if (!isSankalpCompleted) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xffFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Complete all $totalDays days to earn +${totalDays * sankalp.karmaPointsPerDay} Karma",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffff7438),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Your Journey",
                  style: GoogleFonts.lora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff4E342E),
                  ),
                ),
                const SizedBox(height: 16),
                // Days List
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalDays,
                  itemBuilder: (context, index) {
                    final dayNum = index + 1;

                    // Determine status for this day from dailyReports
                    // We need to find if there is a report for 'dayNum'
                    String status = 'not_reported';

                    final report = userSankalp?.dailyReports.firstWhere(
                      (r) => r.day == dayNum,
                      orElse: () =>
                          DailyReport(day: dayNum, status: 'not_reported'),
                    );
                    status = report?.status ?? 'not_reported';

                    final isCompleted = status == 'yes';

                    // Check if it's "TODAY" (next unreported day)
                    // If we rely on 'currentDay' from API:
                    final isToday =
                        dayNum == currentDayDisplay && !isSankalpCompleted;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Status Accent
                            Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.green
                                    : (isToday
                                          ? const Color(0xffff7438)
                                          : Colors.grey[300]),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: isCompleted
                                            ? Colors.green.withOpacity(0.1)
                                            : Colors.grey[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          dayNum.toString().padLeft(2, '0'),
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: isCompleted
                                                ? Colors.green
                                                : const Color(0xff4E342E),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Day $dayNum",
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: const Color(0xff4E342E),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                isCompleted
                                                    ? Icons.check_circle
                                                    : (isToday
                                                          ? Icons.timer_outlined
                                                          : Icons
                                                                .radio_button_unchecked),
                                                size: 14,
                                                color: isCompleted
                                                    ? Colors.green
                                                    : (isToday
                                                          ? const Color(
                                                              0xffff7438,
                                                            )
                                                          : Colors.grey[400]),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isCompleted
                                                    ? "Completed"
                                                    : (isToday
                                                          ? "Today"
                                                          : "Coming Up"),
                                                style: GoogleFonts.inter(
                                                  fontSize: 12,
                                                  fontWeight: isToday
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isCompleted
                                                      ? Colors.green
                                                      : (isToday
                                                            ? const Color(
                                                                0xffff7438,
                                                              )
                                                            : Colors.grey[600]),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "+${sankalp.karmaPointsPerDay}",
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: const Color(0xff4E342E),
                                          ),
                                        ),
                                        Text(
                                          "KARMA",
                                          style: GoogleFonts.inter(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff8D6E63),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (!isSankalpCompleted) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 60,
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
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          context.read<SankalpBloc>().add(
                            ReportDailyStatus(
                              userSankalpId: userSankalp!.id,
                              status: 'yes',
                            ),
                          );
                        },
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Mark Day $currentDayDisplay Completed",
                                style: GoogleFonts.inter(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xff8D6E63),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff8D6E63).withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () => Get.back(),
                        child: Center(
                          child: Text(
                            "Back to My Sankalp",
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
