import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/credit_history_controller.dart';

class CreditHistoryView extends StatelessWidget {
  const CreditHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreditHistoryController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'credit_history_title'.tr,
          style: GoogleFonts.lora(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGold),
          );
        }

        if (controller.creditHistory.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppTheme.primaryGold,
          onRefresh: () => controller.fetchCreditHistory(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification &&
                  notification.metrics.extentAfter < 100) {
                controller.fetchCreditHistory(loadMore: true);
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount:
                  controller.creditHistory.length +
                  (controller.hasMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.creditHistory.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGold,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }
                return _buildHistoryCard(controller.creditHistory[index]);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'no_credit_history_msg'.tr,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'credit_usage_appear_msg'.tr,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final int creditsUsed = item['creditsUsed'] ?? 0;
    final int billableMinutes = item['billableMinutes'] ?? 0;
    final String createdAt = item['createdAt'] ?? '';
    final partner = item['partner'];
    final String partnerName = partner is Map
        ? (partner['name'] ?? 'Astrologer')
        : 'Astrologer';
    final String partnerPhoto = partner is Map
        ? (partner['profilePhoto'] ?? partner['profilePicture'] ?? '')
        : '';
    final String expertise = partner is Map
        ? _parseExpertise(partner['expertise'])
        : '';

    // Format date
    String formattedDate = '';
    String formattedTime = '';
    if (createdAt.isNotEmpty) {
      try {
        final dt = DateTime.parse(createdAt).toLocal();
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
        formattedTime = DateFormat('hh:mm a').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Partner info + credits
          Row(
            children: [
              // Partner avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryGold.withOpacity(0.1),
                  backgroundImage: partnerPhoto.isNotEmpty
                      ? NetworkImage(partnerPhoto)
                      : null,
                  child: partnerPhoto.isEmpty
                      ? const Icon(
                          Icons.person,
                          size: 20,
                          color: AppTheme.primaryGold,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Partner name & expertise
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partnerName,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    if (expertise.isNotEmpty)
                      Text(
                        expertise,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              // Credits badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.toll, size: 14, color: AppTheme.primaryGold),
                    const SizedBox(width: 4),
                    Text(
                      '$creditsUsed',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 10),

          // Bottom row: Duration & Date
          Row(
            children: [
              // Duration
              _buildInfoChip(Icons.timer_outlined, 'min_suffix'.trParams({'min': billableMinutes.toString()})),
              const SizedBox(width: 16),
              // Date
              _buildInfoChip(Icons.calendar_today_outlined, formattedDate),
              const Spacer(),
              // Time
              Text(
                formattedTime,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF8D6E63),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF8D6E63)),
        const SizedBox(width: 4),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  String _parseExpertise(dynamic value) {
    if (value is List) return value.join(', ');
    if (value is String) return value;
    return '';
  }
}