import 'package:cloud_firestore/cloud_firestore.dart';

class EmotionAnalysis {
  final String emotion;
  final double confidence;
  final DateTime timestamp;

  EmotionAnalysis({
    required this.emotion,
    required this.confidence,
    required this.timestamp,
  });

  factory EmotionAnalysis.fromMap(Map<String, dynamic> data) {
    return EmotionAnalysis(
      emotion: data['emotion'] ?? 'neutral',
      confidence: (data['confidence'] ?? 0.5).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'emotion': emotion,
      'confidence': confidence,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

class JournalEntry {
  final String id;
  final String text;
  final DateTime timestamp;
  final DateTime? analyzedAt;
  final EmotionAnalysis? analysis;
  final bool localQuickTrigger;
  final String userId;

  JournalEntry({
    required this.id,
    required this.text,
    required this.timestamp,
    this.analyzedAt,
    this.analysis,
    this.localQuickTrigger = false,
    required this.userId,
  });

  factory JournalEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return JournalEntry(
      id: doc.id,
      text: data['text'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      analyzedAt: data['analyzedAt'] != null 
          ? (data['analyzedAt'] as Timestamp).toDate() 
          : null,
      analysis: data['analysis'] != null 
          ? EmotionAnalysis.fromMap(data['analysis']) 
          : null,
      localQuickTrigger: data['localQuickTrigger'] ?? false,
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'analyzedAt': analyzedAt != null ? Timestamp.fromDate(analyzedAt!) : null,
      'analysis': analysis?.toMap(),
      'localQuickTrigger': localQuickTrigger,
      'userId': userId,
    };
  }

  JournalEntry copyWith({
    String? text,
    DateTime? analyzedAt,
    EmotionAnalysis? analysis,
    bool? localQuickTrigger,
  }) {
    return JournalEntry(
      id: id,
      text: text ?? this.text,
      timestamp: timestamp,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      analysis: analysis ?? this.analysis,
      localQuickTrigger: localQuickTrigger ?? this.localQuickTrigger,
      userId: userId,
    );
  }
}
