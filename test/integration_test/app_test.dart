import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mindmitra/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MindMitra Integration Tests', () {
    testWidgets('Complete user flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test splash screen
      expect(find.text('MindMitra'), findsOneWidget);
      
      // Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Test consent screen (if shown)
      if (find.text('Privacy & Consent').evaluate().isNotEmpty) {
        // Accept local-only mode
        await tester.tap(find.text('Local-Only Mode').last);
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
      }

      // Test onboarding flow
      if (find.text('Welcome to MindMitra').evaluate().isNotEmpty) {
        // Navigate through onboarding
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
        }
        
        // Complete onboarding
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle();
      }

      // Test main app navigation
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Test journal entry
      await tester.tap(find.text('Journal'));
      await tester.pumpAndSettle();
      
      // Enter journal text
      await tester.enterText(
        find.byType(TextField).first,
        'This is a test journal entry. I am feeling good today.',
      );
      await tester.pumpAndSettle();

      // Submit journal entry
      await tester.tap(find.text('Save Entry'));
      await tester.pumpAndSettle();

      // Test dashboard
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(find.text('Mood Dashboard'), findsOneWidget);

      // Test chat
      await tester.tap(find.text('Chat'));
      await tester.pumpAndSettle();
      expect(find.text('AI Support Chat'), findsOneWidget);

      // Test wellness activities
      await tester.tap(find.text('Wellness'));
      await tester.pumpAndSettle();
      expect(find.text('Wellness Activities'), findsOneWidget);

      // Test profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Crisis detection flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to journal (assuming user is already onboarded)
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      // Skip to journal if needed
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        await tester.tap(find.text('Journal'));
        await tester.pumpAndSettle();

        // Enter crisis-related text
        await tester.enterText(
          find.byType(TextField).first,
          'I am having thoughts of suicide and want to hurt myself.',
        );
        await tester.pumpAndSettle();

        // Submit entry
        await tester.tap(find.text('Save Entry'));
        await tester.pumpAndSettle();

        // Verify crisis alert dialog appears
        expect(find.text('We\'re Here for You'), findsOneWidget);
        expect(find.text('AASRA: +91-98204 66726'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('I understand'));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Wellness activities flow test', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to wellness (assuming user is onboarded)
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      if (find.byType(BottomNavigationBar).evaluate().isNotEmpty) {
        await tester.tap(find.text('Wellness'));
        await tester.pumpAndSettle();

        // Test breathing exercise
        expect(find.text('Breathing Exercise'), findsOneWidget);
        
        // Mark breathing exercise as completed
        await tester.tap(find.text('Mark as Completed').first);
        await tester.pumpAndSettle();

        // Verify completion
        expect(find.text('Completed ✓'), findsOneWidget);

        // Test mindfulness activity
        if (find.text('5-Minute Body Scan').evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            find.text('5-Minute Body Scan'),
            500.0,
          );
          await tester.pumpAndSettle();
        }
      }
    });
  });
}
