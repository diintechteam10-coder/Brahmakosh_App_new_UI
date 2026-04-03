import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/chat_history_controller.dart';
import '../../../common/widgets/custom_profile_avatar.dart';
import 'conversation_messages_view.dart';
import '../../../common/models/astrologist_model.dart';
import 'astrology_chat_view.dart';
import 'call_history_view.dart';
import '../../../common/utils.dart';
import '../../../core/utils/app_snackbar.dart';

class ConversationHistoryView extends StatelessWidget {
  const ConversationHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatHistoryController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Chat History',
          style: GoogleFonts.lora(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.phone_in_talk_outlined,
              color: Colors.white,
            ),
            onPressed: () => Get.to(() => const CallHistoryView()),
            tooltip: 'Call Logs',
          ),
        ],
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
                          color: Colors.white.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No conversations yet',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start a chat with an expert to see it here',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.5),
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
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
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
                CustomProfileAvatar(
                  imageUrl: photo,
                  radius: 26,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
                const SizedBox(width: 14),

                // Name + Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
                              style: GoogleFonts.poppins(
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
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.5),
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
                            style: GoogleFonts.poppins(
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
                AppSnackBar.showError(
                  'Error',
                  'Could not identify the partner for this conversation.',
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListView.builder(
          controller: controller.filterScrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final value = filter.toLowerCase();
            return Obx(() {
              final isSelected = controller.selectedStatus.value == value;
              return InkWell(
                onTap: () {
                  controller.changeStatus(value);
                  
                  // Centering logic
                  final screenWidth = MediaQuery.of(context).size.width;
                  const itemWidth = 100.0; // Approx width for history chips
                  double offset = (index * itemWidth) - (screenWidth / 2) + (itemWidth / 2);
                  
                  if (offset < 0) offset = 0;
                  final maxScroll = controller.filterScrollController.position.maxScrollExtent;
                  if (offset > maxScroll) offset = maxScroll;

                  controller.filterScrollController.animateTo(
                    offset,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                borderRadius: BorderRadius.circular(18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryGold : Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    filter.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1A1A1A),
      highlightColor: const Color(0xFF262626),
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

