import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/call_history_controller.dart';
import '../models/call_history_model.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CallHistoryController());

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Call Logs',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryGold,
        onRefresh: controller.fetchCallHistory,
        child: Obx(() {
          if (controller.isLoading.value && controller.callLogs.isEmpty) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (_, __) => _buildShimmerCard(),
            );
          }

          if (controller.hasError.value && controller.callLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load call logs',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: controller.fetchCallHistory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (controller.callLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_in_talk_outlined,
                    size: 72,
                    color: AppTheme.textSecondary.withOpacity(0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No voice calls yet',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a voice call with an expert to see it here',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textSecondary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: controller.callLogs.length,
            itemBuilder: (context, index) {
              final log = controller.callLogs[index];
              return _buildCallCard(context, log, controller);
            },
          );
        }),
      ),
    );
  }

  Widget _buildCallCard(
    BuildContext context,
    CallHistoryItem log,
    CallHistoryController controller,
  ) {
    final name = controller.getPartnerName(log);
    final status = log.status ?? 'ended';
    final date = controller.getFormattedDate(log.createdAt);
    final duration = controller.formatDuration(log.durationSeconds);

    final bool isEnded = status.toLowerCase() == 'ended';
    final bool isRejected = status.toLowerCase() == 'rejected';

    Color statusColor = isEnded
        ? Colors.green
        : isRejected
        ? const Color(0xFFE57373)
        : Colors.orange;

    String statusLabel = status.isNotEmpty
        ? status[0].toUpperCase() + status.substring(1)
        : 'Ended';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar Default
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFD4AF37),
                      Color(0xFFA67C00),
                    ], // Gold Gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),

              // Name + Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusLabel,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        if (log.durationSeconds != null &&
                            log.durationSeconds! > 0) ...[
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 12,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                duration,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (log.voiceRecordings?.user?.signedUrl != null ||
                      log.voiceRecordings?.partner?.signedUrl != null)
                    Icon(
                      Icons.mic_outlined,
                      color: AppTheme.textSecondary.withOpacity(0.5),
                      size: 20,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
