import 'dart:math';
import '../models/journal_entry.dart';

class LocalAIService {
  static final LocalAIService _instance = LocalAIService._internal();
  factory LocalAIService() => _instance;
  LocalAIService._internal();

  final Random _random = Random();

  // Local emotion analysis
  EmotionAnalysis analyzeEmotion(String text) {
    final lowerText = text.toLowerCase();
    final words = lowerText.split(' ');
    
    // Emotion keywords with weights
    final emotionKeywords = {
      'happy': ['happy', 'joy', 'excited', 'great', 'amazing', 'wonderful', 'fantastic', 'awesome', 'love', 'blessed', 'grateful', 'cheerful', 'delighted'],
      'sad': ['sad', 'depressed', 'down', 'upset', 'crying', 'tears', 'lonely', 'heartbroken', 'miserable', 'gloomy', 'melancholy', 'disappointed'],
      'angry': ['angry', 'mad', 'furious', 'annoyed', 'frustrated', 'rage', 'irritated', 'pissed', 'outraged', 'livid', 'hostile', 'bitter'],
      'anxious': ['anxious', 'worried', 'nervous', 'stressed', 'panic', 'fear', 'scared', 'overwhelmed', 'tense', 'restless', 'uneasy', 'troubled'],
      'calm': ['calm', 'peaceful', 'relaxed', 'serene', 'tranquil', 'composed', 'balanced', 'centered', 'quiet', 'still', 'content'],
      'excited': ['excited', 'thrilled', 'energetic', 'pumped', 'enthusiastic', 'eager', 'motivated', 'inspired', 'passionate', 'vibrant']
    };

    Map<String, double> emotionScores = {};
    
    // Calculate emotion scores
    for (String emotion in emotionKeywords.keys) {
      double score = 0.0;
      for (String keyword in emotionKeywords[emotion]!) {
        if (lowerText.contains(keyword)) {
          score += 1.0;
        }
      }
      emotionScores[emotion] = score;
    }

    // Find dominant emotion
    String dominantEmotion = 'neutral';
    double maxScore = 0.0;
    
    emotionScores.forEach((emotion, score) {
      if (score > maxScore) {
        maxScore = score;
        dominantEmotion = emotion;
      }
    });

    // Calculate confidence based on word count and matches
    double confidence = maxScore > 0 
        ? (maxScore / words.length * 10).clamp(0.3, 0.95)
        : 0.5;

    return EmotionAnalysis(
      emotion: dominantEmotion,
      confidence: confidence,
      timestamp: DateTime.now(),
    );
  }

  // Local chatbot responses
  String generateChatResponse(String userMessage) {
    final lowerMessage = userMessage.toLowerCase();
    
    // Crisis detection responses
    if (_containsCrisisKeywords(lowerMessage)) {
      return _getCrisisResponse();
    }
    
    // Greeting responses
    if (_containsGreeting(lowerMessage)) {
      return _getGreetingResponse();
    }
    
    // Emotion-based responses
    if (_containsEmotionKeywords(lowerMessage, 'sad')) {
      return _getSadResponse();
    }
    
    if (_containsEmotionKeywords(lowerMessage, 'happy')) {
      return _getHappyResponse();
    }
    
    if (_containsEmotionKeywords(lowerMessage, 'anxious')) {
      return _getAnxiousResponse();
    }
    
    if (_containsEmotionKeywords(lowerMessage, 'angry')) {
      return _getAngryResponse();
    }
    
    // Mental health topics
    if (_containsMentalHealthKeywords(lowerMessage)) {
      return _getMentalHealthResponse();
    }
    
    // Default supportive responses
    return _getDefaultResponse();
  }

  bool _containsCrisisKeywords(String text) {
    final crisisKeywords = [
      'suicide', 'kill myself', 'end my life', 'want to die', 'hurt myself',
      'self harm', 'cut myself', 'no point living', 'better off dead'
    ];
    
    return crisisKeywords.any((keyword) => text.contains(keyword));
  }

  bool _containsGreeting(String text) {
    final greetings = ['hello', 'hi', 'hey', 'good morning', 'good evening', 'namaste'];
    return greetings.any((greeting) => text.contains(greeting));
  }

  bool _containsEmotionKeywords(String text, String emotion) {
    final emotionKeywords = {
      'sad': ['sad', 'depressed', 'down', 'upset', 'crying', 'lonely'],
      'happy': ['happy', 'joy', 'excited', 'great', 'amazing', 'wonderful'],
      'anxious': ['anxious', 'worried', 'nervous', 'stressed', 'panic', 'fear'],
      'angry': ['angry', 'mad', 'furious', 'annoyed', 'frustrated', 'rage']
    };
    
    return emotionKeywords[emotion]?.any((keyword) => text.contains(keyword)) ?? false;
  }

  bool _containsMentalHealthKeywords(String text) {
    final keywords = ['therapy', 'counseling', 'depression', 'anxiety', 'mental health', 'stress', 'meditation'];
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _getCrisisResponse() {
    final responses = [
      "I'm really concerned about you. Please reach out to a mental health professional or call a crisis helpline immediately. In India, you can contact AASRA at +91-98204 66726.",
      "Your life has value and meaning. Please don't hesitate to seek immediate help. Contact AASRA helpline: +91-98204 66726 or visit your nearest hospital.",
      "I hear that you're in pain right now. Please reach out for professional help immediately. AASRA: +91-98204 66726. You don't have to go through this alone."
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getGreetingResponse() {
    final responses = [
      "Hello! I'm here to support you. How are you feeling today?",
      "Hi there! It's good to see you. What's on your mind?",
      "Hey! I'm glad you're here. How can I help you today?",
      "Namaste! How are you doing today? I'm here to listen."
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getSadResponse() {
    final responses = [
      "I hear that you're feeling sad right now. It's okay to feel this way - your emotions are valid. Would you like to talk about what's troubling you?",
      "Sadness is a natural human emotion. It's brave of you to acknowledge these feelings. Remember, this feeling will pass. What small thing could bring you a moment of comfort today?",
      "I'm sorry you're going through a difficult time. Sometimes it helps to express these feelings. Have you tried journaling or talking to someone you trust?",
      "Your sadness matters, and so do you. It's okay to not be okay sometimes. What usually helps you feel a little better when you're down?"
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getHappyResponse() {
    final responses = [
      "It's wonderful to hear that you're feeling happy! What's bringing you joy today?",
      "Your happiness is contagious! I'm glad you're having a good day. What made it special?",
      "That's fantastic! It's beautiful when we can appreciate the good moments. What are you most grateful for right now?",
      "I love hearing about your positive experiences! Happiness is precious - savor this feeling."
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getAnxiousResponse() {
    final responses = [
      "Anxiety can feel overwhelming, but you're not alone. Try taking slow, deep breaths. What's causing you to feel anxious right now?",
      "I understand that anxiety can be really challenging. Have you tried grounding techniques like focusing on 5 things you can see, 4 you can touch, 3 you can hear?",
      "Anxiety is your mind's way of trying to protect you, but sometimes it can be too much. What helps you feel more calm and centered?",
      "It's okay to feel anxious - many people experience this. Remember that this feeling will pass. Have you tried any relaxation techniques?"
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getAngryResponse() {
    final responses = [
      "I can sense your frustration. Anger is a valid emotion that often signals something important. What's making you feel this way?",
      "It sounds like something has really upset you. Sometimes it helps to take a step back and breathe. What triggered these feelings?",
      "Anger can be intense and overwhelming. It's okay to feel this way. Have you found healthy ways to express or release these feelings?",
      "I hear your anger, and it's completely valid. What would help you feel more at peace right now?"
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getMentalHealthResponse() {
    final responses = [
      "Mental health is just as important as physical health. It's great that you're thinking about it. What aspects of mental wellness are you interested in?",
      "Taking care of your mental health shows strength and self-awareness. What strategies have you found helpful for your wellbeing?",
      "Mental health conversations are so important. Whether it's therapy, meditation, or self-care, there are many paths to wellness. What resonates with you?",
      "I'm glad you're prioritizing your mental health. Everyone's journey is different. What support or resources are you looking for?"
    ];
    return responses[_random.nextInt(responses.length)];
  }

  String _getDefaultResponse() {
    final responses = [
      "I'm here to listen and support you. Tell me more about what's on your mind.",
      "Thank you for sharing with me. How are you feeling about everything right now?",
      "I appreciate you opening up. What would be most helpful for you to talk about today?",
      "Your thoughts and feelings matter. I'm here to support you through whatever you're experiencing.",
      "It sounds like you have a lot on your mind. What's the most important thing you'd like to discuss?",
      "I'm listening. Sometimes it helps just to express what we're thinking and feeling.",
      "Every experience teaches us something. What insights have you gained recently?",
      "You're taking a positive step by reaching out. What support do you need right now?"
    ];
    return responses[_random.nextInt(responses.length)];
  }

  // Generate wellness tips
  List<String> getWellnessTips() {
    return [
      "Practice deep breathing for 5 minutes daily to reduce stress and anxiety.",
      "Try the 5-4-3-2-1 grounding technique: 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste.",
      "Write down 3 things you're grateful for each day to boost positive thinking.",
      "Take a 10-minute walk outside to improve mood and get fresh air.",
      "Practice progressive muscle relaxation before bed for better sleep.",
      "Limit social media use to reduce comparison and negative feelings.",
      "Connect with a friend or family member you haven't talked to in a while.",
      "Try a new hobby or creative activity to engage your mind positively.",
      "Practice mindful eating - focus on the taste, texture, and smell of your food.",
      "Set small, achievable goals for yourself each day to build confidence."
    ];
  }

  // Generate motivational quotes
  String getMotivationalQuote() {
    final quotes = [
      "Every day is a new beginning. Take a deep breath and start again.",
      "You are stronger than you think and more resilient than you know.",
      "Progress, not perfection. Every small step counts.",
      "Your mental health is a priority. Your happiness is essential. Your self-care is a necessity.",
      "It's okay to not be okay. It's not okay to stay that way without seeking help.",
      "You have survived 100% of your worst days. You're doing great.",
      "Healing isn't linear. Be patient with yourself.",
      "You are worthy of love, happiness, and all good things in life.",
      "Sometimes the bravest thing you can do is ask for help.",
      "Your story isn't over yet. Keep writing it, one day at a time."
    ];
    return quotes[_random.nextInt(quotes.length)];
  }
}
