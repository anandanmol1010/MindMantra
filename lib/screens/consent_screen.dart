import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _dataProcessingConsent = false;
  bool _aiAnalysisConsent = false;
  bool _localOnlyMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Icon(
                Icons.security,
                size: 64,
                color: Color(0xFF6B73FF),
              ),
              const SizedBox(height: 24),
              const Text(
                'Privacy & Consent',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your privacy and mental health data are important to us. Please review and consent to how we handle your information.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildConsentCard(
                        title: 'Data Processing',
                        description: 'We process your journal entries and chat messages to provide AI-powered insights and support.',
                        value: _dataProcessingConsent,
                        onChanged: (value) {
                          setState(() {
                            _dataProcessingConsent = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildConsentCard(
                        title: 'AI Analysis',
                        description: 'Allow AI analysis of your entries for emotion detection and personalized responses.',
                        value: _aiAnalysisConsent,
                        onChanged: (value) {
                          setState(() {
                            _aiAnalysisConsent = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildConsentCard(
                        title: 'Local-Only Mode',
                        description: 'Keep all data on your device only. This disables AI features but ensures maximum privacy.',
                        value: _localOnlyMode,
                        onChanged: (value) {
                          setState(() {
                            _localOnlyMode = value;
                            if (value) {
                              _dataProcessingConsent = false;
                              _aiAnalysisConsent = false;
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Important Information',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '• Your data is encrypted and secure\n'
                              '• You can change these settings anytime\n'
                              '• Crisis detection works in both modes\n'
                              '• Local mode stores data only on your device',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed() ? _handleConsent : null,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentCard({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    return _localOnlyMode || (_dataProcessingConsent && _aiAnalysisConsent);
  }

  Future<void> _handleConsent() async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    await appState.setConsentGiven(true);
    await appState.setLocalOnlyMode(_localOnlyMode);
    
    if (!mounted) return;

    // Sign in anonymously and navigate to onboarding
    final success = await appState.signInAnonymously();
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }
}
