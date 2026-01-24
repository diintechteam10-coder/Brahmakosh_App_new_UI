import 'package:brahmakosh/common_imports.dart';
import 'package:brahmakosh/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../common/models/astrologist_model.dart';
import '../controllers/astrology_chat_controller.dart';
import '../models/chat_session_model.dart'; // Import ChatSession model

class AstrologyChatView extends GetView<AstrologyChatController> {
  final Astrologist expert;
  const AstrologyChatView({super.key, required this.expert});

  @override
  Widget build(BuildContext context) {
    Get.put(AstrologyChatController(expert: expert), tag: expert.id);

    return Scaffold(
      key: controller.scaffoldKey, // Assign the GlobalKey to Scaffold
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      drawer: Drawer(
        backgroundColor: AppTheme.backgroundLight,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
           Container(
  height: 120,
  decoration: const BoxDecoration(
    gradient: AppTheme.goldGradient,
  ),
  child: Padding(
    padding: const EdgeInsets.only(left: 20),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Chat with ${expert.name}',
        style: GoogleFonts.cinzel(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
    ),
  ),
),

            Obx(() => Column(
                  children: controller.chatSessions
                      .map((session) => ListTile(
                            leading: const Icon(Icons.chat_bubble_outline, color: AppTheme.textSecondary),
                            title: Text(
                              session.topic,
                              style: GoogleFonts.lora(color: AppTheme.textPrimary),
                            ),
                            subtitle: Text(
                              '${session.timestamp.day}/${session.timestamp.month}/${session.timestamp.year}, ${session.timestamp.hour}:${session.timestamp.minute.toString().padLeft(2, '0')}',
                              style: GoogleFonts.lora(fontSize: 10, color: AppTheme.textSecondary),
                            ),
                            onTap: () => controller.loadChatSession(session),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.lightGoldGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Removed Security banner

              // Main content: messages + suggestions/topics/questions
              Expanded(
                child: Stack(
                  children: [
                    // Chat messages
                    Obx(() {
                      if (controller.messages.isEmpty) return const SizedBox.shrink();
                      return ListView.builder(
                        controller: controller.scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemCount: controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];
                          return _buildChatBubble(msg["text"], msg["isUser"], msg["time"]);
                        },
                      );
                    }),

                    // Topics / Questions overlay
                    Obx(() {
                      if (!controller.showSuggestions.value || controller.messages.isNotEmpty) {
                        return const SizedBox.shrink();
                      }

                      // Display questions directly on the chat screen if a topic is selected
                      if (controller.selectedTopic.value != null) {
                        return _buildQuestionList(controller.selectedTopic.value!); // Show questions
                      }
                      return Center(
                        child: SingleChildScrollView(
                          child: _buildTopicCards(context),
                        ),
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
      ),
    );
  }

  AstrologyChatController get controller => _getController();

  AstrologyChatController _getController() => Get.find<AstrologyChatController>(tag: expert.id);

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.goldGradient,
        ),
      ),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu, color: AppTheme.textPrimary, size: 24), // Drawer icon
            onPressed: () => Scaffold.of(context).openDrawer(), // Open the drawer
          );
        },
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(expert.image),
            backgroundColor: AppTheme.cardBackground,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expert.name,
                  style: GoogleFonts.cinzel(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow( // Subtle shadow for online indicator
                            color: AppTheme.successGreen.withOpacity(0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "Online",
                      style: GoogleFonts.lora( // Use Lora for body text
                        fontSize: 10,
                        color: AppTheme.textSecondary, // Secondary text color
                        fontWeight: FontWeight.w500,
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
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardBackground.withOpacity(0.9), // Card background with slight opacity
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.lightGold, width: 1), // Light gold border
          ),
          child: Center(
            child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, size: 14, color: AppTheme.textPrimary),
                    const SizedBox(width: 6),
                    Text(
                      _getController().formatTime(_getController().secondsRemaining.value),
                      style: GoogleFonts.cinzel( // Use Cinzel for bold text
                        color: AppTheme.textPrimary, // Primary text color
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                )),
          ),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.15), // Error red with opacity
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.errorRed.withOpacity(0.5), width: 1), // Error red border
            ),
            child: const Icon(Icons.call_end, color: AppTheme.errorRed, size: 18), // Error red icon
          ),
          onPressed: () => _getController().showEndChatDialog("End Chat?", "Are you sure you want to end this session?"),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─── Initial Topic Cards ──────────────────────────────────────────────────
  Widget _buildTopicCards(BuildContext context) {
    final topics = [
      {"emoji": "💼", "label": "Career", "topic": Topic.career},
      {"emoji": "❤️", "label": "Relationship", "topic": Topic.relationship},
      {"emoji": "💰", "label": "Finance", "topic": Topic.finance},
      {"emoji": "🧠", "label": "Health", "topic": Topic.health},
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    // Adjusted cardWidth to prevent overflow
    final cardWidth = ((screenWidth - 24 - 32) / 2).clamp(90.0, 110.0); 
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

             Text(
          "How can I guide you today?",
          style: GoogleFonts.cinzel(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 20),
        
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: topics.take(2).map((t) => _buildTopicCard(t, cardWidth)).toList(),
          ),
          const SizedBox(height: 12), // Reduced vertical spacing further
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: topics.skip(2).map((t) => _buildTopicCard(t, cardWidth)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topicData, double cardWidth) { // Added context
    final topic = topicData["topic"] as Topic;
    final emoji = topicData["emoji"] as String;
    final label = topicData["label"] as String;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4), // Reduced horizontal padding
      child: InkWell(
        onTap: () => controller.selectTopic(topic),
        borderRadius: BorderRadius.circular(14), // Smaller border radius
        child: Container(
          width: cardWidth,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10), // Smaller padding
          decoration: BoxDecoration(
            color: AppTheme.cardBackground, // Use app theme card background
            borderRadius: BorderRadius.circular(14), // Match InkWell radius
            border: Border.all(color: AppTheme.lightGold, width: 1), // Light gold border
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightGold.withOpacity(0.2), // Subtle shadow
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row( // Changed to Row for icon and text in same row
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16), // Smaller emoji
              ),
              const SizedBox(width: 4), // Reduced spacing between emoji and text
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.cinzel( // Use Cinzel for titles
                    fontSize: 10, // Smaller font size
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary, // Use app theme text color
                  ),
                  overflow: TextOverflow.ellipsis, // Added ellipsis for overflow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Questions List after selecting topic ─────────────────────────────────
  Widget _buildQuestionList(Topic topic) {
    final questions = controller.getCurrentQuestions();
    final topicName = topic.toString().split('.').last.capitalizeFirstLetter();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16), // Adjusted vertical padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + Back button
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textSecondary, size: 20),
                onPressed: controller.goBackToTopics,
              ),
              const SizedBox(width: 8),
              Text( // Question title style
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
          ...questions.map((qMap) {
            final question = qMap["q"]!;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10), // Reduced vertical spacing
              child: InkWell(
                onTap: () => controller.selectQuestion(question),
                borderRadius: BorderRadius.circular(16), // Smaller border radius
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Smaller padding
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground, // Use app theme card background
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.lightGold, width: 1), // Light gold border
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: GoogleFonts.lora(
                            fontSize: 14, // Smaller font size
                            color: AppTheme.textPrimary, // Use app theme text color
                            height: 1.4,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppTheme.textSecondary),
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

  Widget _buildChatBubble(String text, bool isUser, DateTime time) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align bubble to right for user, left for expert
          children: [ // Text + time inside bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft, // Same gold gradient for user
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primaryGold, AppTheme.darkGold],
                      )
                    : null, // No gradient for expert
                color: isUser ? null : AppTheme.cardBackground, // Card background for expert
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16), // Consistent border radius
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4), // Small tail for user's bubble
                  bottomRight: Radius.circular(isUser ? 4 : 16), // Small tail for expert's bubble
                ),
                border: Border.all( // Consistent border color
                  color: isUser ? AppTheme.primaryGold : AppTheme.lightGold,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.2), // Subtle shadow for user's bubble
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      color: AppTheme.textPrimary, // Primary text color
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textSecondary, // Secondary text color
                      fontWeight: FontWeight.w500, // Medium font weight
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground, // Card background for input bar
        border: Border(top: BorderSide(color: AppTheme.lightGold, width: 1)), // Light gold top border
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground, // Card background for text field
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.lightGold, // Light gold border
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: controller.messageController,
                  style: GoogleFonts.lora( // Lora for input text
                    fontSize: 15,
                    color: AppTheme.textPrimary, // Primary text color
                  ),
                  cursorColor: AppTheme.primaryGold, // Primary gold cursor
                  decoration: InputDecoration(
                    hintText: "Ask anything...",
                    hintStyle: GoogleFonts.lora( // Lora for hint text
                      color: AppTheme.textSecondary, // Secondary text color
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryGold, AppTheme.darkGold], // Gold gradient for send button
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryGold.withOpacity(0.35), blurRadius: 8, offset: Offset(0, 2)), // Subtle shadow
                  ],
                ),
                child: const Icon(Icons.send_rounded, color: AppTheme.textPrimary, size: 18), // Primary text color for icon
              ),
            ),
          ],
        ),
      ),
    );
  }
}
