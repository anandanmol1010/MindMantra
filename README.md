# 🧠 MindMantra - Your AI Mental Health Companion

> *"Transform your mental wellness journey with AI-powered insights and compassionate support"*

**MindMantra** is a revolutionary Flutter app that combines cutting-edge AI technology with mental health best practices to create your personal wellness companion. Whether you're tracking moods, journaling thoughts, or seeking supportive conversations, MindMantra is here to guide you every step of the way.

## ✨ Why MindMantra?

🎯 **Smart & Intuitive** - AI-powered emotion analysis that understands your feelings  
🔒 **Privacy First** - Complete local-only mode for maximum privacy  
💬 **24/7 Support** - Intelligent chatbot powered by Google Gemini AI  
📊 **Visual Insights** - Beautiful charts showing your emotional journey  
🚨 **Crisis Care** - Immediate help when you need it most  
⚡ **Always Available** - Works offline with seamless cloud sync

## 🚀 Features That Make a Difference

### 📱 Core Features
| Feature | Description | Benefit |
|---------|-------------|---------|
| 🤖 **AI Journal Analysis** | Advanced emotion detection using Google Gemini | Understand your feelings better |
| 💭 **Smart Chatbot** | 24/7 AI companion for support | Never feel alone |
| 📈 **Mood Dashboard** | Visual charts & insights | Track your progress |
| 🧘 **Wellness Activities** | Breathing exercises & mindfulness | Daily self-care |
| 🆘 **Crisis Detection** | Automatic safety alerts | Immediate help when needed |
| 🔐 **Privacy Mode** | Complete offline functionality | Your data stays yours |

### 🛠️ Technical Excellence
- ⚡ **Lightning Fast** - Optimized Flutter performance
- 🌙 **Dark Mode** - Easy on the eyes, day or night
- 📱 **Cross-Platform** - Android, iOS, Web ready
- 🔄 **Real-time Sync** - Seamless across all devices
- 🛡️ **Bank-Level Security** - Firebase enterprise security

## 🏗️ Tech Stack

```
🎨 Frontend          🔧 Backend           🤖 AI Engine
├─ Flutter 3.x       ├─ Firebase Auth     ├─ Google Gemini
├─ Material Design   ├─ Cloud Firestore   ├─ Vertex AI
├─ Provider State    ├─ Cloud Functions   └─ Local Fallback
└─ FL Charts         └─ Firebase Hosting
```

## ⚡ Quick Start (5 Minutes!)

### 1️⃣ Get the Code
```bash
git clone <your-repo-url>
cd MindMantra
flutter pub get
```

### 2️⃣ Setup Gemini AI
```bash
# Get your FREE API key from: https://makersuite.google.com/app/apikey
# Replace in: lib/services/gemini_service.dart line 6
```

### 3️⃣ Firebase Setup (Optional - for cloud features)
```bash
# Create project at: https://console.firebase.google.com/
# Download google-services.json to android/app/
```

### 4️⃣ Run the App!
```bash
flutter run
```

🎉 **That's it!** Your AI mental health companion is ready!

## 📋 Detailed Setup Guide

<details>
<summary>🔧 Complete Firebase Configuration</summary>

### Firebase Project Setup
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "MindMantra"
3. Enable these services:
   - 🔐 Authentication (Anonymous)
   - 📊 Cloud Firestore
   - ⚡ Cloud Functions
   - 🌐 Hosting (optional)

### Add Firebase to Your App
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login and initialize
firebase login
firebase init

# Download config files:
# Android: google-services.json → android/app/
# iOS: GoogleService-Info.plist → ios/Runner/
```

### Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```
</details>

<details>
<summary>🤖 AI Configuration Details</summary>

### Gemini API Setup
1. Get FREE API key: [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Update `lib/services/gemini_service.dart`:
```dart
static const String _apiKey = 'YOUR_API_KEY_HERE';
```

### Local AI Fallback
- Works 100% offline
- No API key required
- Privacy-focused keyword detection
- Automatic fallback when Gemini unavailable
</details>

## 🎯 How to Use MindMantra

### 🌟 First Launch Experience
```
📱 Open App → 🔒 Privacy Consent → 🎭 Choose Mode → 🚀 Start Journey
```

1. **🔒 Privacy First**: Choose between cloud sync or local-only mode
2. **🎭 Anonymous Setup**: No personal info required - just start using!
3. **📝 First Journal**: Write your thoughts and see AI magic happen
4. **💬 Meet Your AI**: Chat with your supportive companion anytime

### 📅 Daily Workflow
| Morning | Afternoon | Evening |
|---------|-----------|---------|
| 🌅 Quick mood check | 💭 Chat if needed | 📝 Journal reflection |
| 🧘 Breathing exercise | 📊 View insights | 🌙 Wellness activity |

### 🔐 Privacy Modes

**🌐 Cloud Mode** (Recommended)
- ✅ AI-powered insights
- ✅ Cross-device sync
- ✅ Advanced analytics
- ✅ Still anonymous!

## 🧪 Testing & Quality

```bash
# Run all tests
flutter test

# Integration tests
flutter test integration_test/

# Performance testing
flutter drive --target=test_driver/app.dart
```

## 🚀 Deployment Ready

<details>
<summary>📱 Mobile App Store Deployment</summary>

### Android (Play Store)
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

### iOS (App Store)
```bash
flutter build ios --release
# Archive in Xcode → Upload to App Store Connect
```
</details>

<details>
<summary>🌐 Web Deployment</summary>

```bash
flutter build web
firebase deploy --only hosting
# Live at: your-project.web.app
```
</details>

## 🛠️ Troubleshooting

### Quick Fixes
```bash
# App won't build?
flutter clean && flutter pub get

# Firebase issues?
firebase login && firebase use --add

# Gemini API not working?
# Check your API key in lib/services/gemini_service.dart
```

## 🤝 Contributing

Love MindMantra? Here's how to help:

1. 🍴 Fork the repo
2. 🌿 Create feature branch
3. ✨ Add your magic
4. 🧪 Test everything
5. 📤 Submit PR

## 📞 Support & Resources

### 🆘 Crisis Support
- **India**: AASRA +91-98204 66726
- **US**: 988 Suicide & Crisis Lifeline
- **International**: Your local emergency services

### 💻 Technical Help
- 🐛 [Report Issues](https://github.com/your-repo/issues)
- 📚 [Documentation](https://your-docs-link)
- 💬 [Community Discord](https://your-discord-link)

## 🙏 Special Thanks

- 🤖 **Google Gemini** - For making AI accessible
- 🔥 **Firebase** - For the robust backend
- 🦋 **Flutter** - For the beautiful framework
- 🧠 **Mental Health Experts** - For guidance and validation
- 💝 **Open Source Community** - For inspiration and support

---

<div align="center">

**Made with ❤️ for mental wellness**

*Remember: You're not alone in this journey. MindMantra is here to support you every step of the way.*

</div>
