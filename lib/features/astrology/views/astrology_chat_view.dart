import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/astrologist_model.dart';
import '../controllers/astrology_chat_controller.dart';
import '../models/chat_models.dart';
import 'widgets/astrology_chat_feedback_sheet.dart';
import '../../../common/widgets/custom_profile_avatar.dart';

class AstrologyChatView extends GetView<AstrologyChatController> {
  final Astrologist expert;
  const AstrologyChatView({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    Get.put(AstrologyChatController(expert: expert), tag: expert.id);

    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Obx(() {
          if (controller.isChatRejected.value) {
            return _buildRejectionReport(context);
          }
          if (controller.isChatEnded.value) {
            return _buildSummaryReport(context);
          }
          return Column(
            children: [
              // Chat Header Timer/Status
              _buildChatHeaderInfo(),

              // Main content: messages + suggestions/topics/questions
              Expanded(
                child: Stack(
                  children: [
                    // Chat messages
                    Obx(() {
                      if (controller.messages.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];
                          // Group messages by date
                          bool showDate = false;
                          if (index == 0) {
                            showDate = true;
                          } else {
                            final prevDate = controller.messages[index - 1].createdAt;
                            if (msg.createdAt.day != prevDate.day || 
                                msg.createdAt.month != prevDate.month) {
                              showDate = true;
                            }
                          }

                          return Column(
                            children: [
                              if (showDate) _buildDateDivider(msg.createdAt),
                              _buildChatBubble(
                                msg,
                                controller.isMessageFromMe(msg),
                              ),
                            ],
                          );
                        },
                      );
                    }),

                    // Topics / Questions overlay
                    Obx(() {
                      if (!controller.showSuggestions.value ||
                          controller.messages.isNotEmpty) {
                        return const SizedBox.shrink();
                      }

                      if (controller.selectedTopic.value != null) {
                        return _buildQuestionList(
                          controller.selectedTopic.value!,
                        );
                      }
                      return SingleChildScrollView(
                        child: _buildTopicCards(context),
                      );
                    }),
                  ],
                ),
              ),

              // Input area
              _buildInputBar(context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    String dateStr = "TODAY, ${date.day} ${controller.getMonthName(date.month)}";
    if (date.day != now.day) {
      dateStr = "${date.day} ${controller.getMonthName(date.month)}, ${date.year}";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          dateStr.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white54,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildChatHeaderInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, color: Color(0xFFD4AF37), size: 16),
              const SizedBox(width: 8),
              Obx(() => Text(
                controller.isRequestAccepted.value
                    ? controller.formatTime(controller.chatDuration.value)
                    : "00:00",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37),
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  AstrologyChatController get controller => _getController();

  AstrologyChatController _getController() =>
      Get.find<AstrologyChatController>(tag: expert.id);

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF141414),
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12),
            ),
            child: const Icon(Icons.chevron_left, color: Colors.white),
          ),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD4AF37), width: 1),
            ),
            child: CustomProfileAvatar(
              imageUrl: expert.image,
              radius: 18,
              borderWidth: 0,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expert.name,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Obx(() {
                      final status = controller.onlineStatus.value;
                      return Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: status == "ONLINE" ? Colors.green : Colors.grey,
                        ),
                      );
                    }),
                    const SizedBox(width: 8),
                    const Icon(Icons.access_time, size: 10, color: Color(0xFFD4AF37)),
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
            child: Obx(() {
              final isEnded = controller.isChatEnded.value;
              final isRejected = controller.isChatRejected.value;
              if (isEnded || isRejected) return const SizedBox.shrink();

              return InkWell(
                onTap: () {
                  if (controller.isRequestAccepted.value) {
                    controller.showEndChatDialog(
                      "End Chat?",
                      "Are you sure you want to end this session?",
                    );
                  } else {
                    controller.cancelChatRequest();
                  }
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.isRequestAccepted.value
                        ? Colors.red[900]
                        : const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.isRequestAccepted.value ? "END" : "CANCEL",
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: controller.isRequestAccepted.value
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryReport(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 2,
                ),
              ),
              child: CustomProfileAvatar(
                imageUrl: expert.image,
                radius: 50,
                borderWidth: 0,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Consultation Ended",
              style: GoogleFonts.lora(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Thank you for consulting with\n${expert.name}",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            Obx(() {
              if (controller.sessionDetails.isNotEmpty) {
                return _buildSessionSummary(controller.sessionDetails);
              }
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  children: [
                    Text(
                      "DURATION",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFD4AF37),
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.formatTime(controller.chatDuration.value),
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "New Chat",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => AstrologyChatFeedbackSheet(controller: controller),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Color(0xFFD4AF37)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Give Feedback",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionReport(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red[900]!, width: 2),
            ),
            child: CustomProfileAvatar(
              imageUrl: expert.image,
              radius: 50,
              borderWidth: 0,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Request Declined",
            style: GoogleFonts.lora(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "The expert is currently unavailable and has declined your request.\nPlease try again later or consult another expert.",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Get.back(); // Navigate back
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Find Another Expert",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Get.back(); // Navigate back
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                "Go Back",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionSummary(Map<String, dynamic> details) {
    final duration = details['duration'] ?? 0;
    final credits = details['creditsUsed'] ?? 0;
    final summary = details['summary'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.summarize, color: Color(0xFFD4AF37), size: 20),
              const SizedBox(width: 8),
              Text(
                'Session Summary',
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat('Duration', '${duration}m'),
              _buildSummaryStat('Credits', '$credits'),
              _buildSummaryStat('Messages', '${details['messagesCount'] ?? 0}'),
            ],
          ),
          if (summary.toString().isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Colors.white12),
            ),
            Text(
              'Highlights',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.white70,
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
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 11, color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildTopicCards(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        children: [
          Text(
            "WHAT YOU WOULD LIKE TO DISCUS?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white38,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          _buildVerticalTopicCard(
            context,
            icon: Icons.trending_up,
            iconColor: Colors.orange,
            label: "Career Growth",
            topic: Topic.career,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.favorite,
            iconColor: Colors.pink,
            label: "Relationship Advice",
            topic: Topic.relationship,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.spa,
            iconColor: Colors.green,
            label: "Health & Wellness",
            topic: Topic.health,
          ),
          const SizedBox(height: 12),
          _buildVerticalTopicCard(
            context,
            icon: Icons.account_balance_wallet,
            iconColor: Colors.blue,
            label: "Financial Stability",
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
    required String label,
    required Topic topic,
  }) {
    return InkWell(
      onTap: () => controller.selectTopic(topic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionList(Topic topic) {
    final questions = controller.getCurrentQuestions();
    final topicName = topic.toString().split('.').last.capitalizeFirstLetter();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white54,
                  size: 20,
                ),
                onPressed: controller.goBackToTopics,
              ),
              const SizedBox(width: 8),
              Text(
                "$topicName Questions",
                style: GoogleFonts.lora(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...questions.map((qMap) {
            final question = qMap["q"]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => controller.selectQuestion(question),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Color(0xFFD4AF37),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
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
              ? const Color(0xFFD4AF37)
              : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.content,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isUser ? Colors.black : Colors.white,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: isUser ? Colors.black54 : Colors.white54,
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
                    color: msg.isRead ? Colors.blue : Colors.black54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context) {
    return Obx(() {
      // After first message is sent, hide input until partner accepts
      if (controller.messages.isNotEmpty && !controller.isRequestAccepted.value) {
        return Container(
          padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Waiting for expert to accept...",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white12),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: const Color(0xFF141414),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  maxLines: 3,
                  minLines: 1,
                  controller: controller.messageController,
                  cursorColor: Colors.white,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Ask about your......",
                    hintStyle: GoogleFonts.poppins(color: Colors.white30, fontSize: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (val) => controller.showSuggestions.value = val.isEmpty,
                ),
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: controller.sendMessage,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFD4AF37),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
              ),
            ),
          ],
        ),
      );
    });
  }
}

