import 'package:get/get.dart';

class ChatSession {
  final String id;
  final String expertId;
  final String topic;
  final List<Map<String, dynamic>> messages;
  final DateTime timestamp;

  ChatSession({
    required this.id,
    required this.expertId,
    required this.topic,
    required this.messages,
    required this.timestamp,
  });

  // Convert a ChatSession object to a JSON map
  Map<String, dynamic> toJson() => {
        'id': id,
        'expertId': expertId,
        'topic': topic,
        'messages': messages,
        'timestamp': timestamp.toIso8601String(),
      };

  // Create a ChatSession object from a JSON map
  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'],
        expertId: json['expertId'],
        topic: json['topic'],
        messages: List<Map<String, dynamic>>.from(json['messages']),
        timestamp: DateTime.parse(json['timestamp']),
      );
}
 
