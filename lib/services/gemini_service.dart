import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/journal_entry.dart';

class GeminiService {
  static const String _apiKey =
      'AIzaSyAQUnLQWMZB_r2TRBdSkjUUotrgspUCDCM'; // Replace with your actual API key
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
  }

  // Analyze journal entry emotion
  Future<EmotionAnalysis> analyzeEmotion(String text) async {
    try {
      final prompt =
          '''
      Analyze the emotional content of this journal entry and provide:
      1. Primary emotion (happy, sad, angry, anxious, calm, excited, neutral)
      2. Confidence score (0.0 to 1.0)
      3. Brief explanation (1-2 sentences)

      Journal entry: "$text"

      Respond in JSON format:
      {
        "emotion": "primary_emotion",
        "confidence": 0.0,
        "explanation": "brief explanation"
      }
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        final jsonResponse = json.decode(response.text!);
        return EmotionAnalysis(
          emotion: jsonResponse['emotion'] ?? 'neutral',
          confidence: (jsonResponse['confidence'] ?? 0.5).toDouble(),
          timestamp: DateTime.now(),
        );
      }

      return EmotionAnalysis(emotion: 'neutral', confidence: 0.5, timestamp: DateTime.now());
    } catch (e) {
      print('Error analyzing emotion with Gemini: $e');
      // Fallback to local analysis
      return _fallbackEmotionAnalysis(text);
    }
  }

  // Generate chatbot response
  Future<String> generateChatResponse(
    String userMessage, {
    List<String>? conversationHistory,
  }) async {
    try {
      String contextPrompt =
          '''
      You are MindMitra, a compassionate AI mental health companion. Your role is to:
      - Provide emotional support and empathy
      - Offer practical mental health advice
      - Detect crisis situations and provide helpline information
      - Be encouraging and non-judgmental
      - Keep responses concise but meaningful (2-3 sentences)

      If the user expresses suicidal thoughts or self-harm intentions, immediately provide:
      - AASRA helpline: +91-98204 66726
      - Encourage seeking professional help
      - Express care and concern

      User message: "$userMessage"
      ''';

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        contextPrompt +=
            '\n\nConversation history:\n${conversationHistory.join('\n')}';
      }

      final content = [Content.text(contextPrompt)];
      final response = await _model.generateContent(content);

      return response.text ?? _getFallbackResponse(userMessage);
    } catch (e) {
      print('Error generating chat response with Gemini: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  // Generate wellness tips
  Future<List<String>> generateWellnessTips() async {
    try {
      final prompt = '''
      Generate 5 practical mental health and wellness tips for daily life.
      Each tip should be:
      - Actionable and specific
      - 1-2 sentences long
      - Focused on mental wellbeing
      - Suitable for general audience

      Return as a JSON array of strings.
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        final List<dynamic> tips = json.decode(response.text!);
        return tips.cast<String>();
      }

      return _getFallbackWellnessTips();
    } catch (e) {
      print('Error generating wellness tips with Gemini: $e');
      return _getFallbackWellnessTips();
    }
  }

  // Generate motivational quote
  Future<String> generateMotivationalQuote() async {
    try {
      final prompt = '''
      Generate an inspiring, uplifting quote about mental health, resilience, or personal growth.
      The quote should be:
      - Original and meaningful
      - 1-2 sentences
      - Encouraging and positive
      - Related to mental wellness or overcoming challenges
      ''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);

      return response.text ?? _getFallbackQuote();
    } catch (e) {
      print('Error generating motivational quote with Gemini: $e');
      return _getFallbackQuote();
    }
  }

  // Fallback methods when Gemini API fails
  EmotionAnalysis _fallbackEmotionAnalysis(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains(
      RegExp(r'\b(happy|joy|excited|great|amazing|wonderful)\b'),
    )) {
      return EmotionAnalysis(emotion: 'happy', confidence: 0.7, timestamp: DateTime.now());
    } else if (lowerText.contains(
      RegExp(r'\b(sad|depressed|down|upset|crying)\b'),
    )) {
      return EmotionAnalysis(emotion: 'sad', confidence: 0.7, timestamp: DateTime.now());
    } else if (lowerText.contains(
      RegExp(r'\b(angry|mad|furious|annoyed|frustrated)\b'),
    )) {
      return EmotionAnalysis(emotion: 'angry', confidence: 0.7, timestamp: DateTime.now());
    } else if (lowerText.contains(
      RegExp(r'\b(anxious|worried|nervous|stressed|panic)\b'),
    )) {
      return EmotionAnalysis(emotion: 'anxious', confidence: 0.7, timestamp: DateTime.now());
    } else {
      return EmotionAnalysis(emotion: 'neutral', confidence: 0.5, timestamp: DateTime.now());
    }
  }

  String _getFallbackResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();

    if (lowerMessage.contains(
      RegExp(r'\b(suicide|kill myself|hurt myself|end my life)\b'),
    )) {
      return "I'm really concerned about you. Please reach out to AASRA helpline at +91-98204 66726 immediately. You don't have to go through this alone.";
    } else if (lowerMessage.contains(RegExp(r'\b(hello|hi|hey)\b'))) {
      return "Hello! I'm here to support you. How are you feeling today?";
    } else if (lowerMessage.contains(RegExp(r'\b(sad|depressed|down)\b'))) {
      return "I hear that you're feeling sad right now. Your emotions are valid, and it's okay to not be okay sometimes. What's troubling you?";
    } else {
      return "I'm here to listen and support you. Tell me more about what's on your mind.";
    }
  }

  List<String> _getFallbackWellnessTips() {
    return [
      "Practice deep breathing for 5 minutes daily to reduce stress and anxiety.",
      "Write down 3 things you're grateful for each day to boost positive thinking.",
      "Take a 10-minute walk outside to improve mood and get fresh air.",
      "Connect with a friend or family member you haven't talked to in a while.",
      "Set small, achievable goals for yourself each day to build confidence.",
    ];
  }

  String _getFallbackQuote() {
    final quotes = [
      "Every day is a new beginning. Take a deep breath and start again.",
      "You are stronger than you think and more resilient than you know.",
      "Progress, not perfection. Every small step counts.",
      "Your mental health is a priority. Your happiness is essential.",
      "You have survived 100% of your worst days. You're doing great.",
    ];
    return quotes[(DateTime.now().millisecondsSinceEpoch % quotes.length)];
  }
}
