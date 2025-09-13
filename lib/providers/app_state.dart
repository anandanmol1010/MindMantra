import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/local_storage_service.dart';
import '../services/local_ai_service.dart';
import '../services/gemini_service.dart';
import '../models/user_profile.dart';
import '../models/journal_entry.dart';
import '../models/user_stats.dart';
import '../models/chat_message.dart';

class AppState extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final LocalStorageService _localStorageService = LocalStorageService();
  final LocalAIService _localAIService = LocalAIService();
  final GeminiService _geminiService = GeminiService();

  User? _currentUser;
  UserProfile? _userProfile;
  UserStats? _userStats;
  bool _isLoading = false;
  bool _localOnlyMode = false;
  bool _consentGiven = false;

  // Getters
  User? get currentUser => _currentUser;
  UserProfile? get userProfile => _userProfile;
  UserStats? get userStats => _userStats;
  bool get isLoading => _isLoading;
  bool get localOnlyMode => _localOnlyMode;
  bool get consentGiven => _consentGiven;
  bool get isAuthenticated => _currentUser != null;

  AppState() {
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    _setLoading(true);
    
    // Load local settings
    _localOnlyMode = await _localStorageService.getLocalOnlyMode();
    _consentGiven = await _localStorageService.getConsentGiven();
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _userProfile = null;
        _userStats = null;
      }
      notifyListeners();
    });

    _setLoading(false);
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      if (!_localOnlyMode) {
        // Load from Firestore
        _userProfile = await _authService.getUserProfile();
        
        // Listen to user stats
        _firestoreService.getUserStats().listen((stats) {
          _userStats = stats;
          notifyListeners();
        });
      } else {
        // Load from local storage
        _userProfile = await _localStorageService.getUserProfile();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Authentication methods
  Future<bool> signUpWithEmailPassword(String email, String password, String displayName) async {
    _setLoading(true);
    
    try {
      final user = await _authService.signUpWithEmailPassword(email, password, displayName);
      if (user != null) {
        await _loadUserProfile();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      print('Error signing up: $e');
      return false;
    }
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    _setLoading(true);
    
    try {
      final user = await _authService.signInWithEmailPassword(email, password);
      if (user != null) {
        await _loadUserProfile();
        _setLoading(false);
        return true;
      }
      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      return await _authService.resetPassword(email);
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _userProfile = null;
    _userStats = null;
    notifyListeners();
  }

  // Settings methods
  Future<void> setLocalOnlyMode(bool enabled) async {
    _localOnlyMode = enabled;
    await _localStorageService.setLocalOnlyMode(enabled);
    
    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(localOnlyMode: enabled);
      await updateUserProfile(updatedProfile);
    }
    
    notifyListeners();
  }

  Future<void> setConsentGiven(bool given) async {
    _consentGiven = given;
    await _localStorageService.setConsentGiven(given);
    notifyListeners();
  }

  // User profile methods
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      if (!_localOnlyMode) {
        await _authService.updateUserProfile(profile);
      } else {
        await _localStorageService.saveUserProfile(profile);
      }
      
      _userProfile = profile;
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<void> completeOnboarding() async {
    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(hasCompletedOnboarding: true);
      await updateUserProfile(updatedProfile);
    }
  }

  // Journal methods
  Future<void> submitJournalEntry(String text) async {
    if (text.trim().isEmpty) return;

    try {
      // Check for crisis triggers locally
      final hasCrisisTrigger = checkForCrisisTriggers(text);
      
      // AI emotion analysis (Gemini with local fallback)
      EmotionAnalysis analysis;
      try {
        analysis = await _geminiService.analyzeEmotion(text);
      } catch (e) {
        print('Gemini API failed, using local analysis: $e');
        analysis = _localAIService.analyzeEmotion(text);
      }
      
      final entry = JournalEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: text,
        timestamp: DateTime.now(),
        localQuickTrigger: hasCrisisTrigger,
        analysis: analysis,
        userId: _currentUser?.uid ?? 'anonymous',
      );

      if (_localOnlyMode) {
        // Store locally only
        await _localStorageService.saveJournalEntry(entry);
      } else {
        // Store in Firestore with local AI analysis
        await _firestoreService.saveJournalEntry(entry);
      }

      // Update stats
      // Update stats if needed
      // await _updateUserStats();
      
      notifyListeners();
    } catch (e) {
      print('Error submitting journal entry: $e');
    }
  }



  // Chat methods
  Future<String?> createChatSession() async {
    try {
      if (_localOnlyMode) {
        return DateTime.now().millisecondsSinceEpoch.toString();
      } else {
        return await _firestoreService.createChatSession();
      }
    } catch (e) {
      print('Error creating chat session: $e');
      return null;
    }
  }

  Future<String?> sendChatMessage(String chatId, String message) async {
    try {
      // Generate AI response (Gemini with local fallback)
      String aiResponse;
      try {
        aiResponse = await _geminiService.generateChatResponse(message);
      } catch (e) {
        print('Gemini API failed, using local response: $e');
        aiResponse = _localAIService.generateChatResponse(message);
      }
      
      // Create user message
      final userMessage = ChatMessage(
        role: 'user',
        text: message,
        timestamp: DateTime.now(),
      );

      // Create AI response message
      final aiMessage = ChatMessage(
        role: 'bot',
        text: aiResponse,
        timestamp: DateTime.now().add(const Duration(seconds: 1)),
      );

      if (_localOnlyMode) {
        await _localStorageService.saveChatMessage(chatId, userMessage);
        await _localStorageService.saveChatMessage(chatId, aiMessage);
      } else {
        await _firestoreService.saveChatMessage(chatId, userMessage);
        await _firestoreService.saveChatMessage(chatId, aiMessage);
      }
      
      notifyListeners();
      return aiResponse;
    } catch (e) {
      print('Error sending chat message: $e');
      return null;
    }
  }

  // Wellness methods
  Future<void> markActivityCompleted(String activityId) async {
    await _localStorageService.saveCompletedActivity(activityId);
    notifyListeners();
  }

  Future<List<String>> getCompletedActivities() async {
    return await _localStorageService.getCompletedActivities();
  }

  // Get wellness tips from local AI
  List<String> getWellnessTips() {
    return _localAIService.getWellnessTips();
  }

  // Get motivational quote
  String getMotivationalQuote() {
    return _localAIService.getMotivationalQuote();
  }

  // Crisis detection
  bool checkForCrisisTriggers(String text) {
    return LocalStorageService.crisisTriggers.any(
      (trigger) => text.toLowerCase().contains(trigger)
    );
  }
}
