import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/chat_history_controller.dart';
import 'conversation_messages_view.dart';
import '../../../common/models/astrologist_model.dart';
import 'astrology_chat_view.dart';
import '../../../common/utils.dart';

class ConversationHistoryView extends StatelessWidget {
  const ConversationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatHistoryController());

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
          'Chat History',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildFilterChips(controller),
          Expanded(
            child: RefreshIndicator(
              color: AppTheme.primaryGold,
              onRefresh: controller.fetchConversations,
              child: Obx(() {
                Utils.print(
                  '🔄 Obx rebuild: isLoading=${controller.isLoading.value}, count=${controller.conversations.length}',
                );
                if (controller.isLoading.value) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 6,
                    itemBuilder: (_, __) => _buildShimmerCard(),
                  );
                }

                if (controller.conversations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 72,
                          color: AppTheme.textSecondary.withOpacity(0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a chat with an expert to see it here',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: controller.conversations.length,
                  itemBuilder: (context, index) {
                    final conv = controller.conversations[index];
                    return _buildConversationCard(context, conv, controller);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(
    BuildContext context,
    Map<String, dynamic> conv,
    ChatHistoryController controller,
  ) {
    final name = controller.getPartnerName(conv);
    final photo = controller.getPartnerPhoto(conv);
    final status = controller.getStatus(conv);
    final date = controller.getFormattedDate(conv);

    final bool isEnded = status.toLowerCase() == 'ended';
    final bool isActive = status.toLowerCase() == 'active';

    Color statusColor = isActive
        ? Colors.green
        : isEnded
        ? const Color(0xFF8D6E63)
        : Colors.orange;
    String statusLabel = status[0].toUpperCase() + status.substring(1);

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
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                photo.isNotEmpty
                    ? Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          image: DecorationImage(
                            image: NetworkImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : Container(
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
                        ],
                      ),
                    ],
                  ),
                ),

                // Date + unread badge / arrow
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
                    Obx(() {
                      final conversationId = controller.getConversationId(conv);
                      final count =
                          controller.unreadCounts[conversationId] ?? 0;
                      if (count > 0) {
                        return Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE57373),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      return Icon(
                        Icons.chevron_right,
                        color: AppTheme.textSecondary.withOpacity(0.5),
                        size: 20,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            if (isActive) {
              final partnerId = controller.getPartnerId(conv);

              // Guard: prevent navigation with empty partner ID
              if (partnerId.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Could not identify the partner for this conversation.',
                  backgroundColor: const Color(0xFFE57373),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              final expert = Astrologist(
                id: partnerId,
                name: name,
                image: photo,
                skills: ['Vedic'],
                languages: ['English', 'Hindi'],
                experience: 5,
                rating: 4.5,
                totalConsultations: 100,
                pricePerMinute: 15,
                isOnline: true,
                bio: 'Astrologer',
              );

              Get.to(() => AstrologyChatView(expert: expert));
            } else {
              final conversationId = controller.getConversationId(conv);
              controller.currentPartnerName = name;
              controller.currentPartnerPhoto = photo;
              controller.currentPartnerId = controller.getPartnerId(conv);
              controller.currentPartnerExpertise = controller
                  .getPartnerExpertise(conv);
              controller.currentPartnerExperience = controller
                  .getPartnerExperience(conv);
              controller.currentPartnerRating = controller.getPartnerRating(
                conv,
              );
              controller.currentSessionStatus = status;
              controller.currentSessionDate = date;

              // Mark as read when opening history
              controller.markConversationAsRead(conversationId);

              Get.to(
                () => ConversationMessagesView(conversationId: conversationId),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildFilterChips(ChatHistoryController controller) {
    final filters = ['All', 'Active', 'Pending', 'Accepted', 'Ended'];
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final value = filter.toLowerCase();
          return Obx(() {
            final isSelected = controller.selectedStatus.value == value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => controller.changeStatus(value),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGold : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? Colors.transparent
                          : AppTheme.primaryGold.withOpacity(0.3),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          });
        },
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
