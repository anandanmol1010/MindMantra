const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

// Initialize Firestore
const db = admin.firestore();

// Crisis trigger words for local detection
const CRISIS_TRIGGERS = [
  'suicide', 'kill myself', 'end my life', 'want to die', 'hurt myself',
  'self harm', 'cut myself', 'overdose', 'jump off', 'hang myself',
  'no point living', 'better off dead', 'worthless', 'hopeless'
];

// Gemini AI configuration
const GEMINI_API_ENDPOINT = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

/**
 * Analyzes journal entry for emotion and sentiment
 */
exports.analyzeEntry = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { text, journalId } = data;
  const userId = context.auth.uid;

  if (!text || !journalId) {
    throw new functions.https.HttpsError('invalid-argument', 'Text and journalId are required');
  }

  try {
    // Check for local crisis triggers
    const textLower = text.toLowerCase();
    const hasCrisisTrigger = CRISIS_TRIGGERS.some(trigger => textLower.includes(trigger));

    // Call Gemini AI for emotion analysis
    const geminiResponse = await callGeminiForAnalysis(text);
    
    // Parse the AI response
    const analysis = parseGeminiResponse(geminiResponse);
    
    // Store analysis in Firestore
    const journalRef = db.collection('users').doc(userId).collection('journals').doc(journalId);
    
    await journalRef.update({
      analysis: {
        emotion: analysis.emotion,
        confidence: analysis.confidence,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      },
      localQuickTrigger: hasCrisisTrigger,
      analyzedAt: admin.firestore.FieldValue.serverTimestamp()
    });

    return {
      success: true,
      analysis: analysis,
      hasCrisisTrigger: hasCrisisTrigger
    };

  } catch (error) {
    console.error('Error analyzing entry:', error);
    throw new functions.https.HttpsError('internal', 'Failed to analyze entry');
  }
});

/**
 * Chatbot proxy for AI conversations
 */
exports.chatbotProxy = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }

  const { message, chatId } = data;
  const userId = context.auth.uid;

  if (!message || !chatId) {
    throw new functions.https.HttpsError('invalid-argument', 'Message and chatId are required');
  }

  try {
    // Get chat history for context
    const chatRef = db.collection('users').doc(userId).collection('chats').doc(chatId);
    const chatDoc = await chatRef.get();
    
    let messages = [];
    if (chatDoc.exists) {
      messages = chatDoc.data().messages || [];
    }

    // Add user message
    const userMessage = {
      role: 'user',
      text: message,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };

    // Call Gemini AI for response
    const botResponse = await callGeminiForChat(message, messages);
    
    const botMessage = {
      role: 'bot',
      text: botResponse,
      timestamp: admin.firestore.FieldValue.serverTimestamp()
    };

    // Update chat in Firestore
    const updatedMessages = [...messages, userMessage, botMessage];
    
    await chatRef.set({
      messages: updatedMessages,
      mode: 'support',
      lastActivity: admin.firestore.FieldValue.serverTimestamp()
    }, { merge: true });

    return {
      success: true,
      response: botResponse,
      messageId: botMessage.timestamp
    };

  } catch (error) {
    console.error('Error in chatbot proxy:', error);
    throw new functions.https.HttpsError('internal', 'Failed to get chatbot response');
  }
});

/**
 * Call Gemini AI for emotion analysis
 */
async function callGeminiForAnalysis(text) {
  const prompt = `Analyze the emotional content of this journal entry and respond with ONLY a JSON object in this exact format:
{
  "emotion": "one of: happy, sad, anxious, angry, neutral, excited, depressed, hopeful, frustrated, calm",
  "confidence": 0.85
}

Journal entry: "${text}"

Respond with only the JSON object, no other text.`;

  const requestBody = {
    contents: [{
      parts: [{
        text: prompt
      }]
    }],
    generationConfig: {
      temperature: 0.1,
      maxOutputTokens: 100
    }
  };

  const response = await axios.post(
    `${GEMINI_API_ENDPOINT}?key=${functions.config().gemini.api_key}`,
    requestBody,
    {
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );

  return response.data;
}

/**
 * Call Gemini AI for chat responses
 */
async function callGeminiForChat(message, chatHistory) {
  const contextMessages = chatHistory.slice(-5).map(msg => 
    `${msg.role}: ${msg.text}`
  ).join('\n');

  const prompt = `You are MindMitra, a compassionate AI mental health companion. Provide supportive, empathetic responses to help users with their mental wellness. Keep responses concise (2-3 sentences), warm, and encouraging. If someone expresses crisis thoughts, gently suggest professional help.

Previous conversation:
${contextMessages}

User: ${message}

Respond as MindMitra:`;

  const requestBody = {
    contents: [{
      parts: [{
        text: prompt
      }]
    }],
    generationConfig: {
      temperature: 0.7,
      maxOutputTokens: 200
    }
  };

  const response = await axios.post(
    `${GEMINI_API_ENDPOINT}?key=${functions.config().gemini.api_key}`,
    requestBody,
    {
      headers: {
        'Content-Type': 'application/json'
      }
    }
  );

  const botResponse = response.data.candidates[0].content.parts[0].text;
  return botResponse.trim();
}

/**
 * Parse Gemini response for emotion analysis
 */
function parseGeminiResponse(response) {
  try {
    const text = response.candidates[0].content.parts[0].text;
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    
    if (jsonMatch) {
      const parsed = JSON.parse(jsonMatch[0]);
      return {
        emotion: parsed.emotion || 'neutral',
        confidence: parsed.confidence || 0.5
      };
    }
  } catch (error) {
    console.error('Error parsing Gemini response:', error);
  }
  
  // Fallback
  return {
    emotion: 'neutral',
    confidence: 0.5
  };
}
