# MindMitra Setup Guide

This guide provides step-by-step instructions to set up and run the MindMitra app locally and deploy it to Firebase.

## Quick Start

### Prerequisites Checklist
- [ ] Flutter SDK 3.0+ installed
- [ ] Firebase CLI installed
- [ ] Node.js 18+ installed
- [ ] Google Cloud Project created
- [ ] Android Studio/VS Code with Flutter extensions

### 1. Project Setup (5 minutes)

```bash
# Clone and setup
git clone <your-repo-url>
cd MindMantra
flutter pub get

# Install Firebase CLI
npm install -g firebase-tools
firebase login
```

### 2. Firebase Configuration (10 minutes)

#### Create Firebase Project
1. Visit [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "MindMitra"
3. Enable services:
   - Authentication → Anonymous
   - Firestore Database
   - Cloud Functions

#### Add App Configuration
1. Add Android app (package: `com.example.mindmitra`)
2. Download `google-services.json` → `android/app/`
3. Add iOS app (bundle: `com.example.mindmitra`)
4. Download `GoogleService-Info.plist` → `ios/Runner/`

### 3. Cloud Functions Setup (5 minutes)

```bash
# Setup functions
cd functions
npm install

# Configure Gemini API (get key from Google AI Studio)
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"

# Deploy functions
firebase deploy --only functions
```

### 4. Database Setup (2 minutes)

```bash
# Deploy Firestore rules and indexes
firebase deploy --only firestore
```

### 5. Run the App (1 minute)

```bash
# Run on device/emulator
flutter run
```

## Detailed Setup Instructions

### Firebase Project Configuration

#### 1. Authentication Setup
```bash
# In Firebase Console:
# Authentication → Sign-in method → Anonymous → Enable
```

#### 2. Firestore Database
```bash
# In Firebase Console:
# Firestore Database → Create database → Start in test mode
```

#### 3. Cloud Functions
```bash
# Enable required APIs in Google Cloud Console:
# - Cloud Functions API
# - Vertex AI API
# - Cloud Build API
```

### Environment Configuration

#### Local Development
Create `.env` file in project root:
```env
FIREBASE_PROJECT_ID=your-project-id
GEMINI_API_KEY=your-gemini-api-key
```

#### Firebase Functions Config
```bash
firebase functions:config:set gemini.api_key="YOUR_API_KEY"
firebase functions:config:set project.id="YOUR_PROJECT_ID"
```

### Testing the Setup

#### 1. Test Firebase Connection
```bash
flutter run
# Check if app loads without Firebase errors
```

#### 2. Test Cloud Functions
```bash
# In Firebase Console → Functions
# Check if analyzeEntry and chatbotProxy are deployed
```

#### 3. Test AI Integration
1. Create a journal entry in the app
2. Check if emotion analysis works
3. Try the chat feature

## Troubleshooting

### Common Issues

#### Flutter Build Errors
```bash
flutter clean
flutter pub get
flutter run
```

#### Firebase Connection Issues
```bash
# Check Firebase project
firebase projects:list
firebase use your-project-id

# Verify configuration files exist
ls android/app/google-services.json
ls ios/Runner/GoogleService-Info.plist
```

#### Cloud Functions Deployment Errors
```bash
# Check Node.js version
node --version  # Should be 18+

# Check function logs
firebase functions:log

# Redeploy functions
cd functions
npm install
firebase deploy --only functions
```

#### Gemini API Issues
```bash
# Verify API key is set
firebase functions:config:get

# Check if Vertex AI API is enabled in Google Cloud Console
```

### Debug Mode

Enable detailed logging by modifying `lib/main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Enable debug logging
  if (kDebugMode) {
    print('MindMitra Debug Mode Enabled');
  }
  
  await Firebase.initializeApp();
  runApp(const MindMitraApp());
}
```

## Production Deployment

### Mobile App Store Deployment

#### Android (Google Play)
```bash
# Build release bundle
flutter build appbundle --release

# Upload to Google Play Console
# Follow Play Store review guidelines
```

#### iOS (App Store)
```bash
# Build for iOS
flutter build ios --release

# Open in Xcode and archive
# Upload to App Store Connect
```

### Web Deployment
```bash
# Build and deploy web version
flutter build web
firebase deploy --only hosting
```

## Security Checklist

### Before Production
- [ ] Update Firestore security rules
- [ ] Enable App Check for additional security
- [ ] Configure proper CORS settings
- [ ] Set up monitoring and alerts
- [ ] Review privacy policy compliance
- [ ] Test crisis detection functionality

### Firestore Security Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## Performance Optimization

### App Performance
- Enable code splitting for web builds
- Optimize image assets
- Use lazy loading for heavy components
- Implement proper state management

### Cloud Functions Performance
- Set appropriate memory allocation
- Use connection pooling for database
- Implement proper error handling
- Monitor execution times

## Monitoring Setup

### Firebase Analytics
```bash
# Add to pubspec.yaml
firebase_analytics: ^10.7.4

# Initialize in main.dart
FirebaseAnalytics analytics = FirebaseAnalytics.instance;
```

### Crashlytics
```bash
# Add to pubspec.yaml
firebase_crashlytics: ^3.4.8

# Initialize crash reporting
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

## Support Resources

### Documentation
- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Vertex AI Documentation](https://cloud.google.com/vertex-ai/docs)

### Community
- [Flutter Community](https://flutter.dev/community)
- [Firebase Community](https://firebase.google.com/community)
- [Mental Health Resources](https://www.who.int/health-topics/mental-health)

### Crisis Resources
- **AASRA (India)**: +91-98204 66726
- **International Association for Suicide Prevention**: https://www.iasp.info/resources/Crisis_Centres/

---

**Need Help?** Create an issue in the GitHub repository with detailed error logs and system information.
