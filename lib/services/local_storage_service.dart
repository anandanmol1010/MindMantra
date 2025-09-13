import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/journal_entry.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';

class LocalStorageService {
  static const String _journalEntriesKey = 'journal_entries';
  static const String _userProfileKey = 'user_profile';
  static const String _localOnlyModeKey = 'local_only_mode';
  static const String _consentGivenKey = 'consent_given';
  static const String _wellnessActivitiesKey = 'wellness_activities';

  // Crisis trigger words for local detection
  static const List<String> crisisTriggers = [
    'suicide', 'kill myself', 'end my life', 'want to die', 'hurt myself',
    'self harm', 'cut myself', 'overdose', 'jump off', 'hang myself',
    'no point living', 'better off dead', 'worthless', 'hopeless'
  ];

  // Journal Entry Methods
  Future<void> saveJournalEntry(JournalEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getJournalEntries();
    
    // Check for crisis triggers locally
    final hasTrigger = _checkForCrisisTriggers(entry.text);
    final updatedEntry = entry.copyWith(localQuickTrigger: hasTrigger);
    
    entries.add(updatedEntry);
    
    final jsonList = entries.map((e) => _journalEntryToJson(e)).toList();
    await prefs.setString(_journalEntriesKey, jsonEncode(jsonList));
  }

  Future<List<JournalEntry>> getJournalEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_journalEntriesKey);
    
    if (jsonString == null) return [];
    
    final jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList.map((json) => _journalEntryFromJson(json)).toList();
  }

  Future<List<JournalEntry>> getJournalEntriesForPeriod(
      DateTime startDate, DateTime endDate) async {
    final entries = await getJournalEntries();
    return entries.where((entry) {
      return entry.timestamp.isAfter(startDate) && 
             entry.timestamp.isBefore(endDate);
    }).toList();
  }

  bool _checkForCrisisTriggers(String text) {
    final textLower = text.toLowerCase();
    return crisisTriggers.any((trigger) => textLower.contains(trigger));
  }

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(_userProfileToJson(profile)));
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_userProfileKey);
    
    if (jsonString == null) return null;
    
    final json = jsonDecode(jsonString);
    return _userProfileFromJson(json);
  }

  // Settings Methods
  Future<void> setLocalOnlyMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localOnlyModeKey, enabled);
  }

  Future<bool> getLocalOnlyMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localOnlyModeKey) ?? false;
  }

  Future<void> setConsentGiven(bool given) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentGivenKey, given);
  }

  Future<bool> getConsentGiven() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentGivenKey) ?? false;
  }

  // Chat Methods
  Future<void> saveChatMessage(String chatId, ChatMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_${chatId}_messages';
    final existingMessages = prefs.getStringList(key) ?? [];
    
    final messageJson = jsonEncode({
      'role': message.role,
      'text': message.text,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
    });
    
    existingMessages.add(messageJson);
    await prefs.setStringList(key, existingMessages);
  }

  Future<List<ChatMessage>> getChatMessages(String chatId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'chat_${chatId}_messages';
    final messageStrings = prefs.getStringList(key) ?? [];
    
    return messageStrings.map((messageString) {
      final json = jsonDecode(messageString);
      return ChatMessage(
        role: json['role'],
        text: json['text'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      );
    }).toList();
  }

  // Wellness Activities Methods
  Future<void> saveCompletedActivity(String activityId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedActivities();
    
    if (!completed.contains(activityId)) {
      completed.add(activityId);
      await prefs.setStringList(_wellnessActivitiesKey, completed);
    }
  }

  Future<List<String>> getCompletedActivities() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_wellnessActivitiesKey) ?? [];
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // JSON Conversion Methods
  Map<String, dynamic> _journalEntryToJson(JournalEntry entry) {
    return {
      'id': entry.id,
      'text': entry.text,
      'timestamp': entry.timestamp.millisecondsSinceEpoch,
      'analyzedAt': entry.analyzedAt?.millisecondsSinceEpoch,
      'analysis': entry.analysis != null ? {
        'emotion': entry.analysis!.emotion,
        'confidence': entry.analysis!.confidence,
        'timestamp': entry.analysis!.timestamp.millisecondsSinceEpoch,
      } : null,
      'localQuickTrigger': entry.localQuickTrigger,
      'userId': entry.userId,
    };
  }

  JournalEntry _journalEntryFromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      analyzedAt: json['analyzedAt'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['analyzedAt'])
          : null,
      analysis: json['analysis'] != null ? EmotionAnalysis(
        emotion: json['analysis']['emotion'],
        confidence: json['analysis']['confidence'].toDouble(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['analysis']['timestamp']),
      ) : null,
      localQuickTrigger: json['localQuickTrigger'] ?? false,
      userId: json['userId'] ?? '',
    );
  }

  Map<String, dynamic> _userProfileToJson(UserProfile profile) {
    return {
      'uid': profile.uid,
      'displayName': profile.displayName,
      'createdAt': profile.createdAt.millisecondsSinceEpoch,
      'hasCompletedOnboarding': profile.hasCompletedOnboarding,
      'localOnlyMode': profile.localOnlyMode,
    };
  }

  UserProfile _userProfileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      displayName: json['displayName'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
      localOnlyMode: json['localOnlyMode'] ?? false,
    );
  }
}
