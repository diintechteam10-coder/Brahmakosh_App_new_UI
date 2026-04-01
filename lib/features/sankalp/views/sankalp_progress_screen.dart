import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../common/utils.dart';

import '../blocs/sankalp_bloc.dart';
import '../blocs/sankalp_event.dart';
import '../blocs/sankalp_state.dart';
import '../models/sankalp_model.dart';
import '../models/sankalp_progress_model.dart';

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Progress",
          style: GoogleFonts.lora(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 28),
          onPressed: () => Get.back(),
        ),
      ),
      body: BlocConsumer<SankalpBloc, SankalpState>(
        listener: (context, state) {
          if (state is SankalpOperationSuccess) {
            _showSuccessDialog(context, state.message);
            context.read<SankalpBloc>().add(FetchSankalpProgress(widget.sankalpId));
          } else if (state is SankalpError) {
            Get.snackbar(
              "Error",
              state.message,
              backgroundColor: Colors.red.withOpacity(0.8),
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          }
        },
        builder: (context, state) {
          if (state is SankalpLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          UserSankalpModel? userSankalp;
          ProgressStats? progressStats;

          if (state is SankalpProgressLoaded) {
            userSankalp = state.progressData.userSankalp;
            progressStats = state.progressData.progress;
          } else if (state is SankalpLoaded) {
            try {
              userSankalp = state.userSankalps.firstWhere((s) => s.id == widget.sankalpId);
            } catch (_) {}
          }

          if (userSankalp == null) {
            return const Center(child: Text("Loading...", style: TextStyle(color: Colors.white70)));
          }
          final activeUserSankalp = userSankalp;

          final sankalp = userSankalp.sankalp;
          final totalDays = progressStats?.totalDays ?? activeUserSankalp.totalDays;
          final completedDays = progressStats?.yesCount ?? 
              activeUserSankalp.dailyReports.where((r) => r.status == 'yes').length;
          final double progressPercentage = progressStats != null
              ? progressStats.progressPercentage.toDouble()
              : (totalDays > 0 ? (completedDays / totalDays) * 100 : 0);

          final isSankalpCompleted = activeUserSankalp.status == 'completed';
          final rawCurrentDay = progressStats?.currentDay ?? activeUserSankalp.currentDay;
          final currentDayDisplay = rawCurrentDay > totalDays ? totalDays : rawCurrentDay;
          
          final now = DateTime.now();
          debugPrint("=== Sankalp Progress Debug ===");
          debugPrint("Current Day: $rawCurrentDay");
          debugPrint("Total Days: $totalDays");
          debugPrint("Status: ${activeUserSankalp.status}");
          debugPrint("Reports Count: ${activeUserSankalp.dailyReports.length}");
          for (var r in activeUserSankalp.dailyReports) {
            debugPrint(" - Day ${r.day}: ${r.status} (${r.date})");
          }

          final bool isTodayMarkedAndCompleted = activeUserSankalp.dailyReports.any((r) {
            final reportDate = r.date;
            if (reportDate == null) return r.day == currentDayDisplay && r.status == 'yes';
            return reportDate.year == now.year &&
                reportDate.month == now.month &&
                reportDate.day == now.day &&
                r.status == 'yes';
          });
          
          final bool isTodayMarkedAsNo = activeUserSankalp.dailyReports.any((r) {
            final reportDate = r.date;
            if (reportDate == null) return r.day == currentDayDisplay && r.status == 'no';
            return reportDate.year == now.year &&
                reportDate.month == now.month &&
                reportDate.day == now.day &&
                r.status == 'no';
          });

          // A day is "Actually Missed" if its scheduled date is before today and it wasn't reported yes
          final bool isDayMissedByDate = activeUserSankalp.dailyReports.any((r) {
            final reportDate = r.date;
            if (reportDate == null) return false;
            
            // Compare only dates (year, month, day)
            final reportDateOnly = DateTime(reportDate.year, reportDate.month, reportDate.day);
            final todayDateOnly = DateTime(now.year, now.month, now.day);
            
            return reportDateOnly.isBefore(todayDateOnly) && r.day == currentDayDisplay && r.status != 'yes';
          });

          final bool isActionDisabled = isTodayMarkedAndCompleted || isTodayMarkedAsNo || isDayMissedByDate;
          
          debugPrint("=== Sankalp UI Status ===");
          debugPrint("Current Day Display: $currentDayDisplay");
          debugPrint("isTodayMarkedAndCompleted: $isTodayMarkedAndCompleted");
          debugPrint("isTodayMarkedAsNo: $isTodayMarkedAsNo");
          debugPrint("isDayMissedByDate: $isDayMissedByDate");
          debugPrint("isActionDisabled: $isActionDisabled");
          debugPrint("=========================");

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  sankalp.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Day $currentDayDisplay of $totalDays",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Overall Progress",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "${progressPercentage.toInt()}%",
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryGold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressPercentage / 100,
                              backgroundColor: Colors.white.withOpacity(0.05),
                              color: AppTheme.primaryGold,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "$totalDays Days ${sankalp.subcategory.isNotEmpty ? sankalp.subcategory : 'Daily Routine'}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ClipOval(
                                child: Image.asset(
                                  'assets/images/brahmkosh_logo.jpeg',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, s) => const Icon(Icons.stars, color: AppTheme.primaryGold, size: 24),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "+${sankalp.karmaPointsPerDay} Karma / Day",
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          if (isActionDisabled)
                            // Today Completed/Closed Status
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: isTodayMarkedAndCompleted ? const Color(0xFF1B3326) : const Color(0xFF331B1B),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: (isTodayMarkedAndCompleted ? const Color(0xFF2E7D32) : Colors.red).withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isTodayMarkedAndCompleted ? Icons.celebration : Icons.error_outline, 
                                    color: isTodayMarkedAndCompleted ? const Color(0xFF4CAF50) : Colors.redAccent, 
                                    size: 20
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSankalpCompleted 
                                      ? "Sankalp completed" 
                                      : (isTodayMarkedAndCompleted ? "Today Completed! Keep it up..." : "This day was missed."),
                                    style: GoogleFonts.poppins(
                                      color: isTodayMarkedAndCompleted ? const Color(0xFF4CAF50) : Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            // Motivational Goal (SCREEN 7)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                              ),
                              child: Center(
                                child: Text(
                                  "Complete $totalDays days to earn +${sankalp.completionBonusKarma} Karma",
                                  style: GoogleFonts.poppins(
                                    color: AppTheme.primaryGold,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    Text(
                      "Your Journey",
                      style: GoogleFonts.lora(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
    
                    // Journey Timeline List
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: totalDays,
                      itemBuilder: (context, index) {
                        final dayNum = index + 1;
                        final report = userSankalp?.dailyReports.firstWhere(
                          (r) => r.day == dayNum,
                          orElse: () => DailyReport(day: dayNum, status: 'not_reported'),
                        );
                        final status = report?.status ?? 'not_reported';
                        
                        // Check if missed by date
                        bool isMissedByDate = false;
                        if (status == 'not_reported' && report?.date != null) {
                          final reportDateOnly = DateTime(report!.date!.year, report.date!.month, report.date!.day);
                          final todayDateOnly = DateTime(now.year, now.month, now.day);
                          if (reportDateOnly.isBefore(todayDateOnly)) {
                            isMissedByDate = true;
                          }
                        }

                        final isCompleted = status == 'yes';
                        final isMissed = status == 'no' || isMissedByDate;
                        final isToday = dayNum == currentDayDisplay && !isSankalpCompleted && !isMissedByDate;
    
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isCompleted 
                                ? const Color(0xFF2E7D32).withOpacity(0.5) 
                                : isMissed 
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.05),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Day Number (Cinzel)
                              SizedBox(
                                width: 50,
                                child: Text(
                                  dayNum < 10 ? "0$dayNum" : "$dayNum",
                                  style: GoogleFonts.lora(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted 
                                      ? const Color(0xFF4CAF50) 
                                      : isMissed
                                        ? Colors.red.withOpacity(0.6)
                                        : AppTheme.primaryGold.withOpacity(0.8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              
                              // Status Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Day $dayNum",
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                          ),
                                        ),
                                        if (isToday) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                                            ),
                                            child: Text(
                                              "TODAY",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryGold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(
                                          isCompleted ? Icons.check_circle : isMissed ? Icons.cancel : Icons.circle_outlined,
                                          size: 14,
                                          color: isCompleted ? const Color(0xFF4CAF50) : isMissed ? Colors.redAccent : Colors.white.withOpacity(0.4),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          isCompleted ? "Completed" : isMissed ? "Missed" : "Not Completed",
                                          style: GoogleFonts.poppins(
                                            color: isCompleted ? const Color(0xFF4CAF50) : isMissed ? Colors.redAccent : Colors.white.withOpacity(0.4),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Karma Points
                              Text(
                                "+${sankalp.karmaPointsPerDay} KARMA",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.4),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    if (!isSankalpCompleted) ...[
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isActionDisabled) {
                              context.read<SankalpBloc>().add(ClearSankalpOperationStatus());
                              Get.back();
                            } else {
                              Utils.print("Mark Day $currentDayDisplay Complete clicked for Sankalp: ${sankalp.title} (ID: ${activeUserSankalp.id})");
                              context.read<SankalpBloc>().add(
                                ReportDailyStatus(userSankalpId: activeUserSankalp.id, status: 'yes'),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isActionDisabled ? Colors.grey[800] : AppTheme.primaryGold,
                            foregroundColor: isActionDisabled ? Colors.white70 : Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isActionDisabled ? Icons.arrow_forward : Icons.check_circle_outline,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isActionDisabled
                                  ? "Go To My Sankalp" 
                                  : "Mark Day $currentDayDisplay Complete",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    final sankalpBloc = context.read<SankalpBloc>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.2)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 60),
              const SizedBox(height: 16),
              Text(
                message.contains("Already") ? "Information" : "Great Job!",
                style: GoogleFonts.lora(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    sankalpBloc.add(ClearSankalpOperationStatus());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

