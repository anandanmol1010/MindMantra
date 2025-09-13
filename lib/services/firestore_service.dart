import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';
import '../models/chat_message.dart';
import '../models/user_stats.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Journal Entry Methods
  Future<void> saveJournalEntry(JournalEntry entry) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .doc(entry.id)
        .set(entry.toFirestore());

    // Update user stats
    await _updateJournalStats();
  }

  Future<String> createJournalEntry(String text) async {
    if (_userId == null) throw Exception('User not authenticated');

    final entry = JournalEntry(
      id: '',
      text: text,
      timestamp: DateTime.now(),
      userId: _userId!,
    );

    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .add(entry.toFirestore());

    // Update user stats
    await _updateJournalStats();

    return docRef.id;
  }

  Future<void> _updateJournalStats() async {
    if (_userId == null) return;

    final statsRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('stats')
        .doc('main');

    await _firestore.runTransaction((transaction) async {
      final statsDoc = await transaction.get(statsRef);
      
      if (statsDoc.exists) {
        final stats = UserStats.fromFirestore(statsDoc);
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        
        int newStreak = stats.streak;
        if (stats.lastJournalDate != null) {
          final lastDate = DateTime(
            stats.lastJournalDate!.year,
            stats.lastJournalDate!.month,
            stats.lastJournalDate!.day,
          );
          
          if (today.difference(lastDate).inDays == 1) {
            newStreak += 1;
          } else if (today.difference(lastDate).inDays > 1) {
            newStreak = 1;
          }
        } else {
          newStreak = 1;
        }

        final updatedStats = stats.copyWith(
          streak: newStreak,
          lastJournalDate: now,
          totalJournalEntries: stats.totalJournalEntries + 1,
        );

        transaction.update(statsRef, updatedStats.toFirestore());
      }
    });
  }

  Stream<List<JournalEntry>> getJournalEntries({int limit = 30}) {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => JournalEntry.fromFirestore(doc))
            .toList());
  }

  Future<List<JournalEntry>> getJournalEntriesForPeriod(
      DateTime startDate, DateTime endDate) async {
    if (_userId == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('journals')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('timestamp', descending: false)
        .get();

    return snapshot.docs
        .map((doc) => JournalEntry.fromFirestore(doc))
        .toList();
  }

  Future<void> saveChatMessage(String chatId, ChatMessage message) async {
    if (_userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Update last activity
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .update({'lastActivity': Timestamp.fromDate(DateTime.now())});
  }

  // Chat Methods
  Future<String> createChatSession() async {
    if (_userId == null) throw Exception('User not authenticated');

    final session = ChatSession(
      id: '',
      messages: [],
      mode: 'support',
      lastActivity: DateTime.now(),
      userId: _userId!,
    );

    final docRef = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .add(session.toFirestore());

    return docRef.id;
  }

  Stream<ChatSession?> getChatSession(String chatId) {
    if (_userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .doc(chatId)
        .snapshots()
        .map((doc) => doc.exists ? ChatSession.fromFirestore(doc) : null);
  }

  Stream<List<ChatSession>> getChatSessions() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('chats')
        .orderBy('lastActivity', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatSession.fromFirestore(doc))
            .toList());
  }

  // User Stats Methods
  Stream<UserStats?> getUserStats() {
    if (_userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('stats')
        .doc('main')
        .snapshots()
        .map((doc) => doc.exists ? UserStats.fromFirestore(doc) : null);
  }

  Future<void> addBadge(String badgeName) async {
    if (_userId == null) return;

    final statsRef = _firestore
        .collection('users')
        .doc(_userId)
        .collection('stats')
        .doc('main');

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(statsRef);
      if (doc.exists) {
        final stats = UserStats.fromFirestore(doc);
        if (!stats.badges.contains(badgeName)) {
          final updatedBadges = [...stats.badges, badgeName];
          transaction.update(statsRef, {'badges': updatedBadges});
        }
      }
    });
  }
}
