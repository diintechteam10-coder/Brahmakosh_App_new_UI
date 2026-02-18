import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'astrologist_profile_view.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/chat_history_controller.dart';
import '../models/chat_models.dart';

class ConversationMessagesView extends StatelessWidget {
  final String conversationId;

  const ConversationMessagesView({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatHistoryController>();
    // Always fetch if the conversation changed (fixes: tapping different
    // history items was showing stale messages from the first opened one).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMessages(conversationId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFFBE6D0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBE6D0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // Partner avatar with gold border
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGold.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
              child: controller.currentPartnerPhoto.isNotEmpty
                  ? CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        controller.currentPartnerPhoto,
                      ),
                      backgroundColor: const Color(0xFFD7CCC8),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFD4AF37),
                            Color(0xFFA67C00),
                          ], // Gold Gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name
                  Text(
                    controller.currentPartnerName,
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Expertise + Experience row or Status
                  Row(
                    children: [
                      // Online Status Indicator similar to Chat Screen
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color:
                              Colors.grey, // History so likely offline/unknown
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${controller.currentPartnerExperience} Years of Experience', // Static context
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF5D4037),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (controller.currentPartnerRating > 0) ...[
                        const Icon(
                          Icons.star_rounded,
                          size: 12,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          controller.currentPartnerRating.toStringAsFixed(1),
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF5D4037),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: const [],
      ),
      body: Obx(() {
        if (controller.isLoadingMessages.value) {
          return _buildLoadingState();
        }

        if (controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_outlined,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.4),
                ),
                const SizedBox(height: 16),
                Text(
                  'No messages in this conversation',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          // +1 for session summary header if available
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final msg = controller.messages[index];
            final isUser = controller.isMessageFromMe(msg);
            return _buildChatBubble(msg, isUser);
          },
        );
      }),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Session Summary (if available)
              if (controller.sessionDetails.isNotEmpty) ...[
                _buildSessionSummary(
                  controller.sessionDetails,
                  isEmbedded: true,
                ),
                const SizedBox(height: 16),
              ],

              // New Chat Button
              ElevatedButton(
                onPressed: () {
                  // Navigate to Astrologist Profile for new chat
                  final expert = controller.getAstrologistItemForConversation(
                    conversationId,
                  );
                  Get.to(() => AstrologistProfileView(expert: expert));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA67C00), // Dark Gold
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.chat_bubble_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "New Chat",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFA67C00) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: isUser
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isUser ? Colors.white : AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.createdAt),
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : AppTheme.textSecondary.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$hour:$min';
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (_, index) {
        final isRight = index % 2 == 0;
        return Align(
          alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              width: 200,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionSummary(
    Map<String, dynamic> details, {
    bool isEmbedded = false,
  }) {
    final duration = details['duration'] ?? 0;
    final credits = details['creditsUsed'] ?? 0;
    final summary = details['summary'] ?? '';

    // If embedded, we remove the container styling to avoid double-boxing
    return Container(
      margin: isEmbedded ? EdgeInsets.zero : const EdgeInsets.only(bottom: 20),
      padding: isEmbedded ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: isEmbedded
          ? null
          : BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: AppTheme.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Session Summary',
                style: GoogleFonts.lora(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Duration', '${duration}m'),
              _buildSummaryStat('Credits', '$credits'),
              _buildSummaryStat('Messages', '${details['messagesCount'] ?? 0}'),
            ],
          ),
          if (summary.toString().isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              'Highlights',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              summary,
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.5,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryGold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}
