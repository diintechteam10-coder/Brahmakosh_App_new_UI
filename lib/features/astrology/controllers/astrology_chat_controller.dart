import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart'; // For generating unique IDs
import '../../../common/gemini_service.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../common/models/astrologist_model.dart';
import '../../../common/utils.dart';
import '../../../common_imports.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../astrology/models/chat_session_model.dart'; // Import ChatSession model

extension StringExtension on String {
  String capitalizeFirstLetter() {
    // ← changed name
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }
}

enum Topic { career, relationship, finance, health }

class AstrologyChatController extends GetxController {
  final Astrologist expert;

  AstrologyChatController({required this.expert});

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  final GlobalKey<ScaffoldState> scaffoldKey =
      GlobalKey<ScaffoldState>(); // Added Scaffold key
  final messages = <Map<String, dynamic>>[].obs;
  final showSuggestions = true.obs;
  final selectedTopic = Rxn<Topic>();

  // New: Chat history management
  final chatSessions = <ChatSession>[].obs;
  String? currentChatId; // To keep track of the current chat session
  final Uuid uuid = const Uuid();

  Timer? _timer;
  final secondsRemaining = 300.obs;

  // Birth details from profile
  String? _name;
  String? _dob;
  String? _timeOfBirth;
  String? _placeOfBirth;
  String? _gowthra;

  @override
  void onInit() {
    super.onInit();
    _startTimer();
    _fetchUserProfile();
    _loadChatSessions(); // Load existing chat sessions
  }

  Future<void> _fetchUserProfile() async {
    try {
      final token = StorageService.getString(AppConstants.keyAuthToken);
      if (token == null || token.isEmpty) {
        Utils.print('No auth token found for profile fetch');
        return;
      }

      await callWebApiGet(
        null,
        ApiUrls.getProfile,
        token: token,
        showLoader: false,
        hideLoader: false,
        onResponse: (response) {
          try {
            final responseBody = json.decode(response.body);
            if (responseBody['success'] == true &&
                responseBody['data'] != null) {
              final userData = responseBody['data']['user'];
              final profile = userData['profile'];

              if (profile != null) {
                _name = profile['name'];
                _dob = profile['dob'];
                _timeOfBirth = profile['timeOfBirth'];
                _placeOfBirth = profile['placeOfBirth'];
                _gowthra = profile['gowthra'];

                Utils.print(
                  '✅ Birth details loaded: Name=$_name, DOB=$_dob, Time=$_timeOfBirth, Place=$_placeOfBirth, Gowthra=$_gowthra',
                );
              }
            }
          } catch (e) {
            Utils.print('❌ Error parsing profile: $e');
          }
        },
        onError: (error) {
          Utils.print('❌ Profile fetch error: $error');
        },
      );
    } catch (e) {
      Utils.print('❌ Exception fetching profile: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        showEndChatDialog("Time Over", "Your consultation session has ended.");
      }
    });
  }

  // New: Generate a concise topic for the chat
  String _generateChatTopic(String firstMessage) {
    if (selectedTopic.value != null) {
      return "${selectedTopic.value!.toString().split('.').last.capitalizeFirstLetter()} Chat";
    } else {
      final words = firstMessage.split(' ');
      return words.take(3).join(' ').capitalizeFirstLetter();
    }
  }

  // New: Save the current chat session
  void _saveCurrentChatSession() {
    if (messages.isEmpty) return; // Only save if there are messages

    final topic = _generateChatTopic(messages.first['text']);

    if (currentChatId == null) {
      // New chat session
      currentChatId = uuid.v4();
      final newSession = ChatSession(
        id: currentChatId!,
        expertId: expert.id,
        topic: topic,
        messages: List<Map<String, dynamic>>.from(
          messages,
        ), // Deep copy messages
        timestamp: DateTime.now(),
      );
      chatSessions.add(newSession);
    } else {
      // Update existing chat session
      final existingIndex = chatSessions.indexWhere(
        (session) => session.id == currentChatId,
      );
      if (existingIndex != -1) {
        chatSessions[existingIndex] = ChatSession(
          id: currentChatId!,
          expertId: expert.id,
          topic: topic, // Topic might change if user asks different questions
          messages: List<Map<String, dynamic>>.from(
            messages,
          ), // Update messages
          timestamp: DateTime.now(), // Update timestamp
        );
      }
    }
    // For persistence, you would save chatSessions to local storage here.
    // Example: StorageService.setString('chat_sessions_${expert.id}', json.encode(chatSessions.toJson()));
  }

  // New: Load a previous chat session
  void loadChatSession(ChatSession session) {
    currentChatId = session.id;
    messages.assignAll(
      session.messages,
    ); // Load messages from the selected session
    selectedTopic.value = null; // Reset selected topic when loading a past chat
    showSuggestions.value = false;
    _scrollToBottom();
    Get.back(); // Close the drawer
  }

  // New: Placeholder for loading chat sessions from storage
  void _loadChatSessions() {
    // In a real app, you would load these from persistent storage.
    // For now, let's mock some past sessions.
    // Example:
    // final storedSessionsJson = StorageService.getString('chat_sessions_${expert.id}');
    // if (storedSessionsJson != null) {
    //   final List<dynamic> decoded = json.decode(storedSessionsJson);
    //   chatSessions.assignAll(decoded.map((json) => ChatSession.fromJson(json)).toList());
    // }

    // Mock data for demonstration
    chatSessions.assignAll([
      ChatSession(
        id: uuid.v4(),
        expertId: expert.id,
        topic: 'Career Forecast',
        messages: [
          {
            "text": "Hello, I need a career forecast.",
            "isUser": true,
            "time": DateTime.now().subtract(const Duration(days: 2)),
          },
          {
            "text":
                "Certainly! Please provide your birth details for an accurate reading.",
            "isUser": false,
            "time": DateTime.now().subtract(const Duration(days: 2)),
          },
        ],
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
      ChatSession(
        id: uuid.v4(),
        expertId: expert.id,
        topic: 'Relationship Advice',
        messages: [
          {
            "text": "My relationship is facing some challenges.",
            "isUser": true,
            "time": DateTime.now().subtract(const Duration(hours: 10)),
          },
          {
            "text":
                "I understand. Let's explore the planetary influences on your relationship.",
            "isUser": false,
            "time": DateTime.now().subtract(const Duration(hours: 10)),
          },
        ],
        timestamp: DateTime.now().subtract(const Duration(hours: 10)),
      ),
    ]);
  }

  // 🔥 MAIN SEND MESSAGE (NOW GEMINI)
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // If this is the first message in a new session, save it.
    if (currentChatId == null || messages.isEmpty) {
      messages.add({"text": text, "isUser": true, "time": DateTime.now()});
      _saveCurrentChatSession(); // Save new session
    } else {
      // For existing sessions, just add the message.
      messages.add({"text": text, "isUser": true, "time": DateTime.now()});
      _saveCurrentChatSession(); // Update session with new message
    }

    messageController.clear();
    showSuggestions.value = false;
    _scrollToBottom();

    // typing indicator
    messages.add({
      "text": "Typing...",
      "isUser": false,
      "time": DateTime.now(),
      "loading": true,
    });

    _scrollToBottom();

    try {
      final reply = await GeminiService.askAstrologer(
        userMessage: text,
        name: _name,
        dob: _dob,
        timeOfBirth: _timeOfBirth,
        placeOfBirth: _placeOfBirth,
        gowthra: _gowthra,
      );

      messages.removeLast(); // remove typing
      messages.add({
        "text": reply.trim(),
        "isUser": false,
        "time": DateTime.now(),
      });
    } catch (e) {
      // Remove typing indicator and show error message
      messages.removeLast();
      messages.add({
        "text":
            "Some planetary energies are unclear right now. Please try again shortly.",
        "isUser": false,
        "time": DateTime.now(),
      });
    }

    _scrollToBottom();
    // After receiving a reply, update the current chat session
    _saveCurrentChatSession();
  }

  void selectTopic(Topic topic) {
    selectedTopic.value = topic;
  }

  void selectQuestion(String question) {
    messageController.text = question;
    sendMessage();
    // selectedTopic.value = null; // Removed this line to keep the topic selected
  }

  void goBackToTopics() {
    selectedTopic.value = null;
  }

  List<Map<String, String>> getCurrentQuestions() {
    switch (selectedTopic.value) {
      case Topic.career:
        return [
          {"q": "Which career is best for me?"},
          {"q": "When will I get promotion or growth?"},
          {"q": "Should I change my job now?"},
        ];
      case Topic.relationship:
        return [
          {"q": "When will I meet my life partner?"},
          {"q": "Is my relationship stable?"},
          {"q": "Will my marriage be successful?"},
        ];
      case Topic.finance:
        return [
          {"q": "When will my income improve?"},
          {"q": "Is this a good time to invest?"},
          {"q": "Why is money getting blocked?"},
        ];
      case Topic.health:
        return [
          {"q": "Why do I feel low energy?"},
          {"q": "Are there health concerns ahead?"},
        ];
      default:
        return [];
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void showEndChatDialog(String title, String message) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFAF3E0,
                      ), // Light beige background for icon
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chat_bubble,
                      color: Color(0xFF8D6E63), // Brown icon
                      size: 28,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF8D6E63),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                "End Conversation?",
                style: GoogleFonts.cinzel(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                "Are you sure you want to end your session with ${expert.name}?",
                style: GoogleFonts.inter(
                  // Keep body text clean
                  fontSize: 14,
                  color: const Color(0xFF8D6E63), // Brown text
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // End Chat Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    // Add actual end chat logic here (e.g., call API, navigation)
                    Get.back(); // Navigate back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFA1887F,
                    ), // Muted Brown/Gold
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "End Chat",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: Get.back, // Close dialog
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(
                      color: Color(0xFF8D6E63),
                    ), // Brown border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    "Continue",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8D6E63), // Brown text
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return "$minutes:${remainingSeconds.toString().padLeft(2, '0')}";
  }

  @override
  void onClose() {
    _timer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
