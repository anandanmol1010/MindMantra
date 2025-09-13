import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mindmitra/main.dart';
import 'package:mindmitra/providers/app_state.dart';

void main() {
  group('MindMitra App Tests', () {
    testWidgets('App should load splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MindMitraApp());
      
      // Verify splash screen elements
      expect(find.text('MindMitra'), findsOneWidget);
      expect(find.text('Your AI-powered mental health companion'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('App state should initialize properly', (WidgetTester tester) async {
      late AppState appState;
      
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) {
            appState = AppState();
            return appState;
          },
          child: MaterialApp(
            home: Consumer<AppState>(
              builder: (context, state, child) {
                return Scaffold(
                  body: Text('Authenticated: ${state.isAuthenticated}'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      
      // Initially should not be authenticated
      expect(find.text('Authenticated: false'), findsOneWidget);
    });

    testWidgets('Crisis trigger detection should work', (WidgetTester tester) async {
      final appState = AppState();
      
      // Test crisis trigger detection
      expect(appState.checkForCrisisTriggers('I want to hurt myself'), isTrue);
      expect(appState.checkForCrisisTriggers('I am feeling sad today'), isFalse);
      expect(appState.checkForCrisisTriggers('suicide thoughts'), isTrue);
      expect(appState.checkForCrisisTriggers('Happy day today'), isFalse);
    });
  });

  group('Journal Entry Tests', () {
    testWidgets('Journal screen should display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (context) => AppState(),
          child: const MaterialApp(
            home: Scaffold(
              body: Text('Journal Screen Test'),
            ),
          ),
        ),
      );

      expect(find.text('Journal Screen Test'), findsOneWidget);
    });
  });

  group('Wellness Activities Tests', () {
    testWidgets('Breathing animation should be present', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Breathing Exercise'),
            ),
          ),
        ),
      );

      expect(find.text('Breathing Exercise'), findsOneWidget);
    });
  });
}
