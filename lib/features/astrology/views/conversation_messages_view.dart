import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_theme.dart';
import '../controllers/chat_history_controller.dart';
import '../models/chat_models.dart';

class ConversationMessagesView extends StatelessWidget {
  final String conversationId;

  const ConversationMessagesView({super.key, required this.conversationId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatHistoryController>();
    // Fetch messages only once, not on every rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.messages.isEmpty || controller.isLoadingMessages.value) {
        controller.fetchMessages(conversationId);
      }
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
        title: Row(
          children: [
            // Partner avatar
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                image: DecorationImage(
                  image: NetworkImage(
                    controller.currentPartnerPhoto.isNotEmpty
                        ? controller.currentPartnerPhoto
                        : 'https://randomuser.me/api/portraits/men/1.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.currentPartnerName,
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
          itemCount:
              controller.messages.length +
              (controller.sessionDetails.isNotEmpty ? 1 : 0),
          itemBuilder: (context, index) {
            // Show session summary at the top
            if (controller.sessionDetails.isNotEmpty) {
              if (index == 0) {
                return _buildSessionSummary(controller.sessionDetails);
              }
              // Adjust index for messages
              index = index - 1;
            }

            final msg = controller.messages[index];
            final isUser = controller.isMessageFromMe(msg);
            return _buildChatBubble(msg, isUser);
          },
        );
      }),
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

  Widget _buildSessionSummary(Map<String, dynamic> details) {
    final duration = details['duration'] ?? 0;
    final credits = details['creditsUsed'] ?? 0;
    final summary = details['summary'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
