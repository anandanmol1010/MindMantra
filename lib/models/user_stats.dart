import 'package:cloud_firestore/cloud_firestore.dart';

class UserStats {
  final String userId;
  final int streak;
  final DateTime? lastJournalDate;
  final List<String> badges;
  final int totalJournalEntries;
  final int totalChatSessions;

  UserStats({
    required this.userId,
    this.streak = 0,
    this.lastJournalDate,
    this.badges = const [],
    this.totalJournalEntries = 0,
    this.totalChatSessions = 0,
  });

  factory UserStats.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserStats(
      userId: doc.id,
      streak: data['streak'] ?? 0,
      lastJournalDate: data['lastJournalDate'] != null 
          ? (data['lastJournalDate'] as Timestamp).toDate() 
          : null,
      badges: List<String>.from(data['badges'] ?? []),
      totalJournalEntries: data['totalJournalEntries'] ?? 0,
      totalChatSessions: data['totalChatSessions'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'streak': streak,
      'lastJournalDate': lastJournalDate != null 
          ? Timestamp.fromDate(lastJournalDate!) 
          : null,
      'badges': badges,
      'totalJournalEntries': totalJournalEntries,
      'totalChatSessions': totalChatSessions,
    };
  }

  UserStats copyWith({
    int? streak,
    DateTime? lastJournalDate,
    List<String>? badges,
    int? totalJournalEntries,
    int? totalChatSessions,
  }) {
    return UserStats(
      userId: userId,
      streak: streak ?? this.streak,
      lastJournalDate: lastJournalDate ?? this.lastJournalDate,
      badges: badges ?? this.badges,
      totalJournalEntries: totalJournalEntries ?? this.totalJournalEntries,
      totalChatSessions: totalChatSessions ?? this.totalChatSessions,
    );
  }
}
