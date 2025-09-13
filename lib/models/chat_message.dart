import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String role; // 'user' or 'bot'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      role: data['role'] ?? 'user',
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class ChatSession {
  final String id;
  final List<ChatMessage> messages;
  final String mode; // 'support' or 'peer'
  final DateTime lastActivity;
  final String userId;

  ChatSession({
    required this.id,
    required this.messages,
    this.mode = 'support',
    required this.lastActivity,
    required this.userId,
  });

  factory ChatSession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final messagesList = data['messages'] as List<dynamic>? ?? [];
    
    return ChatSession(
      id: doc.id,
      messages: messagesList
          .map((msg) => ChatMessage.fromMap(msg as Map<String, dynamic>))
          .toList(),
      mode: data['mode'] ?? 'support',
      lastActivity: (data['lastActivity'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'messages': messages.map((msg) => msg.toMap()).toList(),
      'mode': mode,
      'lastActivity': Timestamp.fromDate(lastActivity),
      'userId': userId,
    };
  }
}
