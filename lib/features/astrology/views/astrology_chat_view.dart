import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/astrologist_model.dart';
import '../controllers/astrology_chat_controller.dart';
import '../models/chat_models.dart';

class AstrologyChatView extends GetView<AstrologyChatController> {
  final Astrologist expert;
  const AstrologyChatView({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    Get.put(AstrologyChatController(expert: expert), tag: expert.id);

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: const Color(0xFFFFF3E0), // Peach/Beige background
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Main content: messages + suggestions/topics/questions
            Expanded(
              child: Stack(
                children: [
                  // Chat messages
                  Obx(() {
                    if (controller.messages.isEmpty)
                      return const SizedBox.shrink();
                    return ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
                      itemCount: controller.messages.length,
                      itemBuilder: (context, index) {
                        final msg = controller.messages[index];
                        return _buildChatBubble(
                          msg,
                          controller.isMessageFromMe(msg),
                        );
                      },
                    );
                  }),

                  // Topics / Questions overlay
                  Obx(() {
                    if (!controller.isRequestAccepted.value ||
                        !controller.showSuggestions.value ||
                        controller.messages.isNotEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Display questions directly on the chat screen if a topic is selected
                    if (controller.selectedTopic.value != null) {
                      return _buildQuestionList(
                        controller.selectedTopic.value!,
                      ); // Show questions
                    }
                    return SingleChildScrollView(
                      child: _buildTopicCards(context),
                    );
                  }),
                ],
              ),
            ),

            // Input area
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  AstrologyChatController get controller => _getController();

  AstrologyChatController _getController() =>
      Get.find<AstrologyChatController>(tag: expert.id);

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFFFF3E0), // Match Scaffold background
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF5D4037)),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(expert.image),
                backgroundColor: AppTheme.cardBackground,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expert.name.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3E2723),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Obx(() {
                      final isTyping = _getController().isTyping.value;
                      final status = _getController().onlineStatus.value;

                      if (isTyping) {
                        return Text(
                          "TYPING...",
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(
                              0xFF8D6E63,
                            ), // Brownish for typing
                          ),
                        );
                      }

                      return Text(
                        status,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: status == "ONLINE"
                              ? Colors.green
                              : Colors.grey,
                        ),
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      "• Vedic Astrology", // Hardcoded or from expert.expertise
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 10,
                      color: const Color(0xFF5D4037),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      "15/Min", // Hardcoded or use expert.charge
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(
                      () => Text(
                        controller.isRequestAccepted.value
                            ? "•  ${_getController().formatTime(_getController().chatDuration.value)}"
                            : "•  Waiting...",
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8B4513),
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
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Center(
            child: SizedBox(
              height: 28,
              child: OutlinedButton(
                onPressed: () => _getController().showEndChatDialog(
                  "End Chat?",
                  "Are you sure you want to end this session?",
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  side: const BorderSide(color: Colors.red, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  "END",
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Vertical Topic Cards ──────────────────────────────────────────────────
  Widget _buildTopicCards(BuildContext context) {
    // Mapping specific colors from design for icons backgrounds

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            "WHAT YOU WOULD LIKE TO DISCUS?",
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF9E9E9E), // Grey text
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          _buildVerticalTopicCard(
            context,
            icon: Icons.trending_up,
            iconColor: Colors.orange,
            bgIconColor: const Color(0xFFFFE0B2),
            label: "Career Growth",
            topic: Topic.career,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.favorite,
            iconColor: Colors.pink,
            bgIconColor: const Color(0xFFF8BBD0),
            label: "Relationship Advice",
            topic: Topic.relationship,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.spa,
            iconColor: Colors.green,
            bgIconColor: const Color(0xFFC8E6C9),
            label: "Health & Wellness",
            topic: Topic.health,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.account_balance_wallet,
            iconColor: Colors.blue,
            bgIconColor: const Color(0xFFBBDEFB),
            label: "Financial Stability", // Swapped position to match design
            topic: Topic.finance,
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalTopicCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color bgIconColor,
    required String label,
    required Topic topic,
  }) {
    return InkWell(
      onTap: () => controller.selectTopic(topic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgIconColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF212121),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Questions List after selecting topic ─────────────────────────────────
  Widget _buildQuestionList(Topic topic) {
    final questions = controller.getCurrentQuestions();
    final topicName = topic.toString().split('.').last.capitalizeFirstLetter();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: controller.goBackToTopics,
              ),
              const SizedBox(width: 8),
              Text(
                "$topicName Questions",
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Questions
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: questions.map((qMap) {
                  final question = qMap["q"]!;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: InkWell(
                      onTap: () => controller.selectQuestion(question),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.lightGold,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                question,
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF8D6E63)
              : Colors.white, // Brown for user, White for expert
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isUser ? Colors.white : const Color(0xFF3E2723),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isUser ? Colors.white70 : Colors.grey,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead
                        ? Icons.done_all
                        : msg.isDelivered
                        ? Icons.done_all
                        : Icons.check,
                    size: 14,
                    color: msg.isRead ? Colors.blue : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Obx(() {
      if (!controller.isRequestAccepted.value) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          color: Colors.white,
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "Waiting for expert to accept...",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        color: Colors.transparent,
        child: SafeArea(
          top: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Plus Button
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0), // Slightly darker or same as bg
                  shape: BoxShape.circle,
                ),
                // Use a slight elevation or just icon
                child: IconButton(
                  onPressed: () {}, // Add attachment logic if needed
                  icon: const Icon(Icons.add, color: Color(0xFF8D6E63)),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.transparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    cursorColor: const Color(0xFF8D6E63),
                    decoration: InputDecoration(
                      hintText: "Ask about your........",
                      hintStyle: GoogleFonts.inter(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      controller.showSuggestions.value = value.trim().isEmpty;
                    },
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: controller.sendMessage,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8D6E63), // Brown send button
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
