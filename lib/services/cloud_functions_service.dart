import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/journal_entry.dart';

class CloudFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Analyze journal entry using Cloud Function
  Future<Map<String, dynamic>?> analyzeJournalEntry(
      String journalId, String text) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final HttpsCallable callable = _functions.httpsCallable('analyzeEntry');
      
      final result = await callable.call({
        'journalId': journalId,
        'text': text,
      });

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error analyzing journal entry: $e');
      return null;
    }
  }

  // Get chatbot response using Cloud Function
  Future<String?> getChatbotResponse(String chatId, String message) async {
    try {
      if (_auth.currentUser == null) {
        throw Exception('User not authenticated');
      }

      final HttpsCallable callable = _functions.httpsCallable('chatbotProxy');
      
      final result = await callable.call({
        'chatId': chatId,
        'message': message,
      });

      final data = result.data as Map<String, dynamic>?;
      return data?['response'] as String?;
    } catch (e) {
      print('Error getting chatbot response: $e');
      return null;
    }
  }
}
